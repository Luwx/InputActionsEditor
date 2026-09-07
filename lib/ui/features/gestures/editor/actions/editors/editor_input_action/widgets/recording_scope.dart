import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/input_recording_provider.dart';

/// Marks an in-app recorder as active for as long as it is mounted, so the
/// app's global input handlers (mouse back / forward navigation, undo / redo
/// shortcuts) stand down and let the captured events be recorded instead.
///
/// Also absorbs key events so stray keypresses during recording don't trigger
/// focused-widget behavior.
class RecordingScope extends HookConsumerWidget {
  const RecordingScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Deferred: hooks run effects during build, and Riverpod forbids
      // modifying a provider mid-build.
      final notifier = ref.read(inputRecordingProvider.notifier);
      scheduleMicrotask(notifier.begin);
      return () => scheduleMicrotask(notifier.end);
    }, const []);

    return Focus(
      autofocus: true,
      onKeyEvent: (_, _) => KeyEventResult.handled,
      child: child,
    );
  }
}
