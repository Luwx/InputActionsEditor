import 'package:flutter/services.dart' show TextInputFormatter;
import 'package:flutter_hooks/flutter_hooks.dart';

String formatNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

final _partialNumber = RegExp(r'^-?\d*\.?\d*$');

/// Rejects edits that can never become a number, while still allowing the
/// incomplete states typed on the way to one.
final numberInputFormatters = <TextInputFormatter>[
  TextInputFormatter.withFunction(
    (old, next) => _partialNumber.hasMatch(next.text) ? next : old,
  ),
];

/// Text of numeric fields whose value round-trips through [double].
///
/// `''`, `'-'` and `'3.'` do not survive that round trip, so the typed text is
/// kept verbatim for as long as the incoming values match what was last
/// emitted from here.
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
