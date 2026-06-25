import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

/// Holds the KDE color scheme read synchronously before runApp.
/// Overridden in main.dart so _ThemedShell never flashes on the first frame.
final kdeColorSchemeInitialProvider = Provider<KdeColorScheme?>((ref) => null);

/// Emits the current KDE color scheme and re-emits whenever the user changes
/// it in KDE System Settings (inotify watches ~/.config/kdeglobals).
final kdeColorSchemeProvider = StreamProvider<KdeColorScheme>((ref) async* {
  final watcher = KdeColorSchemeWatcher();
  ref.onDispose(watcher.dispose);
  yield ref.read(kdeColorSchemeInitialProvider) ?? watcher.current;
  await for (final scheme in watcher.stream) {
    yield scheme;
  }
});

/// The effective KDE scheme: the live watcher value, falling back to the
/// synchronous initial and then [KdeColorScheme.fallback].
final resolvedKdeColorSchemeProvider = Provider<KdeColorScheme>((ref) {
  return ref.watch(kdeColorSchemeProvider).value ??
      ref.watch(kdeColorSchemeInitialProvider) ??
      KdeColorScheme.fallback;
});
