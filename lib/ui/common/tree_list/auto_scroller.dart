import 'dart:async';

import 'package:flutter/widgets.dart';

/// Scrolls a viewport while a pointer drag sits near its leading or trailing
/// edge. Shell-agnostic: it only needs the [ScrollController] of the scrollable
/// the drag happens in, so a list that owns its scroll view and one that lives
/// inside a foreign viewport drive it the same way.
class ListAutoScroller {
  ListAutoScroller({required this.controller, this.onScrolled});

  static const _edge = 64.0;
  static const _maxStep = 18.0;
  static const _frame = Duration(milliseconds: 16);

  final ScrollController controller;

  /// Runs after each scroll step, for state anchored in content space that has
  /// to be recomputed while the pointer itself stays still.
  final VoidCallback? onScrolled;

  Timer? _timer;
  double _velocity = 0;

  /// The render box of the scrollable's viewport, or null before it is laid
  /// out. Reached through the scroll position rather than `Scrollable.of` so a
  /// list sitting above the scroll view it owns can still find it.
  RenderBox? get viewportBox {
    if (!controller.hasClients) return null;
    final context = controller.position.context.notificationContext;
    final box = context?.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  void update(Offset globalPosition) {
    final box = viewportBox;
    if (box == null) return;

    final local = box.globalToLocal(globalPosition);
    final topDistance = local.dy;
    final bottomDistance = box.size.height - local.dy;
    _velocity = switch ((topDistance, bottomDistance)) {
      (final top, _) when top < _edge => -(_edge - top) / _edge * _maxStep,
      (_, final bottom) when bottom < _edge =>
        (_edge - bottom) / _edge * _maxStep,
      _ => 0.0,
    };

    if (_velocity == 0) {
      stop();
      return;
    }

    _timer ??= Timer.periodic(_frame, (_) {
      if (!controller.hasClients || _velocity == 0) {
        stop();
        return;
      }
      final position = controller.position;
      final next = (position.pixels + _velocity).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if (next == position.pixels) return;
      controller.jumpTo(next);
      onScrolled?.call();
    });
  }

  void stop() {
    _velocity = 0;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => stop();
}
