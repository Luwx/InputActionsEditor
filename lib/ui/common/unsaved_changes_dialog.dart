import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

enum UnsavedChangesAction { apply, discard }

enum SaveScope { settings, gestures }

extension on SaveScope {
  DirtyMarkState dirtyState(WidgetRef ref) => switch (this) {
    SaveScope.settings => ref.watch(settingsDirtyStateProvider),
    SaveScope.gestures => ref.watch(gesturesDirtyStateProvider),
  };

  Future<void> save(ConfigController c) => switch (this) {
    SaveScope.settings => c.saveSettings(),
    SaveScope.gestures => c.saveGestures(),
  };

  void discard(ConfigController c) => switch (this) {
    SaveScope.settings => c.discardSettings(),
    SaveScope.gestures => c.discardGestures(),
  };
}

Future<UnsavedChangesAction?> showUnsavedChangesDialog(
  BuildContext context,
) async {
  return showFDialog<UnsavedChangesAction>(
    context: context,
    builder: (ctx, style, animation) => _UnsavedChangesDialog(
      style: style,
      animation: animation,
    ),
  );
}

class _UnsavedChangesDialog extends StatelessWidget {
  const _UnsavedChangesDialog({this.style, this.animation});

  final FDialogStyleDelta? style;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    return FDialog(
      style: style ?? const FDialogStyleDelta.context(),
      animation: animation,
      direction: .horizontal,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      title: const Text('Unsaved Changes'),
      body: const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'You have unsaved changes. Apply them or discard before leaving.',
        ),
      ),
      actions: [
        FButton(
          onPress: () => Navigator.of(context).pop(UnsavedChangesAction.apply),
          child: const Text('Apply'),
        ),
        FButton(
          variant: .outline,
          onPress: () =>
              Navigator.of(context).pop(UnsavedChangesAction.discard),
          child: const Text('Discard'),
        ),
        FButton(
          variant: .ghost,
          onPress: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class ApplyButton extends ConsumerWidget {
  const ApplyButton({required this.scope, super.key});

  final SaveScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDirty = scope.dirtyState(ref).isDirty;
    return FButton(
      variant: .outline,
      size: .sm,
      onPress: isDirty
          ? () => scope.save(ref.read(configControllerProvider.notifier))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          const Icon(FLucideIcons.save),
          Text(context.l10n.actionSave),
        ],
      ),
    );
  }
}

class DiscardButton extends ConsumerWidget {
  const DiscardButton({required this.scope, super.key});

  final SaveScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canRevert = scope.dirtyState(ref).canRevert;
    return FButton(
      variant: .ghost,
      size: .sm,
      onPress: canRevert
          ? () => scope.discard(ref.read(configControllerProvider.notifier))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          const Icon(FLucideIcons.undo2),
          Text(context.l10n.actionDiscardChanges),
        ],
      ),
    );
  }
}

class ScopedSaveActions extends StatelessWidget {
  const ScopedSaveActions({required this.scope, super.key});

  final SaveScope scope;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        // DiscardButton(scope: scope),
        ApplyButton(scope: scope),
      ],
    );
  }
}
