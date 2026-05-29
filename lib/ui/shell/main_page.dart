import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/config_controller.dart';
// import 'package:input_actions_editor/state/local_settings_provider.dart';
import 'package:input_actions_editor/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';
// import 'package:kde_blur/kde_blur.dart';
import 'package:scroll_animator/scroll_animator.dart';

/// The persistent app shell: device sidebar + the routed [child] content.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    // Initialize the DBus history listener immediately, before user visits tab.
    ref.read(recognitionHistoryProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(configControllerProvider);
    // final settings = ref.watch(localSettingsProvider);
    // final transparentSidebar = settings.transparentSidebar;

    // Column(
    //         children: [
    //           Expanded(
    //             child: Row(
    //               crossAxisAlignment: CrossAxisAlignment.stretch,
    //               children: [
    //                 Blurred(
    //                   disabled: !transparentSidebar,
    //                   color: context.theme.colors.background.withValues(
    //                     alpha: 0.7,
    //                   ),
    //                   child: const DeviceSidebar(),
    //                 ),
    //                 Expanded(child: widget.child),
    //               ],
    //             ),
    //           ),
    //           // Expanded(child: widget.child),
    //         ],
    //       )

    return AnimatedPrimaryScrollController(
      child: FScaffold(
        sidebar: const DeviceSidebar(),
        childPad: false,
        child: widget.child,
      ),
    );
  }
}
