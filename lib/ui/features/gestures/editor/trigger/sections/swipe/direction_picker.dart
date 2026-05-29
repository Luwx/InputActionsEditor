import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/direction_utils.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/direction_wheel_painter.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

class DirectionPicker extends StatefulWidget {
  const DirectionPicker({
    required this.direction,
    required this.onChanged,
    super.key,
  });

  final SwipeDirection direction;
  final void Function(SwipeDirection) onChanged;

  @override
  State<DirectionPicker> createState() => _DirectionPickerState();
}

class _DirectionPickerState extends State<DirectionPicker> {
  static const _size = 128.0;
  static const double _r = _size / 2;
  static const double _innerR = _r * 0.28;

  int? _hovered;

  int? _hitTest(Offset pos) {
    final delta = pos - const Offset(_r, _r);
    final dist = delta.distance;
    if (dist > _r) return null;
    if (dist < _innerR) return 8;
    var angle = math.atan2(delta.dy, delta.dx);
    if (angle < 0) angle += 2 * math.pi;
    return ((angle + math.pi / 8) / (math.pi / 4)).floor() % 8;
  }

  void _onTap(Offset pos) {
    final hit = _hitTest(pos);
    if (hit == null) return;
    if (hit == 8) {
      widget.onChanged(SwipeDirection.any);
    } else {
      final dir = kSectorDirs[hit];
      final isBidi = kBiDirs.contains(widget.direction);
      widget.onChanged(isBidi ? toBidirectional(dir) : dir);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final active = activeSectors(widget.direction);
    final isAny = widget.direction == SwipeDirection.any;
    final displayLabel = _hovered != null
        ? (_hovered == 8
              ? 'Any direction'
              : directionLabel(kSectorDirs[_hovered!]))
        : directionLabel(widget.direction);

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onHover: (e) =>
                        setState(() => _hovered = _hitTest(e.localPosition)),
                    onExit: (_) => setState(() => _hovered = null),
                    child: GestureDetector(
                      onTapDown: (e) => _onTap(e.localPosition),
                      child: SizedBox.square(
                        dimension: _size,
                        child: CustomPaint(
                          painter: DirectionWheelPainter(
                            activeSectors: active,
                            isAny: isAny,
                            hovered: _hovered,
                            primary: colors.primary,
                            surface: colors.card,
                            border: colors.border,
                            arrow: colors.foreground,
                            muted: colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 8),
                // Text(displayLabel),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayLabel,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FCheckbox(
          value: kBiDirs.contains(widget.direction),
          enabled: !isAny,
          onChange: (checked) {
            if (checked) {
              widget.onChanged(toBidirectional(widget.direction));
            } else {
              widget.onChanged(
                toSingleDirection(widget.direction),
              );
            }
          },
          label: const LabelWithTooltip(
            label: 'Bidirectional',
            tooltip:
                'Also match motion in the opposite direction. '
                'Motion in the opposite direction will have '
                'a negative delta value.',
          ),
        ),
      ],
    );
  }
}
