import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/angle_picker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/direction_picker.dart';

/// Standalone swipe mode picker / direction wheel or angle range.
/// Used by both the mouse SwipeSection and touch gesture editors.
class SwipeModeSelector extends StatefulWidget {
  const SwipeModeSelector({
    required this.mode,
    required this.onModeChanged,
    super.key,
  });

  final SwipeMode mode;
  final void Function(SwipeMode) onModeChanged;

  @override
  State<SwipeModeSelector> createState() => _SwipeModeSelectorState();
}

class _SwipeModeSelectorState extends State<SwipeModeSelector> {
  static const _cardSpacing = 12.0;
  static const _directionMinWidth = 250.0;
  static const _angleMinWidth = 280.0;
  static const _anglePreferredWidth = 300.0;
  static const _maxCardWidth = 350.0;

  late SwipeDirectionMode _savedDirection;
  late SwipeAngleMode _savedAngle;

  @override
  void initState() {
    super.initState();
    final mode = widget.mode;
    _savedDirection = mode is SwipeDirectionMode
        ? mode
        : const SwipeDirectionMode(direction: SwipeDirection.any);
    _savedAngle = mode is SwipeAngleMode
        ? mode
        : const SwipeAngleMode(minAngle: 0, maxAngle: 45);
  }

  bool get _useDirection => widget.mode is SwipeDirectionMode;

  void _setDirection(SwipeDirection dir) =>
      widget.onModeChanged(SwipeDirectionMode(direction: dir));

  void _setAngleMode(SwipeAngleMode mode) => widget.onModeChanged(mode);

  void _setMode(bool toDirection) {
    if (toDirection == _useDirection) return;

    if (toDirection) {
      _savedAngle = widget.mode as SwipeAngleMode;
      widget.onModeChanged(_savedDirection);
    } else {
      _savedDirection = widget.mode as SwipeDirectionMode;
      widget.onModeChanged(_savedAngle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final directionMode = mode is SwipeDirectionMode ? mode : _savedDirection;
    final angleMode = mode is SwipeAngleMode ? mode : _savedAngle;

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
            final pairedWidth = availableWidth - _cardSpacing;
            const minPairedWidth = _directionMinWidth + _angleMinWidth;
            final equalWidth = pairedWidth / 2;
            final canShowSideBySide = pairedWidth >= minPairedWidth;
            final useEqualWidths = equalWidth >= _anglePreferredWidth;

            late final double directionWidth;
            late final double angleWidth;

            // print(
            //   'availableWidth: $availableWidth, pairedWidth: $pairedWidth, '
            //   'equalWidth: $equalWidth, canStackSideBySide:
            //$canStackSideBySide, '
            //   'useEqualWidths: $useEqualWidths',
            // );

            if (!canShowSideBySide) {
              final stackedWidth = math.min(availableWidth, _maxCardWidth);
              directionWidth = stackedWidth;
              angleWidth = stackedWidth;
            } else if (useEqualWidths) {
              final sharedWidth = math.min(equalWidth, _maxCardWidth);
              directionWidth = sharedWidth;
              angleWidth = sharedWidth;
            } else {
              angleWidth = math.min(_anglePreferredWidth, _maxCardWidth);
              directionWidth = pairedWidth - angleWidth;
            }

            final directionCard = SizedBox(
              width: directionWidth,
              child: _SwipeModeCard(
                title: 'Direction',
                selected: _useDirection,
                onTap: () => _setMode(true),
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
                onTap: () => _setMode(false),
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
                  const SizedBox(width: _cardSpacing),
                  angleCard,
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                directionCard,
                const SizedBox(height: _cardSpacing),
                angleCard,
              ],
            );
          },
        ),
        const SizedBox(height: 12),
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
