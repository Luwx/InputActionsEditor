import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  Map<int, List<InheritedProperty>> inheritedFor(String yaml) {
    final config = assignEditIds(decodeConfig(yaml));
    return inheritedPropertiesForDevice(config, DeviceType.mouse);
  }

  List<InheritedProperty> singleGesture(String yaml) {
    final all = inheritedFor(yaml);
    expect(all, hasLength(1));
    return all.values.single;
  }

  group('group inheritance', () {
    test('a gesture outside any group inherits nothing', () {
      expect(
        inheritedFor('''
mouse:
  gestures:
    - type: press
      id: solo
'''),
        isEmpty,
      );
    });

    test('a property set only on the group is inherited', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - id: shared
      gestures:
        - type: press
''');
      expect(inherited, hasLength(1));
      expect(inherited.single.property, SharedTriggerProperty.id);
      expect(inherited.single.value, 'shared');
    });

    test('a gesture value the group also sets gives way on load', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - id: shared
      mouse_buttons: [ back ]
      gestures:
        - type: press
          id: mine
          mouse_buttons: [ forward ]
''');
      final own = config.mouseGestures.single.common;
      expect(own.id, isNull);
      expect(own.mouseButtons, isEmpty);

      final effective = withInheritedValues(config).mouseGestures.single.common;
      expect(effective.id, 'shared');
      expect(effective.mouseButtons, [MouseButtonValue.back]);
    });

    test('the nearest of several groups supplies the value', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - id: outer
      gestures:
        - id: inner
          gestures:
            - type: press
''');
      expect(inherited.single.value, 'inner');
    });

    test('properties accumulate across ancestors', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - id: outer
      gestures:
        - resume_timeout: 250
          gestures:
            - type: press
''');
      expect(inherited, hasLength(2));
      expect(
        inherited.map((i) => i.property).toSet(),
        {SharedTriggerProperty.id, SharedTriggerProperty.resumeTimeout},
      );
    });

    test('conditions are not reported, the daemon AND-merges them', () {
      final inherited = inheritedFor(r'''
mouse:
  gestures:
    - conditions: $a
      gestures:
        - type: press
          conditions: $b
''');
      expect(inherited, isEmpty);
    });

    test('the reporting group is identified for navigation', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - name: Browser
      threshold: 10
      gestures:
        - type: press
''');
      expect(inherited.single.groupName, 'Browser');
      expect(inherited.single.groupEditId, isNotNull);
    });

    test('sibling subtrees do not leak properties to each other', () {
      final all = inheritedFor('''
mouse:
  gestures:
    - id: first
      gestures:
        - type: press
    - gestures:
        - type: press
''');
      expect(all, hasLength(1));
      expect(all.values.single.single.value, 'first');
    });

    test('conditions are reported separately, outermost group first', () {
      final config = assignEditIds(
        decodeConfig(r'''
mouse:
  gestures:
    - name: Outer
      conditions: $a
      gestures:
        - name: Inner
          conditions: $b
          gestures:
            - type: press
              conditions: $c
'''),
      );
      final all = inheritedConditionsForDevice(config, DeviceType.mouse);

      // The gesture, plus the inner group which inherits from the outer one.
      expect(all, hasLength(2));

      final gesture = all.values.firstWhere((list) => list.length == 2);
      expect(gesture.map((i) => i.groupName), ['Outer', 'Inner']);
      expect(gesture.every((i) => i.groupEditId != null), isTrue);

      final innerGroup = all.values.firstWhere((list) => list.length == 1);
      expect(innerGroup.single.groupName, 'Outer');
    });

    test('a group without conditions contributes no branch', () {
      final all = inheritedConditionsForDevice(
        assignEditIds(
          decodeConfig(r'''
mouse:
  gestures:
    - name: Outer
      threshold: 10
      gestures:
        - type: press
          conditions: $c
'''),
        ),
        DeviceType.mouse,
      );

      expect(all, isEmpty);
    });

    test('sibling subtrees do not leak conditions to each other', () {
      final all = inheritedConditionsForDevice(
        assignEditIds(
          decodeConfig(r'''
mouse:
  gestures:
    - name: Browser
      conditions: $a
      gestures:
        - type: press
    - gestures:
        - type: press
'''),
        ),
        DeviceType.mouse,
      );

      expect(all, hasLength(1));
      expect(all.values.single.single.groupName, 'Browser');
    });

    test('every shared property the daemon copies is covered', () {
      final inherited = singleGesture(r'''
mouse:
  gestures:
    - id: a
      threshold: 5
      resume_timeout: 250
      accelerated: true
      block_events: false
      clear_modifiers: true
      set_last_trigger: false
      end_conditions: $a
      mouse_buttons: [ back ]
      mouse_buttons_exact_order: true
      fingers: 3
      speed: fast
      instant: true
      lock_pointer: true
      gestures:
        - type: press
''');
      expect(
        inherited.map((i) => i.property).toSet(),
        SharedTriggerProperty.values.toSet(),
      );
    });
  });

  group('withGroupValues', () {
    test('a gesture placed under a group drops what the group sets', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - mouse_buttons: [ back ]
      threshold: 5
      gestures:
        - type: press
          name: In
''');
      final group = config.mouseNodes.single as GestureGroupNode;
      final placed = config.withNodesForDevice(DeviceType.mouse, [
        group.copyWith(
          children: [
            ...group.children,
            const GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  name: 'Moved',
                  mouseButtons: [MouseButtonValue.forward],
                  threshold: '9',
                ),
              ),
            ),
          ],
        ),
      ]);

      final adopted = withGroupValues(placed).mouseGestures.last.common;
      expect(adopted.name, 'Moved');
      expect(adopted.mouseButtons, isEmpty);
      expect(adopted.threshold, isNull);
    });

    test('a config already following its groups is returned as is', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: stroke
      mouse_buttons: [ back ]
      gestures:
        - strokes: [ 'MGQA0DMnPMwwAGQA' ]
''');
      expect(identical(withGroupValues(config), config), isTrue);
    });
  });

  group('withInheritedValues', () {
    test('fills in what a gesture leaves to its groups, nearest first', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - mouse_buttons: [ back ]
      speed: slow
      gestures:
        - speed: fast
          gestures:
            - type: stroke
              lock_pointer: true
''');
      final gesture =
          withInheritedValues(config).mouseGestures.single as StrokeGesture;
      expect(gesture.common.mouseButtons, [MouseButtonValue.back]);
      expect(gesture.motion.speed, TriggerSpeed.fast);
      expect(gesture.motion.lockPointer, isTrue);
    });
  });
}
