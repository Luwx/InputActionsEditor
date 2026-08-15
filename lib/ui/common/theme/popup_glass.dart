import 'dart:ui' show ImageFilter, TileMode;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Alpha applied to the surface color of transient popups (popovers, menus,
/// select dropdowns, tooltips) so the blurred content behind shows through.
///
/// Dialogs deliberately stay opaque.
const _popupSurfaceAlpha = 0.8;

/// Blur radius behind a translucent popup surface.
const _popupBlurSigma = 8.0;

/// `Colors.transparent` without pulling material into the theme.
const _transparent = Color(0x00000000);

/// Backdrop blur that ramps with the popup's entrance animation, so the blur
/// fades in alongside the surface instead of popping in at full strength.
/// [TileMode.decal] stops the blur sampling pixels from outside the popup and
/// smearing that content into the surface. The stricter fix is `ImageFilter`'s
/// `bounds` argument, but that needs a canvas-space rect the theme never sees.
ImageFilter _popupBlur(BuildContext context, double animation) =>
    ImageFilter.blur(
      sigmaX: animation * _popupBlurSigma,
      sigmaY: animation * _popupBlurSigma,
      tileMode: TileMode.decal,
    );

/// Returns [theme] with glassmorphic popups: a translucent card surface over a
/// backdrop blur, for popovers, menus, select dropdowns and tooltips.
///
/// Each style keeps its inherited border, shadow and shape; only the surface
/// color's alpha changes. [FDialog] is intentionally left out — dialogs stay
/// opaque.
///
/// Applies to every theme, so it must be called on all theme-building paths,
/// not just the KDE one.
FThemeData withGlassPopups(FThemeData theme) {
  final popupSurface = theme.colors.card.withValues(alpha: _popupSurfaceAlpha);

  return theme.copyWith(
    popoverStyle: .delta(
      decoration: .shapeDelta(color: popupSurface),
      backgroundFilter: _popupBlur,
    ),
    // Covers both FPopoverMenu and FContextMenu, which share this style.
    popoverMenuStyle: .delta(
      decoration: .shapeDelta(color: popupSurface),
      backgroundFilter: () => _popupBlur,
      // FPopoverMenuStyle.inherit paints an opaque `colors.card` behind the
      // item group *and* behind every item, which would sit on top of the
      // translucent popover surface and hide it. Clear both so the popover's
      // own surface is the only thing tinting the menu. Only the `base`
      // content decoration is cleared: hover, pressed and selected live in
      // their own variants and must keep their fills.
      itemGroupStyle: .delta(
        decoration: const .shapeDelta(color: _transparent),
        itemStyles: .delta([
          .all(
            .delta(
              backgroundColor: .delta([.all(_transparent)]),
              contentDecoration: .delta([
                .base(const .shapeDelta(color: _transparent)),
              ]),
            ),
          ),
        ]),
      ),
    ),
    selectStyle: .delta(
      contentStyle: .delta(
        decoration: .shapeDelta(color: popupSurface),
        backgroundFilter: () => _popupBlur,
      ),
    ),
    // FTooltip takes a static filter rather than an animation-driven one.
    tooltipStyle: .delta(
      decoration: .shapeDelta(color: popupSurface),
      backgroundFilter: ImageFilter.blur(
        sigmaX: _popupBlurSigma,
        sigmaY: _popupBlurSigma,
        tileMode: TileMode.decal,
      ),
    ),
  );
}
