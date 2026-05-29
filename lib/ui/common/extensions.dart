import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension AppearEffects<T extends AnimateManager<T>> on T {
  T appear({
    Duration? duration,
    Curve? curve,
    Axis axis = Axis.vertical,
    AlignmentGeometry alignment = Alignment.center,
  }) => addEffect(
    CustomEffect(
      duration: duration ?? Durations.medium1,
      curve: curve ?? Easing.emphasizedDecelerate,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Align(
          alignment: alignment,
          heightFactor: axis == Axis.vertical ? value : null,
          widthFactor: axis == Axis.horizontal ? value : null,
          child: child,
        ),
      ),
    ),
  );
}

extension AppearToggleEffects on Widget {
  Animate appearToggle({
    required bool visible,
    Duration? duration,
    Axis axis = Axis.vertical,
    AlignmentGeometry alignment = Alignment.center,
  }) =>
      animate(
        target: visible ? 1.0 : 0.0,
        onInit: (controller) => controller.value = visible ? 1.0 : 0.0,
      ).appear(
        duration: duration,
        curve: visible
            ? Easing.emphasizedDecelerate
            : Easing.emphasizedAccelerate,
        axis: axis,
        alignment: alignment,
      );
}
