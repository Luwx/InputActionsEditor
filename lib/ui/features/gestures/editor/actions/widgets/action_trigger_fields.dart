import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ActionTriggerFields extends HookConsumerWidget {
  const ActionTriggerFields({
    super.key,
    this.fields = ActionTriggerOptionField.values,
  });

  final Iterable<ActionTriggerOptionField> fields;

  static const Map<String, TriggerOn> onOptions = {
    'begin': TriggerOn.begin,
    'update': TriggerOn.update,
    'end': TriggerOn.end,
    'cancel': TriggerOn.cancel,
    'end_cancel': TriggerOn.endCancel,
    'tick': TriggerOn.tick,
  };

  static Set<ActionTriggerOptionField> nonDefaultFields(TriggerAction action) =>
      {
        if (action.on != null) ActionTriggerOptionField.triggerOn,
        if (action.interval != null) ActionTriggerOptionField.interval,
        if (action.threshold != null) ActionTriggerOptionField.threshold,
        if (action.limit != null && action.limit != 0)
          ActionTriggerOptionField.limit,
        if (!action.conflicting) ActionTriggerOptionField.conflicting,
        if (action.conditions != null) ActionTriggerOptionField.conditions,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleFields = fields.toSet();
    if (visibleFields.isEmpty) return const SizedBox.shrink();

    final actionLocation = context.actionLocation;
    final gestureLocation = context.gestureLocation;
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
      fallbackValue: () => TriggerOn.end,
    );
    final intervalField = ref.actionSchemaField(context, actionIntervalField);
    final thresholdField = ref.actionSchemaField(context, actionThresholdField);
    final limitField = ref.actionSchemaField(context, actionLimitField);
    final conflictingField = ref.actionField(
      context,
      actionConflictingLens,
      fallbackValue: () => true,
    );
    final gesture = ref.watch(
      configControllerProvider.select(
        (s) => gestureAt(s.requireValue.draft, gestureLocation),
      ),
    );
    final supportedOnValues = gesture == null
        ? kAllTriggerOnOptions
        : supportedTriggerOnOptions(
            gesture,
            conflicting: conflictingField.value,
          );
    // The lens collapses unset to `end`, so the `end` item is the default.
    final supportedOnOptions = {
      for (final MapEntry(:key, :value) in onOptions.entries)
        if (supportedOnValues.contains(value))
          (value == TriggerOn.end
                  ? context.l10n.actionTriggerOnDefaultOption
                  : key):
              value,
    };
    final triggerOnValue = triggerOnField.value;
    final displayOnValue = supportedOnOptions.containsValue(triggerOnValue)
        ? triggerOnValue
        : TriggerOn.end;
    final conditionsField = ref.actionField(
      context,
      actionConditionsLens,
      fallbackValue: () => null,
    );

    final intervalController = useSyncedTextController(
      intervalField.text,
      intervalField.onTextChanged,
    );
    final thresholdController = useSyncedTextController(
      thresholdField.text,
      thresholdField.onTextChanged,
    );
    final limitController = useSyncedTextController(
      limitField.text,
      limitField.onTextChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (visibleFields.contains(ActionTriggerOptionField.triggerOn) ||
            (visibleFields.contains(ActionTriggerOptionField.interval) &&
                showInterval) ||
            (visibleFields.contains(ActionTriggerOptionField.threshold) &&
                showThreshold) ||
            visibleFields.contains(ActionTriggerOptionField.limit))
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (visibleFields.contains(ActionTriggerOptionField.triggerOn))
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
                    key: ValueKey(displayOnValue),
                    items: supportedOnOptions,
                    control: FSelectManagedControl<TriggerOn>(
                      initial: displayOnValue,
                      onChange: (value) {
                        if (value != null) triggerOnField.onChanged(value);
                      },
                    ),
                  ),
                ),
              if (showInterval &&
                  visibleFields.contains(ActionTriggerOptionField.interval))
                SizedBox(
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
                      controller: intervalController,
                    ),
                    hint: context.l10n.actionIntervalHint,
                  ),
                ),
              if (showThreshold &&
                  visibleFields.contains(ActionTriggerOptionField.threshold))
                SizedBox(
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
                      controller: thresholdController,
                    ),
                    hint: context.l10n.triggerFieldThresholdHint,
                  ),
                ),
              if (visibleFields.contains(ActionTriggerOptionField.limit))
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
                      controller: limitController,
                    ),
                    hint: context.l10n.actionLimitHint,
                  ),
                ),
            ],
          ),
        if (visibleFields.contains(ActionTriggerOptionField.conflicting)) ...[
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
        ],
        if (visibleFields.contains(ActionTriggerOptionField.conditions)) ...[
          const SizedBox(height: 16),
          ConditionEditor.generic(
            title: context.l10n.actionConditionsTitle,
            heroTag: actionLocation,
            dirtyState: conditionsField.dirty,
            onRevert: conditionsField.onRevert,
            titleTooltipContent: const ActionConditionsTooltip(),
            condition: conditionsField.value,
            onConditionChanged: conditionsField.onChanged,
          ),
        ],
      ],
    );
  }
}

enum ActionTriggerOptionField {
  triggerOn,
  interval,
  threshold,
  limit,
  conflicting,
  conditions,
}
