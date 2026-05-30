import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/state/dirty/dirty_semantics.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/settings/speed_settings_editor.dart';
import 'package:input_actions_editor/ui/widgets/unsaved_marker.dart';

class DeviceConfigEditor extends ConsumerWidget {
  const DeviceConfigEditor({required this.section, super.key});

  final DeviceSettingsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configControllerProvider).value;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (config == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final deviceType = _sectionToDeviceType(section);
    final deviceLabel = _sectionLabel(section);
    final conditionVar = _sectionConditionVar(section);

    int? defaultRuleIndex;
    var currentProps = const DeviceRuleProperties();
    if (conditionVar != null) {
      for (var i = 0; i < config.deviceRules.length; i++) {
        final rule = config.deviceRules[i];
        if (_isSimpleTypeCondition(rule.conditions, conditionVar)) {
          defaultRuleIndex = i;
          currentProps = rule.properties;
          break;
        }
      }
    }

    final notifier = ref.read(configControllerProvider.notifier);

    void updateProps(DeviceRuleProperties Function(DeviceRuleProperties) m) {
      final updated = m(currentProps);
      if (defaultRuleIndex != null) {
        if (updated.isEmpty) {
          notifier.removeDeviceRule(defaultRuleIndex);
        } else {
          notifier.updateDeviceRule(
            defaultRuleIndex,
            (r) => r.copyWith(properties: updated),
          );
        }
      } else if (!updated.isEmpty) {
        final cond = VariableCondition(
          variable: conditionVar!,
          operator: '==',
          value: 'true',
        );
        notifier.addDeviceRule(
          DeviceRule(conditions: cond, properties: updated),
        );
      }
    }

    final speedSettings = deviceType != null
        ? config.speedForDevice(deviceType)
        : null;

    void updateSpeed(SpeedSettings? s) {
      if (deviceType == null) return;
      switch (deviceType) {
        case DeviceType.mouse:
          notifier.updateMouseSpeed(s);
        case DeviceType.touchpad:
          notifier.updateTouchpadSpeed(s);
        case DeviceType.touchscreen:
          notifier.updateTouchscreenSpeed(s);
        case DeviceType.keyboard:
          break;
        case DeviceType.pointer:
          break;
      }
    }

    final hasSpeed =
        deviceType == DeviceType.mouse ||
        deviceType == DeviceType.touchpad ||
        deviceType == DeviceType.touchscreen;

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(title: deviceLabel),
          if (section == DeviceSettingsSection.pointer)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No configurable properties for Pointer devices.',
                  style: typography.sm.copyWith(color: colors.mutedForeground),
                ),
              ),
            )
          else ...[
            if (conditionVar != null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _DevicePropertiesSection(
                    section: section,
                    properties: currentProps,
                    onChanged: updateProps,
                    onDeviceRulesPress: () => context.goToSettingsSection(
                      SettingsSection.deviceRules,
                    ),
                    colors: colors,
                    typography: typography,
                  ),
                ),
              ),
            if (hasSpeed)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: SpeedSettingsEditor(
                    device: deviceType!,
                    settings: speedSettings,
                    onChanged: updateSpeed,
                  ),
                ),
              ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ],
      ),
    );
  }
}

bool _isSimpleTypeCondition(Condition? cond, String varName) {
  if (cond is! VariableCondition) return false;
  return cond.variable == varName &&
      cond.operator == '==' &&
      cond.value == 'true' &&
      !cond.negate;
}

DeviceType? _sectionToDeviceType(DeviceSettingsSection s) => switch (s) {
  DeviceSettingsSection.mouse => DeviceType.mouse,
  DeviceSettingsSection.pointer => DeviceType.pointer,
  DeviceSettingsSection.keyboard => DeviceType.keyboard,
  DeviceSettingsSection.touchpad => DeviceType.touchpad,
  DeviceSettingsSection.touchscreen => DeviceType.touchscreen,
};

String _sectionLabel(DeviceSettingsSection s) => switch (s) {
  DeviceSettingsSection.mouse => 'Mouse',
  DeviceSettingsSection.pointer => 'Pointer',
  DeviceSettingsSection.keyboard => 'Keyboard',
  DeviceSettingsSection.touchpad => 'Touchpad',
  DeviceSettingsSection.touchscreen => 'Touchscreen',
};

String? _sectionConditionVar(DeviceSettingsSection s) => switch (s) {
  DeviceSettingsSection.mouse => 'mouse',
  DeviceSettingsSection.keyboard => 'keyboard',
  DeviceSettingsSection.touchpad => 'touchpad',
  DeviceSettingsSection.touchscreen => 'touchscreen',
  _ => null,
};

// ---------------------------------------------------------------------------
// Device Properties Section
// ---------------------------------------------------------------------------

class _DevicePropertiesSection extends ConsumerWidget {
  const _DevicePropertiesSection({
    required this.section,
    required this.properties,
    required this.onChanged,
    required this.onDeviceRulesPress,
    required this.colors,
    required this.typography,
  });

  final DeviceSettingsSection section;
  final DeviceRuleProperties properties;
  final void Function(DeviceRuleProperties Function(DeviceRuleProperties))
  onChanged;
  final VoidCallback onDeviceRulesPress;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = _sectionToDeviceType(section)!;
    final savedProperties = ref.watch(savedDevicePropertiesProvider(device));
    final sectionState = ref.watch(
      rootConfigDirtyStateProvider(switch (device) {
        DeviceType.mouse => RootConfigDirtyField.mouseDeviceProperties,
        DeviceType.keyboard => RootConfigDirtyField.keyboardDeviceProperties,
        DeviceType.touchpad => RootConfigDirtyField.touchpadDeviceProperties,
        DeviceType.touchscreen =>
          RootConfigDirtyField.touchscreenDeviceProperties,
        _ => RootConfigDirtyField.mouseDeviceProperties,
      }),
    );

    Widget dirtyTitle(DevicePropertyDirtyField field, String label) {
      return UnsavedLabel(
        state: ref.watch(
          devicePropertyDirtyStateProvider(
            DevicePropertyLocation(device: device, field: field),
          ),
        ),
        onRevert: savedProperties == null
            ? null
            : () => onChanged(
                (_) => restoreSavedDeviceProperty(
                  properties,
                  savedProperties,
                  field,
                ),
              ),
        child: Text(label),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FTileGroup(
          divider: .full,
          label: UnsavedLabel(
            state: sectionState,
            onRevert: savedProperties == null
                ? null
                : () => onChanged((_) => savedProperties),
            child: const Text('Device Properties'),
          ),
          description: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Applies to all devices of this type. Use ',
                ),
                TextSpan(
                  text: 'Device Rules',
                  style: TextStyle(
                    color: colors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onDeviceRulesPress,
                ),
                const TextSpan(text: ' to override per device.'),
              ],
            ),
          ),
          children: [
            FTile(
              title: dirtyTitle(DevicePropertyDirtyField.ignore, 'Ignore'),
              subtitle: const Text('Ignore all events from this device type.'),
              suffix: _NullableBoolToggle(
                value: properties.ignore,
                onChanged: (v) => onChanged((p) => p.copyWith(ignore: v)),
                colors: colors,
                typography: typography,
              ),
            ),
            FTile(
              title: dirtyTitle(DevicePropertyDirtyField.grab, 'Grab'),
              subtitle: const Text('Grab the evdev device (standalone only).'),
              suffix: _NullableBoolToggle(
                value: properties.grab,
                onChanged: (v) => onChanged((p) => p.copyWith(grab: v)),
                colors: colors,
                typography: typography,
              ),
            ),
            if (section == DeviceSettingsSection.mouse) ...[
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionTimeout,
                  'Motion Timeout',
                ),
                subtitle: const Text(
                  'Time (ms) during which a motion trigger must be performed.',
                ),
                suffix: _NumberField(
                  value: properties.motionTimeout?.toDouble(),
                  isInt: true,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionTimeout: v?.toInt())),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionThreshold,
                  'Motion Threshold',
                ),
                subtitle: const Text(
                  'For accurately determining the direction of swipe triggers.',
                ),
                suffix: _NumberField(
                  value: properties.motionThreshold,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionThreshold: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.pressTimeout,
                  'Press Timeout',
                ),
                subtitle: const Text(
                  'Time (ms) before press triggers are started.',
                ),
                suffix: _NumberField(
                  value: properties.pressTimeout?.toDouble(),
                  isInt: true,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(pressTimeout: v?.toInt())),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.swipeAngleTolerance,
                  'Swipe Angle Tolerance',
                ),
                subtitle: const Text(
                  'Angle tolerance (0–45) for cardinal swipe directions.',
                ),
                suffix: _NumberField(
                  value: properties.swipeAngleTolerance,
                  min: 0,
                  max: 45,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(swipeAngleTolerance: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.unblockButtonsOnTimeout,
                  'Unblock Buttons On Timeout',
                ),
                subtitle: const Text(
                  'Press blocked buttons immediately on motion timeout.',
                ),
                suffix: _NullableBoolToggle(
                  value: properties.unblockButtonsOnTimeout,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(unblockButtonsOnTimeout: v)),
                  colors: colors,
                  typography: typography,
                ),
              ),
            ],
            if (section == DeviceSettingsSection.touchpad) ...[
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.buttonpad,
                  'Buttonpad',
                ),
                subtitle: const Text(
                  'Whether the touchpad is a buttonpad'
                  ' (detected automatically).',
                ),
                suffix: _NullableBoolToggle(
                  value: properties.buttonpad,
                  onChanged: (v) => onChanged((p) => p.copyWith(buttonpad: v)),
                  colors: colors,
                  typography: typography,
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.clickTimeout,
                  'Click Timeout',
                ),
                subtitle: const Text(
                  'Time (ms) during which a click trigger must be performed.',
                ),
                suffix: _NumberField(
                  value: properties.clickTimeout?.toDouble(),
                  isInt: true,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(clickTimeout: v?.toInt())),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.handleEvdevEvents,
                  'Handle Evdev Events',
                ),
                subtitle: const Text(
                  'Disable if there are issues with evdev event processing.',
                ),
                suffix: _NullableBoolToggle(
                  value: properties.handleEvdevEvents,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(handleEvdevEvents: v)),
                  colors: colors,
                  typography: typography,
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionThreshold,
                  'Motion Threshold (1-finger)',
                ),
                subtitle: const Text(
                  'For accurately determining 1-finger swipe direction.',
                ),
                suffix: _NumberField(
                  value: properties.motionThreshold,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionThreshold: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionThreshold2,
                  'Motion Threshold (2-finger)',
                ),
                subtitle: const Text(
                  'For accurately determining 2-finger swipe direction.',
                ),
                suffix: _NumberField(
                  value: properties.motionThreshold2,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionThreshold2: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionThreshold3,
                  'Motion Threshold (3+ finger)',
                ),
                subtitle: const Text(
                  'For accurately determining 3- and 4-finger swipe direction.',
                ),
                suffix: _NumberField(
                  value: properties.motionThreshold3,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionThreshold3: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.swipeAngleTolerance,
                  'Swipe Angle Tolerance',
                ),
                subtitle: const Text(
                  'Angle tolerance (0–45) for cardinal swipe directions.',
                ),
                suffix: _NumberField(
                  value: properties.swipeAngleTolerance,
                  min: 0,
                  max: 45,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(swipeAngleTolerance: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.pressureRangesFinger,
                  'Pressure: Finger',
                ),
                subtitle: const Text(
                  'Minimum pressure to consider a touch point as a finger.',
                ),
                suffix: _NumberField(
                  value: properties.pressureRangesFinger?.toDouble(),
                  isInt: true,
                  onChanged: (v) => onChanged(
                    (p) => p.copyWith(pressureRangesFinger: v?.toInt()),
                  ),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.pressureRangesThumb,
                  'Pressure: Thumb',
                ),
                subtitle: const Text(
                  'Minimum pressure to consider a touch point as a thumb.',
                ),
                suffix: _NumberField(
                  value: properties.pressureRangesThumb?.toDouble(),
                  isInt: true,
                  onChanged: (v) => onChanged(
                    (p) => p.copyWith(pressureRangesThumb: v?.toInt()),
                  ),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.pressureRangesPalm,
                  'Pressure: Palm',
                ),
                subtitle: const Text(
                  'Maximum pressure before a touch point is ignored as palm.',
                ),
                suffix: _NumberField(
                  value: properties.pressureRangesPalm?.toDouble(),
                  isInt: true,
                  onChanged: (v) => onChanged(
                    (p) => p.copyWith(pressureRangesPalm: v?.toInt()),
                  ),
                ),
              ),
            ],
            if (section == DeviceSettingsSection.touchscreen) ...[
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.motionThreshold,
                  'Motion Threshold',
                ),
                subtitle: const Text(
                  'For accurately determining swipe direction (mm).',
                ),
                suffix: _NumberField(
                  value: properties.motionThreshold,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(motionThreshold: v)),
                ),
              ),
              FTile(
                title: dirtyTitle(
                  DevicePropertyDirtyField.swipeAngleTolerance,
                  'Swipe Angle Tolerance',
                ),
                subtitle: const Text(
                  'Angle tolerance (0–45) for cardinal swipe directions.',
                ),
                suffix: _NumberField(
                  value: properties.swipeAngleTolerance,
                  min: 0,
                  max: 45,
                  onChanged: (v) =>
                      onChanged((p) => p.copyWith(swipeAngleTolerance: v)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Suffix widgets
// ---------------------------------------------------------------------------

class _NullableBoolToggle extends StatelessWidget {
  const _NullableBoolToggle({
    required this.value,
    required this.onChanged,
    required this.colors,
    required this.typography,
  });

  final bool? value;
  final void Function(bool?) onChanged;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (value != null)
          GestureDetector(
            onTap: () => onChanged(null),
            child: Text(
              'reset',
              style: typography.xs.copyWith(color: colors.mutedForeground),
            ),
          ),
        FSwitch(
          value: value ?? false,
          onChange: onChanged,
        ),
      ],
    );
  }
}

class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.value,
    required this.onChanged,
    this.isInt = false,
    this.min,
    this.max,
  });

  final double? value;
  final void Function(double?) onChanged;
  final bool isInt;
  final double? min;
  final double? max;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatValue(widget.value));
  }

  @override
  void didUpdateWidget(_NumberField old) {
    super.didUpdateWidget(old);
    if (!_focused && old.value != widget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(double? v) {
    if (v == null) return '';
    return widget.isInt ? v.toInt().toString() : v.toString();
  }

  void _commit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      _controller.text = _formatValue(widget.value);
      return;
    }
    var clamped = parsed;
    if (widget.min != null && clamped < widget.min!) clamped = widget.min!;
    if (widget.max != null && clamped > widget.max!) clamped = widget.max!;
    widget.onChanged(clamped);
    if (clamped != parsed) _controller.text = _formatValue(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Focus(
        onFocusChange: (focused) {
          _focused = focused;
          if (!focused) _commit(_controller.text);
        },
        child: FTextField(
          control: FTextFieldControl.managed(
            controller: _controller,
            onChange: (_) {},
          ),
          hint: 'default',
          onSubmit: _commit,
        ),
      ),
    );
  }
}
