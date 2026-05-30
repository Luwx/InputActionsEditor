import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_preview.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/widgets/unsaved_marker.dart';

class GestureListTile extends ConsumerWidget {
  const GestureListTile({
    required this.device,
    required this.index,
    required this.gesture,
    required this.newlyAddedMarkerId,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.isMultiSelected,
    required this.groupDisabled,
    required this.onTap,
    super.key,
  });

  final DeviceType device;
  final int index;
  final Object gesture;
  final int? newlyAddedMarkerId;
  final bool isSelected;
  final bool isMultiSelectMode;
  final bool isMultiSelected;

  /// True when this gesture's group is disabled (UI-only dimming).
  final bool groupDisabled;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final common = gestureCommon(gesture);
    final isDirty = ref.watch(
      gestureDirtyProvider(GestureLocation(device: device, index: index)),
    );
    final isDisabled = common.enabled == false || groupDisabled;
    final summaryText = _summary(gesture);
    final firstAction = _firstActionSummary(common);
    final nameText = (common.name?.isNotEmpty ?? false)
        ? common.name!
        : gestureTypeLabel(gesture);
    final effectiveSelected = isMultiSelectMode ? isMultiSelected : isSelected;
    final showAccent = effectiveSelected;

    final hasAddedMarker = newlyAddedMarkerId != null;

    return Opacity(
      opacity: isDisabled ? 0.45 : 1.0,
      child: Material(
        color: colors.background,
        child: InkWell(
          onTap: onTap,
          splashFactory: InkSparkle.splashFactory,
          child: TweenAnimationBuilder<double>(
            key: ValueKey<int?>(newlyAddedMarkerId),
            tween: Tween(begin: hasAddedMarker ? 0.16 : 0.0, end: 0),
            duration: hasAddedMarker
                ? const Duration(milliseconds: 1200)
                : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, addedOpacity, child) {
              final selectedOpacity = effectiveSelected ? 0.08 : 0.0;
              final tileOpacity = math.min(
                0.26,
                selectedOpacity + addedOpacity,
              );
              return AnimatedContainer(
                duration: Durations.medium1,
                decoration: BoxDecoration(
                  color: tileOpacity > 0
                      ? colors.primary.withValues(alpha: tileOpacity)
                      : null,
                  border: showAccent
                      ? Border(
                          left: BorderSide(
                            color: colors.primary,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                padding: EdgeInsets.fromLTRB(showAccent ? 12 : 14, 8, 12, 8),
                child: child,
              );
            },
            child: Row(
              children: [
                if (isMultiSelectMode)
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Center(
                      child: FCheckbox(
                        value: isMultiSelected,
                        onChange: (_) => onTap(),
                      ),
                    ),
                  )
                else
                  _GestureTypeIcon(
                    gesture: gesture,
                    isSelected: isSelected,
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UnsavedLabel(
                        isDirty: isDirty,
                        child: Flexible(
                          child: Text(
                            nameText,
                            style: typography.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Color.lerp(
                                colors.primary,
                                colors.foreground,
                                effectiveSelected ? 0.5 : 1,
                              ),
                              decoration: isDisabled
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (summaryText.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          summaryText,
                          style: typography.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (firstAction.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          firstAction,
                          style: typography.xs.copyWith(
                            color: colors.mutedForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Amber/orange accent used to flag gestures that conflict with others.
/// forui's zinc theme has no dedicated warning colour, so this is a fixed
/// value that reads well on both light and dark backgrounds.
String _summary(Object g) {
  final parts = <String>[];
  switch (g) {
    // Mouse
    case StrokeGesture(:final strokes):
      parts.add('${strokes.length} stroke${strokes.length == 1 ? '' : 's'}');
    case SwipeGesture():
      break;
    case CircleGesture(:final direction):
      parts.add(direction.toYaml());
    case PressGesture(:final instant):
      if (instant == true) parts.add('instant');
    case WheelGesture(:final direction):
      parts.add(direction.toYaml());
    // Keyboard
    case ShortcutGesture(:final keys):
      if (keys.isNotEmpty) parts.add(keys.join('+'));
    // Pointer, no extra summary fields
    case HoverGesture():
      break;
    // Touchpad / touchscreen, show fingers if set
    case TouchpadGesture(:final fingers):
      if (fingers != null) {
        parts.add('$fingers finger${fingers == 1 ? '' : 's'}');
      }
      _addTouchSummary(g, parts);
    case TouchscreenGesture(:final fingers):
      if (fingers != null) {
        parts.add('$fingers finger${fingers == 1 ? '' : 's'}');
      }
      _addTouchSummary(g, parts);
  }
  if (g is MouseGesture && g.common.mouseButtons.isNotEmpty) {
    parts.add(g.common.mouseButtons.map((b) => b.toYaml()).join('+'));
  }
  final common = gestureCommon(g);
  if (common.id != null) parts.add('#${common.id}');
  return parts.join(' · ');
}

void _addTouchSummary(Object g, List<String> parts) {
  switch (g) {
    case TouchpadSwipeGesture(:final mode) ||
        TouchscreenSwipeGesture(:final mode):
      if (mode is SwipeDirectionMode && mode.direction != SwipeDirection.any) {
        parts.add(mode.direction.name);
      }
    case TouchpadPinchGesture(:final direction)
        when direction != PinchDirection.any:
      parts.add(direction.name);
    case TouchscreenPinchGesture(:final direction)
        when direction != PinchDirection.any:
      parts.add(direction.name);
    case TouchpadRotateGesture(:final direction)
        when direction != RotateDirection.any:
      parts.add(direction.name);
    case TouchscreenRotateGesture(:final direction)
        when direction != RotateDirection.any:
      parts.add(direction.name);
    case TouchpadCircleGesture(:final direction)
        when direction != CircleDirection.any:
      parts.add(direction.name);
    case TouchscreenCircleGesture(:final direction)
        when direction != CircleDirection.any:
      parts.add(direction.name);
    case TouchpadStrokeGesture(:final strokes):
      parts.add('${strokes.length} stroke${strokes.length == 1 ? '' : 's'}');
    case TouchscreenStrokeGesture(:final strokes):
      parts.add('${strokes.length} stroke${strokes.length == 1 ? '' : 's'}');
    default:
      break;
  }
}

String _firstActionSummary(TriggerCommon common) {
  if (common.actions.isEmpty) return '';
  final action = common.actions.first.action;
  return switch (action) {
    CommandAction(:final command) => command.isEmpty ? '(no command)' : command,
    InputAction(:final entries) when entries.isEmpty => 'input (empty)',
    InputAction(:final entries) =>
      'input: ${entries.map((e) => e.device.name).join(', ')}',
    PlasmaShortcutAction(:final shortcut) =>
      shortcut.isEmpty ? 'plasma shortcut' : shortcut,
    SleepAction(:final milliseconds) => 'sleep ${milliseconds}ms',
    RawAction() => 'raw yaml',
  };
}

// ---------------------------------------------------------------------------

class _GestureTypeIcon extends StatelessWidget {
  const _GestureTypeIcon({required this.gesture, required this.isSelected});

  final Object gesture;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final primary = isSelected ? colors.primary : colors.foreground;
    final surface = colors.secondary.withAlpha(100);
    final border = colors.border;

    return switch (gesture) {
      SwipeGesture(:final mode) => _SwipeIcon(
        mode: mode,
        primary: primary,
        surface: surface,
        border: border,
        muted: colors.mutedForeground,
      ),
      TouchpadSwipeGesture(:final mode) ||
      TouchscreenSwipeGesture(:final mode) => _SwipeIcon(
        mode: mode,
        primary: primary,
        surface: surface,
        border: border,
        muted: colors.mutedForeground,
      ),
      StrokeGesture() ||
      TouchpadStrokeGesture() ||
      TouchscreenStrokeGesture() => _StrokeGestureIcon(
        strokes: _strokeValues(gesture),
        primary: primary,
        muted: colors.mutedForeground,
        surface: surface,
        border: border,
      ),
      CircleGesture() ||
      TouchpadCircleGesture() ||
      TouchscreenCircleGesture() ||
      TouchpadRotateGesture() ||
      TouchscreenRotateGesture() => _SymbolGestureIcon(
        icon: Icons.rotate_right_rounded,
        color: primary,
        surface: surface,
        border: border,
      ),
      PressGesture() ||
      TouchpadTapGesture() ||
      TouchscreenTapGesture() ||
      TouchpadHoldGesture() ||
      TouchscreenHoldGesture() ||
      HoverGesture() => _SymbolGestureIcon(
        icon: Icons.touch_app_rounded,
        color: primary,
        surface: surface,
        border: border,
      ),
      WheelGesture() => _SymbolGestureIcon(
        icon: FLucideIcons.loaderPinwheel,
        color: primary,
        surface: surface,
        border: border,
      ),
      TouchpadClickGesture() => _SymbolGestureIcon(
        icon: Icons.mouse_outlined,
        color: primary,
        surface: surface,
        border: border,
      ),
      TouchpadPinchGesture() || TouchscreenPinchGesture() => _SymbolGestureIcon(
        icon: Icons.pinch_outlined,
        color: primary,
        surface: surface,
        border: border,
      ),
      ShortcutGesture() => _SymbolGestureIcon(
        icon: Icons.keyboard_alt_outlined,
        color: primary,
        surface: surface,
        border: border,
      ),
      _ => _SymbolGestureIcon(
        icon: Icons.touch_app_rounded,
        color: primary,
        surface: surface,
        border: border,
      ),
    };
  }
}

List<String> _strokeValues(Object gesture) => switch (gesture) {
  StrokeGesture(:final strokes) => strokes,
  TouchpadStrokeGesture(:final strokes) => strokes,
  TouchscreenStrokeGesture(:final strokes) => strokes,
  _ => const [],
};

class _SymbolGestureIcon extends StatelessWidget {
  const _SymbolGestureIcon({
    required this.icon,
    required this.color,
    required this.surface,
    required this.border,
  });

  final IconData icon;
  final Color color;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _StrokeGestureIcon extends StatelessWidget {
  const _StrokeGestureIcon({
    required this.strokes,
    required this.primary,
    required this.muted,
    required this.surface,
    required this.border,
  });

  final List<String> strokes;
  final Color primary;
  final Color muted;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    if (strokes.isEmpty) {
      return _SymbolGestureIcon(
        icon: Icons.gesture_outlined,
        color: primary,
        surface: surface,
        border: border,
      );
    }

    return StrokePreview(
      strokeBase64: strokes.first,
      size: 42,
      startColor: muted,
      endColor: primary,
      surface: surface,
      border: border,
      strokeWidth: 1.6,
    );
  }
}

// ---------------------------------------------------------------------------
// 42×42 swipe direction/angle mini icon
// ---------------------------------------------------------------------------

class _SwipeIcon extends StatelessWidget {
  const _SwipeIcon({
    required this.mode,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
  });

  final SwipeMode mode;
  final Color primary;
  final Color surface;
  final Color border;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: CustomPaint(
        painter: _SwipeIconPainter(
          mode: mode,
          primary: primary,
          surface: surface,
          border: border,
          muted: muted,
        ),
      ),
    );
  }
}

Set<int> _iconActiveSectors(SwipeDirection d) => switch (d) {
  SwipeDirection.right => {0},
  SwipeDirection.rightDown => {1},
  SwipeDirection.down => {2},
  SwipeDirection.leftDown => {3},
  SwipeDirection.left => {4},
  SwipeDirection.leftUp => {5},
  SwipeDirection.up => {6},
  SwipeDirection.rightUp => {7},
  SwipeDirection.leftRight => {0, 4},
  SwipeDirection.upDown => {2, 6},
  SwipeDirection.leftUpRightDown => {5, 1},
  SwipeDirection.leftDownRightUp => {3, 7},
  SwipeDirection.any => {0, 1, 2, 3, 4, 5, 6, 7},
};

class _SwipeIconPainter extends CustomPainter {
  const _SwipeIconPainter({
    required this.mode,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
  });

  final SwipeMode mode;
  final Color primary;
  final Color surface;
  final Color border;
  final Color muted;

  static const _innerRatio = 0.28;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = cx - 1;
    final innerR = r * _innerRatio;

    switch (mode) {
      case SwipeDirectionMode(:final direction):
        _paintDirection(canvas, center, cx, cy, r, innerR, direction);
      case SwipeAngleMode(
        :final minAngle,
        :final maxAngle,
        :final bidirectional,
      ):
        _paintAngle(
          canvas,
          center,
          cx,
          cy,
          r,
          minAngle,
          maxAngle,
          bidirectional,
        );
    }
  }

  void _paintDirection(
    Canvas canvas,
    Offset center,
    double cx,
    double cy,
    double r,
    double innerR,
    SwipeDirection direction,
  ) {
    final isAny = direction == SwipeDirection.any;
    final active = _iconActiveSectors(direction);

    canvas.drawCircle(center, r, Paint()..color = surface);

    for (var i = 0; i < 8; i++) {
      if (!active.contains(i)) continue;
      final alpha = isAny ? 0.18 : 0.28;
      final startAngle = (i - 0.5) * math.pi / 4;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          startAngle,
          math.pi / 4,
          false,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = primary.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }

    final linePaint = Paint()
      ..color = border
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 8; i++) {
      final angle = (i - 0.5) * math.pi / 4;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * innerR, cy + math.sin(angle) * innerR),
        Offset(cx + math.cos(angle) * r, cy + math.sin(angle) * r),
        linePaint,
      );
    }

    canvas.drawCircle(center, r, linePaint);

    final centerColor = isAny ? primary.withValues(alpha: 0.38) : surface;
    canvas
      ..drawCircle(center, innerR, Paint()..color = centerColor)
      ..drawCircle(center, innerR, linePaint);

    switch (direction) {
      case SwipeDirection.any:
        for (final deg in [0.0, 90.0, 180.0, 270.0]) {
          _drawArrow(canvas, center, r * 0.38, r * 0.82, deg, muted, 1.1);
        }
      case SwipeDirection.right:
        _drawArrow(canvas, center, r * 0.15, r * 0.82, 0, primary, 1.6);
      case SwipeDirection.down:
        _drawArrow(canvas, center, r * 0.15, r * 0.82, 90, primary, 1.6);
      case SwipeDirection.left:
        _drawArrow(canvas, center, r * 0.15, r * 0.82, 180, primary, 1.6);
      case SwipeDirection.up:
        _drawArrow(canvas, center, r * 0.15, r * 0.82, 270, primary, 1.6);
      case SwipeDirection.rightDown:
        _drawArrow(canvas, center, r * 0.15, r * 0.80, 45, primary, 1.6);
      case SwipeDirection.leftDown:
        _drawArrow(canvas, center, r * 0.15, r * 0.80, 135, primary, 1.6);
      case SwipeDirection.leftUp:
        _drawArrow(canvas, center, r * 0.15, r * 0.80, 225, primary, 1.6);
      case SwipeDirection.rightUp:
        _drawArrow(canvas, center, r * 0.15, r * 0.80, 315, primary, 1.6);
      case SwipeDirection.leftRight:
        _drawArrow(canvas, center, r * 0.12, r * 0.82, 0, primary, 1.4);
        _drawArrow(canvas, center, r * 0.12, r * 0.82, 180, primary, 1.4);
      case SwipeDirection.upDown:
        _drawArrow(canvas, center, r * 0.12, r * 0.82, 90, primary, 1.4);
        _drawArrow(canvas, center, r * 0.12, r * 0.82, 270, primary, 1.4);
      case SwipeDirection.leftUpRightDown:
        _drawArrow(canvas, center, r * 0.12, r * 0.80, 45, primary, 1.4);
        _drawArrow(canvas, center, r * 0.12, r * 0.80, 225, primary, 1.4);
      case SwipeDirection.leftDownRightUp:
        _drawArrow(canvas, center, r * 0.12, r * 0.80, 135, primary, 1.4);
        _drawArrow(canvas, center, r * 0.12, r * 0.80, 315, primary, 1.4);
    }
  }

  void _paintAngle(
    Canvas canvas,
    Offset center,
    double cx,
    double cy,
    double r,
    double minAngle,
    double maxAngle,
    bool bidirectional,
  ) {
    canvas.drawCircle(center, r, Paint()..color = surface);

    final minRad = _toRad(minAngle);
    final sweep = ((maxAngle - minAngle) + 360) % 360;
    final sweepRad = _toRad(sweep);

    void drawSlice(double startRad, double sweepR, double alpha) {
      if (sweepR <= 0) return;
      final path = Path()
        ..moveTo(cx, cy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: r),
          startRad,
          sweepR,
          false,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = primary.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }

    drawSlice(minRad, sweepRad, 0.28);
    if (bidirectional) drawSlice(minRad + math.pi, sweepRad, 0.15);

    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final midDeg = (minAngle + sweep / 2) % 360;
    _drawArrow(canvas, center, r * 0.12, r * 0.82, midDeg, primary, 1.6);
  }

  void _drawArrow(
    Canvas canvas,
    Offset center,
    double tailDist,
    double tipDist,
    double angleDeg,
    Color color,
    double strokeWidth,
  ) {
    final rad = _toRad(angleDeg);
    final dx = math.cos(rad);
    final dy = math.sin(rad);
    final tip = Offset(center.dx + dx * tipDist, center.dy + dy * tipDist);
    final tail = Offset(center.dx + dx * tailDist, center.dy + dy * tailDist);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(tail, tip, paint);
    const spread = 0.45;
    const wingLen = 4.5;
    final backRad = rad + math.pi;
    canvas
      ..drawLine(
        tip,
        Offset(
          tip.dx + math.cos(backRad - spread) * wingLen,
          tip.dy + math.sin(backRad - spread) * wingLen,
        ),
        paint,
      )
      ..drawLine(
        tip,
        Offset(
          tip.dx + math.cos(backRad + spread) * wingLen,
          tip.dy + math.sin(backRad + spread) * wingLen,
        ),
        paint,
      );
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  @override
  bool shouldRepaint(_SwipeIconPainter old) =>
      old.mode != mode ||
      old.primary != primary ||
      old.surface != surface ||
      old.border != border ||
      old.muted != muted;
}
