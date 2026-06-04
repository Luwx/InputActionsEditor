import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerAdvancedFields extends ConsumerWidget {
  const TriggerAdvancedFields({
    required this.common,
    required this.onChanged,
    super.key,
  });

  final TriggerCommon common;
  final void Function(TriggerCommon) onChanged;

  static bool hasNonDefaultFields(TriggerCommon c) =>
      c.conditions != null ||
      c.id != null ||
      c.threshold != null ||
      c.resumeTimeout != null ||
      c.accelerated != null ||
      c.blockEvents != null ||
      c.clearModifiers != null ||
      c.setLastTrigger != null ||
      c.endConditions != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final conditionsBodyBackgroundColor = Color.alphaBlend(
      context.theme.colors.card.withValues(alpha: 0.55),
      context.theme.colors.background,
    );

    final idField = ref.gestureSchemaField(context, gestureIdField);
    final thresholdField = ref.gestureSchemaField(
      context,
      gestureThresholdField,
    );
    final resumeTimeoutField = ref.gestureSchemaField(
      context,
      gestureResumeTimeoutField,
    );
    final acceleratedField = ref.gestureSchemaField(
      context,
      gestureAcceleratedField,
    );
    final blockEventsField = ref.gestureSchemaField(
      context,
      gestureBlockEventsField,
    );
    final clearModifiersField = ref.gestureSchemaField(
      context,
      gestureClearModifiersField,
    );
    final setLastTriggerField = ref.gestureSchemaField(
      context,
      gestureSetLastTriggerField,
    );
    final conditionsField = ref.gestureSchemaField(
      context,
      gestureConditionsField,
    );
    final endConditionsField = ref.gestureSchemaField(
      context,
      gestureEndConditionsField,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Column(
          spacing: 12,
          children: [
            FTextField(
              label: UnsavedLabel(
                state: idField.dirty,
                onRevert: idField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldIdLabel,
                  tooltip: l10n.triggerFieldIdTooltip,
                ),
              ),
              control: FTextFieldControl.managed(
                initial: idField.textEditingValue,
                onChange: idField.onTextChanged,
              ),
              hint: l10n.triggerFieldIdHint,
            ),
            FTextField(
              label: UnsavedLabel(
                state: thresholdField.dirty,
                onRevert: thresholdField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldThresholdLabel,
                  tooltip: l10n.triggerFieldThresholdTooltip,
                  textStyle: const TextStyle(
                    height: 1.4,
                    fontFamily: 'monospaced',
                  ),
                ),
              ),
              control: FTextFieldControl.managed(
                initial: thresholdField.textEditingValue,
                onChange: thresholdField.onTextChanged,
              ),
              hint: l10n.triggerFieldThresholdHint,
            ),
            FTextField(
              label: UnsavedLabel(
                state: resumeTimeoutField.dirty,
                onRevert: resumeTimeoutField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldResumeTimeoutLabel,
                  tooltip: l10n.triggerFieldResumeTimeoutTooltip,
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              control: FTextFieldControl.managed(
                initial: resumeTimeoutField.textEditingValue,
                onChange: resumeTimeoutField.onTextChanged,
              ),
              hint: l10n.triggerFieldResumeTimeoutHint,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          spacing: 8,
          children: [
            FCheckbox(
              value: common.effectiveAccelerated,
              onChange: (v) => acceleratedField.onChanged(v ? true : null),
              label: UnsavedLabel(
                state: acceleratedField.dirty,
                onRevert: acceleratedField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldAcceleratedLabel,
                  tooltip: l10n.triggerFieldAcceleratedTooltip,
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveBlockEvents,
              onChange: (v) => blockEventsField.onChanged(v ? null : false),
              label: UnsavedLabel(
                state: blockEventsField.dirty,
                onRevert: blockEventsField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldBlockEventsLabel,
                  tooltip: l10n.triggerFieldBlockEventsTooltip,
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveClearModifiers,
              onChange: (v) => clearModifiersField.onChanged(v ? true : null),
              label: UnsavedLabel(
                state: clearModifiersField.dirty,
                onRevert: clearModifiersField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldClearModifiersLabel,
                  tooltip: l10n.triggerFieldClearModifiersTooltip,
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveSetLastTrigger,
              onChange: (v) => setLastTriggerField.onChanged(v ? null : false),
              label: UnsavedLabel(
                state: setLastTriggerField.dirty,
                onRevert: setLastTriggerField.onRevert,
                child: LabelWithTooltip(
                  label: l10n.triggerFieldSetLastTriggerLabel,
                  tooltip: l10n.triggerFieldSetLastTriggerTooltip,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConditionEditor.generic(
          condition: conditionsField.value,
          onConditionChanged: conditionsField.onChanged,
          title: l10n.triggerConditionsTitle,
          titleTooltip: l10n.triggerConditionsTooltip,
          bodyBackgroundColor: conditionsBodyBackgroundColor,
          dirtyState: conditionsField.dirty,
          onRevert: conditionsField.onRevert,
        ),
        const SizedBox(height: 12),
        ConditionEditor.generic(
          title: l10n.triggerEndConditionsTitle,
          dirtyState: endConditionsField.dirty,
          onRevert: endConditionsField.onRevert,
          titleTooltip: l10n.triggerEndConditionsTooltip,
          condition: endConditionsField.value,
          bodyBackgroundColor: conditionsBodyBackgroundColor,
          onConditionChanged: endConditionsField.onChanged,
        ),
      ],
    );
  }
}
