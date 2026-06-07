import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerAdvancedFields extends ConsumerWidget {
  const TriggerAdvancedFields({
    super.key,
    this.fields = TriggerAdvancedField.values,
    this.topPadding = 16,
  });

  final Iterable<TriggerAdvancedField> fields;
  final double topPadding;

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
        if (topPadding > 0) SizedBox(height: topPadding),
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
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldIdLabel,
                      tooltipContent: const TriggerIdTooltip(),
                    ),
                  ),
                  control: FTextFieldControl.managed(
                    initial: idField.textEditingValue,
                    onChange: idField.onTextChanged,
                  ),
                  hint: l10n.triggerFieldIdHint,
                ),
              if (visibleFields.contains(TriggerAdvancedField.threshold))
                FTextField(
                  label: UnsavedLabel(
                    state: thresholdField.dirty,
                    onRevert: thresholdField.onRevert,
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
                    initial: thresholdField.textEditingValue,
                    onChange: thresholdField.onTextChanged,
                  ),
                  hint: l10n.triggerFieldThresholdHint,
                ),
              if (visibleFields.contains(TriggerAdvancedField.resumeTimeout))
                FTextField(
                  label: UnsavedLabel(
                    state: resumeTimeoutField.dirty,
                    onRevert: resumeTimeoutField.onRevert,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldResumeTimeoutLabel,
                      tooltipContent: const TriggerResumeTimeoutTooltip(),
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
        ],
        if (visibleFields.contains(TriggerAdvancedField.accelerated) ||
            visibleFields.contains(TriggerAdvancedField.blockEvents) ||
            visibleFields.contains(TriggerAdvancedField.clearModifiers) ||
            visibleFields.contains(TriggerAdvancedField.setLastTrigger)) ...[
          const SizedBox(height: 16),
          Column(
            spacing: 8,
            children: [
              if (visibleFields.contains(TriggerAdvancedField.accelerated))
                FCheckbox(
                  value: acceleratedField.value ?? false,
                  onChange: (v) => acceleratedField.onChanged(v ? true : null),
                  label: UnsavedLabel(
                    state: acceleratedField.dirty,
                    onRevert: acceleratedField.onRevert,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldAcceleratedLabel,
                      tooltipContent: const TriggerAcceleratedTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.blockEvents))
                FCheckbox(
                  value: blockEventsField.value ?? true,
                  onChange: (v) => blockEventsField.onChanged(v ? null : false),
                  label: UnsavedLabel(
                    state: blockEventsField.dirty,
                    onRevert: blockEventsField.onRevert,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldBlockEventsLabel,
                      tooltipContent: const TriggerBlockEventsTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.clearModifiers))
                FCheckbox(
                  value: clearModifiersField.value ?? false,
                  onChange: (v) =>
                      clearModifiersField.onChanged(v ? true : null),
                  label: UnsavedLabel(
                    state: clearModifiersField.dirty,
                    onRevert: clearModifiersField.onRevert,
                    child: LabelWithTooltip(
                      label: l10n.triggerFieldClearModifiersLabel,
                      tooltipContent: const TriggerClearModifiersTooltip(),
                    ),
                  ),
                ),
              if (visibleFields.contains(TriggerAdvancedField.setLastTrigger))
                FCheckbox(
                  value: setLastTriggerField.value ?? true,
                  onChange: (v) =>
                      setLastTriggerField.onChanged(v ? null : false),
                  label: UnsavedLabel(
                    state: setLastTriggerField.dirty,
                    onRevert: setLastTriggerField.onRevert,
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
          const SizedBox(height: 16),
          ConditionEditor.generic(
            condition: conditionsField.value,
            onConditionChanged: conditionsField.onChanged,
            title: l10n.triggerConditionsTitle,
            titleTooltipContent: const TriggerConditionsTooltip(),
            bodyBackgroundColor: conditionsBodyBackgroundColor,
            dirtyState: conditionsField.dirty,
            onRevert: conditionsField.onRevert,
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.endConditions)) ...[
          const SizedBox(height: 12),
          ConditionEditor.generic(
            title: l10n.triggerEndConditionsTitle,
            dirtyState: endConditionsField.dirty,
            onRevert: endConditionsField.onRevert,
            titleTooltipContent: const TriggerEndConditionsTooltip(),
            condition: endConditionsField.value,
            bodyBackgroundColor: conditionsBodyBackgroundColor,
            onConditionChanged: endConditionsField.onChanged,
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
