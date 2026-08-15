import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/theme/color_contrast.dart';

/// Minimum contrast between a checked switch's track and its thumb.
const _thumbContrast = 1.5;

/// How much of the track color is mixed into an unchecked switch's thumb.
const _thumbDim = 0.2;

/// Restores the separation between a switch's track and thumb in dark mode.
///
/// Monochrome dark schemes (zinc, neutral, slate, …) paint the checked track
/// with a near-white primary and the thumb with a near-white foreground, so
/// the switch reads as a single white blob. Dim the track until the thumb
/// separates from it, and take the edge off the thumb when unchecked.
/// Dark mode only — light schemes pair a dark track with a light thumb.
///
/// Returns null in light mode, leaving the theme's own style untouched.
FSwitchStyleDelta? switchContrastDelta(FThemeData theme) {
  final colors = theme.colors;
  if (colors.brightness != Brightness.dark) return null;

  final style = theme.switchStyle;
  final thumb = style.thumbColor.resolve({FSwitchVariant.selected});
  final checkedTrack = style.trackColor.resolve({FSwitchVariant.selected});
  final uncheckedTrack = style.trackColor.resolve({});

  final track = blendUntilContrast(
    checkedTrack,
    thumb,
    towards: colors.background,
    minRatio: _thumbContrast,
  );
  final uncheckedThumb = Color.lerp(thumb, uncheckedTrack, _thumbDim)!;

  return .delta(
    trackColor: .delta([
      .exact({FSwitchVariantConstraint.selected}, track),
      .exact({
        FSwitchVariantConstraint.selected.and(.disabled),
      }, colors.disable(track)),
    ]),
    thumbColor: .delta([
      .base(uncheckedThumb),
      .exact({FSwitchVariantConstraint.selected}, thumb),
    ]),
  );
}
