import 'package:input_actions_editor/model/action.dart';

/// Reads one item of an `input:` device sequence. [device] decides which
/// items are recognised: pointer motion only means something under `mouse`.
/// Anything unrecognised becomes [RawInputToken] and is written back
/// unchanged.
InputToken parseInputToken(String raw, InputDevice device) {
  if (raw.startsWith('+') && !raw.contains(' ')) {
    return InputToken.press(raw.substring(1));
  }
  if (raw.startsWith('-') && !raw.contains(' ')) {
    return InputToken.release(raw.substring(1));
  }

  if (device == InputDevice.mouse) {
    final motion = _parseMotion(raw);
    if (motion != null) return motion;
  }

  if (raw.isEmpty || raw.contains(' ') || raw.contains('++')) {
    return InputToken.raw(raw);
  }
  final keys = raw.split('+');
  if (keys.any((key) => key.isEmpty)) return InputToken.raw(raw);
  return InputToken.combo(keys);
}

InputToken? _parseMotion(String raw) {
  final space = raw.indexOf(' ');
  final head = space == -1 ? raw : raw.substring(0, space);
  final rest = space == -1 ? '' : raw.substring(space + 1);

  switch (head) {
    case 'move_by_delta':
      if (rest.isEmpty) return const InputToken.moveByDelta(null);
      final multiplier = double.tryParse(rest.trim());
      return multiplier == null ? null : InputToken.moveByDelta(multiplier);
    case 'move_by':
    case 'move_to':
    case 'wheel':
      final point = _parsePoint(rest);
      if (point == null) return null;
      final (x, y) = point;
      return switch (head) {
        'move_by' => InputToken.moveBy(x, y),
        'move_to' => InputToken.moveTo(x, y),
        _ => InputToken.wheel(x, y),
      };
    default:
      return null;
  }
}

(double, double)? _parsePoint(String raw) {
  final parts = raw.trim().split(' ');
  if (parts.length != 2) return null;
  final x = double.tryParse(parts[0]);
  final y = double.tryParse(parts[1]);
  return x == null || y == null ? null : (x, y);
}

/// The inverse of [parseInputToken]. A [TextInputToken] has no string form
/// because the daemon writes it as a map, so it is not accepted here.
String formatInputToken(InputToken token) => switch (token) {
  PressInputToken(:final key) => '+$key',
  ReleaseInputToken(:final key) => '-$key',
  ComboInputToken(:final keys) => keys.join('+'),
  MoveByInputToken(:final x, :final y) =>
    'move_by ${formatInputNumber(x)} ${formatInputNumber(y)}',
  MoveByDeltaInputToken(:final multiplier) =>
    multiplier == null
        ? 'move_by_delta'
        : 'move_by_delta ${formatInputNumber(multiplier)}',
  MoveToInputToken(:final x, :final y) =>
    'move_to ${formatInputNumber(x)} ${formatInputNumber(y)}',
  WheelInputToken(:final x, :final y) =>
    'wheel ${formatInputNumber(x)} ${formatInputNumber(y)}',
  RawInputToken(:final token) => token,
  TextInputToken() => throw ArgumentError.value(
    token,
    'token',
    'A text item is written as a map, not a string.',
  ),
};

/// Writes a whole number without a trailing `.0`, so `move_by 10 10` does not
/// come back as `move_by 10.0 10.0`.
String formatInputNumber(double value) {
  final text = value.toString();
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
