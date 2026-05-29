import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

String formatConditionValueLabel(
  VariableCondition condition,
  VariableInfo? info,
) {
  final value = condition.value;
  if (value.isEmpty || value == '[]') {
    return '--';
  }

  if (condition.operator == 'between') {
    final (from, to) = splitBetweenValue(value);
    if (to.isNotEmpty) {
      return '$from - $to';
    }
  }

  if (condition.operator == 'one_of') {
    final items = parseListValue(value);
    return items.isEmpty ? '--' : items.join(', ');
  }

  return value;
}

Set<String> parseFlagsValue(String value) {
  final trimmed = value.trim();
  if (trimmed == '[]' || trimmed.isEmpty) {
    return {};
  }
  if (trimmed.startsWith('[')) {
    return trimmed
        .substring(1, trimmed.length - 1)
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet();
  }
  return {trimmed};
}

String serializeFlagsValue(Set<String> flags) {
  if (flags.isEmpty) {
    return '[]';
  }
  if (flags.length == 1) {
    return flags.first;
  }
  return '[ ${flags.join(', ')} ]';
}

List<String> parseListValue(String value) {
  final trimmed = value.trim();
  if (trimmed == '[]' || trimmed.isEmpty) {
    return [];
  }
  if (trimmed.startsWith('[')) {
    return trimmed
        .substring(1, trimmed.length - 1)
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toList();
  }
  return [trimmed];
}

String serializeListValue(List<String> items) {
  if (items.isEmpty) {
    return '[]';
  }
  if (items.length == 1) {
    return items.first;
  }
  return '[ ${items.join(', ')} ]';
}

(String, String) splitBetweenValue(String value) {
  final separator = value.indexOf('|');
  if (separator == -1) {
    return (value, '');
  }
  return (value.substring(0, separator), value.substring(separator + 1));
}
