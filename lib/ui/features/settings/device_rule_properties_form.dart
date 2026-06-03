import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/ui/fields/editable_field.dart';

/// A compact form for editing all device rule properties.
class DeviceRulePropertiesForm extends ConsumerWidget {
  const DeviceRulePropertiesForm({
    required this.properties,
    required this.onChanged,
    required this.colors,
    required this.typography,
    this.ruleIndex,
    super.key,
  });

  final DeviceRuleProperties properties;
  final void Function(DeviceRuleProperties) onChanged;
  final FColors colors;
  final FTypography typography;
  final int? ruleIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void upd(DeviceRuleProperties p) => onChanged(p);
    EditableField<T>? field<T>(
      Lens<T> Function(DeviceRuleLocation location) lens,
      T fallback,
    ) {
      final index = ruleIndex;
      if (index == null) return null;
      return ref.field(
        lens(DeviceRuleLocation(deviceRuleIndex: index)),
        fallbackValue: () => fallback,
      );
    }

    Widget boolChip({
      required String label,
      required bool? value,
      required Lens<bool?> Function(DeviceRuleLocation location) lens,
      required DeviceRuleProperties Function(bool? value) update,
    }) {
      final editable = field(lens, value);
      return _BoolChip(
        label: label,
        value: editable?.value ?? value,
        onChanged: (v) =>
            editable == null ? upd(update(v)) : editable.onChanged(v),
        colors: colors,
        typography: typography,
      );
    }

    Widget numberChip({
      required String label,
      required double? value,
      required Lens<double?> Function(DeviceRuleLocation location) lens,
      required DeviceRuleProperties Function(double? value) update,
    }) {
      final editable = field(lens, value);
      return _NumberChip(
        label: label,
        value: editable?.value ?? value,
        onChanged: (v) =>
            editable == null ? upd(update(v)) : editable.onChanged(v),
        colors: colors,
        typography: typography,
      );
    }

    Widget intChip({
      required String label,
      required int? value,
      required Lens<int?> Function(DeviceRuleLocation location) lens,
      required DeviceRuleProperties Function(int? value) update,
    }) {
      final editable = field(lens, value);
      return _NumberChip(
        label: label,
        value: (editable?.value ?? value)?.toDouble(),
        isInt: true,
        onChanged: (v) => editable == null
            ? upd(update(v?.toInt()))
            : editable.onChanged(v?.toInt()),
        colors: colors,
        typography: typography,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          'Properties',
          style: typography.sm.copyWith(fontWeight: FontWeight.w500),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            boolChip(
              label: 'ignore',
              value: properties.ignore,
              lens: deviceRulePropertiesIgnoreLens,
              update: (v) => properties.copyWith(ignore: v),
            ),
            boolChip(
              label: 'grab',
              value: properties.grab,
              lens: deviceRulePropertiesGrabLens,
              update: (v) => properties.copyWith(grab: v),
            ),
            intChip(
              label: 'motion_timeout',
              value: properties.motionTimeout,
              lens: deviceRulePropertiesMotionTimeoutLens,
              update: (v) => properties.copyWith(motionTimeout: v),
            ),
            numberChip(
              label: 'motion_threshold',
              value: properties.motionThreshold,
              lens: deviceRulePropertiesMotionThresholdLens,
              update: (v) => properties.copyWith(motionThreshold: v),
            ),
            intChip(
              label: 'press_timeout',
              value: properties.pressTimeout,
              lens: deviceRulePropertiesPressTimeoutLens,
              update: (v) => properties.copyWith(pressTimeout: v),
            ),
            numberChip(
              label: 'swipe.angle_tolerance',
              value: properties.swipeAngleTolerance,
              lens: deviceRulePropertiesSwipeAngleToleranceLens,
              update: (v) => properties.copyWith(swipeAngleTolerance: v),
            ),
            boolChip(
              label: 'unblock_buttons_on_timeout',
              value: properties.unblockButtonsOnTimeout,
              lens: deviceRulePropertiesUnblockButtonsOnTimeoutLens,
              update: (v) => properties.copyWith(unblockButtonsOnTimeout: v),
            ),
            boolChip(
              label: 'buttonpad',
              value: properties.buttonpad,
              lens: deviceRulePropertiesButtonpadLens,
              update: (v) => properties.copyWith(buttonpad: v),
            ),
            intChip(
              label: 'click_timeout',
              value: properties.clickTimeout,
              lens: deviceRulePropertiesClickTimeoutLens,
              update: (v) => properties.copyWith(clickTimeout: v),
            ),
            boolChip(
              label: 'handle_evdev_events',
              value: properties.handleEvdevEvents,
              lens: deviceRulePropertiesHandleEvdevEventsLens,
              update: (v) => properties.copyWith(handleEvdevEvents: v),
            ),
            numberChip(
              label: 'motion_threshold_2',
              value: properties.motionThreshold2,
              lens: deviceRulePropertiesMotionThreshold2Lens,
              update: (v) => properties.copyWith(motionThreshold2: v),
            ),
            numberChip(
              label: 'motion_threshold_3',
              value: properties.motionThreshold3,
              lens: deviceRulePropertiesMotionThreshold3Lens,
              update: (v) => properties.copyWith(motionThreshold3: v),
            ),
            intChip(
              label: 'pressure_ranges.finger',
              value: properties.pressureRangesFinger,
              lens: deviceRulePropertiesPressureRangesFingerLens,
              update: (v) => properties.copyWith(pressureRangesFinger: v),
            ),
            intChip(
              label: 'pressure_ranges.thumb',
              value: properties.pressureRangesThumb,
              lens: deviceRulePropertiesPressureRangesThumbLens,
              update: (v) => properties.copyWith(pressureRangesThumb: v),
            ),
            intChip(
              label: 'pressure_ranges.palm',
              value: properties.pressureRangesPalm,
              lens: deviceRulePropertiesPressureRangesPalmLens,
              update: (v) => properties.copyWith(pressureRangesPalm: v),
            ),
          ],
        ),
        if (properties.isEmpty)
          Text(
            'No properties set. Add conditions'
            ' and properties to configure device behavior.',
            style: typography.xs.copyWith(color: colors.mutedForeground),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chip widgets
// ---------------------------------------------------------------------------

class _BoolChip extends StatelessWidget {
  const _BoolChip({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.typography,
  });

  final String label;
  final bool? value;
  final void Function(bool?) onChanged;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    final isSet = value != null;
    return GestureDetector(
      onTap: () {
        if (!isSet) {
          onChanged(true);
        } else if (value == true) {
          onChanged(false);
        } else {
          onChanged(null);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSet ? colors.primary.withValues(alpha: 0.12) : colors.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSet
                ? colors.primary.withValues(alpha: 0.4)
                : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Text(
              label,
              style: typography.xs.copyWith(
                fontFamily: 'monospace',
                color: isSet ? colors.primary : colors.mutedForeground,
              ),
            ),
            if (isSet)
              Text(
                ': ${value! ? 'true' : 'false'}',
                style: typography.xs.copyWith(
                  fontFamily: 'monospace',
                  color: colors.foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NumberChip extends HookWidget {
  const _NumberChip({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.typography,
    this.isInt = false,
  });

  final String label;
  final double? value;
  final void Function(double?) onChanged;
  final FColors colors;
  final FTypography typography;
  final bool isInt;

  String _fmt(double? v) {
    if (v == null) return '';
    return isInt ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = useTextEditingController(text: _fmt(value));
    final focus = useFocusNode();
    final editing = useState(false);

    // Sync text when external value changes and not editing.
    final prevValue = usePrevious(value);
    if (prevValue != value && !editing.value) {
      ctrl.text = _fmt(value);
    }

    // Keep the "commit" logic in a ref so the focus listener stays fresh.
    final commitRef = useRef<void Function()>(() {})
      ..value = () {
        final trimmed = ctrl.text.trim();
        editing.value = false;
        if (trimmed.isEmpty) {
          onChanged(null);
        } else {
          onChanged(double.tryParse(trimmed));
        }
      };

    useEffect(() {
      void onFocusChange() {
        if (!focus.hasFocus && editing.value) commitRef.value();
      }

      focus.addListener(onFocusChange);
      return () => focus.removeListener(onFocusChange);
    }, const []);

    final isSet = value != null;

    if (editing.value) {
      return SizedBox(
        width: 140,
        child: Focus(
          focusNode: focus,
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: ctrl,
              onChange: (_) {},
            ),
            hint: label,
            onSubmit: (_) => commitRef.value(),
            autofocus: true,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        ctrl.text = isSet ? _fmt(value) : '';
        editing.value = true;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => focus.requestFocus(),
        );
      },
      onSecondaryTap: isSet ? () => onChanged(null) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSet ? colors.primary.withValues(alpha: 0.12) : colors.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSet
                ? colors.primary.withValues(alpha: 0.4)
                : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              label,
              style: typography.xs.copyWith(
                fontFamily: 'monospace',
                color: isSet ? colors.primary : colors.mutedForeground,
              ),
            ),
            if (isSet)
              Text(
                ': ${_fmt(value)}',
                style: typography.xs.copyWith(
                  fontFamily: 'monospace',
                  color: colors.foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
