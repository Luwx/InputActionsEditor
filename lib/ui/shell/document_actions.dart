import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/clipboard_load_dialog.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

Future<void> newConfigDocument(BuildContext context, WidgetRef ref) async {
  final configController = ref.read(configControllerProvider.notifier);

  if (ref.read(configControllerProvider).value?.isDirty ?? false) {
    final action = await showUnsavedChangesDialog(context);
    if (action == null) return;
    if (action == UnsavedChangesAction.apply) {
      // A failed write must not be followed by throwing the document away.
      if (!await configController.save()) return;
    }
  }

  ref.read(navProvider.notifier).reset();
  configController.newConfig();
}

Future<void> loadConfigDocument(BuildContext context, WidgetRef ref) async {
  final configController = ref.read(configControllerProvider.notifier);

  if (ref.read(configControllerProvider).value?.isDirty ?? false) {
    final action = await showUnsavedChangesDialog(context);
    if (action == null) return;
    if (action == UnsavedChangesAction.apply) {
      // A failed write must not be followed by throwing the document away.
      if (!await configController.save()) return;
    }
  }

  await configController.loadFromPicker(
    onBeforeLoad: () => ref.read(navProvider.notifier).reset(),
  );
}

/// Throws away the session and reads the file on disk again.
Future<void> reloadConfigDocument(BuildContext context, WidgetRef ref) async {
  final configController = ref.read(configControllerProvider.notifier);

  if (ref.read(configControllerProvider).value?.isDirty ?? false) {
    final action = await showUnsavedChangesDialog(context);
    if (action == null) return;
    if (action == UnsavedChangesAction.apply) {
      // A failed write must not be followed by throwing the document away.
      if (!await configController.save()) return;
    }
  }

  ref.read(navProvider.notifier).reset();
  await configController.reload();
}

Future<void> loadConfigFromClipboard(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final configController = ref.read(configControllerProvider.notifier);
  final data = await Clipboard.getData(Clipboard.kTextPlain);
  final text = data?.text ?? '';

  if (!context.mounted) return;

  if (text.trim().isEmpty) {
    showFToast(
      context: context,
      title: Text(l10n.configLoadClipboardError),
      duration: const Duration(seconds: 3),
    );
    return;
  }

  final error = configController.validateConfigText(text);
  if (error != null) {
    showFToast(
      context: context,
      title: Text(l10n.configLoadClipboardError),
      suffixBuilder: (toastContext, entry) => FButton(
        variant: .ghost,
        size: .sm,
        onPress: () {
          entry.dismiss();
          unawaited(
            showFDialog<void>(
              context: context,
              builder: (ctx, style, animation) => AppDialog(
                style: style,
                animation: animation,
                constraints: const BoxConstraints(
                  minWidth: 280,
                  maxWidth: 480,
                ),
                title: Text(l10n.configLoadClipboardError),
                body: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SelectableText(error),
                ),
                actions: [
                  FButton(
                    onPress: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.actionClose),
                  ),
                ],
              ),
            ),
          );
        },
        child: Text(l10n.configLoadClipboardDetailsButton),
      ),
    );
    return;
  }

  final currentConfig = ref.read(configControllerProvider).value?.draft;
  final isEmpty = currentConfig == null || currentConfig.totalGestureCount == 0;
  final ClipboardLoadAction loadAction;
  if (isEmpty) {
    loadAction = ClipboardLoadAction.newConfig;
  } else {
    final dialogAction = await showClipboardLoadDialog(context);
    if (dialogAction == null) return;
    loadAction = dialogAction;
  }

  switch (loadAction) {
    case ClipboardLoadAction.newConfig:
      if (!context.mounted) return;
      if (ref.read(configControllerProvider).value?.isDirty ?? false) {
        final unsavedAction = await showUnsavedChangesDialog(context);
        if (unsavedAction == null) return;
        if (unsavedAction == UnsavedChangesAction.apply) {
          if (!await configController.save()) return;
        }
      }
      ref.read(navProvider.notifier).reset();
      configController.loadFromText(text);
    case ClipboardLoadAction.merge:
      configController.mergeFromText(text);
  }
}

/// Saves what the current view owns: in settings that is the settings slice
/// alone, so pending gesture edits stay unsaved.
Future<void> saveConfigDocument(BuildContext context, WidgetRef ref) async {
  final controller = ref.read(configControllerProvider.notifier);
  final l10n = context.l10n;
  final bool saved;
  if (ref.read(currentViewProvider) == AppView.settings) {
    if (!ref.read(settingsDirtyStateProvider).isDirty) return;
    saved = await controller.saveSettings();
  } else {
    if (!(ref.read(configControllerProvider).value?.isDirty ?? false)) return;
    saved = await controller.save();
  }
  if (!context.mounted) return;
  if (!saved) {
    showFToast(
      context: context,
      variant: .destructive,
      icon: const Icon(FLucideIcons.triangleAlert),
      title: Text(l10n.configSaveFailedTitle),
      description: Text('${ref.read(configSaveErrorProvider)}'),
      duration: const Duration(seconds: 8),
    );
    return;
  }
  showFToast(
    context: context,
    title: Text(l10n.configSaveSuccess),
    suffixBuilder: (context, entry) => FButton.icon(
      onPress: entry.dismiss,
      child: const Icon(FLucideIcons.x),
    ),
    duration: const Duration(seconds: 3),
  );
}

Future<void> copyConfigToClipboard(
  BuildContext context,
  ConfigController configController,
) async {
  final yaml = configController.configToYamlText();
  await Clipboard.setData(ClipboardData(text: yaml));
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(context.l10n.configCopyToClipboardSuccess),
    suffixBuilder: (context, entry) => FButton.icon(
      onPress: entry.dismiss,
      child: const Icon(FLucideIcons.x),
    ),
    duration: const Duration(seconds: 3),
  );
}
