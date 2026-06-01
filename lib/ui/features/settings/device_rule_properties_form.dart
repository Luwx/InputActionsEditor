import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:input_actions_editor/state/edit/lenses/settings_lenses.dart';

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
      Lens<T> Function(int index) lens,
      T fallback,
    ) {
      final index = ruleIndex;
      if (index == null) return null;
      return ref.field(
        lens(index),
        fallbackValue: () => fallback,
      );
    }

    Widget boolChip({
      required String label,
      required bool? value,
      required Lens<bool?> Function(int index) lens,
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
      required Lens<double?> Function(int index) lens,
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
      required Lens<int?> Function(int index) lens,
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
              lens: deviceRuleIgnoreLens,
              update: (v) => properties.copyWith(ignore: v),
            ),
            boolChip(
              label: 'grab',
              value: properties.grab,
              lens: deviceRuleGrabLens,
              update: (v) => properties.copyWith(grab: v),
            ),
            intChip(
              label: 'motion_timeout',
              value: properties.motionTimeout,
              lens: deviceRuleMotionTimeoutLens,
              update: (v) => properties.copyWith(motionTimeout: v),
            ),
            numberChip(
              label: 'motion_threshold',
              value: properties.motionThreshold,
              lens: deviceRuleMotionThresholdLens,
              update: (v) => properties.copyWith(motionThreshold: v),
            ),
            intChip(
              label: 'press_timeout',
              value: properties.pressTimeout,
              lens: deviceRulePressTimeoutLens,
              update: (v) => properties.copyWith(pressTimeout: v),
            ),
            numberChip(
              label: 'swipe.angle_tolerance',
              value: properties.swipeAngleTolerance,
              lens: deviceRuleSwipeAngleToleranceLens,
              update: (v) => properties.copyWith(swipeAngleTolerance: v),
            ),
            boolChip(
              label: 'unblock_buttons_on_timeout',
              value: properties.unblockButtonsOnTimeout,
              lens: deviceRuleUnblockButtonsOnTimeoutLens,
              update: (v) => properties.copyWith(unblockButtonsOnTimeout: v),
            ),
            boolChip(
              label: 'buttonpad',
              value: properties.buttonpad,
              lens: deviceRuleButtonpadLens,
              update: (v) => properties.copyWith(buttonpad: v),
            ),
            intChip(
              label: 'click_timeout',
              value: properties.clickTimeout,
              lens: deviceRuleClickTimeoutLens,
              update: (v) => properties.copyWith(clickTimeout: v),
            ),
            boolChip(
              label: 'handle_evdev_events',
              value: properties.handleEvdevEvents,
              lens: deviceRuleHandleEvdevEventsLens,
              update: (v) => properties.copyWith(handleEvdevEvents: v),
            ),
            numberChip(
              label: 'motion_threshold_2',
              value: properties.motionThreshold2,
              lens: deviceRuleMotionThreshold2Lens,
              update: (v) => properties.copyWith(motionThreshold2: v),
            ),
            numberChip(
              label: 'motion_threshold_3',
              value: properties.motionThreshold3,
              lens: deviceRuleMotionThreshold3Lens,
              update: (v) => properties.copyWith(motionThreshold3: v),
            ),
            intChip(
              label: 'pressure_ranges.finger',
              value: properties.pressureRangesFinger,
              lens: deviceRulePressureRangesFingerLens,
              update: (v) => properties.copyWith(pressureRangesFinger: v),
            ),
            intChip(
              label: 'pressure_ranges.thumb',
              value: properties.pressureRangesThumb,
              lens: deviceRulePressureRangesThumbLens,
              update: (v) => properties.copyWith(pressureRangesThumb: v),
            ),
            intChip(
              label: 'pressure_ranges.palm',
              value: properties.pressureRangesPalm,
              lens: deviceRulePressureRangesPalmLens,
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

class _NumberChip extends StatefulWidget {
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

  @override
  State<_NumberChip> createState() => _NumberChipState();
}

class _NumberChipState extends State<_NumberChip> {
  bool _editing = false;
  late final TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.value));
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) {
        _commit();
      }
    });
  }

  @override
  void didUpdateWidget(_NumberChip old) {
    super.didUpdateWidget(old);
    if (!_editing && old.value != widget.value) {
      _ctrl.text = _fmt(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _fmt(double? v) {
    if (v == null) return '';
    return widget.isInt ? v.toInt().toString() : v.toString();
  }

  void _commit() {
    final trimmed = _ctrl.text.trim();
    setState(() => _editing = false);
    if (trimmed.isEmpty) {
      widget.onChanged(null);
    } else {
      widget.onChanged(double.tryParse(trimmed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSet = widget.value != null;

    if (_editing) {
      return SizedBox(
        width: 140,
        child: Focus(
          focusNode: _focus,
          child: FTextField(
            control: FTextFieldControl.managed(
              controller: _ctrl,
              onChange: (_) {},
            ),
            hint: widget.label,
            onSubmit: (_) => _commit(),
            autofocus: true,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (!isSet) {
          _ctrl.text = '';
          setState(() => _editing = true);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _focus.requestFocus(),
          );
        } else {
          _ctrl.text = _fmt(widget.value);
          setState(() => _editing = true);
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _focus.requestFocus(),
          );
        }
      },
      onSecondaryTap: isSet ? () => widget.onChanged(null) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSet
              ? widget.colors.primary.withValues(alpha: 0.12)
              : widget.colors.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSet
                ? widget.colors.primary.withValues(alpha: 0.4)
                : widget.colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              widget.label,
              style: widget.typography.xs.copyWith(
                fontFamily: 'monospace',
                color: isSet
                    ? widget.colors.primary
                    : widget.colors.mutedForeground,
              ),
            ),
            if (isSet)
              Text(
                ': ${_fmt(widget.value)}',
                style: widget.typography.xs.copyWith(
                  fontFamily: 'monospace',
                  color: widget.colors.foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
