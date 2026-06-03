import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

part 'touchscreen_gesture.freezed.dart';

@freezed
sealed class TouchscreenGesture with _$TouchscreenGesture implements Gesture {
  const TouchscreenGesture._();

  const factory TouchscreenGesture.swipe({
    required TriggerCommon common,
    required SwipeMode mode,
    int? fingers,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenSwipeGesture;

  const factory TouchscreenGesture.pinch({
    required TriggerCommon common,
    int? fingers,
    @Default(PinchDirection.any) PinchDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenPinchGesture;

  const factory TouchscreenGesture.rotate({
    required TriggerCommon common,
    int? fingers,
    @Default(RotateDirection.any) RotateDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenRotateGesture;

  const factory TouchscreenGesture.circle({
    required TriggerCommon common,
    int? fingers,
    @Default(CircleDirection.any) CircleDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenCircleGesture;

  const factory TouchscreenGesture.tap({
    required TriggerCommon common,
    int? fingers,
  }) = TouchscreenTapGesture;

  const factory TouchscreenGesture.hold({
    required TriggerCommon common,
    int? fingers,
  }) = TouchscreenHoldGesture;

  const factory TouchscreenGesture.stroke({
    required TriggerCommon common,
    int? fingers,
    @Default([]) List<String> strokes,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenStrokeGesture;

  TouchscreenTriggerType get triggerType => switch (this) {
    TouchscreenSwipeGesture() => TouchscreenTriggerType.swipe,
    TouchscreenPinchGesture() => TouchscreenTriggerType.pinch,
    TouchscreenRotateGesture() => TouchscreenTriggerType.rotate,
    TouchscreenCircleGesture() => TouchscreenTriggerType.circle,
    TouchscreenTapGesture() => TouchscreenTriggerType.tap,
    TouchscreenHoldGesture() => TouchscreenTriggerType.hold,
    TouchscreenStrokeGesture() => TouchscreenTriggerType.stroke,
  };

  @override
  TouchscreenGesture withCommon(TriggerCommon c) => switch (this) {
    final TouchscreenSwipeGesture g => g.copyWith(common: c),
    final TouchscreenPinchGesture g => g.copyWith(common: c),
    final TouchscreenRotateGesture g => g.copyWith(common: c),
    final TouchscreenCircleGesture g => g.copyWith(common: c),
    final TouchscreenTapGesture g => g.copyWith(common: c),
    final TouchscreenHoldGesture g => g.copyWith(common: c),
    final TouchscreenStrokeGesture g => g.copyWith(common: c),
  };

  TouchscreenGesture withFingers(int? f) => switch (this) {
    final TouchscreenSwipeGesture g => g.copyWith(fingers: f),
    final TouchscreenPinchGesture g => g.copyWith(fingers: f),
    final TouchscreenRotateGesture g => g.copyWith(fingers: f),
    final TouchscreenCircleGesture g => g.copyWith(fingers: f),
    final TouchscreenTapGesture g => g.copyWith(fingers: f),
    final TouchscreenHoldGesture g => g.copyWith(fingers: f),
    final TouchscreenStrokeGesture g => g.copyWith(fingers: f),
  };

  int? get fingersTest => fingers;
}
