import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/trigger_editor.dart';

class GestureEditorLayout extends ConsumerWidget {
  const GestureEditorLayout({
    required this.device,
    required this.sections,
    required this.common,
    required this.gestureIndex,
    super.key,
  });

  final DeviceType device;
  final List<Widget> sections;
  final TriggerCommon common;
  final int gestureIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAdvanced = TriggerAdvancedFields.hasNonDefaultFields(common);
    final gestureLocation = GestureLocation(
      device: device,
      index: gestureIndex,
    );
    final vm = ref.watch(gestureEditorProvider(gestureLocation));
    final notifier = ref.read(gestureEditorProvider(gestureLocation).notifier);
    return EditLocationScope(
      gesture: gestureLocation,
      child: Column(
        children: [
          TriggerEditor(
            sections: sections,
            hasAdvanced: hasAdvanced,
            common: common,
            onCommonChanged: notifier.replaceCommon,
            dirtyState: vm.triggerDirtyState,
            onRevert: vm.savedCommon == null
                ? null
                : () => notifier.revertTriggerConfig(common, vm.savedCommon!),
          ),
          const SizedBox(height: 16),
          const ActionListEditor(),
        ],
      ),
    );
  }
}
