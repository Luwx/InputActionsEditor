import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:meta_generator/meta_generator.dart';

part 'action.freezed.dart';
part 'action.g.dart';

@freezed
@withMeta
abstract class TriggerAction with _$TriggerAction {
  const factory TriggerAction({
    required Action action,
    bool? enabled,

    /// Null means the `on:` key was absent in YAML (daemon defaults to
    /// `end`).
    TriggerOn? on,
    Condition? conditions,
    String? interval,
    String? threshold,
    @Default(true) bool conflicting,
    String? id,
    int? limit,

    /// In-memory identity, filled in by `assignEditIds`; never serialized.
    int? editId,
  }) = _TriggerAction;
}

@freezed
@withMeta
sealed class Action with _$Action {
  const factory Action.command({required String command, bool? wait}) =
      CommandAction;

  const factory Action.input({
    @Default([]) List<InputEntry> entries,
    int? delay,
  }) = InputAction;

  const factory Action.plasmaShortcut({
    required String component,
    required String shortcut,
  }) = PlasmaShortcutAction;

  const factory Action.activateWindow({required String windowId}) =
      ActivateWindowAction;

  const factory Action.replaceText({
    @Default([]) List<TextSubstitutionRule> rules,
  }) = ReplaceTextAction;

  const factory Action.sleep({required int milliseconds}) = SleepAction;

  /// A JavaScript function executed by the daemon for its side effects (the
  /// return value is ignored). [expression] is the raw `() => ...` source.
  const factory Action.function({required String expression}) = FunctionAction;

  /// The daemon's `one:`: the first action whose conditions match runs.
  /// Nesting is unbounded. The daemon parses children as plain actions, so
  /// only `conditions`, `limit` and `id` apply to them.
  const factory Action.group({@Default([]) List<TriggerAction> actions}) =
      ActionGroup;

  /// Raw YAML for action types we don't model.
  const factory Action.raw({required String raw}) = RawAction;
}

@freezed
@withMeta
abstract class TextSubstitutionRule with _$TextSubstitutionRule {
  const factory TextSubstitutionRule({
    required String regex,
    required DynamicText replace,
  }) = _TextSubstitutionRule;
}

@freezed
@withMeta
sealed class DynamicText with _$DynamicText {
  const factory DynamicText.literal(String text) = LiteralText;

  const factory DynamicText.command(String command) = CommandText;
}

enum InputDevice { keyboard, mouse }

@freezed
@withMeta
abstract class InputEntry with _$InputEntry {
  const factory InputEntry({
    required InputDevice device,
    @Default([]) List<InputToken> tokens,
  }) = _InputEntry;
}

/// One item of an `input:` device sequence. Mirrors the daemon's own item
/// set; anything it does not recognise stays a [RawInputToken] so an
/// unfamiliar config still round-trips.
@freezed
@withMeta
sealed class InputToken with _$InputToken {
  const factory InputToken.press(String key) = PressInputToken;

  const factory InputToken.release(String key) = ReleaseInputToken;

  /// Keys pressed in order and released in reverse, written `a+b+c`. A lone
  /// key or mouse button is a one-element combo.
  const factory InputToken.combo(List<String> keys) = ComboInputToken;

  const factory InputToken.text(DynamicText value) = TextInputToken;

  const factory InputToken.moveBy(double x, double y) = MoveByInputToken;

  /// Null multiplier is the bare `move_by_delta`, which the daemon reads as 1.
  const factory InputToken.moveByDelta(double? multiplier) =
      MoveByDeltaInputToken;

  const factory InputToken.moveTo(double x, double y) = MoveToInputToken;

  const factory InputToken.wheel(double x, double y) = WheelInputToken;

  const factory InputToken.raw(String token) = RawInputToken;
}
