import 'package:flutter/material.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';

/// Wraps [child] in a [MaterialApp] that provides the app's localizations,
/// so widgets using `context.l10n` work in widget tests.
Widget testApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
