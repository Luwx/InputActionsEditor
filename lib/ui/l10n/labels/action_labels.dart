import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';

typedef ModeOption = ({InputEntryMode mode, String label});

List<ModeOption> inputModeOptions(
  InputDevice device,
  AppLocalizations l10n,
) => switch (device) {
  InputDevice.keyboard => [
    (mode: InputEntryMode.keyboardTimeline, label: l10n.inputModeKeySequence),
    (mode: InputEntryMode.keyboardText, label: l10n.inputModeTextInput),
  ],
  InputDevice.mouse => [
    (mode: InputEntryMode.mouseTimeline, label: l10n.inputModeButtonSequence),
    (mode: InputEntryMode.mouseMoveBy, label: l10n.inputModeMoveBy),
    (mode: InputEntryMode.mouseMoveByDelta, label: l10n.inputModeMoveByDelta),
    (mode: InputEntryMode.mouseMoveTo, label: l10n.inputModeMoveTo),
    (mode: InputEntryMode.mouseWheel, label: l10n.inputModeScrollWheel),
  ],
};

String tokenLabel(String token, InputDevice device, AppLocalizations l10n) {
  if (device == InputDevice.keyboard) {
    final (:type, :val) = parseKeyToken(token);
    return switch (type) {
      KeyTokenType.press => '↓ $val',
      KeyTokenType.release => '↑ $val',
      KeyTokenType.text => l10n.tokenLabelText(val),
      KeyTokenType.combo => val,
    };
  }
  final (:type, :v1, :v2) = parseMouseToken(token);
  return switch (type) {
    MouseTokenType.press => '↓ $v1',
    MouseTokenType.release => '↑ $v1',
    MouseTokenType.moveBy => l10n.tokenLabelMoveBy(v1, v2),
    MouseTokenType.moveByDelta =>
      v1.isEmpty
          ? l10n.tokenLabelMoveByDelta
          : l10n.tokenLabelMoveByDeltaParam(v1),
    MouseTokenType.moveTo => l10n.tokenLabelMoveTo(v1, v2),
    MouseTokenType.wheel => l10n.tokenLabelWheel(v1, v2),
    MouseTokenType.combo => v1,
  };
}
