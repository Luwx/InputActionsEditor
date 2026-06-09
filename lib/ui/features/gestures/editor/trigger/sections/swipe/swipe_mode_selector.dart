import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/angle_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/direction_picker.dart';

/// Standalone swipe mode picker / direction wheel or angle range.
/// Used by both the mouse SwipeSection and touch gesture editors.
class SwipeModeSelector extends HookWidget {
  const SwipeModeSelector({
    required this.mode,
    required this.onModeChanged,
    super.key,
  });

  final SwipeMode mode;
  final void Function(SwipeMode) onModeChanged;

  bool get _useDirection => mode is SwipeDirectionMode;

  void _setDirection(SwipeDirection dir) =>
      onModeChanged(SwipeDirectionMode(direction: dir));

  void _setAngleMode(SwipeAngleMode m) => onModeChanged(m);

  @override
  Widget build(BuildContext context) {
    const cardSpacing = 12.0;
    const directionMinWidth = 250.0;
    const angleMinWidth = 280.0;
    const anglePreferredWidth = 300.0;
    const maxCardWidth = 350.0;

    final savedDirection = useState<SwipeDirectionMode>(
      mode is SwipeDirectionMode
          ? mode as SwipeDirectionMode
          : const SwipeDirectionMode(direction: SwipeDirection.any),
    );
    final savedAngle = useState<SwipeAngleMode>(
      mode is SwipeAngleMode
          ? mode as SwipeAngleMode
          : const SwipeAngleMode(minAngle: 0, maxAngle: 45),
    );

    void setMode(bool toDirection) {
      if (toDirection == _useDirection) return;
      if (toDirection) {
        savedAngle.value = mode as SwipeAngleMode;
        onModeChanged(savedDirection.value);
      } else {
        savedDirection.value = mode as SwipeDirectionMode;
        onModeChanged(savedAngle.value);
      }
    }

    final directionMode = mode is SwipeDirectionMode
        ? mode as SwipeDirectionMode
        : savedDirection.value;
    final angleMode = mode is SwipeAngleMode
        ? mode as SwipeAngleMode
        : savedAngle.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Swipe',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final pairedWidth = availableWidth - cardSpacing;
            const minPairedWidth = directionMinWidth + angleMinWidth;
            final equalWidth = pairedWidth / 2;
            final canShowSideBySide = pairedWidth >= minPairedWidth;
            final useEqualWidths = equalWidth >= anglePreferredWidth;

            late final double directionWidth;
            late final double angleWidth;

            if (!canShowSideBySide) {
              final stackedWidth = math.min(availableWidth, maxCardWidth);
              directionWidth = stackedWidth;
              angleWidth = stackedWidth;
            } else if (useEqualWidths) {
              final sharedWidth = math.min(equalWidth, maxCardWidth);
              directionWidth = sharedWidth;
              angleWidth = sharedWidth;
            } else {
              angleWidth = math.min(anglePreferredWidth, maxCardWidth);
              directionWidth = pairedWidth - angleWidth;
            }

            final directionCard = SizedBox(
              width: directionWidth,
              child: _SwipeModeCard(
                title: 'Direction',
                selected: _useDirection,
                onTap: () => setMode(true),
                child: DirectionPicker(
                  direction: directionMode.direction,
                  onChanged: _setDirection,
                ),
              ),
            );

            final angleCard = SizedBox(
              width: angleWidth,
              child: _SwipeModeCard(
                title: 'Angle range',
                selected: !_useDirection,
                onTap: () => setMode(false),
                child: AnglePicker(
                  mode: angleMode,
                  onChanged: _setAngleMode,
                ),
              ),
            );

            if (canShowSideBySide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  directionCard,
                  const SizedBox(width: cardSpacing),
                  angleCard,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                directionCard,
                const SizedBox(height: cardSpacing),
                angleCard,
              ],
            );
          },
        ),
        // const SizedBox(height: 12),
      ],
    );
  }
}

class _SwipeModeCard extends StatelessWidget {
  const _SwipeModeCard({
    required this.title,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final titleStyle = context.theme.typography.sm.copyWith(
      fontWeight: FontWeight.w600,
      color: selected ? colors.foreground : colors.mutedForeground,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card.withValues(alpha: selected ? 1 : 0.65),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: titleStyle),
            const SizedBox(height: 8),
            IgnorePointer(
              ignoring: !selected,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: selected ? 1 : 0.55,
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
