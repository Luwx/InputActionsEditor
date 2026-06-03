import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:meta_generator/meta_generator.dart';

part 'keyboard_gesture.freezed.dart';
part 'keyboard_gesture.g.dart';

@freezed
@withMeta
sealed class KeyboardGesture with _$KeyboardGesture implements Gesture {
  const KeyboardGesture._();

  const factory KeyboardGesture.shortcut({
    required TriggerCommon common,
    @Default([]) List<String> keys,
  }) = ShortcutGesture;

  KeyboardTriggerType get triggerType => switch (this) {
    ShortcutGesture() => KeyboardTriggerType.shortcut,
  };

  @override
  KeyboardGesture withCommon(TriggerCommon c) => switch (this) {
    final ShortcutGesture g => g.copyWith(common: c),
  };
}
