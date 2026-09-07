import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';

/// The app's localizations and theme around [child]. Pass the scaffold in:
/// most of the app sits in an [FScaffold], but a widget under test that draws
/// its own surface wants a plain one, or none.
Widget themedApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: FTheme(data: AppThemes.zinc.dark.desktop, child: child),
);
