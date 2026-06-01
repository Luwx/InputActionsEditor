import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lenses/gesture_lenses.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

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
    final gestureLocation = context.gestureLocation;
    final conditionsBodyBackgroundColor = Color.alphaBlend(
      context.theme.colors.card.withValues(alpha: 0.55),
      context.theme.colors.background,
    );
    final idField = ref.field(
      gestureIdLens(gestureLocation),
      fallbackValue: () => common.id,
      scope: gestureLocation,
    );
    final thresholdField = ref.field(
      gestureThresholdLens(gestureLocation),
      fallbackValue: () => common.threshold,
      scope: gestureLocation,
    );
    final resumeTimeoutField = ref.field(
      gestureResumeTimeoutLens(gestureLocation),
      fallbackValue: () => common.resumeTimeout,
      scope: gestureLocation,
    );
    final acceleratedField = ref.field(
      gestureAcceleratedLens(gestureLocation),
      fallbackValue: () => common.accelerated,
      scope: gestureLocation,
    );
    final blockEventsField = ref.field(
      gestureBlockEventsLens(gestureLocation),
      fallbackValue: () => common.blockEvents,
      scope: gestureLocation,
    );
    final clearModifiersField = ref.field(
      gestureClearModifiersLens(gestureLocation),
      fallbackValue: () => common.clearModifiers,
      scope: gestureLocation,
    );
    final setLastTriggerField = ref.field(
      gestureSetLastTriggerLens(gestureLocation),
      fallbackValue: () => common.setLastTrigger,
      scope: gestureLocation,
    );
    final conditionsField = ref.field(
      gestureConditionsLens(gestureLocation),
      fallbackValue: () => common.conditions,
      scope: gestureLocation,
    );
    final endConditionsField = ref.field(
      gestureEndConditionsLens(gestureLocation),
      fallbackValue: () => common.endConditions,
      scope: gestureLocation,
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
                child: const LabelWithTooltip(
                  label: 'ID',
                  tooltip:
                      'Unique name for this trigger.\n\n'
                      'When set, the daemon exposes variables:\n'
                      '  \$<id>_active  - true while running\n'
                      '  \$last_trigger - equals this id after it fires\n\n'
                      "Use these in other gestures' conditions to chain "
                      'or block behaviors.\n'
                      'Example: id: swipe_right, then another gesture can '
                      r'check $last_trigger == swipe_right.',
                ),
              ),
              control: FTextFieldControl.managed(
                initial: TextEditingValue(text: idField.value ?? ''),
                onChange: (v) =>
                    idField.onChanged(v.text.isEmpty ? null : v.text),
              ),
              hint: 'e.g. my_trigger',
            ),
            FTextField(
              label: UnsavedLabel(
                state: thresholdField.dirty,
                onRevert: thresholdField.onRevert,
                child: const LabelWithTooltip(
                  label: 'Threshold',
                  tooltip:
                      'Minimum accumulated input before the gesture is '
                      'recognized as started.\n\n'
                      '"Progress" units by gesture type:\n'
                      '  Swipe / stroke  - pixels of movement\n'
                      '  Wheel           - scroll ticks\n'
                      '  Pinch           - scale factor (e.g. 0.1 = 10%)\n'
                      '  Rotate / circle - degrees\n'
                      '  Press           - not applicable '
                      '(press has no movement phase)\n\n'
                      'Below the threshold the input is passed through '
                      'to the application normally.\n'
                      'Use a range like 50-200 to require at least 50 '
                      'and cancel if it exceeds 200.\n\n'
                      'Note: this is distinct from the per-action Threshold, '
                      'which gates a specific action after recognition.',
                  textStyle: TextStyle(height: 1.4, fontFamily: 'monospaced'),
                ),
              ),
              control: FTextFieldControl.managed(
                initial: TextEditingValue(text: thresholdField.value ?? ''),
                onChange: (v) =>
                    thresholdField.onChanged(v.text.isEmpty ? null : v.text),
              ),
              hint: 'e.g. 100 or 50-200',
            ),
            FTextField(
              label: UnsavedLabel(
                state: resumeTimeoutField.dirty,
                onRevert: resumeTimeoutField.onRevert,
                child: const LabelWithTooltip(
                  label: 'Resume timeout',
                  tooltip:
                      'If another identical gesture starts within this many '
                      'milliseconds after this one ends, it resumes as a '
                      'continuation rather than starting fresh.\n\n'
                      'Useful for:\n'
                      '  • Multi-tap sequences where a brief pause between '
                      'taps should not reset state\n'
                      '  • Repeated wheel scrolls that accumulate delta '
                      'across short gaps\n\n'
                      '0 = disabled (every gesture starts from scratch).',
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              control: FTextFieldControl.managed(
                initial: TextEditingValue(
                  text: resumeTimeoutField.value?.toString() ?? '',
                ),
                onChange: (v) => resumeTimeoutField.onChanged(
                  v.text.isEmpty ? null : int.tryParse(v.text),
                ),
              ),
              hint: '0 = disabled',
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
                child: const LabelWithTooltip(
                  label: 'Accelerated',
                  tooltip:
                      'Scale delta values by pointer acceleration, matching '
                      'how fast the cursor moves on screen.\n\n'
                      'Enable for actions that should feel proportional to '
                      'movement speed (e.g. move_by_delta input actions).\n'
                      'Disable for uniform responses regardless of speed '
                      '(e.g. a fixed key press per scroll tick).',
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveBlockEvents,
              onChange: (v) => blockEventsField.onChanged(v ? null : false),
              label: UnsavedLabel(
                state: blockEventsField.dirty,
                onRevert: blockEventsField.onRevert,
                child: const LabelWithTooltip(
                  label: 'Block events',
                  tooltip:
                      'Suppress the raw input events used by this gesture '
                      'so they do not reach other applications.\n\n'
                      'Example: holding right-click to draw a stroke gesture '
                      'prevents the context menu from opening.\n\n'
                      'Disable if the application should also receive those '
                      'events while the gesture is active.',
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveClearModifiers,
              onChange: (v) => clearModifiersField.onChanged(v ? true : null),
              label: UnsavedLabel(
                state: clearModifiersField.dirty,
                onRevert: clearModifiersField.onRevert,
                child: const LabelWithTooltip(
                  label: 'Clear modifiers',
                  tooltip:
                      'Release all held modifier keys (Ctrl, Shift, Alt, '
                      'Super) when this gesture begins.\n\n'
                      'Automatically enabled when an input: action is '
                      'present, to prevent those modifiers from leaking '
                      'into the replayed key events.\n'
                      'Disable only if you intentionally need the modifiers '
                      'to remain held during the action.',
                ),
              ),
            ),
            FCheckbox(
              value: common.effectiveSetLastTrigger,
              onChange: (v) => setLastTriggerField.onChanged(v ? null : false),
              label: UnsavedLabel(
                state: setLastTriggerField.dirty,
                onRevert: setLastTriggerField.onRevert,
                child: const LabelWithTooltip(
                  label: 'Set last trigger',
                  tooltip:
                      r"Update $last_trigger to this trigger's ID when it "
                      'executes.\n\n'
                      r"Use $last_trigger in other gestures' conditions to "
                      'build sequences - e.g. a second gesture that only '
                      'fires if a specific gesture ran first.\n\n'
                      'Disable for utility triggers you do not want to '
                      r'pollute the $last_trigger state.',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ConditionEditor.generic(
          condition: conditionsField.value,
          onConditionChanged: conditionsField.onChanged,
          titleTooltip:
              'Conditions that must ALL be true for this gesture to '
              'activate.\n\n'
              'Examples:\n'
              r'  $window_class == firefox'
              '\n'
              '      → only fires inside Firefox\n'
              r'  $window_class == konsole'
              '\n'
              '      → only fires inside the terminal\n'
              r'  $window_id == $window_under_id'
              '\n'
              '      → cursor is over the focused window\n'
              r'  $pointer_position_screen_percentage_x >= 0.95'
              '\n'
              '      → cursor is at the right screen edge\n'
              r'  $fingers == 3'
              '\n'
              '      → exactly 3 fingers on touchpad\n\n'
              'Multiple rows are ANDed together.\n'
              'Use an "any" group inside for OR logic.',
          bodyBackgroundColor: conditionsBodyBackgroundColor,
          dirtyState: conditionsField.dirty,
          onRevert: conditionsField.onRevert,
        ),
        const SizedBox(height: 12),
        ConditionEditor.generic(
          title: 'End conditions',
          dirtyState: endConditionsField.dirty,
          onRevert: endConditionsField.onRevert,
          titleTooltip:
              'Checked at the moment the gesture ends.\n\n'
              '  • Met → gesture ends normally; on:end actions fire.\n'
              '  • Not met → gesture is cancelled; on:cancel actions '
              'fire instead.\n\n'
              'Use this to require a minimum movement before the gesture '
              '"counts".\n'
              r'Example: $distance >= 100 cancels the gesture if the '
              'finger did not travel at least 100 px, so a short '
              'accidental movement is ignored.',
          condition: endConditionsField.value,
          bodyBackgroundColor: conditionsBodyBackgroundColor,
          onConditionChanged: endConditionsField.onChanged,
        ),
      ],
    );
  }
}
