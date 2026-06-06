import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:meta_generator/meta_generator.dart';

part 'touchpad_gesture.freezed.dart';
part 'touchpad_gesture.g.dart';

@freezed
@withMeta
sealed class TouchpadGesture with _$TouchpadGesture implements Gesture {
  const TouchpadGesture._();

  const factory TouchpadGesture.swipe({
    required TriggerCommon common,
    required SwipeMode mode,
    int? fingers,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchpadSwipeGesture;

  const factory TouchpadGesture.pinch({
    required TriggerCommon common,
    int? fingers,
    @Default(PinchDirection.any) PinchDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchpadPinchGesture;

  const factory TouchpadGesture.rotate({
    required TriggerCommon common,
    int? fingers,
    @Default(RotateDirection.any) RotateDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchpadRotateGesture;

  const factory TouchpadGesture.circle({
    required TriggerCommon common,
    int? fingers,
    @Default(CircleDirection.any) CircleDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchpadCircleGesture;

  const factory TouchpadGesture.tap({
    required TriggerCommon common,
    int? fingers,
  }) = TouchpadTapGesture;

  const factory TouchpadGesture.click({
    required TriggerCommon common,
    int? fingers,
  }) = TouchpadClickGesture;

  const factory TouchpadGesture.hold({
    required TriggerCommon common,
    int? fingers,
  }) = TouchpadHoldGesture;

  const factory TouchpadGesture.stroke({
    required TriggerCommon common,
    int? fingers,
    @Default([]) List<String> strokes,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchpadStrokeGesture;

  TouchpadTriggerType get triggerType => switch (this) {
    TouchpadSwipeGesture() => TouchpadTriggerType.swipe,
    TouchpadPinchGesture() => TouchpadTriggerType.pinch,
    TouchpadRotateGesture() => TouchpadTriggerType.rotate,
    TouchpadCircleGesture() => TouchpadTriggerType.circle,
    TouchpadTapGesture() => TouchpadTriggerType.tap,
    TouchpadClickGesture() => TouchpadTriggerType.click,
    TouchpadHoldGesture() => TouchpadTriggerType.hold,
    TouchpadStrokeGesture() => TouchpadTriggerType.stroke,
  };

  @override
  TouchpadGesture withCommon(TriggerCommon c) => switch (this) {
    final TouchpadSwipeGesture g => g.copyWith(common: c),
    final TouchpadPinchGesture g => g.copyWith(common: c),
    final TouchpadRotateGesture g => g.copyWith(common: c),
    final TouchpadCircleGesture g => g.copyWith(common: c),
    final TouchpadTapGesture g => g.copyWith(common: c),
    final TouchpadClickGesture g => g.copyWith(common: c),
    final TouchpadHoldGesture g => g.copyWith(common: c),
    final TouchpadStrokeGesture g => g.copyWith(common: c),
  };

  TouchpadGesture withFingers(int? f) => switch (this) {
    final TouchpadSwipeGesture g => g.copyWith(fingers: f),
    final TouchpadPinchGesture g => g.copyWith(fingers: f),
    final TouchpadRotateGesture g => g.copyWith(fingers: f),
    final TouchpadCircleGesture g => g.copyWith(fingers: f),
    final TouchpadTapGesture g => g.copyWith(fingers: f),
    final TouchpadClickGesture g => g.copyWith(fingers: f),
    final TouchpadHoldGesture g => g.copyWith(fingers: f),
    final TouchpadStrokeGesture g => g.copyWith(fingers: f),
  };
}
