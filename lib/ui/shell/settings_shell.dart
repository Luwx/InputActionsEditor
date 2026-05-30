import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/settings/settings_split_layout.dart';

/// Settings shell: settings sidebar + content area.
///
/// The [child] is the animated content surface MiniRouter supplies; this shell
/// only provides the sidebar chrome.
class SettingsShell extends StatelessWidget {
  const SettingsShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SettingsSplitLayout(child: child);
  }
}
