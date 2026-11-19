import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:meta_generator/meta_generator.dart';

part 'touchscreen_gesture.freezed.dart';
part 'touchscreen_gesture.g.dart';

@freezed
@withMeta
sealed class TouchscreenGesture with _$TouchscreenGesture implements Gesture {
  const TouchscreenGesture._();

  const factory TouchscreenGesture.swipe({
    required TriggerCommon common,
    required SwipeMode mode,
    FingerRange? fingers,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenSwipeGesture;

  const factory TouchscreenGesture.pinch({
    required TriggerCommon common,
    FingerRange? fingers,
    @Default(PinchDirection.any) PinchDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenPinchGesture;

  const factory TouchscreenGesture.rotate({
    required TriggerCommon common,
    FingerRange? fingers,
    @Default(RotationDirection.any) RotationDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenRotateGesture;

  const factory TouchscreenGesture.circle({
    required TriggerCommon common,
    FingerRange? fingers,
    @Default(RotationDirection.any) RotationDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = TouchscreenCircleGesture;

  const factory TouchscreenGesture.tap({
    required TriggerCommon common,
    FingerRange? fingers,
  }) = TouchscreenTapGesture;

  const factory TouchscreenGesture.hold({
    required TriggerCommon common,
    FingerRange? fingers,
  }) = TouchscreenHoldGesture;

  const factory TouchscreenGesture.stroke({
    required TriggerCommon common,
    FingerRange? fingers,
    @Default([]) List<Stroke> strokes,
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

  MotionCommon? get motionOrNull => switch (this) {
    final TouchscreenSwipeGesture g => g.motion,
    final TouchscreenPinchGesture g => g.motion,
    final TouchscreenRotateGesture g => g.motion,
    final TouchscreenCircleGesture g => g.motion,
    final TouchscreenStrokeGesture g => g.motion,
    TouchscreenTapGesture() => null,
    TouchscreenHoldGesture() => null,
  };

  /// No-op for the kinds without motion.
  TouchscreenGesture withMotion(MotionCommon m) => switch (this) {
    final TouchscreenSwipeGesture g => g.copyWith(motion: m),
    final TouchscreenPinchGesture g => g.copyWith(motion: m),
    final TouchscreenRotateGesture g => g.copyWith(motion: m),
    final TouchscreenCircleGesture g => g.copyWith(motion: m),
    final TouchscreenStrokeGesture g => g.copyWith(motion: m),
    TouchscreenTapGesture() => this,
    TouchscreenHoldGesture() => this,
  };

  TouchscreenGesture withFingers(FingerRange? f) => switch (this) {
    final TouchscreenSwipeGesture g => g.copyWith(fingers: f),
    final TouchscreenPinchGesture g => g.copyWith(fingers: f),
    final TouchscreenRotateGesture g => g.copyWith(fingers: f),
    final TouchscreenCircleGesture g => g.copyWith(fingers: f),
    final TouchscreenTapGesture g => g.copyWith(fingers: f),
    final TouchscreenHoldGesture g => g.copyWith(fingers: f),
    final TouchscreenStrokeGesture g => g.copyWith(fingers: f),
  };
}
