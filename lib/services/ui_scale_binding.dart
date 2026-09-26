import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class UiScaleBinding extends WidgetsFlutterBinding {
  UiScaleBinding._();

  static const _envUiScale = 'INPUT_ACTIONS_UI_SCALE';
  static const _zoomSteps = [0.75, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 1.75, 2.0];

  static UiScaleBinding? _instance;

  static final _scale = ValueNotifier<double>(
    _validatedScale(
      double.tryParse(Platform.environment[_envUiScale] ?? '') ?? 1.0,
    ),
  );

  static double get scale => _scale.value;

  static set scale(double value) {
    final next = _validatedScale(value);
    if (next == scale) return;
    _scale.value = next;
    _instance?.handleMetricsChanged();
  }

  static ValueListenable<double> get scaleListenable => _scale;

  static double _validatedScale(double value) =>
      value.isFinite ? value.clamp(_zoomSteps.first, _zoomSteps.last) : 1.0;

  static void zoomIn() => scale = _zoomSteps.firstWhere(
    (step) => step > scale,
    orElse: () => _zoomSteps.last,
  );

  static void zoomOut() => scale = _zoomSteps.reversed.firstWhere(
    (step) => step < scale,
    orElse: () => _zoomSteps.first,
  );

  static void ensureInitialized() => _instance ??= UiScaleBinding._();

  @override
  void handlePointerEvent(PointerEvent event) {
    // Flutter converts pointer coordinates using the unscaled view pixel ratio.
    super.handlePointerEvent(
      scale == 1
          ? event
          : event.copyWith(
              position: event.position / scale,
              delta: event.delta / scale,
            ),
    );
  }

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    final view = renderView.flutterView;
    final ratio = view.devicePixelRatio * scale;
    final constraints = BoxConstraints.fromViewConstraints(
      view.physicalConstraints,
    );
    return ViewConfiguration(
      physicalConstraints: constraints,
      logicalConstraints: constraints / ratio,
      devicePixelRatio: ratio,
    );
  }
}
