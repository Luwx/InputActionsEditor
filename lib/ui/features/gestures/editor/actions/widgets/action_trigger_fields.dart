import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart'
    show fieldErrorStyle;
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger_input_formatters.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/action_labels.dart';

class ActionTriggerFields extends HookConsumerWidget {
  const ActionTriggerFields({
    super.key,
    this.fields = ActionTriggerOptionField.values,
  });

  final Iterable<ActionTriggerOptionField> fields;

  static Set<ActionTriggerOptionField> nonDefaultFields(TriggerAction action) =>
      {
        if (action.action case InputAction(delay: final delay?) when delay != 0)
          ActionTriggerOptionField.inputDelay,
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
    printBuild(8, 'actionTriggerFields build');
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
    final triggerOnField = ref.actionSchemaField(context, actionTriggerOnField);
    final intervalField = ref.actionSchemaField(context, actionIntervalField);
    final thresholdField = ref.actionSchemaField(context, actionThresholdField);
    final limitField = ref.actionSchemaField(context, actionLimitField);
    final showDelay = visibleFields.contains(
      ActionTriggerOptionField.inputDelay,
    );
    final delayField = showDelay
        ? ref.actionSchemaField(context, actionInputDelayField)
        : null;
    final conflictingField = ref.actionField(
      context,
      actionConflictingLens,
      fallbackValue: () => true,
    );
    // The lists are const, so an unrelated edit reselects the same instance.
    final supportedOnValues = ref.watch(
      configControllerProvider.select((s) {
        final gesture = gestureAt(s.requireValue.draft, gestureLocation);
        return gesture == null
            ? kAllTriggerOnOptions
            : supportedTriggerOnOptions(
                gesture,
                conflicting: conflictingField.value,
              );
      }),
    );
    final defaultOn = actionTriggerOnField.defaultValue!;
    String onLabel(TriggerOn on) {
      final label = triggerOnLabel(on, context.l10n);
      return on == defaultOn
          ? context.l10n.actionTriggerOnDefaultOption(label)
          : label;
    }

    final triggerOnValue = triggerOnField.value;
    final displayOnValue = supportedOnValues.contains(triggerOnValue)
        ? triggerOnValue
        : defaultOn;
    final tooltipKind = ref.watch(
      configControllerProvider.select(
        (s) => _conflictingTooltipKind(
          gestureAt(s.requireValue.draft, gestureLocation),
        ),
      ),
    );
    final conditionsField = ref.actionField(
      context,
      actionConditionsLens,
      fallbackValue: () => null,
    );

    Widget revealable(ActionTriggerOptionField field, Widget child) =>
        RevealedField(field: field.dirtyField, child: child);

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
    final delayController = useSyncedTextController(
      delayField?.text ?? '',
      delayField?.onTextChanged ?? (_) {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (delayField != null)
          revealable(
            ActionTriggerOptionField.inputDelay,
            SizedBox(
              width: 180,
              child: FTextField(
                label: UnsavedLabel(
                  state: delayField.dirty,
                  onRevert: delayField.onRevert,
                  child: LabelWithTooltip(
                    label: context.l10n.inputDelayLabel,
                    tooltip: context.l10n.inputDelayTooltip,
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                control: FTextFieldControl.managed(controller: delayController),
                hint: '0',
              ),
            ),
          ),
        if (visibleFields.contains(ActionTriggerOptionField.triggerOn) ||
            (visibleFields.contains(ActionTriggerOptionField.interval) &&
                showInterval) ||
            (visibleFields.contains(ActionTriggerOptionField.threshold) &&
                showThreshold) ||
            visibleFields.contains(ActionTriggerOptionField.limit)) ...[
          if (delayField != null) const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (visibleFields.contains(ActionTriggerOptionField.triggerOn))
                revealable(
                  ActionTriggerOptionField.triggerOn,
                  SizedBox(
                    width: 180,
                    child: FSelect<TriggerOn>.rich(
                      label: UnsavedLabel(
                        state: triggerOnField.dirty,
                        onRevert: triggerOnField.onRevert,
                        child: LabelWithTooltip(
                          label: context.l10n.actionTriggerOnLabel,
                          tooltipContent: ActionTriggerOnTooltip(
                            stroke:
                                tooltipKind == ConflictingTooltipKind.stroke,
                          ),
                        ),
                      ),
                      key: ValueKey(displayOnValue),
                      format: onLabel,
                      enabled: supportedOnValues.length > 1,
                      contentConstraints: const FPortalConstraints(
                        maxWidth: 300,
                        maxHeight: 420,
                      ),
                      control: FSelectManagedControl<TriggerOn>(
                        initial: displayOnValue,
                        onChange: (value) {
                          if (value != null) {
                            ref
                                .read(
                                  actionEditorProvider(actionLocation).notifier,
                                )
                                .setTriggerOn(value);
                          }
                        },
                      ),
                      children: [
                        for (final on in kAllTriggerOnOptions)
                          if (supportedOnValues.contains(on))
                            FSelectItem(
                              value: on,
                              title: Text(onLabel(on)),
                              subtitle: Text(
                                triggerOnDescription(on, context.l10n),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              if (showInterval &&
                  visibleFields.contains(ActionTriggerOptionField.interval))
                revealable(
                  ActionTriggerOptionField.interval,
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
                      inputFormatters: intervalInputFormatters,
                      keyboardType: TextInputType.number,
                      control: FTextFieldControl.managed(
                        controller: intervalController,
                      ),
                      hint: context.l10n.actionIntervalHint,
                    ),
                  ),
                ),
              if (showThreshold &&
                  visibleFields.contains(ActionTriggerOptionField.threshold))
                revealable(
                  ActionTriggerOptionField.threshold,
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
                      inputFormatters: thresholdInputFormatters,
                      control: FTextFieldControl.managed(
                        controller: thresholdController,
                      ),
                      hint: context.l10n.triggerFieldThresholdHint,
                      error: isCompleteThreshold(thresholdField.text)
                          ? null
                          : Text(
                              context.l10n.triggerFieldThresholdInvalid,
                              style: fieldErrorStyle(context),
                            ),
                    ),
                  ),
                ),
              if (visibleFields.contains(ActionTriggerOptionField.limit))
                revealable(
                  ActionTriggerOptionField.limit,
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
                ),
            ],
          ),
        ],
        if (visibleFields.contains(ActionTriggerOptionField.conflicting)) ...[
          const SizedBox(height: 12),
          revealable(
            ActionTriggerOptionField.conflicting,
            FCheckbox(
              value: conflictingField.value,
              onChange: ref
                  .read(actionEditorProvider(actionLocation).notifier)
                  .setConflicting,
              description: Text(context.l10n.actionConflictingDescription),
              label: UnsavedLabel(
                state: conflictingField.dirty,
                onRevert: conflictingField.onRevert == null
                    ? null
                    : ref
                          .read(actionEditorProvider(actionLocation).notifier)
                          .revertConflicting,
                child: LabelWithTooltip(
                  label: context.l10n.actionConflictingLabel,
                  tooltipContent: ActionConflictingTooltip(kind: tooltipKind),
                ),
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
            revealField: ActionTriggerOptionField.conditions.dirtyField,
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

  /// Only applies to an input action.
  inputDelay,
}

extension ActionTriggerOptionFieldSchema on ActionTriggerOptionField {
  ConfigDirtyField get dirtyField => switch (this) {
    ActionTriggerOptionField.triggerOn => ConfigDirtyField.actionTriggerOn,
    ActionTriggerOptionField.interval => ConfigDirtyField.actionInterval,
    ActionTriggerOptionField.threshold => ConfigDirtyField.actionThreshold,
    ActionTriggerOptionField.limit => ConfigDirtyField.actionLimit,
    ActionTriggerOptionField.conflicting => ConfigDirtyField.actionConflicting,
    ActionTriggerOptionField.conditions => ConfigDirtyField.actionConditions,
    ActionTriggerOptionField.inputDelay => ConfigDirtyField.actionInputDelay,
  };
}

ConflictingTooltipKind _conflictingTooltipKind(Gesture? gesture) =>
    switch (gesture) {
      StrokeGesture() ||
      TouchpadStrokeGesture() ||
      TouchscreenStrokeGesture() => ConflictingTooltipKind.stroke,
      MouseGesture() => ConflictingTooltipKind.mouse,
      TouchpadGesture() ||
      TouchscreenGesture() => ConflictingTooltipKind.fingers,
      _ => ConflictingTooltipKind.other,
    };
