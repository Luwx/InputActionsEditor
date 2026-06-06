import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ActionTriggerFields extends ConsumerWidget {
  const ActionTriggerFields({super.key});

  static const Map<String, TriggerOn> onOptions = {
    'begin': TriggerOn.begin,
    'update': TriggerOn.update,
    'end': TriggerOn.end,
    'cancel': TriggerOn.cancel,
    'end_cancel': TriggerOn.endCancel,
    'tick': TriggerOn.tick,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLocation = context.actionLocation;
    final (:showInterval, :showThreshold) = ref.watch(
      actionEditorProvider(actionLocation).select(
        (vm) => (
          showInterval: vm.showInterval,
          showThreshold: vm.showThreshold,
        ),
      ),
    );
    final triggerOnField = ref.actionField(
      context,
      actionTriggerOnLens,
      fallbackValue: () => null,
    );
    final limitField = ref.actionSchemaField(
      context,
      actionLimitField,
    );
    final conflictingField = ref.actionField(
      context,
      actionConflictingLens,
      fallbackValue: () => true,
    );
    final conditionsField = ref.actionField(
      context,
      actionConditionsLens,
      fallbackValue: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            SizedBox(
              width: 180,
              child: FSelect<TriggerOn>(
                label: UnsavedLabel(
                  state: triggerOnField.dirty,
                  onRevert: triggerOnField.onRevert,
                  child: LabelWithTooltip(
                    label: context.l10n.actionTriggerOnLabel,
                    tooltipContent: const ActionTriggerOnTooltip(),
                  ),
                ),
                key: ValueKey(triggerOnField.value),
                items: onOptions,
                control: FSelectManagedControl<TriggerOn>(
                  initial: triggerOnField.value,
                  onChange: (value) {
                    if (value != null) triggerOnField.onChanged(value);
                  },
                ),
              ),
            ),
            if (showInterval)
              Builder(
                builder: (context) {
                  final intervalField = ref.actionSchemaField(
                    context,
                    actionIntervalField,
                  );
                  return SizedBox(
                    width: 180,
                    child: FTextField(
                      label: UnsavedLabel(
                        state: intervalField.dirty,
                        onRevert: intervalField.onRevert,
                        child: LabelWithTooltip(
                          label: context.l10n.actionIntervalLabel,
                          tooltipContent: const ActionIntervalTooltip(),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      control: FTextFieldControl.managed(
                        initial: intervalField.textEditingValue,
                        onChange: intervalField.onTextChanged,
                      ),
                      hint: context.l10n.actionIntervalHint,
                    ),
                  );
                },
              ),
            if (showThreshold)
              Builder(
                builder: (context) {
                  final thresholdField = ref.actionSchemaField(
                    context,
                    actionThresholdField,
                  );
                  return SizedBox(
                    width: 180,
                    child: FTextField(
                      label: UnsavedLabel(
                        state: thresholdField.dirty,
                        onRevert: thresholdField.onRevert,
                        child: LabelWithTooltip(
                          label: context.l10n.actionThresholdLabel,
                          tooltipContent: const ActionThresholdTooltip(),
                        ),
                      ),
                      control: FTextFieldControl.managed(
                        initial: thresholdField.textEditingValue,
                        onChange: thresholdField.onTextChanged,
                      ),
                      hint: context.l10n.triggerFieldThresholdHint,
                    ),
                  );
                },
              ),
            SizedBox(
              width: 180,
              child: FTextField(
                label: UnsavedLabel(
                  state: limitField.dirty,
                  onRevert: limitField.onRevert,
                  child: LabelWithTooltip(
                    label: context.l10n.actionLimitLabel,
                    tooltipContent: const ActionLimitTooltip(),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                control: FTextFieldControl.managed(
                  initial: limitField.textEditingValue,
                  onChange: limitField.onTextChanged,
                ),
                hint: context.l10n.actionLimitHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FCheckbox(
          value: conflictingField.value,
          onChange: conflictingField.onChanged,
          label: UnsavedLabel(
            state: conflictingField.dirty,
            onRevert: conflictingField.onRevert,
            child: LabelWithTooltip(
              label: context.l10n.actionConflictingLabel,
              tooltipContent: const ActionConflictingTooltip(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConditionEditor.generic(
          title: context.l10n.actionConditionsTitle,
          dirtyState: conditionsField.dirty,
          onRevert: conditionsField.onRevert,
          titleTooltipContent: const ActionConditionsTooltip(),
          condition: conditionsField.value,
          onConditionChanged: conditionsField.onChanged,
        ),
      ],
    );
  }
}
