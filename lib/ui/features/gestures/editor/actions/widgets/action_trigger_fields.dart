import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/dirty/dirty_semantics.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

class ActionTriggerFields extends ConsumerWidget {
  const ActionTriggerFields({
    required this.actionLocation,
    required this.triggerAction,
    required this.onChanged,
    super.key,
  });

  final ActionLocation actionLocation;
  final TriggerAction triggerAction;
  final void Function(TriggerAction) onChanged;

  static const Map<String, TriggerOn> onOptions = {
    'begin': TriggerOn.begin,
    'update': TriggerOn.update,
    'end': TriggerOn.end,
    'cancel': TriggerOn.cancel,
    'end_cancel': TriggerOn.endCancel,
    'tick': TriggerOn.tick,
  };

  static bool hasNonDefaultFields(TriggerAction t) =>
      t.on != null ||
      t.conditions != null ||
      t.interval != null ||
      t.threshold != null ||
      (t.limit != null && t.limit != 0) ||
      !t.conflicting;

  bool get _showInterval =>
      triggerAction.on == TriggerOn.update ||
      triggerAction.on == TriggerOn.tick;

  bool get _showThreshold =>
      triggerAction.on != null && triggerAction.on != TriggerOn.begin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAction = ref.watch(savedActionProvider(actionLocation));
    VoidCallback? revertField(ActionDirtyField field) => savedAction == null
        ? null
        : () => onChanged(
            restoreSavedTriggerActionField(
              current: triggerAction,
              saved: savedAction,
              field: field,
            ),
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
                  state: ref.watch(
                    actionFieldDirtyStateProvider(
                      ActionDirtyLocation(
                        action: actionLocation,
                        field: ActionDirtyField.triggerOn,
                      ),
                    ),
                  ),
                  onRevert: revertField(ActionDirtyField.triggerOn),
                  child: const LabelWithTooltip(
                    label: 'Trigger on',
                    tooltip:
                        'When during the gesture lifecycle this action fires.'
                        '\n\n'
                        '  begin      - as soon as the gesture is recognized\n'
                        '               (e.g. immediately play a sound or\n'
                        '               start holding a key)\n'
                        '  update     - every time input moves while active\n'
                        '               (e.g. scroll content while swiping)\n'
                        '  end        - when the gesture completes normally\n'
                        '               (default; e.g. open a tab on stroke)\n'
                        '  cancel     - if the gesture is aborted\n'
                        '               (e.g. restore state on failed swipe)\n'
                        '  end_cancel - on both end AND cancel\n'
                        '               (e.g. always release a held key)\n'
                        '  tick       - at fixed time intervals while active,'
                        '\n'
                        '               regardless of movement\n'
                        '               (e.g. auto-repeat a key every 500 ms)',
                  ),
                ),
                key: ValueKey(triggerAction.on),
                items: onOptions,
                control: FSelectManagedControl<TriggerOn>(
                  initial: triggerAction.on,
                  onChange: (value) {
                    if (value != null) {
                      onChanged(triggerAction.copyWith(on: value));
                    }
                  },
                ),
              ),
            ),
            if (_showInterval)
              SizedBox(
                width: 180,
                child: FTextField(
                  label: UnsavedLabel(
                    state: ref.watch(
                      actionFieldDirtyStateProvider(
                        ActionDirtyLocation(
                          action: actionLocation,
                          field: ActionDirtyField.interval,
                        ),
                      ),
                    ),
                    onRevert: revertField(ActionDirtyField.interval),
                    child: const LabelWithTooltip(
                      label: 'Interval',
                      tooltip:
                          'Controls how often the action repeats for '
                          'on:update and on:tick.\n\n'
                          '  empty / 0  - every input event or tick\n'
                          '  +          - only while delta is increasing\n'
                          '               (positive direction)\n'
                          '  -          - only while delta is decreasing\n'
                          '               (negative direction)\n'
                          '  number     - once per N units of accumulated '
                          'delta\n\n'
                          'Example: interval:4 on a wheel action fires every '
                          '4 scroll ticks instead of every single tick.',
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(
                      text: triggerAction.interval ?? '',
                    ),
                    onChange: (value) => onChanged(
                      triggerAction.copyWith(
                        interval: value.text.isEmpty ? null : value.text,
                      ),
                    ),
                  ),
                  hint: '+, -, or number',
                ),
              ),
            if (_showThreshold)
              SizedBox(
                width: 180,
                child: FTextField(
                  label: UnsavedLabel(
                    state: ref.watch(
                      actionFieldDirtyStateProvider(
                        ActionDirtyLocation(
                          action: actionLocation,
                          field: ActionDirtyField.threshold,
                        ),
                      ),
                    ),
                    onRevert: revertField(ActionDirtyField.threshold),
                    child: const LabelWithTooltip(
                      label: 'Threshold',
                      tooltip:
                          'Accumulated movement since the gesture began '
                          'before this action fires.\n\n'
                          'Same units as the trigger threshold:\n'
                          '  Swipe / stroke  - pixels\n'
                          '  Wheel           - scroll ticks\n'
                          '  Pinch           - scale factor (0.1 = 10%)\n'
                          '  Rotate / circle - degrees\n\n'
                          'Unlike the trigger Threshold (which gates '
                          'recognition), this gates only this action after '
                          'the gesture is already active.\n\n'
                          'Use a range like 50-200 to fire only within '
                          'that window of movement.',
                    ),
                  ),
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(
                      text: triggerAction.threshold ?? '',
                    ),
                    onChange: (value) => onChanged(
                      triggerAction.copyWith(
                        threshold: value.text.isEmpty ? null : value.text,
                      ),
                    ),
                  ),
                  hint: 'e.g. 100 or 50-200',
                ),
              ),
            SizedBox(
              width: 180,
              child: FTextField(
                label: UnsavedLabel(
                  state: ref.watch(
                    actionFieldDirtyStateProvider(
                      ActionDirtyLocation(
                        action: actionLocation,
                        field: ActionDirtyField.limit,
                      ),
                    ),
                  ),
                  onRevert: revertField(ActionDirtyField.limit),
                  child: const LabelWithTooltip(
                    label: 'Limit',
                    tooltip:
                        'Maximum times this action can fire during a single '
                        'gesture activation. 0 = unlimited.\n\n'
                        'Example: limit:1 with on:update fires the action '
                        'exactly once no matter how far the gesture travels.',
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                control: FTextFieldControl.managed(
                  initial: TextEditingValue(
                    text: triggerAction.limit?.toString() ?? '',
                  ),
                  onChange: (value) => onChanged(
                    triggerAction.copyWith(
                      limit: value.text.isEmpty
                          ? null
                          : int.tryParse(value.text),
                    ),
                  ),
                ),
                hint: '0 = unlimited',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FCheckbox(
          value: triggerAction.conflicting,
          onChange: (value) =>
              onChanged(triggerAction.copyWith(conflicting: value)),
          label: UnsavedLabel(
            state: ref.watch(
              actionFieldDirtyStateProvider(
                ActionDirtyLocation(
                  action: actionLocation,
                  field: ActionDirtyField.conflicting,
                ),
              ),
            ),
            onRevert: revertField(ActionDirtyField.conflicting),
            child: const LabelWithTooltip(
              label: 'Conflicting',
              tooltip:
                  'Whether this action participates in conflict resolution.\n\n'
                  'When two gestures could both match the same input (e.g. '
                  'a 2-finger swipe and a 3-finger swipe that starts the '
                  'same way), the daemon waits to see which one completes.\n\n'
                  '  On  (default) - this action holds back competing '
                  'gestures until one wins.\n'
                  '  Off - this action fires immediately without blocking '
                  'or being blocked by others.',
            ),
          ),
        ),
        const SizedBox(height: 16),
        ConditionEditor.generic(
          title: 'Action Conditions',
          dirtyState: ref.watch(
            actionFieldDirtyStateProvider(
              ActionDirtyLocation(
                action: actionLocation,
                field: ActionDirtyField.conditions,
              ),
            ),
          ),
          onRevert: revertField(ActionDirtyField.conditions),
          titleTooltip:
              'Conditions checked just before this action executes.\n'
              'The gesture fires regardless; only this action is skipped '
              'when conditions are not met.\n\n'
              'Primary use: same gesture, different action per context.\n'
              'Example - one stroke, two actions:\n'
              '  Action 1: \$window_class == firefox  → Ctrl+T (new tab)\n'
              '  Action 2: \$window_class == code     → Ctrl+N (new file)\n\n'
              'Other examples:\n'
              '  \$window_id == \$window_under_id\n'
              '      → only if cursor is over the focused window\n'
              '  \$last_trigger == my_swipe\n'
              '      → only if a specific gesture ran just before this one',
          condition: triggerAction.conditions,
          onConditionChanged: (c) =>
              onChanged(triggerAction.copyWith(conditions: c)),
        ),
      ],
    );
  }
}
