import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/device_rule.dart';

/// A compact form for editing all device rule properties.
class DeviceRulePropertiesForm extends StatelessWidget {
  const DeviceRulePropertiesForm({
    required this.properties,
    required this.onChanged,
    required this.colors,
    required this.typography,
    super.key,
  });

  final DeviceRuleProperties properties;
  final void Function(DeviceRuleProperties) onChanged;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    void upd(DeviceRuleProperties p) => onChanged(p);

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
            _BoolChip(
              label: 'ignore',
              value: properties.ignore,
              onChanged: (v) => upd(properties.copyWith(ignore: v)),
              colors: colors,
              typography: typography,
            ),
            _BoolChip(
              label: 'grab',
              value: properties.grab,
              onChanged: (v) => upd(properties.copyWith(grab: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'motion_timeout',
              value: properties.motionTimeout?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(motionTimeout: v?.toInt())),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'motion_threshold',
              value: properties.motionThreshold,
              onChanged: (v) => upd(properties.copyWith(motionThreshold: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'press_timeout',
              value: properties.pressTimeout?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(pressTimeout: v?.toInt())),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'swipe.angle_tolerance',
              value: properties.swipeAngleTolerance,
              onChanged: (v) =>
                  upd(properties.copyWith(swipeAngleTolerance: v)),
              colors: colors,
              typography: typography,
            ),
            _BoolChip(
              label: 'unblock_buttons_on_timeout',
              value: properties.unblockButtonsOnTimeout,
              onChanged: (v) =>
                  upd(properties.copyWith(unblockButtonsOnTimeout: v)),
              colors: colors,
              typography: typography,
            ),
            _BoolChip(
              label: 'buttonpad',
              value: properties.buttonpad,
              onChanged: (v) => upd(properties.copyWith(buttonpad: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'click_timeout',
              value: properties.clickTimeout?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(clickTimeout: v?.toInt())),
              colors: colors,
              typography: typography,
            ),
            _BoolChip(
              label: 'handle_evdev_events',
              value: properties.handleEvdevEvents,
              onChanged: (v) => upd(properties.copyWith(handleEvdevEvents: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'motion_threshold_2',
              value: properties.motionThreshold2,
              onChanged: (v) => upd(properties.copyWith(motionThreshold2: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'motion_threshold_3',
              value: properties.motionThreshold3,
              onChanged: (v) => upd(properties.copyWith(motionThreshold3: v)),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'pressure_ranges.finger',
              value: properties.pressureRangesFinger?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(pressureRangesFinger: v?.toInt())),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'pressure_ranges.thumb',
              value: properties.pressureRangesThumb?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(pressureRangesThumb: v?.toInt())),
              colors: colors,
              typography: typography,
            ),
            _NumberChip(
              label: 'pressure_ranges.palm',
              value: properties.pressureRangesPalm?.toDouble(),
              isInt: true,
              onChanged: (v) =>
                  upd(properties.copyWith(pressureRangesPalm: v?.toInt())),
              colors: colors,
              typography: typography,
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
