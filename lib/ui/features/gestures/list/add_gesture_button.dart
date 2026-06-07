import 'package:animations/animations.dart';
import 'package:flutter/material.dart' show Colors, Durations, Easing, Icons;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';

enum _DialogStep { device, type }

Future<void> showAddGestureDialogForDevice(
  BuildContext context,
  DeviceType device,
  void Function(DeviceType device, Gesture gesture) onGestureAdded,
) async {
  final types = _triggerTypesFor(device, context.l10n);
  if (types.length == 1) {
    onGestureAdded(device, types.single.factory());
    return;
  }
  await _showTypePicker(context, device, onGestureAdded, types: types);
}

Future<void> _showTypePicker(
  BuildContext context,
  DeviceType device,
  void Function(DeviceType, Gesture) onGestureAdded, {
  List<_TriggerEntry>? types,
}) async {
  final availableTypes = types ?? _triggerTypesFor(device, context.l10n);
  await showFDialog<void>(
    context: context,
    builder: (ctx, style, animation) => AppDialog(
      animation: animation,
      title: Text(
        context.l10n.addGestureForDevice(
          gestureDeviceLabel(device, context.l10n),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              context.l10n.addGestureSelectTemplate(
                gestureDeviceNoun(device, context.l10n),
              ),
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
          child: Text(context.l10n.actionCancel),
        ),
      ],
    ),
  );
}

class AddGestureButton extends StatelessWidget {
  const AddGestureButton({
    required this.deviceFilter,
    required this.onGestureAdded,
    super.key,
  });

  final DeviceType? deviceFilter;
  final void Function(DeviceType device, Gesture gesture) onGestureAdded;

  @override
  Widget build(BuildContext context) {
    return FButton(
      size: .sm,
      onPress: () => _show(context),
      prefix: const Icon(FLucideIcons.plus),
      child: Text(context.l10n.addGestureTitle),
    );
  }

  Future<void> _show(BuildContext context) async {
    if (deviceFilter == null) {
      await _showDeviceThenTypePicker(context);
    } else {
      await showAddGestureDialogForDevice(
        context,
        deviceFilter!,
        onGestureAdded,
      );
    }
  }

  Future<void> _showDeviceThenTypePicker(BuildContext context) {
    return showFDialog<void>(
      context: context,
      builder: (ctx, style, animation) => _AddGestureDialogContent(
        dialogAnimation: animation,
        onGestureAdded: onGestureAdded,
      ),
    );
  }
}

class _AddGestureDialogContent extends StatefulWidget {
  const _AddGestureDialogContent({
    required this.dialogAnimation,
    required this.onGestureAdded,
  });

  final Animation<double> dialogAnimation;
  final void Function(DeviceType device, Gesture gesture) onGestureAdded;

  @override
  State<_AddGestureDialogContent> createState() =>
      _AddGestureDialogContentState();
}

class _AddGestureDialogContentState extends State<_AddGestureDialogContent> {
  _DialogStep _step = _DialogStep.device;
  DeviceType? _selectedDevice;
  bool _forward = true;

  void _onDeviceSelected(DeviceType device) {
    final types = _triggerTypesFor(device, context.l10n);
    if (types.length == 1) {
      Navigator.of(context).pop();
      widget.onGestureAdded(device, types.single.factory());
      return;
    }
    setState(() {
      _selectedDevice = device;
      _step = _DialogStep.type;
      _forward = true;
    });
  }

  void _onBack() {
    setState(() {
      _step = _DialogStep.device;
      _forward = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final device = _selectedDevice;

    return AppDialog(
      animation: widget.dialogAnimation,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedCrossFade(
            firstChild: const SizedBox(
              width: 1,
              height: 34,
            ),
            secondChild: FButton(
              size: .sm,
              variant: .ghost,
              onPress: _onBack,
              child: const Icon(FLucideIcons.arrowLeft, size: 16),
            ),
            crossFadeState: _step == _DialogStep.device
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Durations.medium1,
            reverseDuration: Durations.medium1,
            sizeCurve: Easing.emphasizedDecelerate,
            firstCurve: Easing.emphasizedDecelerate,
          ),
          const SizedBox(width: 4),
          if (_step == _DialogStep.type)
            Text(
              l10n.addGestureForDevice(gestureDeviceLabel(device!, l10n)),
            )
          else
            Text(l10n.addGestureTitle),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: PageTransitionSwitcher(
          reverse: !_forward,
          transitionBuilder: (child, animation, secondaryAnimation) =>
              SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                fillColor: Colors.transparent,
                child: child,
              ),
          child: _step == _DialogStep.device
              ? _buildDeviceList(l10n)
              : _buildTypeList(l10n, device!),
        ),
      ),
      actions: [
        FButton(
          variant: .outline,
          onPress: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
      ],
    );
  }

  Widget _buildDeviceList(AppLocalizations l10n) {
    return Column(
      key: const ValueKey(_DialogStep.device),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.addGestureChooseDevice,
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        for (final d in DeviceType.values)
          _DeviceTile(device: d, onTap: () => _onDeviceSelected(d)),
      ],
    );
  }

  Widget _buildTypeList(AppLocalizations l10n, DeviceType device) {
    return ListView(
      key: const ValueKey(_DialogStep.type),
      shrinkWrap: true,
      children: [
        Text(
          l10n.addGestureSelectTemplate(gestureDeviceNoun(device, l10n)),
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        for (final type in _triggerTypesFor(device, l10n))
          _TypeTile(
            type: type,
            onTap: () {
              Navigator.of(context).pop();
              widget.onGestureAdded(device, type.factory());
            },
          ),
      ],
    );
  }
}

typedef _TriggerEntry = ({
  String label,
  String description,
  IconData icon,
  Gesture Function() factory,
});

const _common = TriggerCommon();

List<_TriggerEntry> _triggerTypesFor(
  DeviceType device,
  AppLocalizations l10n,
) => switch (device) {
  DeviceType.mouse => [
    (
      label: l10n.gestureTypeStroke,
      description: l10n.templateMouseStrokeDescription,
      icon: Icons.gesture_outlined,
      factory: () => const StrokeGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeSwipe,
      description: l10n.templateMouseSwipeDescription,
      icon: Icons.swipe_outlined,
      factory: () => const SwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: l10n.gestureTypeCircle,
      description: l10n.templateMouseCircleDescription,
      icon: Icons.rotate_right_rounded,
      factory: () => const CircleGesture(
        common: _common,
        direction: CircleDirection.any,
      ),
    ),
    (
      label: l10n.gestureTypePress,
      description: l10n.templateMousePressDescription,
      icon: Icons.touch_app_rounded,
      factory: () => const PressGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeWheel,
      description: l10n.templateMouseWheelDescription,
      icon: Icons.unfold_more_rounded,
      factory: () => const WheelGesture(
        common: _common,
        direction: WheelDirection.any,
      ),
    ),
  ],
  DeviceType.keyboard => [
    (
      label: l10n.gestureTypeShortcut,
      description: l10n.templateKeyboardShortcutDescription,
      icon: Icons.keyboard_alt_outlined,
      factory: () => const ShortcutGesture(common: _common),
    ),
  ],
  DeviceType.pointer => [
    (
      label: l10n.gestureTypeHover,
      description: l10n.templatePointerHoverDescription,
      icon: Icons.ads_click_outlined,
      factory: () => const HoverGesture(common: _common),
    ),
  ],
  DeviceType.touchpad => [
    (
      label: l10n.gestureTypeSwipe,
      description: l10n.templateTouchpadSwipeDescription,
      icon: Icons.swipe_outlined,
      factory: () => const TouchpadSwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: l10n.gestureTypePinch,
      description: l10n.templateTouchpadPinchDescription,
      icon: Icons.pinch_outlined,
      factory: () => const TouchpadPinchGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeRotate,
      description: l10n.templateTouchpadRotateDescription,
      icon: Icons.rotate_right_rounded,
      factory: () => const TouchpadRotateGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeCircle,
      description: l10n.templateTouchpadCircleDescription,
      icon: Icons.motion_photos_on_outlined,
      factory: () => const TouchpadCircleGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeTap,
      description: l10n.templateTouchpadTapDescription,
      icon: Icons.touch_app_rounded,
      factory: () => const TouchpadTapGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeClick,
      description: l10n.templateTouchpadClickDescription,
      icon: Icons.mouse_outlined,
      factory: () => const TouchpadClickGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeHold,
      description: l10n.templateTouchpadHoldDescription,
      icon: Icons.pan_tool_outlined,
      factory: () => const TouchpadHoldGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeStroke,
      description: l10n.templateTouchpadStrokeDescription,
      icon: Icons.gesture_outlined,
      factory: () => const TouchpadStrokeGesture(common: _common),
    ),
  ],
  DeviceType.touchscreen => [
    (
      label: l10n.gestureTypeSwipe,
      description: l10n.templateTouchscreenSwipeDescription,
      icon: Icons.swipe_outlined,
      factory: () => const TouchscreenSwipeGesture(
        common: _common,
        mode: SwipeDirectionMode(direction: SwipeDirection.any),
      ),
    ),
    (
      label: l10n.gestureTypePinch,
      description: l10n.templateTouchscreenPinchDescription,
      icon: Icons.pinch_outlined,
      factory: () => const TouchscreenPinchGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeRotate,
      description: l10n.templateTouchscreenRotateDescription,
      icon: Icons.rotate_right_rounded,
      factory: () => const TouchscreenRotateGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeCircle,
      description: l10n.templateTouchscreenCircleDescription,
      icon: Icons.motion_photos_on_outlined,
      factory: () => const TouchscreenCircleGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeTap,
      description: l10n.templateTouchscreenTapDescription,
      icon: Icons.touch_app_rounded,
      factory: () => const TouchscreenTapGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeHold,
      description: l10n.templateTouchscreenHoldDescription,
      icon: Icons.pan_tool_outlined,
      factory: () => const TouchscreenHoldGesture(common: _common),
    ),
    (
      label: l10n.gestureTypeStroke,
      description: l10n.templateTouchscreenStrokeDescription,
      icon: Icons.gesture_outlined,
      factory: () => const TouchscreenStrokeGesture(common: _common),
    ),
  ],
};

String _deviceDescription(DeviceType device, AppLocalizations l10n) =>
    switch (device) {
      DeviceType.mouse => l10n.deviceDescriptionMouse,
      DeviceType.keyboard => l10n.deviceDescriptionKeyboard,
      DeviceType.pointer => l10n.deviceDescriptionPointer,
      DeviceType.touchpad => l10n.deviceDescriptionTouchpad,
      DeviceType.touchscreen => l10n.deviceDescriptionTouchscreen,
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
    final l10n = context.l10n;
    final gestureCount = _triggerTypesFor(device, l10n).length;
    return _OptionTile(
      icon: _deviceIcon(device),
      title: gestureDeviceLabel(device, l10n),
      description:
          '${_deviceDescription(device, l10n)} $gestureCount'
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
