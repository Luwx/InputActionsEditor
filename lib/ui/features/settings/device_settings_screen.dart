import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';

class DeviceSettingsScreen extends ConsumerWidget {
  const DeviceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch<DeviceSettingsSection>(
      deviceSettingsSectionProvider,
    );
    final colors = context.theme.colors;

    return ColoredBox(
      color: colors.background,
      child: DeviceConfigEditor(section: section),
    );
  }
}
