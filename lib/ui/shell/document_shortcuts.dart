import 'dart:async' show unawaited;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/shell/document_actions.dart';
import 'package:input_actions_editor/ui/shell/document_intents.dart';

/// Binds the document keys once for the whole app. Undo takes the newest step
/// of any scope, except in settings, which unwinds only its own. An editor
/// wanting its own scope registers [Actions] for the same intents nearer the
/// focus, which are found first.
class DocumentShortcuts extends ConsumerWidget {
  const DocumentShortcuts({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(configControllerProvider.notifier);
    // Which branch is on screen, not what holds focus: the branches live in an
    // indexed stack, so focus stays behind in the one you just left.
    final scope = ref.watch(currentViewProvider) == AppView.settings
        ? const SettingsScope()
        : const GesturesScope();
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          UndoIntent: CallbackAction<UndoIntent>(
            onInvoke: (_) {
              controller.undo(scope: scope);
              return null;
            },
          ),
          RedoIntent: CallbackAction<RedoIntent>(
            onInvoke: (_) {
              controller.redo(scope: scope);
              return null;
            },
          ),
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (_) {
              unawaited(saveConfigDocument(context, ref));
              return null;
            },
          ),
        },
        // A field letting go of the focus hands it to the nearest scope.
        // Without one here that is the route's, above these keys, and they
        // stop working until something inside is clicked.
        child: FocusScope(child: child),
      ),
    );
  }
}
