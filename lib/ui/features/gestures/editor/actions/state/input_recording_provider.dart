import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether an in-app input recorder (keyboard / mouse capture) is
/// currently active.
///
/// While a recorder is active the app's global input handlers must stand down
/// so the captured events are recorded instead of triggering app behavior:
///   * mouse back / forward navigation (the top-level `Listener` in `app.dart`)
///   * the gesture editor's undo / redo shortcuts (`gesture_editor.dart`)
///
/// A counter (rather than a bool) is used so overlapping recorders — e.g. two
/// [InputEntryEditor]s — don't clear the flag while another is still active.
class InputRecordingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void begin() => state = state + 1;
  void end() => state = state > 0 ? state - 1 : 0;
}

final inputRecordingProvider = NotifierProvider<InputRecordingNotifier, int>(
  InputRecordingNotifier.new,
);

/// Whether any in-app recorder is currently capturing input.
final isInputRecordingProvider = Provider<bool>(
  (ref) => ref.watch(inputRecordingProvider) > 0,
);
