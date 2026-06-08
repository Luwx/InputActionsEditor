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
    /// `begin`).
    TriggerOn? on,
    Condition? conditions,
    String? interval,
    String? threshold,
    @Default(true) bool conflicting,
    String? id,
    int? limit,
  }) = _TriggerAction;
}

@freezed
@withMeta
sealed class Action with _$Action {
  const factory Action.command({required String command, bool? wait}) =
      CommandAction;

  const factory Action.input({@Default([]) List<InputEntry> entries}) =
      InputAction;

  const factory Action.plasmaShortcut({
    required String component,
    required String shortcut,
  }) = PlasmaShortcutAction;

  const factory Action.activateWindow({required String windowId}) =
      ActivateWindowAction;

  const factory Action.sleep({required int milliseconds}) = SleepAction;

  /// A JavaScript function executed by the daemon for its side effects (the
  /// return value is ignored). [expression] is the raw `() => ...` source.
  const factory Action.function({required String expression}) = FunctionAction;

  /// Raw YAML for action types we don't model (e.g. one:, replace_text:).
  const factory Action.raw({required String raw}) = RawAction;
}

enum InputDevice { keyboard, mouse }

@freezed
@withMeta
abstract class InputEntry with _$InputEntry {
  const factory InputEntry({
    required InputDevice device,
    @Default([]) List<String> tokens,
  }) = _InputEntry;
}
