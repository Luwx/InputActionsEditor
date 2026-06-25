import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerAdvancedFields extends HookConsumerWidget {
  const TriggerAdvancedFields({
    super.key,
    this.fields = TriggerAdvancedField.values,
  });

  final Iterable<TriggerAdvancedField> fields;

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

  static Set<TriggerAdvancedField> nonDefaultFields(TriggerCommon c) => {
    if (c.id != null) TriggerAdvancedField.id,
    if (c.threshold != null) TriggerAdvancedField.threshold,
    if (c.resumeTimeout != null) TriggerAdvancedField.resumeTimeout,
    if (c.accelerated != null) TriggerAdvancedField.accelerated,
    if (c.blockEvents != null) TriggerAdvancedField.blockEvents,
    if (c.clearModifiers != null) TriggerAdvancedField.clearModifiers,
    if (c.setLastTrigger != null) TriggerAdvancedField.setLastTrigger,
    if (c.conditions != null) TriggerAdvancedField.conditions,
    if (c.endConditions != null) TriggerAdvancedField.endConditions,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final visibleFields = fields.toSet();
    if (visibleFields.isEmpty) return const SizedBox.shrink();

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
    final idController = useSyncedTextController(
      idField.text,
      idField.onTextChanged,
    );
    final thresholdController = useSyncedTextController(
      thresholdField.text,
      thresholdField.onTextChanged,
    );
    final resumeTimeoutController = useSyncedTextController(
      resumeTimeoutField.text,
      resumeTimeoutField.onTextChanged,
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
      spacing: 16,
      children: [
        if (visibleFields.contains(TriggerAdvancedField.id) ||
            visibleFields.contains(TriggerAdvancedField.threshold) ||
            visibleFields.contains(TriggerAdvancedField.resumeTimeout)) ...[
          Column(
            spacing: 12,
            children: [
              if (visibleFields.contains(TriggerAdvancedField.id))
                FTextField(
                  label: UnsavedLabel(
                    state: idField.dirty,
                    onRevert: idField.onRevert,
                    mixed: idField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldIdLabel,
                      tooltipContent: const TriggerIdTooltip(),
                    ),
                  ),
                  control: FTextFieldControl.managed(
                    controller: idController,
                  ),
                  hint: l10n.triggerFieldIdHint,
                ),
              if (visibleFields.contains(TriggerAdvancedField.threshold))
                FTextField(
                  label: UnsavedLabel(
                    state: thresholdField.dirty,
                    onRevert: thresholdField.onRevert,
                    mixed: thresholdField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldThresholdLabel,
                      tooltipContent: const TriggerThresholdTooltip(),
                      textStyle: const TextStyle(
                        height: 1.4,
                        fontFamily: 'monospaced',
                      ),
                    ),
                  ),
                  control: FTextFieldControl.managed(
                    controller: thresholdController,
                  ),
                  hint: l10n.triggerFieldThresholdHint,
                ),
              if (visibleFields.contains(TriggerAdvancedField.resumeTimeout))
                FTextField(
                  label: UnsavedLabel(
                    state: resumeTimeoutField.dirty,
                    onRevert: resumeTimeoutField.onRevert,
                    mixed: resumeTimeoutField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldResumeTimeoutLabel,
                      tooltipContent: const TriggerResumeTimeoutTooltip(),
                    ),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  control: FTextFieldControl.managed(
                    controller: resumeTimeoutController,
                  ),
                  hint: l10n.triggerFieldResumeTimeoutHint,
                ),
            ],
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.accelerated) ||
            visibleFields.contains(TriggerAdvancedField.blockEvents) ||
            visibleFields.contains(TriggerAdvancedField.clearModifiers) ||
            visibleFields.contains(TriggerAdvancedField.setLastTrigger)) ...[
          Column(
            spacing: 8,
            children: [
              if (visibleFields.contains(TriggerAdvancedField.accelerated))
                FCheckbox(
                  value: acceleratedField.value,
                  onChange: acceleratedField.onChanged,
                  label: UnsavedLabel(
                    state: acceleratedField.dirty,
                    onRevert: acceleratedField.onRevert,
                    mixed: acceleratedField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldAcceleratedLabel,
                      tooltipContent: const TriggerAcceleratedTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.blockEvents))
                FCheckbox(
                  value: blockEventsField.value,
                  onChange: blockEventsField.onChanged,
                  label: UnsavedLabel(
                    state: blockEventsField.dirty,
                    onRevert: blockEventsField.onRevert,
                    mixed: blockEventsField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldBlockEventsLabel,
                      tooltipContent: const TriggerBlockEventsTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.clearModifiers))
                FCheckbox(
                  value: clearModifiersField.value,
                  onChange: clearModifiersField.onChanged,
                  label: UnsavedLabel(
                    state: clearModifiersField.dirty,
                    onRevert: clearModifiersField.onRevert,
                    mixed: clearModifiersField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldClearModifiersLabel,
                      tooltipContent: const TriggerClearModifiersTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.setLastTrigger))
                FCheckbox(
                  value: setLastTriggerField.value,
                  onChange: setLastTriggerField.onChanged,
                  label: UnsavedLabel(
                    state: setLastTriggerField.dirty,
                    onRevert: setLastTriggerField.onRevert,
                    mixed: setLastTriggerField.mixed,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldSetLastTriggerLabel,
                      tooltipContent: const TriggerSetLastTriggerTooltip(),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.conditions)) ...[
          ConditionEditor.generic(
            condition: conditionsField.value,
            onConditionChanged: conditionsField.onChanged,
            title: l10n.triggerConditionsTitle,
            titleTooltipContent: const TriggerConditionsTooltip(),
            bodyBackgroundColor: conditionsBodyBackgroundColor,
            dirtyState: conditionsField.dirty,
            onRevert: conditionsField.onRevert,
            mixed: conditionsField.mixed,
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.endConditions)) ...[
          ConditionEditor.generic(
            title: l10n.triggerEndConditionsTitle,
            dirtyState: endConditionsField.dirty,
            onRevert: endConditionsField.onRevert,
            titleTooltipContent: const TriggerEndConditionsTooltip(),
            condition: endConditionsField.value,
            bodyBackgroundColor: conditionsBodyBackgroundColor,
            onConditionChanged: endConditionsField.onChanged,
            mixed: endConditionsField.mixed,
          ),
        ],
      ],
    );
  }
}

enum TriggerAdvancedField {
  id,
  threshold,
  resumeTimeout,
  accelerated,
  blockEvents,
  clearModifiers,
  setLastTrigger,
  conditions,
  endConditions,
}
