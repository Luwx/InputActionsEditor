import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class SpeedSettingsEditor extends ConsumerWidget {
  const SpeedSettingsEditor({
    required this.device,
    required this.settings,
    super.key,
  });

  final DeviceType device;
  final SpeedSettings? settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = settings ?? const SpeedSettings();
    final sectionState = ref.watch(
      rootConfigDirtyStateProvider(switch (device) {
        DeviceType.mouse => RootConfigDirtyField.mouseSpeed,
        DeviceType.touchpad => RootConfigDirtyField.touchpadSpeed,
        DeviceType.touchscreen => RootConfigDirtyField.touchscreenSpeed,
        _ => RootConfigDirtyField.mouseSpeed,
      }),
    );
    final sectionField = ref.settingsField(
      speedSettingsLens(device),
      fallbackValue: () => s,
    );
    final eventsField = ref.settingsField(
      speedEventsLens(device),
      fallbackValue: () => s.events,
    );
    final swipeThresholdField = ref.settingsField(
      speedSwipeThresholdLens(device),
      fallbackValue: () => s.swipeThreshold,
    );
    final pinchInThresholdField = ref.settingsField(
      speedPinchInThresholdLens(device),
      fallbackValue: () => s.pinchInThreshold,
    );
    final pinchOutThresholdField = ref.settingsField(
      speedPinchOutThresholdLens(device),
      fallbackValue: () => s.pinchOutThreshold,
    );
    final rotateThresholdField = ref.settingsField(
      speedRotateThresholdLens(device),
      fallbackValue: () => s.rotateThreshold,
    );
    final multiTouch = device != DeviceType.mouse;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FTileGroup(
          divider: .full,
          label: UnsavedLabel(
            state: sectionState,
            onRevert: sectionField.onRevert,
            child: Text(l10n.speedSettingsTitle),
          ),
          description: Text(l10n.speedSettingsDescription),
          children: [
            FTile(
              title: UnsavedLabel(
                state: eventsField.dirty,
                onRevert: eventsField.onRevert,
                child: Text(l10n.speedEventsLabel),
              ),
              subtitle: Text(l10n.speedEventsSubtitle),
              suffix: _SpeedField(
                value: eventsField.value?.toDouble(),
                isInt: true,
                hint: '3',
                onChanged: (v) => eventsField.onChanged(v?.toInt()),
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: swipeThresholdField.dirty,
                onRevert: swipeThresholdField.onRevert,
                child: Text(l10n.speedSwipeThresholdLabel),
              ),
              subtitle: Text(l10n.speedSwipeThresholdSubtitle),
              suffix: _SpeedField(
                value: swipeThresholdField.value,
                hint: '20',
                onChanged: swipeThresholdField.onChanged,
              ),
            ),
            if (multiTouch) ...[
              FTile(
                title: UnsavedLabel(
                  state: pinchInThresholdField.dirty,
                  onRevert: pinchInThresholdField.onRevert,
                  child: Text(l10n.speedPinchInThresholdLabel),
                ),
                subtitle: Text(l10n.speedPinchInThresholdSubtitle),
                suffix: _SpeedField(
                  value: pinchInThresholdField.value,
                  hint: '0.04',
                  onChanged: pinchInThresholdField.onChanged,
                ),
              ),
              FTile(
                title: UnsavedLabel(
                  state: pinchOutThresholdField.dirty,
                  onRevert: pinchOutThresholdField.onRevert,
                  child: Text(l10n.speedPinchOutThresholdLabel),
                ),
                subtitle: Text(l10n.speedPinchOutThresholdSubtitle),
                suffix: _SpeedField(
                  value: pinchOutThresholdField.value,
                  hint: '0.08',
                  onChanged: pinchOutThresholdField.onChanged,
                ),
              ),
              FTile(
                title: UnsavedLabel(
                  state: rotateThresholdField.dirty,
                  onRevert: rotateThresholdField.onRevert,
                  child: Text(l10n.speedRotateThresholdLabel),
                ),
                subtitle: Text(l10n.speedRotateThresholdSubtitle),
                suffix: _SpeedField(
                  value: rotateThresholdField.value,
                  hint: '5',
                  onChanged: rotateThresholdField.onChanged,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SpeedField extends HookWidget {
  const _SpeedField({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.isInt = false,
  });

  final double? value;
  final String hint;
  final void Function(double?) onChanged;
  final bool isInt;

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
      } else {
        onChanged(parsed);
      }
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
          hint: hint,
          onSubmit: commit,
        ),
      ),
    );
  }
}
