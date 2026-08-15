import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// The shadcn-derived color schemes offered by the theme picker.
///
/// Copied verbatim from forui 0.23's `FColors`, which only ships `neutral`
/// since 0.25.
abstract final class AppThemes {
  static final AppThemePair neutral = _pair(
    'Neutral',
    FColors.neutralLight,
    FColors.neutralDark,
  );
  static final AppThemePair zinc = _pair('Zinc', _zincLight, _zincDark);
  static final AppThemePair slate = _pair('Slate', _slateLight, _slateDark);
  static final AppThemePair blue = _pair('Blue', _blueLight, _blueDark);
  static final AppThemePair green = _pair('Green', _greenLight, _greenDark);
  static final AppThemePair orange = _pair('Orange', _orangeLight, _orangeDark);
  static final AppThemePair red = _pair('Red', _redLight, _redDark);
  static final AppThemePair rose = _pair('Rose', _roseLight, _roseDark);
  static final AppThemePair violet = _pair('Violet', _violetLight, _violetDark);
  static final AppThemePair yellow = _pair('Yellow', _yellowLight, _yellowDark);
}

typedef AppThemePair = ({FPlatformThemeData light, FPlatformThemeData dark});

AppThemePair _pair(String name, FColors light, FColors dark) => (
  light: FPlatformThemeData(
    desktop: () => FThemeData(
      touch: false,
      debugLabel: '$name Light Desktop',
      colors: light,
    ),
    touch: () =>
        FThemeData(touch: true, debugLabel: '$name Light Touch', colors: light),
  ),
  dark: FPlatformThemeData(
    desktop: () => FThemeData(
      touch: false,
      debugLabel: '$name Dark Desktop',
      colors: dark,
    ),
    touch: () =>
        FThemeData(touch: true, debugLabel: '$name Dark Touch', colors: dark),
  ),
);

final FColors _zincLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFF18181B),
  primaryForeground: const Color(0xFFFAFAFA),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _zincDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFE4E4E7),
  primaryForeground: const Color(0xFF18181B),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _slateLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF020618),
  primary: const Color(0xFF0F172B),
  primaryForeground: const Color(0xFFF8FAFC),
  secondary: const Color(0xFFF1F5F9),
  secondaryForeground: const Color(0xFF0F172B),
  muted: const Color(0xFFF1F5F9),
  mutedForeground: const Color(0xFF62748E),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE2E8F0),
);

final FColors _slateDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF020618),
  foreground: const Color(0xFFF8FAFC),
  primary: const Color(0xFFE2E8F0),
  primaryForeground: const Color(0xFF0F172B),
  secondary: const Color(0xFF1D293D),
  secondaryForeground: const Color(0xFFF8FAFC),
  muted: const Color(0xFF1D293D),
  mutedForeground: const Color(0xFF90A1B9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF0F172B),
  border: const Color(0x1AFFFFFF),
);

final FColors _blueLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFF1447E6),
  primaryForeground: const Color(0xFFEFF6FF),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _blueDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFF1447E6),
  primaryForeground: const Color(0xFFEFF6FF),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _greenLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFF5EA500),
  primaryForeground: const Color(0xFFF7FEE7),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _greenDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFF5EA500),
  primaryForeground: const Color(0xFFF7FEE7),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _orangeLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFFF54A00),
  primaryForeground: const Color(0xFFFFF7ED),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _orangeDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFFF6900),
  primaryForeground: const Color(0xFFFFF7ED),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _redLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFFE7000B),
  primaryForeground: const Color(0xFFFEF2F2),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _redDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFFB2C36),
  primaryForeground: const Color(0xFFFEF2F2),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _roseLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFFEC003F),
  primaryForeground: const Color(0xFFFFF1F2),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _roseDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFFF2056),
  primaryForeground: const Color(0xFFFFF1F2),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _violetLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFF7F22FE),
  primaryForeground: const Color(0xFFF5F3FF),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _violetDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFF8E51FF),
  primaryForeground: const Color(0xFFF5F3FF),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);

final FColors _yellowLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF09090B),
  primary: const Color(0xFFFCC800),
  primaryForeground: const Color(0xFF733E0A),
  secondary: const Color(0xFFF4F4F5),
  secondaryForeground: const Color(0xFF18181B),
  muted: const Color(0xFFF4F4F5),
  mutedForeground: const Color(0xFF71717B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE4E4E7),
);

final FColors _yellowDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF09090B),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFEFB100),
  primaryForeground: const Color(0xFF733E0A),
  secondary: const Color(0xFF27272A),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF27272A),
  mutedForeground: const Color(0xFF9F9FA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF18181B),
  border: const Color(0x1AFFFFFF),
);
