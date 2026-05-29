import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_alt.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/trigger_editor.dart';

class GestureEditorLayout extends ConsumerWidget {
  const GestureEditorLayout({
    required this.device,
    required this.sections,
    required this.common,
    required this.onCommonChanged,
    required this.gestureIndex,
    super.key,
  });

  final DeviceType device;
  final List<Widget> sections;
  final TriggerCommon common;
  final void Function(TriggerCommon) onCommonChanged;
  final int gestureIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAdvanced = TriggerAdvancedFields.hasNonDefaultFields(common);
    final gestureLocation = GestureLocation(
      device: device,
      index: gestureIndex,
    );
    final actionsDirtyState = ref.watch(
      gestureSectionDirtyStateProvider(
        GestureSectionLocation(
          gesture: gestureLocation,
          field: GestureSectionDirtyField.actions,
        ),
      ),
    );
    final triggerDirtyState = ref.watch(
      gestureTriggerConfigDirtyStateProvider(gestureLocation),
    );
    final savedCommon = ref.watch(savedGestureCommonProvider(gestureLocation));
    return Column(
      children: [
        TriggerEditor(
          sections: sections,
          gestureIndex: gestureIndex,
          hasAdvanced: hasAdvanced,
          device: device,
          common: common,
          onCommonChanged: onCommonChanged,
          dirtyState: triggerDirtyState,
          onRevert: savedCommon == null
              ? null
              : () => onCommonChanged(
                  common.copyWith(
                    mouseButtons: savedCommon.mouseButtons,
                    mouseButtonsExactOrder: savedCommon.mouseButtonsExactOrder,
                    conditions: savedCommon.conditions,
                    id: savedCommon.id,
                    threshold: savedCommon.threshold,
                    resumeTimeout: savedCommon.resumeTimeout,
                    accelerated: savedCommon.accelerated,
                    blockEvents: savedCommon.blockEvents,
                    clearModifiers: savedCommon.clearModifiers,
                    setLastTrigger: savedCommon.setLastTrigger,
                    endConditions: savedCommon.endConditions,
                  ),
                ),
        ),
        const SizedBox(height: 16),
        ActionsEditorAlt(
          gestureLocation: gestureLocation,
          common: common,
          onCommonChanged: onCommonChanged,
          dirtyState: actionsDirtyState,
          onRevert: savedCommon == null
              ? null
              : () => onCommonChanged(
                  common.copyWith(actions: savedCommon.actions),
                ),
        ),
      ],
    );
  }
}
