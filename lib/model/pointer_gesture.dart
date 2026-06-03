import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

part 'pointer_gesture.freezed.dart';

@freezed
sealed class PointerGesture with _$PointerGesture implements Gesture {
  const PointerGesture._();

  const factory PointerGesture.hover({required TriggerCommon common}) =
      HoverGesture;

  PointerTriggerType get triggerType => switch (this) {
    HoverGesture() => PointerTriggerType.hover,
  };

  @override
  PointerGesture withCommon(TriggerCommon c) => switch (this) {
    final HoverGesture g => g.copyWith(common: c),
  };
}
