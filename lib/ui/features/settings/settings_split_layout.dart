import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/settings/settings_list_section.dart';

class SettingsSplitLayout extends StatelessWidget {
  const SettingsSplitLayout({required this.child, super.key});

  static const _sidebarWidth = 180.0;
  final Widget child;

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
