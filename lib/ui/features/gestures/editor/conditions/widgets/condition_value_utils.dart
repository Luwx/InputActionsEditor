import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

(double, double)? parsePoint(String value) {
  // Config format uses ',' as x,y separator; accept ';' as legacy fallback.
  var sep = value.indexOf(',');
  if (sep == -1) sep = value.indexOf(';');
  if (sep == -1) return null;
  final x = double.tryParse(value.substring(0, sep).trim());
  final y = double.tryParse(value.substring(sep + 1).trim());
  if (x == null || y == null) return null;
  return (x.clamp(0.0, 1.0), y.clamp(0.0, 1.0));
}

String serializePoint(double x, double y) =>
    '${x.toStringAsFixed(2)},${y.toStringAsFixed(2)}';

String formatPointLabel(String value) {
  final p = parsePoint(value);
  if (p == null) return value.isEmpty ? '--' : value;
  return '(${p.$1.toStringAsFixed(2)}, ${p.$2.toStringAsFixed(2)})';
}

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
    if (info?.type == VarType.point) {
      return '${formatPointLabel(from)} — ${formatPointLabel(to)}';
    }
    if (to.isNotEmpty) {
      return '$from - $to';
    }
  }

  if (condition.operator == 'one_of') {
    final items = parseListValue(value);
    return items.isEmpty ? '--' : items.join(', ');
  }

  if (info?.type == VarType.point) return formatPointLabel(value);

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
  // Legacy UI serialized with '|'; config format uses ';'.
  var separator = value.indexOf('|');
  if (separator == -1) separator = value.indexOf(';');
  if (separator == -1) return (value, '');
  return (value.substring(0, separator), value.substring(separator + 1));
}
