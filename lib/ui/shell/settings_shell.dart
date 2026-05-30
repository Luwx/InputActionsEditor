import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/settings/settings_list_section.dart';

/// Settings shell: settings sidebar + content area.
///
/// The [child] is the animated content surface MiniRouter supplies; this shell
/// only provides the sidebar chrome.
class SettingsShell extends StatelessWidget {
  const SettingsShell({required this.child, super.key});

  final Widget child;
  static const _sidebarWidth = 180.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          width: _sidebarWidth,
          child: SettingsListSection(),
        ),
        const VDivider(),
        Expanded(child: child),
      ],
    );
  }
}
