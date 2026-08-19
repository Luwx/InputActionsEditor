import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class UiScaleBinding extends WidgetsFlutterBinding {
  UiScaleBinding._();

  static const _envUiScale = 'INPUT_ACTIONS_UI_SCALE';
  static const _minScale = 0.5;
  static const _maxScale = 3.0;

  static UiScaleBinding? _instance;

  static final double scale =
      double.tryParse(Platform.environment[_envUiScale] ?? '')?.clamp(
        _minScale,
        _maxScale,
      ) ??
      1.0;

  static void ensureInitialized() => _instance ??= UiScaleBinding._();

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
