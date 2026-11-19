import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart'
    show fieldErrorStyle;
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger_input_formatters.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inheritable_field.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerAdvancedFields extends ConsumerWidget {
  const TriggerAdvancedFields({
    super.key,
    this.fields = TriggerAdvancedField.values,
    this.inheritedConditions = const [],
    this.lockPointer,
    this.speed,
  });

  final Iterable<TriggerAdvancedField> fields;

  /// Rendered among [fields], though not [TriggerAdvancedField]s.
  final Widget? lockPointer;
  final Widget? speed;

  /// Conditions ancestor groups AND-merge into this node's own, outermost
  /// first. Shown read-only inside the conditions editor.
  final List<InheritedCondition> inheritedConditions;

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
    final visible = fields.toSet().contains;
    if (fields.isEmpty && lockPointer == null && speed == null) {
      return const SizedBox.shrink();
    }
    final conditionsBodyBackgroundColor = Color.alphaBlend(
      context.theme.colors.card.withValues(alpha: 0.55),
      context.theme.colors.background,
    );

    Widget flag(
      GestureSchemaField<bool> field,
      GroupSchemaField<bool> groupField,
      String label,
      Widget tooltip,
    ) => InheritableField(
      field: field,
      groupField: groupField,
      builder: (context, field) => FCheckbox(
        value: field.value,
        onChange: field.onChanged,
        label: UnsavedLabel(
          state: field.dirty,
          onRevert: field.onRevert,
          mixed: field.mixed,
          child: LabelWithTooltip(label: label, tooltipContent: tooltip),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        if (visible(TriggerAdvancedField.id) ||
            visible(TriggerAdvancedField.threshold) ||
            visible(TriggerAdvancedField.resumeTimeout) ||
            speed != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              if (visible(TriggerAdvancedField.id))
                InheritableField(
                  field: gestureIdField,
                  groupField: gestureGroupIdField,
                  builder: (context, field) => _TextRow(
                    field: field,
                    label: LabelWithTooltip(
                      label: l10n.triggerFieldIdLabel,
                      tooltipContent: const TriggerIdTooltip(),
                    ),
                    hint: l10n.triggerFieldIdHint,
                  ),
                ),
              if (visible(TriggerAdvancedField.threshold) ||
                  visible(TriggerAdvancedField.resumeTimeout) ||
                  speed != null)
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (visible(TriggerAdvancedField.threshold))
                      SizedBox(
                        width: _fieldWidth,
                        child: InheritableField(
                          field: gestureThresholdField,
                          groupField: gestureGroupThresholdField,
                          builder: (context, field) => _TextRow(
                            field: field,
                            label: LabelWithTooltip(
                              label: l10n.triggerFieldThresholdLabel,
                              tooltipContent: const TriggerThresholdTooltip(),
                              textStyle: const TextStyle(
                                height: 1.4,
                                fontFamily: 'monospaced',
                              ),
                            ),
                            inputFormatters: thresholdInputFormatters,
                            hint: l10n.triggerFieldThresholdHint,
                            validate: (text) => isCompleteThreshold(text)
                                ? null
                                : l10n.triggerFieldThresholdInvalid,
                          ),
                        ),
                      ),
                    if (visible(TriggerAdvancedField.resumeTimeout))
                      SizedBox(
                        width: _fieldWidth,
                        child: InheritableField(
                          field: gestureResumeTimeoutField,
                          groupField: gestureGroupResumeTimeoutField,
                          builder: (context, field) => _TextRow(
                            field: field,
                            label: LabelWithTooltip(
                              label: l10n.triggerFieldResumeTimeoutLabel,
                              tooltipContent:
                                  const TriggerResumeTimeoutTooltip(),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            keyboardType: TextInputType.number,
                            hint: l10n.triggerFieldResumeTimeoutHint,
                          ),
                        ),
                      ),
                    if (speed case final speed?)
                      SizedBox(width: _fieldWidth, child: speed),
                  ],
                ),
            ],
          ),
        if (lockPointer != null ||
            visible(TriggerAdvancedField.accelerated) ||
            visible(TriggerAdvancedField.blockEvents) ||
            visible(TriggerAdvancedField.clearModifiers) ||
            visible(TriggerAdvancedField.setLastTrigger))
          Column(
            spacing: 8,
            children: [
              if (visible(TriggerAdvancedField.accelerated))
                flag(
                  gestureAcceleratedField,
                  gestureGroupAcceleratedField,
                  l10n.triggerFieldAcceleratedLabel,
                  const TriggerAcceleratedTooltip(),
                ),
              if (visible(TriggerAdvancedField.blockEvents))
                flag(
                  gestureBlockEventsField,
                  gestureGroupBlockEventsField,
                  l10n.triggerFieldBlockEventsLabel,
                  const TriggerBlockEventsTooltip(),
                ),
              if (visible(TriggerAdvancedField.clearModifiers))
                flag(
                  gestureClearModifiersField,
                  gestureGroupClearModifiersField,
                  l10n.triggerFieldClearModifiersLabel,
                  const TriggerClearModifiersTooltip(),
                ),
              if (visible(TriggerAdvancedField.setLastTrigger))
                flag(
                  gestureSetLastTriggerField,
                  gestureGroupSetLastTriggerField,
                  l10n.triggerFieldSetLastTriggerLabel,
                  const TriggerSetLastTriggerTooltip(),
                ),
              ?lockPointer,
            ],
          ),
        if (visible(TriggerAdvancedField.conditions))
          InheritableField(
            field: gestureConditionsField,
            groupField: gestureGroupConditionsField,
            reveal: false,
            builder: (context, field) => ConditionEditor.generic(
              condition: field.value,
              onConditionChanged: field.onChanged,
              title: l10n.triggerConditionsTitle,
              titleTooltipContent: const TriggerConditionsTooltip(),
              bodyBackgroundColor: conditionsBodyBackgroundColor,
              dirtyState: field.dirty,
              onRevert: field.onRevert,
              mixed: field.mixed,
              inherited: inheritedConditions,
              inheritedForGroup:
                  EditLocationScope.maybeOf(context)?.group != null,
              onOpenInheritedGroup: (source) {
                final editId = source.groupEditId;
                final device = EditLocationScope.deviceOf(context);
                if (editId == null || device == null) return;
                ref
                    .read(selectedGroupProvider.notifier)
                    .open(GestureGroupLocation(device: device, editId: editId));
              },
              revealField: field.dirtyField,
            ),
          ),
        if (visible(TriggerAdvancedField.endConditions))
          InheritableField(
            field: gestureEndConditionsField,
            groupField: gestureGroupEndConditionsField,
            reveal: false,
            builder: (context, field) => ConditionEditor.generic(
              title: l10n.triggerEndConditionsTitle,
              dirtyState: field.dirty,
              onRevert: field.onRevert,
              titleTooltipContent: const TriggerEndConditionsTooltip(),
              emptyMessage: l10n.triggerEndConditionsEmpty,
              condition: field.value,
              bodyBackgroundColor: conditionsBodyBackgroundColor,
              onConditionChanged: field.onChanged,
              mixed: field.mixed,
              revealField: field.dirtyField,
            ),
          ),
      ],
    );
  }
}

class _TextRow<T> extends HookWidget {
  const _TextRow({
    required this.field,
    required this.label,
    required this.hint,
    this.inputFormatters,
    this.keyboardType,
    this.validate,
  });

  final SchemaEditableField<T> field;
  final Widget label;
  final String hint;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String text)? validate;

  @override
  Widget build(BuildContext context) {
    final controller = useSyncedTextController(
      field.text,
      field.onTextChanged,
    );
    return FTextField(
      label: UnsavedLabel(
        state: field.dirty,
        onRevert: field.onRevert,
        mixed: field.mixed,
        child: label,
      ),
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      control: FTextFieldControl.managed(controller: controller),
      hint: hint,
      error: switch (validate?.call(field.text)) {
        final error? => Text(error, style: fieldErrorStyle(context)),
        null => null,
      },
    );
  }
}

/// Matches the action card's advanced options.
const double _fieldWidth = 180;

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

extension TriggerAdvancedFieldSchema on TriggerAdvancedField {
  ConfigDirtyField get dirtyField => switch (this) {
    TriggerAdvancedField.id => ConfigDirtyField.gestureId,
    TriggerAdvancedField.threshold => ConfigDirtyField.gestureThreshold,
    TriggerAdvancedField.resumeTimeout => ConfigDirtyField.gestureResumeTimeout,
    TriggerAdvancedField.accelerated => ConfigDirtyField.gestureAccelerated,
    TriggerAdvancedField.blockEvents => ConfigDirtyField.gestureBlockEvents,
    TriggerAdvancedField.clearModifiers =>
      ConfigDirtyField.gestureClearModifiers,
    TriggerAdvancedField.setLastTrigger =>
      ConfigDirtyField.gestureSetLastTrigger,
    TriggerAdvancedField.conditions => ConfigDirtyField.gestureConditions,
    TriggerAdvancedField.endConditions => ConfigDirtyField.gestureEndConditions,
  };

  ConfigDirtyField get groupDirtyField => switch (this) {
    TriggerAdvancedField.id => ConfigDirtyField.gestureGroupId,
    TriggerAdvancedField.threshold => ConfigDirtyField.gestureGroupThreshold,
    TriggerAdvancedField.resumeTimeout =>
      ConfigDirtyField.gestureGroupResumeTimeout,
    TriggerAdvancedField.accelerated =>
      ConfigDirtyField.gestureGroupAccelerated,
    TriggerAdvancedField.blockEvents =>
      ConfigDirtyField.gestureGroupBlockEvents,
    TriggerAdvancedField.clearModifiers =>
      ConfigDirtyField.gestureGroupClearModifiers,
    TriggerAdvancedField.setLastTrigger =>
      ConfigDirtyField.gestureGroupSetLastTrigger,
    TriggerAdvancedField.conditions => ConfigDirtyField.gestureGroupConditions,
    TriggerAdvancedField.endConditions =>
      ConfigDirtyField.gestureGroupEndConditions,
  };
}
