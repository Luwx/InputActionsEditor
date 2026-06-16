import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/model/condition.dart';

ConditionVariableRef parseConditionVariableRef(String name) =>
    knownConditionVariable(name) == null
    ? ConditionVariableRef.custom(name)
    : ConditionVariableRef.known(name);

ConditionOperator? parseConditionOperator(String token) {
  for (final entry in _operatorTokens.entries) {
    if (entry.value == token) return entry.key;
  }
  return null;
}

String conditionVariableName(ConditionVariableRef variable) => variable.name;

String conditionOperatorToken(ConditionOperator operator) =>
    _operatorTokens[operator]!;

ConditionValue parseConditionValue(
  String raw, {
  required ConditionValueType type,
  required ConditionOperator operator,
}) {
  if (operator == ConditionOperator.between) {
    final (from, to) = _splitBetweenValue(raw);
    return ConditionValue.range(
      from: parseConditionValue(
        from,
        type: type,
        operator: ConditionOperator.equals,
      ),
      to: parseConditionValue(
        to,
        type: type,
        operator: ConditionOperator.equals,
      ),
    );
  }

  if (operator == ConditionOperator.oneOf) {
    return ConditionValue.list(_parseListValue(raw));
  }

  return switch (type) {
    ConditionValueType.bool_ => ConditionValue.boolean(
      raw.trim().toLowerCase() == 'true',
    ),
    ConditionValueType.flags => ConditionValue.flags(_parseListValue(raw)),
    ConditionValueType.point => _parsePointValue(raw),
    ConditionValueType.number || ConditionValueType.time =>
      ConditionValue.number(double.tryParse(raw.trim()) ?? 0),
    ConditionValueType.enum_ ||
    ConditionValueType.string => ConditionValue.text(raw),
  };
}

String conditionValueToText(ConditionValue value) => switch (value) {
  TextConditionValue(:final value) => value,
  NumberConditionValue(:final value) => _formatNumber(value),
  BoolConditionValue(:final value) => value ? 'true' : 'false',
  FlagsConditionValue(:final values) => _serializeListValue(values),
  PointConditionValue(:final x, :final y) =>
    '${_formatCoord(x)},${_formatCoord(y)}',
  ListConditionValue(:final values) => _serializeListValue(values),
  RangeConditionValue(:final from, :final to) =>
    '${conditionValueToText(from)};${conditionValueToText(to)}',
  RawConditionValue(:final value) => value,
};

const Map<ConditionOperator, String> _operatorTokens = {
  ConditionOperator.equals: '==',
  ConditionOperator.notEquals: '!=',
  ConditionOperator.greaterThan: '>',
  ConditionOperator.greaterOrEqual: '>=',
  ConditionOperator.lessThan: '<',
  ConditionOperator.lessOrEqual: '<=',
  ConditionOperator.between: 'between',
  ConditionOperator.contains: 'contains',
  ConditionOperator.matches: 'matches',
  ConditionOperator.oneOf: 'one_of',
};

ConditionValue _parsePointValue(String raw) {
  var separator = raw.indexOf(',');
  if (separator == -1) separator = raw.indexOf(';');
  if (separator == -1) return ConditionValue.raw(raw);

  final x = double.tryParse(raw.substring(0, separator).trim());
  final y = double.tryParse(raw.substring(separator + 1).trim());
  if (x == null || y == null) return ConditionValue.raw(raw);
  return ConditionValue.point(x, y);
}

(String, String) _splitBetweenValue(String value) {
  var separator = value.indexOf('|');
  if (separator == -1) separator = value.indexOf(';');
  if (separator == -1) return (value, '');
  return (value.substring(0, separator), value.substring(separator + 1));
}

List<String> _parseListValue(String value) {
  final trimmed = value.trim();
  if (trimmed == '[]' || trimmed.isEmpty) return [];
  if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
    return trimmed
        .substring(1, trimmed.length - 1)
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
  return [trimmed];
}

String _serializeListValue(List<String> values) {
  if (values.isEmpty) return '[]';
  if (values.length == 1) return values.first;
  return '[ ${values.join(', ')} ]';
}

String _formatNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

/// Serializes a point coordinate clamped to [0, 1] with up to 4 fraction
/// digits, dropping trailing zeros so e.g. `0.2` stays `0.2` and `0.333` keeps
/// its precision rather than being truncated to `0.33`.
String _formatCoord(double value) {
  var text = value.clamp(0.0, 1.0).toStringAsFixed(4);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}
