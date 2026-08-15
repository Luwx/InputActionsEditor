import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/enums.dart';

/// The daemon copies a group's keys onto descendants at parse time, so what a
/// gesture ends up running with is not what its own node says. These cover the
/// editor's reconstruction of that.
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

    test('a property set only on the group is inherited, not a conflict', () {
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
      expect(inherited.single.overridden, isFalse);
    });

    test('setLocally separates a gesture override from an ancestor clash', () {
      final gestureSets = singleGesture('''
mouse:
  gestures:
    - block_events: false
      gestures:
        - type: press
          block_events: true
''').single;
      expect(gestureSets.setLocally, isTrue);
      expect(gestureSets.overridden, isTrue);

      // Two groups clash over a gesture that sets nothing: still undefined,
      // but the gesture's own controls should show the inherited value.
      final groupsClash = singleGesture('''
mouse:
  gestures:
    - block_events: false
      gestures:
        - block_events: true
          gestures:
            - type: press
''').single;
      expect(groupsClash.setLocally, isFalse);
      expect(groupsClash.overridden, isTrue);
    });

    test('a property set on both group and gesture is flagged', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - id: shared
      gestures:
        - type: press
          id: mine
''');
      expect(inherited.single.property, SharedTriggerProperty.id);
      expect(inherited.single.overridden, isTrue);
    });

    test('two ancestors setting the same property is also flagged', () {
      final inherited = singleGesture('''
mouse:
  gestures:
    - id: outer
      gestures:
        - id: inner
          gestures:
            - type: press
''');
      expect(inherited.single.overridden, isTrue);
      // Nearest ancestor supplies the shown value; the daemon itself does not
      // resolve this in a defined way.
      expect(inherited.single.value, 'inner');
      expect(inherited.single.groupName, '');
    });

    test('properties accumulate across ancestors without colliding', () {
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
      expect(inherited.every((i) => !i.overridden), isTrue);
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
      gestures:
        - type: press
''');
      expect(
        inherited.map((i) => i.property).toSet(),
        SharedTriggerProperty.values.toSet(),
      );
    });
  });
}
