import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
import 'package:input_actions_editor/model/action.dart';

enum InputEntryMode {
  keyboardTimeline,
  keyboardText,
  mouseTimeline,
  mouseMoveBy,
  mouseMoveByDelta,
  mouseMoveTo,
  mouseWheel,
}

/// The item as it reads in the config file. Unlike [formatInputToken] this
/// is total: a text item renders as its YAML shape rather than throwing.
String inputTokenText(InputToken token) => switch (token) {
  TextInputToken(value: LiteralText(:final text)) => 'text: $text',
  TextInputToken(value: CommandText(:final command)) =>
    'text: {command: $command}',
  _ => formatInputToken(token),
};

InputEntryMode inferInputEntryMode(InputEntry entry) {
  if (entry.device == InputDevice.keyboard) {
    return entry.tokens.isNotEmpty &&
            entry.tokens.every((token) => token is TextInputToken)
        ? InputEntryMode.keyboardText
        : InputEntryMode.keyboardTimeline;
  }

  if (entry.tokens.length == 1) {
    return switch (entry.tokens.first) {
      MoveByInputToken() => InputEntryMode.mouseMoveBy,
      MoveByDeltaInputToken() => InputEntryMode.mouseMoveByDelta,
      MoveToInputToken() => InputEntryMode.mouseMoveTo,
      WheelInputToken() => InputEntryMode.mouseWheel,
      _ => InputEntryMode.mouseTimeline,
    };
  }
  return InputEntryMode.mouseTimeline;
}
