import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

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
    final s = settings ?? const SpeedSettings();
    final sectionState = ref.watch(
      rootConfigDirtyStateProvider(switch (device) {
        DeviceType.mouse => RootConfigDirtyField.mouseSpeed,
        DeviceType.touchpad => RootConfigDirtyField.touchpadSpeed,
        DeviceType.touchscreen => RootConfigDirtyField.touchscreenSpeed,
        _ => RootConfigDirtyField.mouseSpeed,
      }),
    );
    final sectionField = ref.field(
      speedSettingsLens(device),
      fallbackValue: () => s,
    );
    final eventsField = ref.field(
      speedEventsLens(device),
      fallbackValue: () => s.events,
    );
    final swipeThresholdField = ref.field(
      speedSwipeThresholdLens(device),
      fallbackValue: () => s.swipeThreshold,
    );
    final pinchInThresholdField = ref.field(
      speedPinchInThresholdLens(device),
      fallbackValue: () => s.pinchInThreshold,
    );
    final pinchOutThresholdField = ref.field(
      speedPinchOutThresholdLens(device),
      fallbackValue: () => s.pinchOutThreshold,
    );
    final rotateThresholdField = ref.field(
      speedRotateThresholdLens(device),
      fallbackValue: () => s.rotateThreshold,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FTileGroup(
          divider: .full,
          label: UnsavedLabel(
            state: sectionState,
            onRevert: sectionField.onRevert,
            child: const Text('Speed Settings'),
          ),
          description: const Text(
            'Controls how motion trigger speed is determined.',
          ),
          children: [
            FTile(
              title: UnsavedLabel(
                state: eventsField.dirty,
                onRevert: eventsField.onRevert,
                child: const Text('Input Events to Sample'),
              ),
              subtitle: const Text(
                'How many input events to sample to determine speed.'
                ' No triggers start until all events are sampled.',
              ),
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
                child: const Text('Swipe Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a swipe as "fast".',
              ),
              suffix: _SpeedField(
                value: swipeThresholdField.value,
                hint: '20',
                onChanged: swipeThresholdField.onChanged,
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: pinchInThresholdField.dirty,
                onRevert: pinchInThresholdField.onRevert,
                child: const Text('Pinch-In Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a pinch-in as "fast".',
              ),
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
                child: const Text('Pinch-Out Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a pinch-out as "fast".',
              ),
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
                child: const Text('Rotate Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a rotation as "fast".',
              ),
              suffix: _SpeedField(
                value: rotateThresholdField.value,
                hint: '5',
                onChanged: rotateThresholdField.onChanged,
              ),
            ),
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
