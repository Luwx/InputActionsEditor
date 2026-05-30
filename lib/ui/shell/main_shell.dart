import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';

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
    ref.read(recognitionHistoryProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(configControllerProvider);

    return FScaffold(
      sidebar: const DeviceSidebar(),
      childPad: false,
      child: widget.child,
    );
  }
}
