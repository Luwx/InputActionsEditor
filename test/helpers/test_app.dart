import 'package:flutter/material.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/ui/common/animated_scrollbar.dart';

/// Wraps [child] in a [MaterialApp] that provides the app's localizations and
/// scroll behaviour, so widgets using `context.l10n` work in widget tests and
/// scrollables carry the same scrollbar grab zone they do in the app.
Widget testApp(Widget child) => MaterialApp(
  scrollBehavior: const AppScrollBehavior(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
