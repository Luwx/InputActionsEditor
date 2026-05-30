import 'package:flutter/material.dart' show Durations, Easing, Icons;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';

class AddGestureButton extends StatelessWidget {
  const AddGestureButton({
    required this.deviceFilter,
    required this.onGestureAdded,
    super.key,
  });

  final DeviceType? deviceFilter;
  final void Function(DeviceType device, Object gesture) onGestureAdded;

  @override
  Widget build(BuildContext context) {
    return FButton(
      size: .sm,
      onPress: () => _show(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FLucideIcons.plus),
          SizedBox(width: 4),
          Text('Add gesture'),
        ],
      ),
    );
  }

  Future<void> _show(BuildContext context) async {
    if (deviceFilter == null) {
      await _showDeviceThenTypePicker(context);
    } else {
      await _showTypePickerOrAdd(context, deviceFilter!);
    }
  }

  Future<void> _showDeviceThenTypePicker(BuildContext context) async {
    await showFDialog<void>(
      context: context,
      builder: (ctx, style, animation) => AppDialog(
        animation: animation,
        title: const Text('Add gesture'),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose the device you want to add a gesture for.',
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              for (final device in DeviceType.values)
                _DeviceTile(
                  device: device,
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await Future<void>.delayed(
                      Durations.short4,
                    );
                    if (context.mounted) {
                      await _showTypePickerOrAdd(context, device);
                    }
                  },
                ),
            ],
          ),
        ),
        actions: [
          FButton(
            variant: .outline,
            onPress: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTypePickerOrAdd(BuildContext context, DeviceType device) {
    final types = _triggerTypesFor(device);
    if (types.length == 1) {
      onGestureAdded(device, types.single.factory());
      return Future.value();
    }

    return _showTypePicker(context, device, types: types);
  }

  Future<void> _showTypePicker(
    BuildContext context,
    DeviceType device, {
    List<_TriggerEntry>? types,
  }) async {
    final availableTypes = types ?? _triggerTypesFor(device);
    await showFDialog<void>(
      context: context,
      builder: (ctx, style, animation) => AppDialog(
        animation: animation,
        title: Text('Add ${_deviceTitle(device)} gesture'),
        body: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Select a gesture template'
                ' for ${gestureDeviceNoun(device)} input.',
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 12),
              for (final type in availableTypes)
                _TypeTile(
                  type: type,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onGestureAdded(device, type.factory());
                  },
                ),
            ],
          ),
        ),
        actions: [
          FButton(
            variant: .outline,
            onPress: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}


typedef _TriggerEntry = ({
  String label,
  String description,
  IconData icon,
  Object Function() factory,
});

const _common = TriggerCommon();

List<_TriggerEntry> _triggerTypesFor(DeviceType device) => switch (device) {
  DeviceType.mouse => [
    (
      label: 'Stroke',
      description: 'Draw a freeform path with the mouse.',
      icon: Icons.gesture_outlined,
      factory: () => const StrokeGesture(common: _common),
    ),
    (
      label: 'Swipe',
      description: 'Recognize directional mouse movement.',
      icon: Icons.swipe_outlined,
      factory: () => const SwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: 'Circle',
      description: 'Match circular movement in either direction.',
      icon: Icons.rotate_right_rounded,
      factory: () => const CircleGesture(
        common: _common,
        direction: CircleDirection.any,
      ),
    ),
    (
      label: 'Press',
      description: 'Trigger from a button press or hold.',
      icon: Icons.touch_app_rounded,
      factory: () => const PressGesture(common: _common),
    ),
    (
      label: 'Wheel',
      description: 'Use scroll wheel direction as the trigger.',
      icon: Icons.unfold_more_rounded,
      factory: () => const WheelGesture(
        common: _common,
        direction: WheelDirection.any,
      ),
    ),
  ],
  DeviceType.keyboard => [
    (
      label: 'Shortcut',
      description: 'Match a keyboard shortcut or key chord.',
      icon: Icons.keyboard_alt_outlined,
      factory: () => const ShortcutGesture(common: _common),
    ),
  ],
  DeviceType.pointer => [
    (
      label: 'Hover',
      description: 'Trigger while the pointer hovers over a region.',
      icon: Icons.ads_click_outlined,
      factory: () => const HoverGesture(common: _common),
    ),
  ],
  DeviceType.touchpad => [
    (
      label: 'Swipe',
      description: 'Track directional touchpad swipes.',
      icon: Icons.swipe_outlined,
      factory: () => const TouchpadSwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: 'Pinch',
      description: 'Detect pinch-in and pinch-out gestures.',
      icon: Icons.pinch_outlined,
      factory: () => const TouchpadPinchGesture(common: _common),
    ),
    (
      label: 'Rotate',
      description: 'Recognize two-finger rotation.',
      icon: Icons.rotate_right_rounded,
      factory: () => const TouchpadRotateGesture(common: _common),
    ),
    (
      label: 'Circle',
      description: 'Track circular movement on the pad.',
      icon: Icons.motion_photos_on_outlined,
      factory: () => const TouchpadCircleGesture(common: _common),
    ),
    (
      label: 'Tap',
      description: 'Trigger on a touchpad tap.',
      icon: Icons.touch_app_rounded,
      factory: () => const TouchpadTapGesture(common: _common),
    ),
    (
      label: 'Click',
      description: 'Use a physical or integrated click.',
      icon: Icons.mouse_outlined,
      factory: () => const TouchpadClickGesture(common: _common),
    ),
    (
      label: 'Hold',
      description: 'Keep fingers down for a press-and-hold trigger.',
      icon: Icons.pan_tool_outlined,
      factory: () => const TouchpadHoldGesture(common: _common),
    ),
    (
      label: 'Stroke',
      description: 'Draw a freeform path on the touchpad surface.',
      icon: Icons.gesture_outlined,
      factory: () => const TouchpadStrokeGesture(common: _common),
    ),
  ],
  DeviceType.touchscreen => [
    (
      label: 'Swipe',
      description: 'Recognize directional finger swipes.',
      icon: Icons.swipe_outlined,
      factory: () => const TouchscreenSwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: 'Pinch',
      description: 'Detect zoom-style pinch gestures.',
      icon: Icons.pinch_outlined,
      factory: () => const TouchscreenPinchGesture(common: _common),
    ),
    (
      label: 'Rotate',
      description: 'Track multi-finger rotation on the screen.',
      icon: Icons.rotate_right_rounded,
      factory: () => const TouchscreenRotateGesture(common: _common),
    ),
    (
      label: 'Circle',
      description: 'Match a circular finger motion.',
      icon: Icons.motion_photos_on_outlined,
      factory: () => const TouchscreenCircleGesture(common: _common),
    ),
    (
      label: 'Tap',
      description: 'Trigger on a screen tap.',
      icon: Icons.touch_app_rounded,
      factory: () => const TouchscreenTapGesture(common: _common),
    ),
    (
      label: 'Hold',
      description: 'Use a long press gesture.',
      icon: Icons.pan_tool_outlined,
      factory: () => const TouchscreenHoldGesture(common: _common),
    ),
    (
      label: 'Stroke',
      description: 'Draw a freeform path on the screen.',
      icon: Icons.gesture_outlined,
      factory: () => const TouchscreenStrokeGesture(common: _common),
    ),
  ],
};

String _deviceTitle(DeviceType device) => gestureDeviceLabel(device);

String _deviceDescription(DeviceType device) => switch (device) {
  DeviceType.mouse => 'Buttons, wheel movement, strokes, and pointer motion.',
  DeviceType.keyboard => 'Shortcuts and key combinations.',
  DeviceType.pointer => 'Pointer hover gestures.',
  DeviceType.touchpad => 'Multi-finger gestures on a trackpad surface.',
  DeviceType.touchscreen => 'Direct touch gestures on a screen.',
};

IconData _deviceIcon(DeviceType device) => switch (device) {
  DeviceType.mouse => Icons.mouse_outlined,
  DeviceType.keyboard => Icons.keyboard_outlined,
  DeviceType.pointer => Icons.ads_click_outlined,
  DeviceType.touchpad => Icons.pan_tool_outlined,
  DeviceType.touchscreen => Icons.smartphone_outlined,
};

// ---------------------------------------------------------------------------
// UI helpers
// ---------------------------------------------------------------------------

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.device,
    required this.onTap,
  });

  final DeviceType device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gestureCount = _triggerTypesFor(device).length;
    return _OptionTile(
      icon: _deviceIcon(device),
      title: _deviceTitle(device),
      description:
          '${_deviceDescription(device)} $gestureCount'
          'gesture type${gestureCount == 1 ? '' : 's'} available.',
      onTap: onTap,
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.type,
    required this.onTap,
  });

  final _TriggerEntry type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: type.icon,
      title: type.label,
      description: type.description,
      onTap: onTap,
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final hoveredNotifier = ValueNotifier(false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ValueListenableBuilder<bool>(
        valueListenable: hoveredNotifier,
        builder: (context, hovered, _) {
          return FTile(
            onPress: onTap,
            onHoverChange: (hovering) => hoveredNotifier.value = hovering,
            title: Text(title),
            subtitle: Text(description),
            prefix: AnimatedContainer(
              duration: Durations.short2,
              curve: Easing.standard,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color.lerp(
                  colors.secondary,
                  colors.primary,
                  hovered ? 0.12 : 0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: colors.secondaryForeground,
              ),
            ),
          );
        },
      ),
    );
  }
}
