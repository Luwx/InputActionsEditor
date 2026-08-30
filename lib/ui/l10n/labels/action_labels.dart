import 'package:input_actions_editor/domain/actions/input_token_codec.dart';
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

String tokenLabel(InputToken token, AppLocalizations l10n) => switch (token) {
  PressInputToken(:final key) => '↓ $key',
  ReleaseInputToken(:final key) => '↑ $key',
  ComboInputToken(:final keys) => keys.join('+'),
  TextInputToken(value: LiteralText(:final text)) => l10n.tokenLabelText(text),
  TextInputToken(value: CommandText(:final command)) =>
    l10n.tokenLabelTextCommand(command),
  MoveByInputToken(:final x, :final y) => l10n.tokenLabelMoveBy(
    formatInputNumber(x),
    formatInputNumber(y),
  ),
  MoveByDeltaInputToken(:final multiplier) =>
    multiplier == null
        ? l10n.tokenLabelMoveByDelta
        : l10n.tokenLabelMoveByDeltaParam(formatInputNumber(multiplier)),
  MoveToInputToken(:final x, :final y) => l10n.tokenLabelMoveTo(
    formatInputNumber(x),
    formatInputNumber(y),
  ),
  WheelInputToken(:final x, :final y) => l10n.tokenLabelWheel(
    formatInputNumber(x),
    formatInputNumber(y),
  ),
  RawInputToken(:final token) => token,
};
