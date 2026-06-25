import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return _AnimatedScrollbar(
      controller: details.controller,
      direction: details.direction,
      child: child,
    );
  }
}

class _AnimatedScrollbar extends HookWidget {
  const _AnimatedScrollbar({
    required this.controller,
    required this.direction,
    required this.child,
  });

  final ScrollController? controller;
  final AxisDirection direction;
  final Widget child;

  static const _hidden = _ScrollbarVisuals(
    thickness: 0,
    thumbColor: Colors.transparent,
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static _ScrollbarVisuals _idle(Color foreground) => _ScrollbarVisuals(
    thickness: 4,
    thumbColor: _scrollbarColor(foreground, 0.20),
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static _ScrollbarVisuals _hovered(Color foreground) => _ScrollbarVisuals(
    thickness: 8,
    thumbColor: _scrollbarColor(foreground, 0.53),
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static _ScrollbarVisuals _dragged(Color foreground) => _ScrollbarVisuals(
    thickness: 8,
    thumbColor: _scrollbarColor(foreground, 0.80),
    trackColor: _scrollbarColor(foreground, 0.09),
    trackBorderColor: Colors.transparent,
  );
  static const _hoverDuration = Duration(milliseconds: 120);
  static const Duration _showDuration = Durations.long1;
  static const _hideDuration = Duration(seconds: 2);
  // Wider than the painted thumb: RawScrollbar's mouse hit area equals its
  // painted thickness, so the region below drives the scroll itself to give a
  // generous grab zone while the bar still renders thin.
  static const _hitExtent = 16.0;

  static Duration _animationDuration(
    _ScrollbarVisuals begin,
    _ScrollbarVisuals end,
  ) {
    if (end.sameAs(_hidden)) return _hideDuration;
    if (begin.thickness == 4 && end.thickness == 8) return _hoverDuration;
    return _showDuration;
  }

  @override
  Widget build(BuildContext context) {
    final animController = useAnimationController(duration: _showDuration);
    final foreground = FTheme.of(context).colors.foreground;

    final isInsideScrollable = useState(false);
    final isHovered = useState(false);
    final isPressed = useState(false);

    // Animation refs: updated synchronously before each forward() call so
    // AnimatedBuilder always reads the correct interpolated values.
    final thicknessAnim = useRef<Animation<double>>(
      const AlwaysStoppedAnimation(0),
    );
    final thumbColorAnim = useRef<Animation<Color?>>(
      const AlwaysStoppedAnimation(Colors.transparent),
    );
    final trackColorAnim = useRef<Animation<Color?>>(
      const AlwaysStoppedAnimation(Colors.transparent),
    );
    final trackBorderColorAnim = useRef<Animation<Color?>>(
      const AlwaysStoppedAnimation(Colors.transparent),
    );

    _ScrollbarVisuals currentVisuals() => _ScrollbarVisuals(
      thickness: thicknessAnim.value.value,
      thumbColor: thumbColorAnim.value.value ?? _hidden.thumbColor,
      trackColor: trackColorAnim.value.value ?? _hidden.trackColor,
      trackBorderColor:
          trackBorderColorAnim.value.value ?? _hidden.trackBorderColor,
    );

    _ScrollbarVisuals targetVisuals() {
      if (!isInsideScrollable.value && !isPressed.value) return _hidden;
      if (isPressed.value) return _dragged(foreground);
      if (isHovered.value) return _hovered(foreground);
      return _idle(foreground);
    }

    void setAnimations(_ScrollbarVisuals begin, _ScrollbarVisuals end) {
      final curve = CurvedAnimation(
        parent: animController,
        curve: Curves.easeOutCubic,
      );
      thicknessAnim.value = Tween<double>(
        begin: begin.thickness,
        end: end.thickness,
      ).animate(curve);
      thumbColorAnim.value = ColorTween(
        begin: begin.thumbColor,
        end: end.thumbColor,
      ).animate(curve);
      trackColorAnim.value = ColorTween(
        begin: begin.trackColor,
        end: end.trackColor,
      ).animate(curve);
      trackBorderColorAnim.value = ColorTween(
        begin: begin.trackBorderColor,
        end: end.trackBorderColor,
      ).animate(curve);
    }

    void animateToCurrentState() {
      final begin = currentVisuals();
      final end = targetVisuals();
      animController.duration = _animationDuration(begin, end);
      setAnimations(begin, end);
      unawaited(animController.forward(from: 0));
    }

    // Initialise to hidden on first mount.
    useEffect(() {
      setAnimations(_hidden, _hidden);
      animController.value = 1;
      return null;
    }, const []);

    final isVertical = switch (direction) {
      AxisDirection.up || AxisDirection.down => true,
      AxisDirection.left || AxisDirection.right => false,
    };

    return MouseRegion(
      onEnter: (_) {
        if (isInsideScrollable.value) return;
        isInsideScrollable.value = true;
        animateToCurrentState();
      },
      onExit: (_) {
        if (!isInsideScrollable.value) return;
        isInsideScrollable.value = false;
        isHovered.value = false;
        animateToCurrentState();
      },
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Invisible but interactive: a transparent thumb is still hit-tested
          // (interaction is gated by opacity, pinned to 1 via thumbVisibility,
          // not colour). Sized to _hitExtent so the grab zone is wider than the
          // painted bar, while RawScrollbar still owns drag/track-click/etc.
          RawScrollbar(
            controller: controller,
            thumbVisibility: true,
            interactive: true,
            thickness: _hitExtent,
            thumbColor: Colors.transparent,
            trackColor: Colors.transparent,
            trackBorderColor: Colors.transparent,
            child: AnimatedBuilder(
              animation: animController,
              builder: (context, child) => RawScrollbar(
                controller: controller,
                // Paint only; the bar above owns interaction in a wider zone.
                interactive: false,
                thumbVisibility: true,
                thickness: thicknessAnim.value.value,
                radius: Radius.zero,
                trackVisibility: true,
                thumbColor: thumbColorAnim.value.value,
                trackColor: trackColorAnim.value.value,
                trackBorderColor: trackBorderColorAnim.value.value,
                child: child!,
              ),
              child: child,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: _ScrollbarInteractionRegion(
                isVertical: isVertical,
                hitExtent: _hitExtent,
                onHoverChanged: (value) {
                  if (isHovered.value == value) return;
                  isHovered.value = value;
                  animateToCurrentState();
                },
                onPressedChanged: (value) {
                  if (isPressed.value == value) return;
                  isPressed.value = value;
                  animateToCurrentState();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _scrollbarColor(Color foreground, double alpha) =>
    foreground.withValues(alpha: alpha);

/// Signals hover/press over a zone wider than the painted thumb.
///
/// Actual scrolling is handled by the invisible, full-width RawScrollbar
/// underneath; this overlay only reports state to drive the bar's animation, so
/// it is translucent and lets pointer events fall through to that scrollbar.
class _ScrollbarInteractionRegion extends StatelessWidget {
  const _ScrollbarInteractionRegion({
    required this.isVertical,
    required this.hitExtent,
    required this.onHoverChanged,
    required this.onPressedChanged,
  });

  final bool isVertical;
  final double hitExtent;
  final ValueChanged<bool> onHoverChanged;
  final ValueChanged<bool> onPressedChanged;

  @override
  Widget build(BuildContext context) {
    final alignment = isVertical
        ? (Directionality.of(context) == TextDirection.rtl
              ? Alignment.centerLeft
              : Alignment.centerRight)
        : Alignment.bottomCenter;

    final region = MouseRegion(
      opaque: false,
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => onPressedChanged(true),
        onPointerUp: (_) => onPressedChanged(false),
        onPointerCancel: (_) => onPressedChanged(false),
        child: const SizedBox.expand(),
      ),
    );

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: isVertical ? hitExtent : null,
        height: isVertical ? null : hitExtent,
        child: region,
      ),
    );
  }
}

class _ScrollbarVisuals {
  const _ScrollbarVisuals({
    required this.thickness,
    required this.thumbColor,
    required this.trackColor,
    required this.trackBorderColor,
  });

  final double thickness;
  final Color thumbColor;
  final Color trackColor;
  final Color trackBorderColor;

  bool sameAs(_ScrollbarVisuals other) =>
      thickness == other.thickness &&
      thumbColor == other.thumbColor &&
      trackColor == other.trackColor &&
      trackBorderColor == other.trackBorderColor;
}
