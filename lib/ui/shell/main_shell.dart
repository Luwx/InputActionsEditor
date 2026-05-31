import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/state/window_title_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';
import 'package:kwin_blur/kwin_blur.dart';
import 'package:window_manager/window_manager.dart';

/// Persistent app shell: device sidebar + content area.
///
/// Kept alive in the widget tree (offstage behind the settings shell when
/// settings is open) so scroll position and other state survive view switches.
/// The [child] is the animated content surface MiniRouter supplies; this shell
/// only provides the surrounding chrome.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    ref
      // listens to dbus events and updates the history list
      ..read(recognitionHistoryProvider.notifier)
      // update window title with '*'
      ..listenManual<String>(
        windowTitleProvider,
        (_, title) => unawaited(windowManager.setTitle(title)),
        fireImmediately: true,
      );
  }

  @override
  Widget build(BuildContext context) {
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
              child: widget.child,
            )
          : widget.child,
    );
  }
}
