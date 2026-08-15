import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolutions offered when translating normalized condition values to pixels.
/// The display the app runs on is added to this list at build time.
const previewResolutionPresets = <Size>[
  Size(1280, 720),
  Size(1366, 768),
  Size(1920, 1080),
  Size(1920, 1200),
  Size(2560, 1440),
  Size(3440, 1440),
  Size(3840, 2160),
];

/// Resolution picked in a point popover, remembered for the session so it does
/// not reset every time a popover is reopened. Null means "use the display the
/// app is running on".
class PreviewResolutionController extends Notifier<Size?> {
  @override
  Size? build() => null;

  @override
  set state(Size? value) => super.state = value;
}

final previewResolutionProvider =
    NotifierProvider<PreviewResolutionController, Size?>(
      PreviewResolutionController.new,
    );

/// Presets plus [display], deduplicated and ordered by size.
List<Size> previewResolutionOptions(Size display) {
  final options = {...previewResolutionPresets, display}.toList()
    ..sort(
      (a, b) => a.width == b.width
          ? a.height.compareTo(b.height)
          : a.width.compareTo(b.width),
    );
  return options;
}

String formatResolution(Size size) =>
    '${size.width.round()} × ${size.height.round()}';
