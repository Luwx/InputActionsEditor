import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:meta_generator/meta_generator.dart';

part 'mouse_gesture.freezed.dart';
part 'mouse_gesture.g.dart';

@freezed
@withMeta
sealed class SwipeMode with _$SwipeMode {
  const factory SwipeMode.direction({required SwipeDirection direction}) =
      SwipeDirectionMode;

  const factory SwipeMode.angle({
    required double minAngle,
    required double maxAngle,
    @Default(false) bool bidirectional,
  }) = SwipeAngleMode;
}

@freezed
@withMeta
sealed class MouseGesture with _$MouseGesture implements Gesture {
  const MouseGesture._();

  const factory MouseGesture.stroke({
    required TriggerCommon common,
    @Default(MotionCommon()) MotionCommon motion,
    @Default([]) List<String> strokes,
  }) = StrokeGesture;

  const factory MouseGesture.swipe({
    required TriggerCommon common,
    required SwipeMode mode,
    @Default(MotionCommon()) MotionCommon motion,
  }) = SwipeGesture;

  const factory MouseGesture.circle({
    required TriggerCommon common,
    required RotationDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = CircleGesture;

  const factory MouseGesture.press({
    required TriggerCommon common,
    @Default(MotionCommon()) MotionCommon motion,
    bool? instant,
  }) = PressGesture;

  const factory MouseGesture.wheel({
    required TriggerCommon common,
    required WheelDirection direction,
    @Default(MotionCommon()) MotionCommon motion,
  }) = WheelGesture;

  MouseTriggerType get triggerType => switch (this) {
    StrokeGesture() => MouseTriggerType.stroke,
    SwipeGesture() => MouseTriggerType.swipe,
    CircleGesture() => MouseTriggerType.circle,
    PressGesture() => MouseTriggerType.press,
    WheelGesture() => MouseTriggerType.wheel,
  };

  @override
  MouseGesture withCommon(TriggerCommon c) => switch (this) {
    final StrokeGesture g => g.copyWith(common: c),
    final SwipeGesture g => g.copyWith(common: c),
    final CircleGesture g => g.copyWith(common: c),
    final PressGesture g => g.copyWith(common: c),
    final WheelGesture g => g.copyWith(common: c),
  };

  MouseGesture withMotion(MotionCommon m) => switch (this) {
    final StrokeGesture g => g.copyWith(motion: m),
    final SwipeGesture g => g.copyWith(motion: m),
    final CircleGesture g => g.copyWith(motion: m),
    final PressGesture g => g.copyWith(motion: m),
    final WheelGesture g => g.copyWith(motion: m),
  };
}
