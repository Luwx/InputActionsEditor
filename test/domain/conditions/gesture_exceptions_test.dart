import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/conditions/gesture_exceptions.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';

const _source = r'''
mouse:
  gestures:
    - name: Strokes
      conditions:
        - $keyboard_modifiers == []
        - none:
            - $window_under_pointer_class == Maltego
            - $window_under_pointer_class == parsecd
      gestures:
        - type: press
          mouse: [ middle ]
          actions:
            - command: "true"
''';

Condition? _conditionsOf(String text) {
  final nodes = gestureNodesForDevice(decodeConfig(text), DeviceType.mouse);
  return (nodes.first as GestureGroupNode).conditions;
}

void main() {
  test('reads exceptions and ignores other conditions', () {
    expect(exceptionApps(_conditionsOf(_source)), ['Maltego', 'parsecd']);
  });

  test('adds to the existing block and keeps other conditions', () {
    final before = _conditionsOf(_source);
    final after = withExceptionApp(before, 'Foo');
    expect(exceptionApps(after), ['Maltego', 'parsecd', 'Foo']);
    expect(
      (after as ConditionGroup).children.first,
      (before! as ConditionGroup).children.first,
    );
  });

  test('adding an app twice changes nothing', () {
    final before = _conditionsOf(_source);
    expect(withExceptionApp(before, 'parsecd'), before);
  });

  test('removes an app and keeps the others', () {
    expect(
      exceptionApps(withoutExceptionApp(_conditionsOf(_source), 'Maltego')),
      ['parsecd'],
    );
  });

  test('removing the last app drops the block only', () {
    var conditions = withoutExceptionApp(_conditionsOf(_source), 'Maltego');
    conditions = withoutExceptionApp(conditions, 'parsecd');
    final root = conditions! as ConditionGroup;
    expect(root.children, hasLength(1));
    expect(root.children.single, isA<VariableCondition>());
    expect(exceptionApps(conditions), isEmpty);
  });

  test('works without any conditions', () {
    final added = withExceptionApp(null, 'Foo');
    expect(exceptionApps(added), ['Foo']);
    expect(withoutExceptionApp(added, 'Foo'), isNull);
  });

  test('wraps a single condition that is not an ALL group', () {
    final single = (_conditionsOf(_source)! as ConditionGroup).children.first;
    final added = withExceptionApp(single, 'Foo');
    expect(exceptionApps(added), ['Foo']);
    expect((added as ConditionGroup).children.first, single);
  });

  test('leaves a NONE block about something else alone', () {
    const other = ConditionGroup(
      mode: ConditionGroupMode.none,
      children: [
        Condition.variable(
          variable: ConditionVariableRef.custom('something'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('x'),
        ),
      ],
    );
    final added = withExceptionApp(
      const ConditionGroup(children: [other]),
      'Foo',
    );
    final root = added as ConditionGroup;
    expect(root.children, hasLength(2));
    expect(root.children.first, other);
    expect(exceptionApps(added), ['Foo']);
  });

  test('finds the group, counts gestures outside it', () {
    final config = assignEditIds(
      decodeConfig('''
$_source
    - type: press
      mouse: [ right ]
      actions:
        - command: "true"
'''),
    );
    final target = gestureExceptionsTarget(config)!;
    expect(target.group.name, 'Strokes');
    expect(target.apps, ['Maltego', 'parsecd']);
    expect(target.outsideCount, 1);
  });

  test('no target when no mouse gesture is in a group', () {
    final config = assignEditIds(
      decodeConfig('''
mouse:
  gestures:
    - type: press
      mouse: [ right ]
      actions:
        - command: "true"
'''),
    );
    expect(gestureExceptionsTarget(config), isNull);
  });
}
