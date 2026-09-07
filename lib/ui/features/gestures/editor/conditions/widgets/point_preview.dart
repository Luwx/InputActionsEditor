import 'dart:async' show unawaited;
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';

/// Screen-shaped (16:9) canvas that shows where the normalized point(s) sit and
/// lets them be dragged. The area the condition matches under [operator] is
/// shaded: comparisons apply to both axes, so `<` covers everything above and
/// left of the point and `>` everything below and right of it. With two points
/// the area between them is drawn as a region that can also be moved as a
/// whole.
class PointPreview extends HookWidget {
  const PointPreview({
    required this.points,
    required this.operator,
    required this.onChanged,
    super.key,
  });

  /// One or two normalized (0..1) points.
  final List<(double, double)> points;
  final ConditionOperator operator;
  final void Function(List<(double, double)> points) onChanged;

  static const int height = 128;
  static final int width = (height * 16 / 9).round();

  static const _hitSlop = 14.0;
  static const _emphasisDuration = Duration(milliseconds: 120);
  static const Curve _emphasisCurve = Curves.easeOutCubic;

  /// Drag/hover target id for the region between two points (handles use
  /// their own index).
  static const _regionTarget = 2;

  static Offset _toLocal((double, double) point) =>
      Offset(point.$1 * width, point.$2 * height);

  static (double, double) _toValue(Offset local) => (
    (local.dx / width).clamp(0.0, 1.0),
    (local.dy / height).clamp(0.0, 1.0),
  );

  int? _handleAt(Offset local) {
    int? nearest;
    var nearestDistance = _hitSlop;
    for (var i = 0; i < points.length; i++) {
      final distance = (local - _toLocal(points[i])).distance;
      if (distance <= nearestDistance) {
        nearestDistance = distance;
        nearest = i;
      }
    }
    return nearest;
  }

  int _nearestHandle(Offset local) {
    if (points.length < 2) return 0;
    final first = (local - _toLocal(points[0])).distance;
    final second = (local - _toLocal(points[1])).distance;
    return first <= second ? 0 : 1;
  }

  bool _inRegion(Offset local) =>
      points.length == 2 &&
      Rect.fromPoints(
        _toLocal(points[0]),
        _toLocal(points[1]),
      ).inflate(1).contains(local);

  int? _targetAt(Offset local) {
    final handle = _handleAt(local);
    if (handle != null) return handle;
    return _inRegion(local) ? _regionTarget : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final dragging = useState<int?>(null);
    final hovered = useState<int?>(null);
    // Accumulates region drags so repeated deltas don't drift when a
    // translation is clamped at an edge.
    final live = useRef(points);

    void emitHandle(int index, Offset local) {
      final next = [...points];
      next[index] = _toValue(local);
      live.value = next;
      onChanged(next);
    }

    void onPanDown(DragDownDetails details) {
      live.value = points;
      final local = details.localPosition;
      final target = _targetAt(local);
      if (target != null) {
        dragging.value = target;
        return;
      }
      // Pressing empty space is a direct placement: grab the closest handle
      // and move it under the pointer.
      final index = _nearestHandle(local);
      dragging.value = index;
      emitHandle(index, local);
    }

    void onPanUpdate(DragUpdateDetails details) {
      final target = dragging.value;
      if (target == null) return;
      if (target != _regionTarget) {
        emitHandle(target, details.localPosition);
        return;
      }
      final [from, to] = live.value;
      final minX = math.min(from.$1, to.$1);
      final maxX = math.max(from.$1, to.$1);
      final minY = math.min(from.$2, to.$2);
      final maxY = math.max(from.$2, to.$2);
      final dx = (details.delta.dx / width).clamp(-minX, 1 - maxX);
      final dy = (details.delta.dy / height).clamp(-minY, 1 - maxY);
      final next = [
        (from.$1 + dx, from.$2 + dy),
        (to.$1 + dx, to.$2 + dy),
      ];
      live.value = next;
      onChanged(next);
    }

    final active = dragging.value ?? hovered.value;

    // One controller per handle plus one for the region, so hover and press
    // emphasis fades in and out instead of snapping.
    final firstCtrl = useAnimationController(duration: _emphasisDuration);
    final secondCtrl = useAnimationController(duration: _emphasisDuration);
    final regionCtrl = useAnimationController(duration: _emphasisDuration);

    useEffect(() {
      unawaited(active == 0 ? firstCtrl.forward() : firstCtrl.reverse());
      unawaited(active == 1 ? secondCtrl.forward() : secondCtrl.reverse());
      unawaited(
        active == _regionTarget ? regionCtrl.forward() : regionCtrl.reverse(),
      );
      return null;
    }, [active]);

    final first = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: firstCtrl, curve: _emphasisCurve),
        [firstCtrl],
      ),
    );
    final second = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: secondCtrl, curve: _emphasisCurve),
        [secondCtrl],
      ),
    );
    final region = useAnimation(
      useMemoized(
        () => CurvedAnimation(parent: regionCtrl, curve: _emphasisCurve),
        [regionCtrl],
      ),
    );

    return MouseRegion(
      cursor: active == _regionTarget
          ? SystemMouseCursors.move
          : SystemMouseCursors.precise,
      onHover: (event) => hovered.value = _targetAt(event.localPosition),
      onExit: (_) => hovered.value = null,
      child: GestureDetector(
        onPanDown: onPanDown,
        onPanUpdate: onPanUpdate,
        onPanEnd: (_) => dragging.value = null,
        onPanCancel: () => dragging.value = null,
        child: SizedBox(
          width: width.toDouble(),
          height: height.toDouble(),
          child: CustomPaint(
            painter: _PointPreviewPainter(
              points: points,
              operator: operator,
              handleEmphasis: [first, second],
              regionEmphasis: region,
              primary: colors.primary,
              surface: colors.secondary,
              border: colors.border,
              muted: colors.mutedForeground,
              background: colors.background,
            ),
          ),
        ),
      ),
    );
  }
}

class _PointPreviewPainter extends CustomPainter {
  const _PointPreviewPainter({
    required this.points,
    required this.operator,
    required this.handleEmphasis,
    required this.regionEmphasis,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
    required this.background,
  });

  final List<(double, double)> points;
  final ConditionOperator operator;

  /// Hover/press emphasis (0..1) for each handle, by index.
  final List<double> handleEmphasis;

  /// Hover/press emphasis (0..1) for the region between two points.
  final double regionEmphasis;
  final Color primary;
  final Color surface;
  final Color border;
  final Color muted;
  final Color background;

  static const _handleRadius = 4;
  static const _activeExtra = 1.5;
  static const _dashLength = 4.0;
  static const _dashGap = 3.0;

  /// Area a comparison matches: both axes are compared, so `<` keeps
  /// everything above and left of the point and `>` everything below and right.
  Rect? _quadrant(Offset corner, Size size) => switch (operator) {
    ConditionOperator.lessThan ||
    ConditionOperator.lessOrEqual => Rect.fromLTRB(0, 0, corner.dx, corner.dy),
    ConditionOperator.greaterThan || ConditionOperator.greaterOrEqual =>
      Rect.fromLTRB(corner.dx, corner.dy, size.width, size.height),
    _ => null,
  };

  /// Solid for inclusive comparisons, dashed when the boundary itself is
  /// excluded.
  void _drawEdge(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint, {
    required bool dashed,
  }) {
    if (!dashed) {
      canvas.drawLine(from, to, paint);
      return;
    }
    final length = (to - from).distance;
    if (length == 0) return;
    final step = (to - from) / length;
    for (var start = 0.0; start < length; start += _dashLength + _dashGap) {
      final end = math.min(start + _dashLength, length);
      canvas.drawLine(from + step * start, from + step * end, paint);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas
      ..save()
      ..clipRect(bounds)
      ..drawRect(bounds, Paint()..color = surface.withValues(alpha: 0.5));

    // Grid lines
    final gridPaint = Paint()
      ..color = muted.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    for (var i = 1; i < 3; i++) {
      final x = (size.width * i ~/ 3) + 0.5;
      final y = (size.height * i ~/ 3) + 0.5;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), gridPaint)
        ..drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final locals = [
      for (final (x, y) in points) Offset(x * size.width, y * size.height),
    ];

    if (locals.length == 2) {
      final region = Rect.fromPoints(locals[0], locals[1]);
      canvas
        ..drawRect(
          region,
          Paint()
            ..color = primary.withValues(alpha: 0.18 + regionEmphasis * 0.1),
        )
        ..drawRect(
          region,
          Paint()
            ..color = primary.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
    } else if (_quadrant(locals.first, size) case final region?) {
      canvas.drawRect(
        region,
        Paint()..color = primary.withValues(alpha: 0.18),
      );
      final strict =
          operator == ConditionOperator.lessThan ||
          operator == ConditionOperator.greaterThan;
      final edge = Paint()
        ..color = primary.withValues(alpha: 0.7)
        ..strokeWidth = 1;
      final corner = locals.first;
      _drawEdge(
        canvas,
        Offset(corner.dx, region.top),
        Offset(corner.dx, region.bottom),
        edge,
        dashed: strict,
      );
      _drawEdge(
        canvas,
        Offset(region.left, corner.dy),
        Offset(region.right, corner.dy),
        edge,
        dashed: strict,
      );
    }

    for (var i = 0; i < locals.length; i++) {
      final local = locals[i];
      final emphasis = handleEmphasis[i];
      final guides = math.max(emphasis, regionEmphasis);
      if (guides > 0) {
        final guidePaint = Paint()
          ..color = primary.withValues(alpha: 0.35 * guides)
          ..strokeWidth = 1;
        canvas
          ..drawLine(
            Offset(0, local.dy),
            Offset(size.width, local.dy),
            guidePaint,
          )
          ..drawLine(
            Offset(local.dx, 0),
            Offset(local.dx, size.height),
            guidePaint,
          );
      }
      final radius = _handleRadius + emphasis * _activeExtra;
      canvas
        ..drawCircle(local, radius + 1, Paint()..color = primary)
        ..drawCircle(local, radius, Paint()..color = surface);
    }

    canvas
      ..restore()
      ..drawRect(
        bounds.deflate(0.5),
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
  }

  @override
  bool shouldRepaint(_PointPreviewPainter old) =>
      !_samePoints(old.points, points) ||
      old.operator != operator ||
      old.handleEmphasis[0] != handleEmphasis[0] ||
      old.handleEmphasis[1] != handleEmphasis[1] ||
      old.regionEmphasis != regionEmphasis ||
      old.primary != primary ||
      old.surface != surface ||
      old.border != border ||
      old.muted != muted ||
      old.background != background;

  static bool _samePoints(List<(double, double)> a, List<(double, double)> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
