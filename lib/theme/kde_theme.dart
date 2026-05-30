import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

/// Builds a [FThemeData] from a [KdeColorScheme].
///
/// Uses forui's zinc theme as the structural base (typography scale, border
/// radii, sizes) then overlays the KDE colors on the parts that are
/// color-dependent: text color, focus ring, icon color, and form field styles.
/// No custom theme.dart is required.
FThemeData buildKdeThemeData(KdeColorScheme kde) {
  final colors = _kdeToFColors(kde);
  final isDark = kde.isDark;
  final base = isDark ? FThemes.zinc.dark.desktop : FThemes.zinc.light.desktop;

  // Rebuild all text styles with the KDE foreground color.
  // Zinc's baked-in foreground (~white/black) would otherwise override
  // whatever ForegroundNormal the scheme provides (e.g. MonochromeTint's
  // muted 171,168,182 would render as zinc's pure white).
  final fg = colors.foreground;
  final typography = base.typography.copyWith(
    xs3: base.typography.xs3.copyWith(color: fg),
    xs2: base.typography.xs2.copyWith(color: fg),
    xs: base.typography.xs.copyWith(color: fg),
    sm: base.typography.sm.copyWith(color: fg),
    md: base.typography.md.copyWith(color: fg),
    lg: base.typography.lg.copyWith(color: fg),
    xl: base.typography.xl.copyWith(color: fg),
    xl2: base.typography.xl2.copyWith(color: fg),
    xl3: base.typography.xl3.copyWith(color: fg),
    xl4: base.typography.xl4.copyWith(color: fg),
    xl5: base.typography.xl5.copyWith(color: fg),
    xl6: base.typography.xl6.copyWith(color: fg),
    xl7: base.typography.xl7.copyWith(color: fg),
    xl8: base.typography.xl8.copyWith(color: fg),
  );

  return FThemeData(
    colors: colors,
    typography: typography,
    icons: base.icons,
    touch: false,
    style: FStyle(
      // Rebuilds border colors, label colors, helper text from KDE colors.
      formFieldStyle: FFormFieldStyle.inherit(
        colors: colors,
        typography: typography,
        touch: false,
      ),
      // Focus ring uses the KDE accent color.
      focusedOutlineStyle: FFocusedOutlineStyle(
        color: colors.primary,
        borderRadius: base.style.focusedOutlineStyle.borderRadius,
      ),
      sizes: base.style.sizes,
      // Icons use the KDE foreground color.
      iconStyle: IconThemeData(color: fg, size: typography.lg.fontSize),
      tappableStyle: base.style.tappableStyle,
      borderRadius: base.style.borderRadius,
      borderWidth: base.style.borderWidth,
      pagePadding: base.style.pagePadding,
      shadow: base.style.shadow,
    ),
  ).copyWith(
    sidebarStyle: const .delta(
      groupStyle: .delta(
        padding: .delta(left: 12, right: 12),
      ),
    ),
  );
}

FColors _kdeToFColors(KdeColorScheme kde) {
  final isDark = kde.isDark;
  final border = kde.window.foregroundNormal.withAlpha(0x1A);
  final secondary = _safeSurface(
    kde.window.backgroundNormal,
    kde.window.backgroundAlternate,
  );

  return FColors(
    brightness: isDark ? Brightness.dark : Brightness.light,
    systemOverlayStyle: isDark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark,
    barrier: isDark ? const Color(0x7A000000) : const Color(0x33000000),
    background: kde.window.backgroundNormal,
    foreground: kde.window.foregroundNormal,
    primary: kde.accentColor,
    primaryForeground: kde.selection.foregroundNormal,
    secondary: secondary,
    secondaryForeground: kde.window.foregroundNormal,
    muted: secondary,
    mutedForeground: kde.window.foregroundInactive,
    destructive: kde.window.foregroundNegative,
    destructiveForeground: kde.selection.foregroundNormal,
    error: kde.window.foregroundNegative,
    errorForeground: kde.selection.foregroundNormal,
    card: kde.view.backgroundNormal,
    border: border,
  );
}

/// Returns [alternate] if its contrast against [base] is ≤ 2.0.
/// If the scheme used [alternate] as a high-contrast reference color
/// (e.g. MonochromeTint's light gray on near-black), blends 25% toward it
/// so the raised surface stays subtle.
Color _safeSurface(Color base, Color alternate) {
  if (_contrastRatio(base, alternate) <= 2.0) return alternate;
  return Color.lerp(base, alternate, 0.25)!;
}

double _contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
