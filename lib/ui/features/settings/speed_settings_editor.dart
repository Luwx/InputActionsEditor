import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/widgets/unsaved_marker.dart';

class SpeedSettingsEditor extends ConsumerWidget {
  const SpeedSettingsEditor({
    required this.device,
    required this.settings,
    required this.onChanged,
    super.key,
  });

  final DeviceType device;
  final SpeedSettings? settings;
  final void Function(SpeedSettings?) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settings ?? const SpeedSettings();
    final savedSettings = ref.watch(savedSpeedSettingsProvider(device));
    final sectionState = ref.watch(
      rootConfigDirtyStateProvider(switch (device) {
        DeviceType.mouse => RootConfigDirtyField.mouseSpeed,
        DeviceType.touchpad => RootConfigDirtyField.touchpadSpeed,
        DeviceType.touchscreen => RootConfigDirtyField.touchscreenSpeed,
        _ => RootConfigDirtyField.mouseSpeed,
      }),
    );

    void update(SpeedSettings updated) {
      onChanged(updated.isEmpty ? null : updated);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: FTileGroup(
          divider: .full,
          label: UnsavedLabel(
            state: sectionState,
            onRevert: savedSettings == null
                ? null
                : () => onChanged(savedSettings),
            child: const Text('Speed Settings'),
          ),
          description: const Text(
            'Controls how motion trigger speed is determined.',
          ),
          children: [
            FTile(
              title: UnsavedLabel(
                state: ref.watch(
                  speedSettingDirtyStateProvider(
                    SpeedSettingLocation(
                      device: device,
                      field: SpeedSettingDirtyField.events,
                    ),
                  ),
                ),
                onRevert: savedSettings == null
                    ? null
                    : () => update(s.copyWith(events: savedSettings.events)),
                child: const Text('Input Events to Sample'),
              ),
              subtitle: const Text(
                'How many input events to sample to determine speed.'
                ' No triggers start until all events are sampled.',
              ),
              suffix: _SpeedField(
                value: s.events?.toDouble(),
                isInt: true,
                hint: '3',
                onChanged: (v) => update(s.copyWith(events: v?.toInt())),
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: ref.watch(
                  speedSettingDirtyStateProvider(
                    SpeedSettingLocation(
                      device: device,
                      field: SpeedSettingDirtyField.swipeThreshold,
                    ),
                  ),
                ),
                onRevert: savedSettings == null
                    ? null
                    : () => update(
                        s.copyWith(
                          swipeThreshold: savedSettings.swipeThreshold,
                        ),
                      ),
                child: const Text('Swipe Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a swipe as "fast".',
              ),
              suffix: _SpeedField(
                value: s.swipeThreshold,
                hint: '20',
                onChanged: (v) => update(s.copyWith(swipeThreshold: v)),
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: ref.watch(
                  speedSettingDirtyStateProvider(
                    SpeedSettingLocation(
                      device: device,
                      field: SpeedSettingDirtyField.pinchInThreshold,
                    ),
                  ),
                ),
                onRevert: savedSettings == null
                    ? null
                    : () => update(
                        s.copyWith(
                          pinchInThreshold: savedSettings.pinchInThreshold,
                        ),
                      ),
                child: const Text('Pinch-In Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a pinch-in as "fast".',
              ),
              suffix: _SpeedField(
                value: s.pinchInThreshold,
                hint: '0.04',
                onChanged: (v) => update(s.copyWith(pinchInThreshold: v)),
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: ref.watch(
                  speedSettingDirtyStateProvider(
                    SpeedSettingLocation(
                      device: device,
                      field: SpeedSettingDirtyField.pinchOutThreshold,
                    ),
                  ),
                ),
                onRevert: savedSettings == null
                    ? null
                    : () => update(
                        s.copyWith(
                          pinchOutThreshold: savedSettings.pinchOutThreshold,
                        ),
                      ),
                child: const Text('Pinch-Out Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a pinch-out as "fast".',
              ),
              suffix: _SpeedField(
                value: s.pinchOutThreshold,
                hint: '0.08',
                onChanged: (v) => update(s.copyWith(pinchOutThreshold: v)),
              ),
            ),
            FTile(
              title: UnsavedLabel(
                state: ref.watch(
                  speedSettingDirtyStateProvider(
                    SpeedSettingLocation(
                      device: device,
                      field: SpeedSettingDirtyField.rotateThreshold,
                    ),
                  ),
                ),
                onRevert: savedSettings == null
                    ? null
                    : () => update(
                        s.copyWith(
                          rotateThreshold: savedSettings.rotateThreshold,
                        ),
                      ),
                child: const Text('Rotate Threshold'),
              ),
              subtitle: const Text(
                'Delta threshold to consider a rotation as "fast".',
              ),
              suffix: _SpeedField(
                value: s.rotateThreshold,
                hint: '5',
                onChanged: (v) => update(s.copyWith(rotateThreshold: v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedField extends StatefulWidget {
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

  @override
  State<_SpeedField> createState() => _SpeedFieldState();
}

class _SpeedFieldState extends State<_SpeedField> {
  late final TextEditingController _controller;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(_SpeedField old) {
    super.didUpdateWidget(old);
    if (!_focused && old.value != widget.value) {
      _controller.text = _fmt(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(double? v) {
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
      _controller.text = _fmt(widget.value);
    } else {
      widget.onChanged(parsed);
    }
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
          hint: widget.hint,
          onSubmit: _commit,
        ),
      ),
    );
  }
}
