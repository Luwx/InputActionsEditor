import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/angle_wheel_painter.dart';

class AnglePicker extends StatefulWidget {
  const AnglePicker({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final SwipeAngleMode mode;
  final void Function(SwipeAngleMode) onChanged;

  @override
  State<AnglePicker> createState() => _AnglePickerState();
}

class _AnglePickerState extends State<AnglePicker> {
  static const _size = 128.0;
  static const double _r = _size / 2;
  static const _handleR = 7.0;
  static const _hitSlop = 16.0;
  static const double _arcR = _r - _handleR - 2;

  int? _dragging;

  Offset _toPoint(double deg) {
    final rad = deg * math.pi / 180;
    return Offset(_r + math.cos(rad) * _arcR, _r + math.sin(rad) * _arcR);
  }

  double _toAngle(Offset local) {
    final delta = local - const Offset(_r, _r);
    return (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
  }

  void _onPanStart(DragStartDetails details) {
    final minPoint = _toPoint(widget.mode.minAngle);
    final maxPoint = _toPoint(widget.mode.maxAngle);
    final minDistance = (details.localPosition - minPoint).distance;
    final maxDistance = (details.localPosition - maxPoint).distance;
    if (minDistance <= _hitSlop || maxDistance <= _hitSlop) {
      setState(() => _dragging = minDistance <= maxDistance ? 0 : 1);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragging == null) return;
    final angle = _toAngle(details.localPosition);
    final mode = widget.mode;
    widget.onChanged(
      _dragging == 0
          ? mode.copyWith(minAngle: angle)
          : mode.copyWith(maxAngle: angle),
    );
  }

  void _onPanEnd(DragEndDetails _) => setState(() => _dragging = null);

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final mode = widget.mode;

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: SizedBox.square(
                  dimension: _size,
                  child: CustomPaint(
                    painter: AngleWheelPainter(
                      minAngle: mode.minAngle,
                      maxAngle: mode.maxAngle,
                      bidirectional: mode.bidirectional,
                      dragging: _dragging,
                      primary: colors.primary,
                      surface: colors.card,
                      border: colors.border,
                      muted: colors.mutedForeground,
                      background: colors.background,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FSpinBox(
                  value: mode.minAngle,
                  onChanged: (value) {
                    widget.onChanged(mode.copyWith(minAngle: value));
                  },
                  label: const LabelWithTooltip(
                    label: 'Min angle °',
                    tooltip:
                        'Start of the angle range. '
                        '0° = right, 90° = up, 180° = left, 270° = down. '
                        'Drag the handle on the wheel or type a value.',
                  ),
                  min: 0,
                  max: 360,
                  hint: '0.0',
                  width: 100,
                ),
                const SizedBox(height: 12),
                FSpinBox(
                  value: mode.maxAngle,
                  onChanged: (value) {
                    widget.onChanged(mode.copyWith(maxAngle: value));
                  },
                  label: const LabelWithTooltip(
                    label: 'Max angle °',
                    tooltip:
                        'End of the angle range. '
                        'If min < max the range is between them. '
                        'If min > max the range wraps around '
                        '(e.g. 330–30 covers rightward motion).',
                  ),
                  min: 0,
                  max: 360,
                  hint: '45.0',
                  width: 100,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        FCheckbox(
          value: mode.bidirectional,
          onChange: (checked) => widget.onChanged(
            mode.copyWith(bidirectional: checked),
          ),
          label: const LabelWithTooltip(
            label: 'Bidirectional',
            tooltip:
                'Also match motion in the opposite angle range. '
                'That motion will have a negative delta value.\n\n'
                'In the case of overlapping angle ranges, the normal'
                ' one takes priority over the opposite one.',
          ),
        ),
      ],
    );
  }
}
