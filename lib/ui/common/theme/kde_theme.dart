import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/theme/color_contrast.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

FThemeData buildKdeThemeData(KdeColorScheme kde) {
  final colors = _kdeToFColors(kde);
  final isDark = kde.isDark;
  final base = isDark
      ? AppThemes.zinc.dark.desktop
      : AppThemes.zinc.light.desktop;

  final fg = colors.foreground;
  final body = base.typography.body.copyWith(
    xs3: base.typography.body.xs3.copyWith(color: fg),
    xs2: base.typography.body.xs2.copyWith(color: fg),
    xs: base.typography.body.xs.copyWith(color: fg),
    sm: base.typography.body.sm.copyWith(color: fg),
    md: base.typography.body.md.copyWith(color: fg),
    lg: base.typography.body.lg.copyWith(color: fg),
    xl: base.typography.body.xl.copyWith(color: fg),
    xl2: base.typography.body.xl2.copyWith(color: fg),
    xl3: base.typography.body.xl3.copyWith(color: fg),
    xl4: base.typography.body.xl4.copyWith(color: fg),
    xl5: base.typography.body.xl5.copyWith(color: fg),
    xl6: base.typography.body.xl6.copyWith(color: fg),
    xl7: base.typography.body.xl7.copyWith(color: fg),
    xl8: base.typography.body.xl8.copyWith(color: fg),
  );
  final display = base.typography.display.copyWith(
    xs3: base.typography.display.xs3.copyWith(color: fg),
    xs2: base.typography.display.xs2.copyWith(color: fg),
    xs: base.typography.display.xs.copyWith(color: fg),
    sm: base.typography.display.sm.copyWith(color: fg),
    md: base.typography.display.md.copyWith(color: fg),
    lg: base.typography.display.lg.copyWith(color: fg),
    xl: base.typography.display.xl.copyWith(color: fg),
    xl2: base.typography.display.xl2.copyWith(color: fg),
    xl3: base.typography.display.xl3.copyWith(color: fg),
    xl4: base.typography.display.xl4.copyWith(color: fg),
    xl5: base.typography.display.xl5.copyWith(color: fg),
    xl6: base.typography.display.xl6.copyWith(color: fg),
    xl7: base.typography.display.xl7.copyWith(color: fg),
    xl8: base.typography.display.xl8.copyWith(color: fg),
  );
  final typography = base.typography.copyWith(body: body, display: display);

  final style = FStyle(
    formFieldStyle: FFormFieldStyle.inherit(
      colors: colors,
      typography: typography,
      touch: false,
    ),
    focusedOutlineStyle: FFocusedOutlineStyle(
      color: kde.window.decorationFocus,
      borderRadius: base.style.focusedOutlineStyle.borderRadius,
    ),
    sizes: base.style.sizes,
    iconStyle: IconThemeData(color: fg, size: typography.body.lg.fontSize),
    tappableStyle: base.style.tappableStyle,
    borderRadius: base.style.borderRadius,
    borderWidth: base.style.borderWidth,
    pagePadding: base.style.pagePadding,
    shadow: base.style.shadow,
  );
  final buttonColors = colors.copyWith(card: kde.button.backgroundNormal);
  final buttonFieldColors = buttonColors.copyWith(
    foreground: kde.button.foregroundNormal,
    mutedForeground: kde.button.foregroundInactive,
    primary: kde.button.decorationFocus,
  );
  final viewColors = colors.copyWith(
    foreground: kde.view.foregroundNormal,
    mutedForeground: kde.view.foregroundInactive,
    primary: kde.view.decorationFocus,
    error: kde.view.foregroundNegative,
  );
  final select = FSelectStyle.inherit(
    colors: colors,
    icons: base.icons,
    typography: typography,
    style: style,
    touch: false,
  );

  return FThemeData(
    colors: colors,
    typography: typography,
    icons: base.icons,
    touch: false,
    style: style,
    buttonStyles: FButtonStyles.inherit(
      colors: buttonColors,
      typography: typography,
      style: style,
      touch: false,
    ),
    textFieldStyles: FTextFieldSizeStyles.inherit(
      colors: viewColors,
      typography: typography,
      style: style,
      touch: false,
    ),
    selectStyle: FSelectStyle(
      fieldStyles: FTextFieldSizeStyles.inherit(
        colors: buttonFieldColors,
        typography: typography,
        style: style,
        touch: false,
      ),
      searchStyle: select.searchStyle,
      contentStyle: select.contentStyle,
      emptyTextStyle: select.emptyTextStyle,
    ),
  ).copyWith(
    tooltipStyle: .delta(
      decoration: .shapeDelta(color: kde.tooltip.backgroundNormal),
      textStyle: .delta(color: kde.tooltip.foregroundNormal),
    ),
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
  final muted = _safeSurface(
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
    primary: kde.selection.backgroundNormal,
    primaryForeground: kde.selection.foregroundNormal,
    secondary: kde.button.backgroundNormal,
    secondaryForeground: kde.button.foregroundNormal,
    muted: muted,
    mutedForeground: kde.window.foregroundInactive,
    destructive: kde.window.foregroundNegative,
    destructiveForeground: kde.selection.foregroundNormal,
    error: kde.window.foregroundNegative,
    errorForeground: kde.selection.foregroundNormal,
    card: kde.view.backgroundNormal,
    border: border,
  );
}

Color _safeSurface(Color base, Color alternate) {
  if (contrastRatio(base, alternate) <= 2.0) return alternate;
  return Color.lerp(base, alternate, 0.25)!;
}
