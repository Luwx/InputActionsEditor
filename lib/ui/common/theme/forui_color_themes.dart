import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';

/// The color schemes offered by the theme picker.
///
/// The ramps and primary pairs are copied from `forui_cli`'s `BaseColor` and
/// `PrimaryColor`, which is where they live since forui 0.25 stopped shipping
/// them at runtime. `slate` predates that split and comes from forui 0.23.
abstract final class AppThemes {
  /// Schemes carrying their own neutral ramp, in forui's order.
  static Iterable<FColorTheme> get ramps => _ramps.keys;

  /// Schemes that are [zinc] with a different primary pair, in forui's order.
  static Iterable<FColorTheme> get accents => _accents.keys;

  static final AppThemePair zinc = _pairs[FColorTheme.zinc]!;

  static AppThemePair? of(FColorTheme theme) => _pairs[theme];

  /// The color standing in for [theme] in the picker: a ramp is represented by
  /// its tinted neutral, a primary scheme by the primary itself.
  static Color swatch(FColorTheme theme, Brightness brightness) {
    final pair = _pairs[theme]!;
    final colors =
        (brightness == Brightness.dark ? pair.dark : pair.light).desktop.colors;
    return _accents.containsKey(theme) ? colors.primary : colors.secondary;
  }

  static final Map<FColorTheme, AppThemePair> _pairs = {
    for (final MapEntry(:key, :value) in _ramps.entries)
      key: _pair(_label(key), value.$1, value.$2),
    for (final MapEntry(:key, :value) in _accents.entries)
      key: _pair(
        _label(key),
        _zincLight.copyWith(primary: value.$1, primaryForeground: value.$3),
        _zincDark.copyWith(primary: value.$2, primaryForeground: value.$3),
      ),
  };
}

typedef AppThemePair = ({FPlatformThemeData light, FPlatformThemeData dark});

String _label(FColorTheme theme) =>
    theme.name[0].toUpperCase() + theme.name.substring(1);

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

final Map<FColorTheme, (FColors, FColors)> _ramps = {
  FColorTheme.neutral: (FColors.neutralLight, FColors.neutralDark),
  FColorTheme.stone: (_stoneLight, _stoneDark),
  FColorTheme.zinc: (_zincLight, _zincDark),
  FColorTheme.mauve: (_mauveLight, _mauveDark),
  FColorTheme.olive: (_oliveLight, _oliveDark),
  FColorTheme.mist: (_mistLight, _mistDark),
  FColorTheme.taupe: (_taupeLight, _taupeDark),
  FColorTheme.slate: (_slateLight, _slateDark),
};

const Map<FColorTheme, (Color, Color, Color)> _accents = {
  FColorTheme.amber: (Color(0xFFBB4D00), Color(0xFF973C00), Color(0xFFFFFBEB)),
  FColorTheme.blue: (Color(0xFF1447E6), Color(0xFF193CB8), Color(0xFFEFF6FF)),
  FColorTheme.cyan: (Color(0xFF007595), Color(0xFF005F78), Color(0xFFECFEFF)),
  FColorTheme.emerald: (
    Color(0xFF007A55),
    Color(0xFF006045),
    Color(0xFFECFDF5),
  ),
  FColorTheme.fuchsia: (
    Color(0xFFA800B7),
    Color(0xFF8A0194),
    Color(0xFFFDF4FF),
  ),
  FColorTheme.green: (Color(0xFF008236), Color(0xFF016630), Color(0xFFF0FDF4)),
  FColorTheme.indigo: (Color(0xFF432DD7), Color(0xFF372AAC), Color(0xFFEEF2FF)),
  FColorTheme.lime: (Color(0xFF9AE600), Color(0xFF7CCF00), Color(0xFF35530E)),
  FColorTheme.orange: (Color(0xFFCA3500), Color(0xFF9F2D00), Color(0xFFFFF7ED)),
  FColorTheme.pink: (Color(0xFFC6005C), Color(0xFFA3004C), Color(0xFFFDF2F8)),
  FColorTheme.purple: (Color(0xFF8200DB), Color(0xFF6E11B0), Color(0xFFFAF5FF)),
  FColorTheme.red: (Color(0xFFC10007), Color(0xFF9F0712), Color(0xFFFEF2F2)),
  FColorTheme.rose: (Color(0xFFC70036), Color(0xFFA50036), Color(0xFFFFF1F2)),
  FColorTheme.sky: (Color(0xFF0069A8), Color(0xFF00598A), Color(0xFFF0F9FF)),
  FColorTheme.teal: (Color(0xFF00786F), Color(0xFF005F5A), Color(0xFFF0FDFA)),
  FColorTheme.violet: (Color(0xFF7008E7), Color(0xFF5D0EC0), Color(0xFFF5F3FF)),
  FColorTheme.yellow: (Color(0xFFFDC700), Color(0xFFF0B100), Color(0xFF733E0A)),
};

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

final FColors _stoneLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF0C0A09),
  primary: const Color(0xFF1C1917),
  primaryForeground: const Color(0xFFFAFAF9),
  secondary: const Color(0xFFF5F5F4),
  secondaryForeground: const Color(0xFF1C1917),
  muted: const Color(0xFFF5F5F4),
  mutedForeground: const Color(0xFF79716B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE7E5E4),
);

final FColors _stoneDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF0C0A09),
  foreground: const Color(0xFFFAFAF9),
  primary: const Color(0xFFE7E5E4),
  primaryForeground: const Color(0xFF1C1917),
  secondary: const Color(0xFF292524),
  secondaryForeground: const Color(0xFFFAFAF9),
  muted: const Color(0xFF292524),
  mutedForeground: const Color(0xFFA6A09B),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF1C1917),
  border: const Color(0x1AFFFFFF),
);

final FColors _mauveLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF0C090C),
  primary: const Color(0xFF1D161E),
  primaryForeground: const Color(0xFFFAFAFA),
  secondary: const Color(0xFFF3F1F3),
  secondaryForeground: const Color(0xFF1D161E),
  muted: const Color(0xFFF3F1F3),
  mutedForeground: const Color(0xFF79697B),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE7E4E7),
);

final FColors _mauveDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF0C090C),
  foreground: const Color(0xFFFAFAFA),
  primary: const Color(0xFFE7E4E7),
  primaryForeground: const Color(0xFF1D161E),
  secondary: const Color(0xFF2A212C),
  secondaryForeground: const Color(0xFFFAFAFA),
  muted: const Color(0xFF2A212C),
  mutedForeground: const Color(0xFFA89EA9),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF1D161E),
  border: const Color(0x1AFFFFFF),
);

final FColors _oliveLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF0C0C09),
  primary: const Color(0xFF1D1D16),
  primaryForeground: const Color(0xFFFBFBF9),
  secondary: const Color(0xFFF4F4F0),
  secondaryForeground: const Color(0xFF1D1D16),
  muted: const Color(0xFFF4F4F0),
  mutedForeground: const Color(0xFF7C7C67),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE8E8E3),
);

final FColors _oliveDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF0C0C09),
  foreground: const Color(0xFFFBFBF9),
  primary: const Color(0xFFE8E8E3),
  primaryForeground: const Color(0xFF1D1D16),
  secondary: const Color(0xFF2B2B22),
  secondaryForeground: const Color(0xFFFBFBF9),
  muted: const Color(0xFF2B2B22),
  mutedForeground: const Color(0xFFABAB9C),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF1D1D16),
  border: const Color(0x1AFFFFFF),
);

final FColors _mistLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF090B0C),
  primary: const Color(0xFF161B1D),
  primaryForeground: const Color(0xFFF9FBFB),
  secondary: const Color(0xFFF1F3F3),
  secondaryForeground: const Color(0xFF161B1D),
  muted: const Color(0xFFF1F3F3),
  mutedForeground: const Color(0xFF67787C),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE3E7E8),
);

final FColors _mistDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF090B0C),
  foreground: const Color(0xFFF9FBFB),
  primary: const Color(0xFFE3E7E8),
  primaryForeground: const Color(0xFF161B1D),
  secondary: const Color(0xFF22292B),
  secondaryForeground: const Color(0xFFF9FBFB),
  muted: const Color(0xFF22292B),
  mutedForeground: const Color(0xFF9CA8AB),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF161B1D),
  border: const Color(0x1AFFFFFF),
);

final FColors _taupeLight = FColors(
  brightness: Brightness.light,
  systemOverlayStyle: .dark,
  barrier: const Color(0x33000000),
  background: const Color(0xFFFFFFFF),
  foreground: const Color(0xFF0C0A09),
  primary: const Color(0xFF1D1816),
  primaryForeground: const Color(0xFFFBFAF9),
  secondary: const Color(0xFFF3F1F1),
  secondaryForeground: const Color(0xFF1D1816),
  muted: const Color(0xFFF3F1F1),
  mutedForeground: const Color(0xFF7C6D67),
  destructive: const Color(0xFFE7000B),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFE7000B),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFFFFFFFF),
  border: const Color(0xFFE8E4E3),
);

final FColors _taupeDark = FColors(
  brightness: Brightness.dark,
  systemOverlayStyle: .light,
  barrier: const Color(0x7A000000),
  background: const Color(0xFF0C0A09),
  foreground: const Color(0xFFFBFAF9),
  primary: const Color(0xFFE8E4E3),
  primaryForeground: const Color(0xFF1D1816),
  secondary: const Color(0xFF2B2422),
  secondaryForeground: const Color(0xFFFBFAF9),
  muted: const Color(0xFF2B2422),
  mutedForeground: const Color(0xFFABA09C),
  destructive: const Color(0xFFFF6467),
  destructiveForeground: const Color(0xFFFAFAFA),
  error: const Color(0xFFFF6467),
  errorForeground: const Color(0xFFFAFAFA),
  card: const Color(0xFF1D1816),
  border: const Color(0x1AFFFFFF),
);
