import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kde_color_scheme/kde_color_scheme.dart';

/// Emits the current KDE color scheme and re-emits whenever the user changes
/// it in KDE System Settings (inotify watches ~/.config/kdeglobals).
///
/// Immediately yields the synchronous read so the app never renders with an
/// unknown theme.
final kdeColorSchemeProvider = StreamProvider<KdeColorScheme>((ref) async* {
  final watcher = KdeColorSchemeWatcher();
  ref.onDispose(watcher.dispose);
  yield watcher.current;
  await for (final scheme in watcher.stream) {
    yield scheme;
  }
});
