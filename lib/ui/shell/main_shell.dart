import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/navigation/nav_transition.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';
import 'package:input_actions_editor/ui/shell/nav_surface.dart';

/// Persistent app shell: device sidebar + animated content area.
///
/// Always kept alive in the widget tree (behind a settings overlay when
/// settings is open) so scroll position and other state survive view switches.
/// The child is wrapped in a [NavSurface] so content transitions
/// (gestures ↔ history) animate vertically while the sidebar stays fixed.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({required this.contentSpec, required this.child, super.key});

  final TransitionConfig contentSpec;
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
      child: NavSurface(
        spec: widget.contentSpec,
        child: widget.child,
      ),
    );
  }
}
