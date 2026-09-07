import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/model/condition.dart';

ConditionValue _parse(String raw, ConditionValueType type) =>
    parseConditionValue(raw, type: type, operator: ConditionOperator.equals);

const _yaml = r'''
touchpad:
  gestures:
    - type: swipe
      direction: left
      conditions:
        - $fingers == $max_finger_distance_percentage
        - $thumb_present == $plasma_overview_active
        - $finger_1_pressure >= 30
      actions: []
''';

void main() {
  test('a value that is not a number is kept raw', () {
    expect(
      _parse(r'$other_var', ConditionValueType.number),
      isA<RawConditionValue>(),
    );
    expect(
      _parse('12', ConditionValueType.number),
      const ConditionValue.number(12),
    );
    expect(
      _parse(r'$other_var', ConditionValueType.time),
      isA<RawConditionValue>(),
    );
  });

  test('a value that is not a bool is kept raw', () {
    expect(
      _parse(r'$other_var', ConditionValueType.bool_),
      isA<RawConditionValue>(),
    );
    expect(
      _parse('TRUE', ConditionValueType.bool_),
      const ConditionValue.boolean(true),
    );
    expect(
      _parse(' false ', ConditionValueType.bool_),
      const ConditionValue.boolean(false),
    );
    expect(
      _parse('yes', ConditionValueType.bool_),
      const ConditionValue.boolean(true),
    );
    expect(
      _parse('off', ConditionValueType.bool_),
      const ConditionValue.boolean(false),
    );
  });

  test('variable references survive a config round trip', () {
    final config = decodeConfig(_yaml);
    final out = encodeConfig(config, _yaml);

    expect(out, contains(r'$fingers == $max_finger_distance_percentage'));
    expect(out, contains(r'$thumb_present == $plasma_overview_active'));
    expect(out, contains(r'$finger_1_pressure >= 30'));
  });

  test('a new condition defaults to a value inside the range', () {
    expect(
      ConditionVariableId.fingers.defaultValue,
      const ConditionValue.number(1),
    );
    expect(
      ConditionVariableId.finger1Pressure.defaultValue,
      const ConditionValue.number(0),
    );
    expect(
      ConditionVariableId.windowTitle.defaultValue,
      const ConditionValue.text(''),
    );
  });
}
