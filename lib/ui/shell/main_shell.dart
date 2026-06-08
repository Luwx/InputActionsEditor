import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
import 'package:input_actions_editor/ui/features/history/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';
import 'package:kwin_blur/kwin_blur.dart';

/// Persistent app shell: device sidebar + content area.
///
/// Kept alive in the widget tree (offstage behind the settings shell when
/// settings is open) so scroll position and other state survive view switches.
/// The [child] is the animated content surface MiniRouter supplies; this shell
/// only provides the surrounding chrome.
class MainShell extends HookConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // use the current mounted BuildContext.
    final contextRef = useRef(context)..value = context;

    useEffect(() {
      final windowSvc = ref.read(windowServiceProvider)
        ..onCloseRequested = () async {
          final controller = ref.read(configControllerProvider.notifier);
          if (!controller.isDirty) return true;

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

    final transparent = ref.watch(
      localSettingsProvider.select((s) => s.transparentSidebar),
    );
    return FScaffold(
      sidebar: Blurred(
        disabled: !transparent,
        expand: const EdgeInsets.only(right: 30),
        child: const DeviceSidebar(),
      ),
      childPad: false,
      child: transparent
          ? ColoredBox(
              color: context.theme.colors.background,
              child: child,
            )
          : child,
    );
  }
}
