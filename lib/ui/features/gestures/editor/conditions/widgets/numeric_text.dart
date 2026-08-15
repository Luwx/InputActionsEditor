import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/domain/conditions/condition_variable_registry.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';

String formatNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

final _partialNumber = RegExp(r'^-?\d*\.?\d*$');

/// Rejects text that is not on its way to being a number. Out-of-range values
/// are accepted and reported by [numberRangeError] instead.
final numberInputFormatters = <TextInputFormatter>[
  TextInputFormatter.withFunction(
    (old, next) => _partialNumber.hasMatch(next.text) ? next : old,
  ),
];

String? numberRangeError(
  ConditionNumberRange? range,
  String text,
  AppLocalizations l10n,
) {
  final value = double.tryParse(text.trim());
  if (range == null || value == null) return null;

  final min = range.min;
  final max = range.max;
  if (range.integer && value != value.roundToDouble()) {
    return l10n.numberRangeWhole;
  }
  if ((min != null && value < min) || (max != null && value > max)) {
    if (min != null && max != null) {
      return l10n.numberRangeBetween(formatNumber(min), formatNumber(max));
    }
    return min != null
        ? l10n.numberRangeMin(formatNumber(min))
        : l10n.numberRangeMax(formatNumber(max!));
  }
  return null;
}

/// Keeps the typed text while the values still match what it last emitted.
/// Without it `''`, `'-'` and `'3.'` are reformatted away mid-edit.
class NumericTexts {
  const NumericTexts(this.texts, this.update);

  final List<String> texts;
  final void Function(List<String> texts) update;
}

NumericTexts useNumericTexts(
  List<double?> values,
  void Function(List<double> values) onChanged,
) {
  final draft = useState<List<String>?>(null);
  final emitted = useRef<List<double>?>(null);

  final last = emitted.value;
  final texts = draft.value != null && last != null && _same(last, values)
      ? draft.value!
      : [for (final value in values) value == null ? '' : formatNumber(value)];

  return NumericTexts(texts, (texts) {
    final parsed = [
      for (final text in texts) double.tryParse(text.trim()) ?? 0,
    ];
    emitted.value = parsed;
    draft.value = texts;
    onChanged(parsed);
  });
}

bool _same(List<double> emitted, List<double?> values) {
  if (emitted.length != values.length) return false;
  for (var i = 0; i < emitted.length; i++) {
    if (emitted[i] != values[i]) return false;
  }
  return true;
}
