import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/spinbox.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/swipe/angle_wheel_painter.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class AnglePicker extends HookWidget {
  const AnglePicker({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final SwipeAngleMode mode;
  final void Function(SwipeAngleMode) onChanged;

  static const _size = 128.0;
  static const double _r = _size / 2;
  static const _handleR = 7.0;
  static const _hitSlop = 10.0;
  static const double _arcR = _r - _handleR - 2;

  static Offset _toPoint(double deg) {
    final rad = deg * math.pi / 180;
    return Offset(_r + math.cos(rad) * _arcR, _r + math.sin(rad) * _arcR);
  }

  static double _toAngle(Offset local) {
    final delta = local - const Offset(_r, _r);
    return (math.atan2(delta.dy, delta.dx) * 180 / math.pi + 360) % 360;
  }

  static double _sweep(SwipeAngleMode mode) =>
      ((mode.maxAngle - mode.minAngle) + 360) % 360;

  static bool _inWedge(Offset local, SwipeAngleMode mode) {
    if ((local - const Offset(_r, _r)).distance > _arcR + _handleR) {
      return false;
    }
    final sweep = _sweep(mode);
    final rel = ((_toAngle(local) - mode.minAngle) + 360) % 360;
    if (rel <= sweep) return true;
    if (mode.bidirectional) {
      final relOpp = ((_toAngle(local) - mode.minAngle - 180) + 360) % 360;
      if (relOpp <= sweep) return true;
    }
    return false;
  }

  static const _hoverDuration = Duration(milliseconds: 100);
  static const _handleHoverExtra = 2.0;

  @override
  Widget build(BuildContext context) {
    final dragging = useState<int?>(null);
    final liveAngles = useRef((mode.minAngle, mode.maxAngle));

    final minHoverCtrl = useAnimationController(duration: _hoverDuration);
    final maxHoverCtrl = useAnimationController(duration: _hoverDuration);
    final wedgeHoverCtrl = useAnimationController(duration: _hoverDuration);

    final minHover = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: minHoverCtrl, curve: Easing.standard),
      ),
    );
    final maxHover = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: maxHoverCtrl, curve: Easing.standard),
      ),
    );
    final wedgeHover = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: wedgeHoverCtrl, curve: Easing.standard),
      ),
    );

    void updateHover(Offset pos) {
      final minPoint = _toPoint(mode.minAngle);
      final maxPoint = _toPoint(mode.maxAngle);
      final nearMin = (pos - minPoint).distance <= _hitSlop;
      final nearMax = (pos - maxPoint).distance <= _hitSlop;
      final inWedge = !nearMin && !nearMax && _inWedge(pos, mode);
      unawaited(nearMin ? minHoverCtrl.forward() : minHoverCtrl.reverse());
      unawaited(nearMax ? maxHoverCtrl.forward() : maxHoverCtrl.reverse());
      unawaited(inWedge ? wedgeHoverCtrl.forward() : wedgeHoverCtrl.reverse());
    }

    void clearHover() {
      unawaited(minHoverCtrl.reverse());
      unawaited(maxHoverCtrl.reverse());
      unawaited(wedgeHoverCtrl.reverse());
    }

    // Hit-test at the exact pointer-down position before pan-slop shifts it.
    final pendingDrag = useRef<int?>(null);

    void onPanDown(DragDownDetails details) {
      liveAngles.value = (mode.minAngle, mode.maxAngle);
      final minPoint = _toPoint(mode.minAngle);
      final maxPoint = _toPoint(mode.maxAngle);
      final minDist = (details.localPosition - minPoint).distance;
      final maxDist = (details.localPosition - maxPoint).distance;
      if (minDist <= _hitSlop || maxDist <= _hitSlop) {
        pendingDrag.value = minDist <= maxDist ? 0 : 1;
      } else if (_inWedge(details.localPosition, mode)) {
        pendingDrag.value = 2;
      } else {
        pendingDrag.value = null;
      }
    }

    void onPanStart(DragStartDetails details) {
      dragging.value = pendingDrag.value;
    }

    void onPanUpdate(DragUpdateDetails details) {
      if (dragging.value == null) return;
      if (dragging.value == 2) {
        final r = details.localPosition - const Offset(_r, _r);
        final rSq = r.distanceSquared;
        if (rSq < 1) return;
        final d = details.delta;
        final degrees = (r.dx * d.dy - r.dy * d.dx) / rSq * 180 / math.pi;
        final (minA, maxA) = liveAngles.value;
        final newMin = (minA + degrees + 360) % 360;
        final newMax = (maxA + degrees + 360) % 360;
        liveAngles.value = (newMin, newMax);
        onChanged(mode.copyWith(minAngle: newMin, maxAngle: newMax));
        return;
      }
      final angle = _toAngle(details.localPosition);
      onChanged(
        dragging.value == 0
            ? mode.copyWith(minAngle: angle)
            : mode.copyWith(maxAngle: angle),
      );
    }

    final colors = context.theme.colors;

    final minHandleR =
        _handleR +
        minHover * _handleHoverExtra +
        (dragging.value == 0 ? _handleHoverExtra : 0.0);
    final maxHandleR =
        _handleR +
        maxHover * _handleHoverExtra +
        (dragging.value == 1 ? _handleHoverExtra : 0.0);
    final wedgeFillAlpha = 0.2 + wedgeHover * 0.10;

    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: MouseRegion(
                onHover: (e) => updateHover(e.localPosition),
                onExit: (_) => clearHover(),
                child: GestureDetector(
                  onPanDown: onPanDown,
                  onPanStart: onPanStart,
                  onPanUpdate: onPanUpdate,
                  onPanEnd: (_) => dragging.value = null,
                  child: SizedBox.square(
                    dimension: _size,
                    child: CustomPaint(
                      painter: AngleWheelPainter(
                        minAngle: mode.minAngle,
                        maxAngle: mode.maxAngle,
                        bidirectional: mode.bidirectional,
                        minHandleR: minHandleR,
                        maxHandleR: maxHandleR,
                        wedgeFillAlpha: wedgeFillAlpha,
                        label: '${_sweep(mode).round()}°',
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
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                FSpinBox(
                  value: mode.minAngle,
                  onChanged: (value) =>
                      onChanged(mode.copyWith(minAngle: value)),
                  label: LabelWithTooltip(
                    label: context.l10n.swipeMinAngleLabel,
                    tooltip: context.l10n.swipeMinAngleTooltip,
                  ),
                  min: 0,
                  max: 360,
                  hint: '0.0',
                  width: 100,
                ),
                const SizedBox(height: 12),
                FSpinBox(
                  value: mode.maxAngle,
                  onChanged: (value) =>
                      onChanged(mode.copyWith(maxAngle: value)),
                  label: LabelWithTooltip(
                    label: context.l10n.swipeMaxAngleLabel,
                    tooltip: context.l10n.swipeMaxAngleTooltip,
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
          onChange: (checked) =>
              onChanged(mode.copyWith(bidirectional: checked)),
          label: LabelWithTooltip(
            label: context.l10n.swipeAngleBidirectionalLabel,
            tooltip: context.l10n.swipeAngleBidirectionalTooltip,
          ),
        ),
      ],
    );
  }
}
