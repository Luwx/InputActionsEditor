import 'dart:async';

import 'package:background_blur_linux/background_blur_linux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/app_state/app/window_title_provider.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart'
    show kwinSupportedProvider;
import 'package:input_actions_editor/services/window_service.dart'
    show windowServiceProvider;
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/history/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/shell/application_menu.dart';
import 'package:input_actions_editor/ui/shell/config_gate.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';

/// Persistent app shell: device sidebar + content area.
class MainShell extends HookConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(0, 'mainShell build');
    // use the current mounted BuildContext.
    final contextRef = useRef(context)..value = context;

    useEffect(() {
      final windowSvc = ref.read(windowServiceProvider)
        ..onCloseRequested = () async {
          final controller = ref.read(configControllerProvider.notifier);
          if (!(ref.read(configControllerProvider).value?.isDirty ?? false)) {
            return true;
          }

          final ctx = contextRef.value;
          if (!ctx.mounted) return true;
          final action = await showUnsavedChangesDialog(ctx);
          if (action == null) return false;
          if (action == UnsavedChangesAction.apply) {
            await controller.save();
          } else {
            controller.discardChanges();
          }
          return true;
        };

      ref
        // warm the KWin support check so it's cached before the sidebar renders
        ..read(kwinSupportedProvider)
        // listens to dbus events and updates the history list
        ..read(recognitionHistoryProvider.notifier)
        // persists gesture filter, selected gesture, and divider width
        ..read(appStateControllerProvider.notifier)
        // update window title with '*'
        ..listenManual<String>(
          windowTitleProvider,
          (_, title) => unawaited(windowSvc.setTitle(title)),
          fireImmediately: true,
        );

      return () => windowSvc.onCloseRequested = null;
    }, const []);

    ref.listen(configLoadErrorProvider, (_, error) {
      if (error == null || !context.mounted) return;
      final l10n = context.l10n;
      showFToast(
        context: context,
        variant: .destructive,
        icon: const Icon(FLucideIcons.triangleAlert),
        title: Text(l10n.configLoadFailedTitle),
        description: Text('$error'),
        duration: const Duration(seconds: 8),
        suffixBuilder: (toastContext, entry) => FButton(
          size: .sm,
          onPress: () {
            entry.dismiss();
            unawaited(
              ref.read(configControllerProvider.notifier).reload(),
            );
          },
          suffix: const Icon(FLucideIcons.refreshCw, size: 12),
          child: Text(l10n.actionRetry),
        ),
      );
    });

    final transparent = ref.watch(
      localSettingsProvider.select((s) => s.transparentSidebar),
    );
    final gatedContent = ConfigGate(child: child);
    return ApplicationMenu(
      child: FScaffold(
        sidebar: Blurred(
          disabled: !transparent,
          expand: const EdgeInsets.only(right: 30),
          child: const DeviceSidebar(),
        ),
        childPad: false,
        child: transparent
            ? ColoredBox(
                color: context.theme.colors.background,
                child: gatedContent,
              )
            : gatedContent,
      ),
    );
  }
}
