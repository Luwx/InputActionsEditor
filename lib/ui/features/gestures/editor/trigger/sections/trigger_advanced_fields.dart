import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inherited_field_note.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerAdvancedFields extends HookConsumerWidget {
  const TriggerAdvancedFields({
    super.key,
    this.fields = TriggerAdvancedField.values,
    this.group,
    this.inherited = const {},
    this.inheritedConditions = const [],
    this.onOpenGroup,
  });

  final Iterable<TriggerAdvancedField> fields;

  /// When set, the fields read and write the group node's shared properties
  /// instead of the gesture in [EditLocationScope].
  final GestureGroupLocation? group;

  /// Properties this gesture picks up from an ancestor group, keyed by field.
  /// Rendered as a note under the corresponding control. Empty in group and
  /// bulk scope.
  final Map<TriggerAdvancedField, InheritedProperty> inherited;

  /// Conditions ancestor groups AND-merge into this node's own, outermost
  /// first. Shown read-only inside the conditions editor.
  final List<InheritedCondition> inheritedConditions;

  /// Opens the group an inherited property or condition came from, by editId.
  final ValueChanged<int>? onOpenGroup;

  /// Which of [TriggerAdvancedField] a group shares with its subtree.
  static Set<TriggerAdvancedField> nonDefaultGroupFields(GestureGroupNode g) =>
      {
        if (g.id != null) TriggerAdvancedField.id,
        if (g.threshold != null) TriggerAdvancedField.threshold,
        if (g.resumeTimeout != null) TriggerAdvancedField.resumeTimeout,
        if (g.accelerated != null) TriggerAdvancedField.accelerated,
        if (g.blockEvents != null) TriggerAdvancedField.blockEvents,
        if (g.clearModifiers != null) TriggerAdvancedField.clearModifiers,
        if (g.setLastTrigger != null) TriggerAdvancedField.setLastTrigger,
        if (g.conditions != null) TriggerAdvancedField.conditions,
        if (g.endConditions != null) TriggerAdvancedField.endConditions,
      };

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

    // One switch per field so gesture, bulk and group scopes render through
    // exactly the same controls below.
    final scope = group;
    SchemaEditableField<T> resolve<T>(
      GeneratedEditField<Config, GestureLocation, T, Lens<Config, T>> gestureF,
      GeneratedEditField<Config, GestureGroupLocation, T, Lens<Config, T>>
      groupF,
    ) => scope == null
        ? ref.gestureSchemaField(context, gestureF)
        : ref.schemaField(
            groupF,
            location: scope,
            scope: scope,
            canRead: (config) => gestureGroupAt(config, scope) != null,
          );

    final idField = resolve(gestureIdField, gestureGroupIdField);
    final thresholdField = resolve(
      gestureThresholdField,
      gestureGroupThresholdField,
    );
    final resumeTimeoutField = resolve(
      gestureResumeTimeoutField,
      gestureGroupResumeTimeoutField,
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
    final acceleratedField = resolve(
      gestureAcceleratedField,
      gestureGroupAcceleratedField,
    );
    final blockEventsField = resolve(
      gestureBlockEventsField,
      gestureGroupBlockEventsField,
    );
    final clearModifiersField = resolve(
      gestureClearModifiersField,
      gestureGroupClearModifiersField,
    );
    final setLastTriggerField = resolve(
      gestureSetLastTriggerField,
      gestureGroupSetLastTriggerField,
    );
    final conditionsField = resolve(
      gestureConditionsField,
      gestureGroupConditionsField,
    );
    final endConditionsField = resolve(
      gestureEndConditionsField,
      gestureGroupEndConditionsField,
    );

    /// What a checkbox should show.
    bool effective(TriggerAdvancedField field, bool own) {
      final note = inherited[field];
      if (note == null || note.setLocally) return own;
      return note.value is bool ? note.value! as bool : own;
    }

    /// Appends the inheritance note, when there is one, under [child].
    Widget withNote(TriggerAdvancedField field, Widget child) {
      final note = inherited[field];
      if (note == null) return child;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          InheritedFieldNote(
            inherited: note,
            onOpenGroup: onOpenGroup == null || note.groupEditId == null
                ? null
                : () => onOpenGroup!(note.groupEditId!),
          ),
        ],
      );
    }

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
                withNote(
                  TriggerAdvancedField.id,
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
                ),
              if (visibleFields.contains(TriggerAdvancedField.threshold))
                withNote(
                  TriggerAdvancedField.threshold,
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
                ),
              if (visibleFields.contains(TriggerAdvancedField.resumeTimeout))
                withNote(
                  TriggerAdvancedField.resumeTimeout,
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
                withNote(
                  TriggerAdvancedField.accelerated,
                  FCheckbox(
                    value: effective(
                      TriggerAdvancedField.accelerated,
                      acceleratedField.value,
                    ),
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
                ),
              if (visibleFields.contains(TriggerAdvancedField.blockEvents))
                withNote(
                  TriggerAdvancedField.blockEvents,
                  FCheckbox(
                    value: effective(
                      TriggerAdvancedField.blockEvents,
                      blockEventsField.value,
                    ),
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
                ),
              if (visibleFields.contains(TriggerAdvancedField.clearModifiers))
                withNote(
                  TriggerAdvancedField.clearModifiers,
                  FCheckbox(
                    value: effective(
                      TriggerAdvancedField.clearModifiers,
                      clearModifiersField.value,
                    ),
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
                ),
              if (visibleFields.contains(TriggerAdvancedField.setLastTrigger))
                withNote(
                  TriggerAdvancedField.setLastTrigger,
                  FCheckbox(
                    value: effective(
                      TriggerAdvancedField.setLastTrigger,
                      setLastTriggerField.value,
                    ),
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
                ),
            ],
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.conditions)) ...[
          withNote(
            TriggerAdvancedField.conditions,
            ConditionEditor.generic(
              condition: conditionsField.value,
              onConditionChanged: conditionsField.onChanged,
              title: l10n.triggerConditionsTitle,
              titleTooltipContent: const TriggerConditionsTooltip(),
              bodyBackgroundColor: conditionsBodyBackgroundColor,
              dirtyState: conditionsField.dirty,
              onRevert: conditionsField.onRevert,
              mixed: conditionsField.mixed,
              inherited: inheritedConditions,
              inheritedForGroup: scope != null,
              onOpenInheritedGroup: onOpenGroup == null
                  ? null
                  : (source) {
                      final editId = source.groupEditId;
                      if (editId != null) onOpenGroup!(editId);
                    },
            ),
          ),
        ],
        if (visibleFields.contains(TriggerAdvancedField.endConditions)) ...[
          withNote(
            TriggerAdvancedField.endConditions,
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
