import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/common/extensions.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

class MouseButtonsField extends ConsumerWidget {
  const MouseButtonsField({
    required this.device,
    required this.gestureIndex,
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final DeviceType device;
  final int gestureIndex;
  final MouseGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  void _toggle(MouseButtonValue btn) {
    final current = gesture.common.mouseButtons;
    final next = current.contains(btn)
        ? current.where((b) => b != btn).toList()
        : [...current, btn];
    onUpdate((g) => g.withCommon(g.common.copyWith(mouseButtons: next)));
  }

  void _toggleExactOrder(bool value) {
    onUpdate(
      (g) => g.withCommon(g.common.copyWith(mouseButtonsExactOrder: value)),
    );
  }

  static String _label(MouseButtonValue b) => switch (b) {
    MouseButtonValue.left => 'Left',
    MouseButtonValue.middle => 'Middle',
    MouseButtonValue.right => 'Right',
    MouseButtonValue.back => 'Back',
    MouseButtonValue.forward => 'Forward',
    MouseButtonValue.task => 'Task',
    MouseButtonValue.side => 'Side',
    MouseButtonValue.extra => 'Extra',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final common = gesture.common;
    final buttons = common.mouseButtons;
    final gestureLocation = GestureLocation(
      device: device,
      index: gestureIndex,
    );
    final dirtyState = ref.watch(
      gestureSectionDirtyStateProvider(
        GestureSectionLocation(
          gesture: gestureLocation,
          field: GestureSectionDirtyField.mouseButtons,
        ),
      ),
    );
    final savedCommon = ref.watch(savedGestureCommonProvider(gestureLocation));

    return _Section(
      title: 'Mouse buttons',
      dirtyState: dirtyState,
      onRevert: savedCommon == null
          ? null
          : () => onUpdate(
              (g) => g.withCommon(
                g.common.copyWith(
                  mouseButtons: savedCommon.mouseButtons,
                  mouseButtonsExactOrder: savedCommon.mouseButtonsExactOrder,
                ),
              ),
            ),
      titleTooltip:
          'Mouse buttons that must be held while performing this gesture.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final btn in MouseButtonValue.values)
                _ButtonChip(
                  label: _label(btn),
                  order: buttons.indexOf(btn),
                  onTap: () => _toggle(btn),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FCheckbox(
              value: common.mouseButtonsExactOrder,
              onChange: _toggleExactOrder,
              label: const LabelWithTooltip(
                label: 'Exact order',
                tooltip:
                    'Require buttons to be pressed in exactly the order shown. '
                    'When disabled, all selected buttons must be held '
                    'but in any order.',
              ),
            ),
          ).appearToggle(visible: buttons.length > 1),
        ],
      ),
    );
  }
}

class _ButtonChip extends StatelessWidget {
  const _ButtonChip({
    required this.label,
    required this.order,
    required this.onTap,
  });

  final String label;
  final int order; // -1 if not selected
  final VoidCallback onTap;

  bool get _selected => order >= 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return SizedBox(
      width: 100,
      child: FButton(
        variant: _selected ? .primary : .outline,
        size: .sm,
        onPress: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _OrderBadge(
                  number: order + 1,
                  background: colors.primaryForeground,
                  foreground: colors.primary,
                ),
              ).appearToggle(
                visible: _selected,
                axis: Axis.horizontal,
                alignment: Alignment.centerLeft,
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({
    required this.number,
    required this.background,
    required this.foreground,
  });

  final int number;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.dirtyState,
    this.titleTooltip,
    this.onRevert,
  });

  final String title;
  final Widget child;
  final DirtyMarkState? dirtyState;
  final String? titleTooltip;
  final VoidCallback? onRevert;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.theme.typography.sm.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titleTooltip != null)
            UnsavedLabel(
              state: dirtyState,
              onRevert: onRevert,
              child: LabelWithTooltip(
                label: title,
                tooltip: titleTooltip!,
                textStyle: titleStyle,
              ),
            )
          else
            UnsavedLabel(
              state: dirtyState,
              onRevert: onRevert,
              child: Text(title, style: titleStyle),
            ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
