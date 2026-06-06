import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/settings/speed_settings_editor.dart';
import 'package:input_actions_editor/ui/features/settings/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class DeviceConfigEditor extends ConsumerWidget {
  const DeviceConfigEditor({required this.section, super.key});

  final DeviceSettingsSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(
      configControllerProvider.select((state) => state.value),
    );
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (config == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final deviceType = _sectionToDeviceType(section);
    final deviceLabel = _sectionLabel(section, l10n);

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
          SliverFrostedAppBar(
            title: deviceLabel,
            trailing: const ScopedSaveActions(scope: SaveScope.settings),
          ),
          if (section == DeviceSettingsSection.pointer)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  l10n.devicePropertiesNoPointer,
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

String _sectionLabel(DeviceSettingsSection s, AppLocalizations l10n) =>
    switch (s) {
      DeviceSettingsSection.mouse => l10n.deviceTypeMouse,
      DeviceSettingsSection.pointer => l10n.deviceTypePointer,
      DeviceSettingsSection.keyboard => l10n.deviceTypeKeyboard,
      DeviceSettingsSection.touchpad => l10n.deviceTypeTouchpad,
      DeviceSettingsSection.touchscreen => l10n.deviceTypeTouchscreen,
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
    final l10n = context.l10n;
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
            child: Text(l10n.devicePropertiesTitle),
          ),
          description: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l10n.devicePropertiesDescriptionBefore),
                TextSpan(
                  text: l10n.deviceRulesLinkText,
                  style: TextStyle(
                    color: colors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = onDeviceRulesPress,
                ),
                TextSpan(text: l10n.devicePropertiesDescriptionAfter),
              ],
            ),
          ),
          children: [
            boolTile(
              title: l10n.devicePropertiesIgnoreLabel,
              subtitle: l10n.devicePropertiesIgnoreSubtitle,
              lens: defaultDeviceIgnoreLens,
            ),
            boolTile(
              title: l10n.devicePropertiesGrabLabel,
              subtitle: l10n.devicePropertiesGrabSubtitle,
              lens: defaultDeviceGrabLens,
            ),
            if (section == DeviceSettingsSection.mouse) ...[
              intTile(
                title: l10n.devicePropertiesMotionTimeoutLabel,
                subtitle: l10n.devicePropertiesMotionTimeoutSubtitle,
                lens: defaultDeviceMotionTimeoutLens,
              ),
              numberTile(
                title: l10n.devicePropertiesMotionThresholdLabel,
                subtitle: l10n.devicePropertiesMotionThresholdSubtitle,
                lens: defaultDeviceMotionThresholdLens,
              ),
              intTile(
                title: l10n.devicePropertiesPressTimeoutLabel,
                subtitle: l10n.devicePropertiesPressTimeoutSubtitle,
                lens: defaultDevicePressTimeoutLens,
              ),
              numberTile(
                title: l10n.devicePropertiesSwipeAngleToleranceLabel,
                subtitle: l10n.devicePropertiesSwipeAngleToleranceSubtitle,
                lens: defaultDeviceSwipeAngleToleranceLens,
                min: 0,
                max: 45,
              ),
              boolTile(
                title: l10n.devicePropertiesUnblockButtonsOnTimeoutLabel,
                subtitle: l10n.devicePropertiesUnblockButtonsOnTimeoutSubtitle,
                lens: defaultDeviceUnblockButtonsOnTimeoutLens,
              ),
            ],
            if (section == DeviceSettingsSection.touchpad) ...[
              boolTile(
                title: l10n.devicePropertiesButtonpadLabel,
                subtitle: l10n.devicePropertiesButtonpadSubtitle,
                lens: defaultDeviceButtonpadLens,
              ),
              intTile(
                title: l10n.devicePropertiesClickTimeoutLabel,
                subtitle: l10n.devicePropertiesClickTimeoutSubtitle,
                lens: defaultDeviceClickTimeoutLens,
              ),
              boolTile(
                title: l10n.devicePropertiesHandleEvdevEventsLabel,
                subtitle: l10n.devicePropertiesHandleEvdevEventsSubtitle,
                lens: defaultDeviceHandleEvdevEventsLens,
              ),
              numberTile(
                title: l10n.devicePropertiesMotionThreshold1FingerLabel,
                subtitle: l10n.devicePropertiesMotionThreshold1FingerSubtitle,
                lens: defaultDeviceMotionThresholdLens,
              ),
              numberTile(
                title: l10n.devicePropertiesMotionThreshold2FingerLabel,
                subtitle: l10n.devicePropertiesMotionThreshold2FingerSubtitle,
                lens: defaultDeviceMotionThreshold2Lens,
              ),
              numberTile(
                title: l10n.devicePropertiesMotionThreshold3FingerLabel,
                subtitle: l10n.devicePropertiesMotionThreshold3FingerSubtitle,
                lens: defaultDeviceMotionThreshold3Lens,
              ),
              numberTile(
                title: l10n.devicePropertiesSwipeAngleToleranceLabel,
                subtitle: l10n.devicePropertiesSwipeAngleToleranceSubtitle,
                lens: defaultDeviceSwipeAngleToleranceLens,
                min: 0,
                max: 45,
              ),
              intTile(
                title: l10n.devicePropertiesPressureFingerLabel,
                subtitle: l10n.devicePropertiesPressureFingerSubtitle,
                lens: defaultDevicePressureRangesFingerLens,
              ),
              intTile(
                title: l10n.devicePropertiesPressureThumbLabel,
                subtitle: l10n.devicePropertiesPressureThumbSubtitle,
                lens: defaultDevicePressureRangesThumbLens,
              ),
              intTile(
                title: l10n.devicePropertiesPressurePalmLabel,
                subtitle: l10n.devicePropertiesPressurePalmSubtitle,
                lens: defaultDevicePressureRangesPalmLens,
              ),
            ],
            if (section == DeviceSettingsSection.touchscreen) ...[
              numberTile(
                title: l10n.devicePropertiesMotionThresholdLabel,
                subtitle:
                    l10n.devicePropertiesMotionThresholdTouchscreenSubtitle,
                lens: defaultDeviceMotionThresholdLens,
              ),
              numberTile(
                title: l10n.devicePropertiesSwipeAngleToleranceLabel,
                subtitle: l10n.devicePropertiesSwipeAngleToleranceSubtitle,
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
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (value != null)
          GestureDetector(
            onTap: () => onChanged(null),
            child: Text(
              l10n.fieldResetButton,
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

class _NumberField extends HookWidget {
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

  String _fmt(double? v) {
    if (v == null) return '';
    return isInt ? v.toInt().toString() : v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: _fmt(value));
    final focused = useRef(false);

    final prevValue = usePrevious(value);
    if (prevValue != value && !focused.value) {
      controller.text = _fmt(value);
    }

    void commit(String text) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        onChanged(null);
        return;
      }
      final parsed = double.tryParse(trimmed);
      if (parsed == null) {
        controller.text = _fmt(value);
        return;
      }
      var clamped = parsed;
      final mn = min;
      final mx = max;
      if (mn != null && clamped < mn) clamped = mn;
      if (mx != null && clamped > mx) clamped = mx;
      onChanged(clamped);
      if (clamped != parsed) controller.text = _fmt(clamped);
    }

    return SizedBox(
      width: 100,
      child: Focus(
        onFocusChange: (f) {
          focused.value = f;
          if (!f) commit(controller.text);
        },
        child: FTextField(
          control: FTextFieldControl.managed(
            controller: controller,
            onChange: (_) {},
          ),
          hint: context.l10n.fieldDefaultHint,
          onSubmit: commit,
        ),
      ),
    );
  }
}
