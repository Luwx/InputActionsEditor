import 'dart:async' show unawaited;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_menu_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_navigation.dart';
import 'package:input_actions_editor/ui/shell/document_actions.dart';
import 'package:input_actions_editor/ui/shell/document_intents.dart';
import 'package:window_manager/window_manager.dart';

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

    bool hasConfig() => ref.read(configControllerProvider).value != null;

    GestureLocation? selectedGesture() =>
        ref.read(currentViewProvider) == AppView.gestures
        ? ref.read(selectedGestureProvider)
        : null;

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true):
            SaveAsIntent(),
        SingleActivator(LogicalKeyboardKey.keyN, control: true):
            NewDocumentIntent(),
        SingleActivator(LogicalKeyboardKey.keyO, control: true):
            OpenDocumentIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, control: true, shift: true):
            LoadFromClipboardIntent(),
        SingleActivator(LogicalKeyboardKey.keyC, control: true, alt: true):
            CopyToClipboardIntent(),
        SingleActivator(LogicalKeyboardKey.comma, control: true):
            OpenSettingsIntent(),
        SingleActivator(LogicalKeyboardKey.keyW, control: true):
            CloseWindowIntent(),
        SingleActivator(LogicalKeyboardKey.keyQ, control: true):
            CloseWindowIntent(),
        renameShortcut: RenameGestureIntent(),
        duplicateShortcut: DuplicateGestureIntent(),
        copyYamlShortcut: CopyGestureYamlIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
            StepGestureIntent(-1, yieldsToTextField: true),
        SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
            StepGestureIntent(1, yieldsToTextField: true),
        SingleActivator(LogicalKeyboardKey.tab, control: true):
            StepGestureIntent(1),
        SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true):
            StepGestureIntent(-1),
        SingleActivator(LogicalKeyboardKey.home): JumpGestureIntent(
          last: false,
          yieldsToTextField: true,
        ),
        SingleActivator(LogicalKeyboardKey.end): JumpGestureIntent(
          last: true,
          yieldsToTextField: true,
        ),
        SingleActivator(LogicalKeyboardKey.pageUp, control: true):
            StepDeviceIntent(-1),
        SingleActivator(LogicalKeyboardKey.pageDown, control: true):
            StepDeviceIntent(1),
        SingleActivator(LogicalKeyboardKey.home, control: true):
            JumpDeviceIntent(last: false, yieldsToTextField: true),
        SingleActivator(LogicalKeyboardKey.end, control: true):
            JumpDeviceIntent(last: true, yieldsToTextField: true),
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
          SaveAsIntent: CallbackAction<SaveAsIntent>(
            onInvoke: (_) {
              if (hasConfig()) unawaited(controller.saveAs());
              return null;
            },
          ),
          NewDocumentIntent: CallbackAction<NewDocumentIntent>(
            onInvoke: (_) {
              unawaited(newConfigDocument(context, ref));
              return null;
            },
          ),
          OpenDocumentIntent: CallbackAction<OpenDocumentIntent>(
            onInvoke: (_) {
              unawaited(loadConfigDocument(context, ref));
              return null;
            },
          ),
          LoadFromClipboardIntent: CallbackAction<LoadFromClipboardIntent>(
            onInvoke: (_) {
              unawaited(loadConfigFromClipboard(context, ref));
              return null;
            },
          ),
          CopyToClipboardIntent: CallbackAction<CopyToClipboardIntent>(
            onInvoke: (_) {
              if (hasConfig()) {
                unawaited(copyConfigToClipboard(context, controller));
              }
              return null;
            },
          ),
          OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
            onInvoke: (_) {
              context.openSettings();
              return null;
            },
          ),
          CloseWindowIntent: CallbackAction<CloseWindowIntent>(
            onInvoke: (_) {
              unawaited(windowManager.close());
              return null;
            },
          ),
          RenameGestureIntent: CallbackAction<RenameGestureIntent>(
            onInvoke: (_) {
              if (selectedGesture() case final location?) {
                unawaited(showGestureRenameDialog(context, ref, location));
              }
              return null;
            },
          ),
          DuplicateGestureIntent: CallbackAction<DuplicateGestureIntent>(
            onInvoke: (_) {
              if (selectedGesture() case final location?) {
                duplicateGestureAndSelect(context, ref, location);
              }
              return null;
            },
          ),
          StepGestureIntent: _NavigationAction<StepGestureIntent>(
            onInvoke: (intent) {
              stepGesture(context, ref, intent.delta);
              return null;
            },
          ),
          JumpGestureIntent: _NavigationAction<JumpGestureIntent>(
            onInvoke: (intent) {
              jumpToGesture(context, ref, last: intent.last);
              return null;
            },
          ),
          StepDeviceIntent: _NavigationAction<StepDeviceIntent>(
            onInvoke: (intent) {
              stepDeviceFilter(context, ref, intent.delta);
              return null;
            },
          ),
          JumpDeviceIntent: _NavigationAction<JumpDeviceIntent>(
            onInvoke: (intent) {
              jumpToDeviceFilter(context, ref, last: intent.last);
              return null;
            },
          ),
          CopyGestureYamlIntent: CallbackAction<CopyGestureYamlIntent>(
            onInvoke: (_) {
              final location = selectedGesture();
              if (location == null) return null;
              final gesture = ref.read(gestureEditorProvider(location)).gesture;
              if (gesture != null) {
                unawaited(copyGestureYaml(context, location, gesture));
              }
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

class _NavigationAction<T extends NavigationIntent> extends CallbackAction<T> {
  _NavigationAction({required super.onInvoke});

  // A disabled action leaves the key unhandled, so it keeps travelling up to
  // the text field's own shortcuts instead of being swallowed here.
  @override
  bool isEnabled(T intent) =>
      !intent.yieldsToTextField ||
      primaryFocus?.context?.findAncestorStateOfType<EditableTextState>() ==
          null;
}
