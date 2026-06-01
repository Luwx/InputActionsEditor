import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:input_actions_editor/state/edit/lenses/settings_lenses.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/settings/speed_settings_editor.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/features/settings/state/settings_editor_notifier.dart';

class DeviceConfigEditor extends ConsumerWidget {
  const DeviceConfigEditor({required this.section, super.key});

  final DeviceSettingsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(settingsEditorProvider);
    final config = vm.config;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (config == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final deviceType = _sectionToDeviceType(section);
    final deviceLabel = _sectionLabel(section);

    final speedSettings = deviceType != null
        ? config.speedForDevice(deviceType)
        : null;

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
            if (deviceType != null && deviceType != DeviceType.pointer)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _DevicePropertiesSection(
                    section: section,
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

// ---------------------------------------------------------------------------
// Device Properties Section
// ---------------------------------------------------------------------------

class _DevicePropertiesSection extends ConsumerWidget {
  const _DevicePropertiesSection({
    required this.section,
    required this.onDeviceRulesPress,
    required this.colors,
    required this.typography,
  });

  final DeviceSettingsSection section;
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
    final propertiesField = ref.field(
      defaultDevicePropertiesLens(device),
    );

    EditableField<T> field<T>(Lens<T> Function(DeviceType device) lens) =>
        ref.field(lens(device));

    Widget dirtyTitle<T>(EditableField<T> field, String label) {
      return UnsavedLabel(
        state: field.dirty,
        onRevert: savedProperties == null ? null : field.onRevert,
        child: Text(label),
      );
    }

    FTileMixin boolTile({
      required String title,
      required String subtitle,
      required Lens<bool?> Function(DeviceType device) lens,
    }) {
      final editable = field(lens);
      return FTile(
        title: dirtyTitle(editable, title),
        subtitle: Text(subtitle),
        suffix: _NullableBoolToggle(
          value: editable.value,
          onChanged: editable.onChanged,
          colors: colors,
          typography: typography,
        ),
      );
    }

    FTileMixin numberTile({
      required String title,
      required String subtitle,
      required Lens<double?> Function(DeviceType device) lens,
      double? min,
      double? max,
    }) {
      final editable = field(lens);
      return FTile(
        title: dirtyTitle(editable, title),
        subtitle: Text(subtitle),
        suffix: _NumberField(
          value: editable.value,
          min: min,
          max: max,
          onChanged: editable.onChanged,
        ),
      );
    }

    FTileMixin intTile({
      required String title,
      required String subtitle,
      required Lens<int?> Function(DeviceType device) lens,
    }) {
      final editable = field(lens);
      return FTile(
        title: dirtyTitle(editable, title),
        subtitle: Text(subtitle),
        suffix: _NumberField(
          value: editable.value?.toDouble(),
          isInt: true,
          onChanged: (v) => editable.onChanged(v?.toInt()),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FTileGroup(
          divider: .full,
          label: UnsavedLabel(
            state: sectionState,
            onRevert: savedProperties == null ? null : propertiesField.onRevert,
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
            boolTile(
              title: 'Ignore',
              subtitle: 'Ignore all events from this device type.',
              lens: defaultDeviceIgnoreLens,
            ),
            boolTile(
              title: 'Grab',
              subtitle: 'Grab the evdev device (standalone only).',
              lens: defaultDeviceGrabLens,
            ),
            if (section == DeviceSettingsSection.mouse) ...[
              intTile(
                title: 'Motion Timeout',
                subtitle:
                    'Time (ms) during which a motion trigger must be '
                    'performed.',
                lens: defaultDeviceMotionTimeoutLens,
              ),
              numberTile(
                title: 'Motion Threshold',
                subtitle:
                    'For accurately determining the direction of swipe '
                    'triggers.',
                lens: defaultDeviceMotionThresholdLens,
              ),
              intTile(
                title: 'Press Timeout',
                subtitle: 'Time (ms) before press triggers are started.',
                lens: defaultDevicePressTimeoutLens,
              ),
              numberTile(
                title: 'Swipe Angle Tolerance',
                subtitle:
                    'Angle tolerance (0–45) for cardinal swipe directions.',
                lens: defaultDeviceSwipeAngleToleranceLens,
                min: 0,
                max: 45,
              ),
              boolTile(
                title: 'Unblock Buttons On Timeout',
                subtitle:
                    'Press blocked buttons immediately on motion timeout.',
                lens: defaultDeviceUnblockButtonsOnTimeoutLens,
              ),
            ],
            if (section == DeviceSettingsSection.touchpad) ...[
              boolTile(
                title: 'Buttonpad',
                subtitle:
                    'Whether the touchpad is a buttonpad '
                    '(detected automatically).',
                lens: defaultDeviceButtonpadLens,
              ),
              intTile(
                title: 'Click Timeout',
                subtitle:
                    'Time (ms) during which a click trigger must be performed.',
                lens: defaultDeviceClickTimeoutLens,
              ),
              boolTile(
                title: 'Handle Evdev Events',
                subtitle:
                    'Disable if there are issues with evdev event processing.',
                lens: defaultDeviceHandleEvdevEventsLens,
              ),
              numberTile(
                title: 'Motion Threshold (1-finger)',
                subtitle:
                    'For accurately determining 1-finger swipe direction.',
                lens: defaultDeviceMotionThresholdLens,
              ),
              numberTile(
                title: 'Motion Threshold (2-finger)',
                subtitle:
                    'For accurately determining 2-finger swipe direction.',
                lens: defaultDeviceMotionThreshold2Lens,
              ),
              numberTile(
                title: 'Motion Threshold (3+ finger)',
                subtitle:
                    'For accurately determining 3- and 4-finger swipe '
                    'direction.',
                lens: defaultDeviceMotionThreshold3Lens,
              ),
              numberTile(
                title: 'Swipe Angle Tolerance',
                subtitle:
                    'Angle tolerance (0–45) for cardinal swipe directions.',
                lens: defaultDeviceSwipeAngleToleranceLens,
                min: 0,
                max: 45,
              ),
              intTile(
                title: 'Pressure: Finger',
                subtitle:
                    'Minimum pressure to consider a touch point as a finger.',
                lens: defaultDevicePressureRangesFingerLens,
              ),
              intTile(
                title: 'Pressure: Thumb',
                subtitle:
                    'Minimum pressure to consider a touch point as a thumb.',
                lens: defaultDevicePressureRangesThumbLens,
              ),
              intTile(
                title: 'Pressure: Palm',
                subtitle:
                    'Maximum pressure before a touch point is ignored as palm.',
                lens: defaultDevicePressureRangesPalmLens,
              ),
            ],
            if (section == DeviceSettingsSection.touchscreen) ...[
              numberTile(
                title: 'Motion Threshold',
                subtitle: 'For accurately determining swipe direction (mm).',
                lens: defaultDeviceMotionThresholdLens,
              ),
              numberTile(
                title: 'Swipe Angle Tolerance',
                subtitle:
                    'Angle tolerance (0–45) for cardinal swipe directions.',
                lens: defaultDeviceSwipeAngleToleranceLens,
                min: 0,
                max: 45,
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
