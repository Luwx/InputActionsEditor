import 'dart:async';

import 'package:flutter/material.dart';

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

  // @override
  // SmoothScrollPolicy get smoothScrollPolicy => SmoothScrollPolicy.alwaysSmooth; // not platformAdaptive while debugging

  // @override
  // ScrollPhysics getScrollPhysics(BuildContext context) {
  //   return const SmoothScrollPhysics(
  //     curve: SmoothScrollCurves.edgeWindows,
  //     duration: SmoothScrollCurves.edgeWindowsDuration,
  //   ).applyTo(super.getScrollPhysics(context));
  // }
}

class _AnimatedScrollbar extends StatefulWidget {
  const _AnimatedScrollbar({
    required this.controller,
    required this.direction,
    required this.child,
  });

  final ScrollController? controller;
  final AxisDirection direction;
  final Widget child;

  @override
  State<_AnimatedScrollbar> createState() => _AnimatedScrollbarState();
}

class _AnimatedScrollbarState extends State<_AnimatedScrollbar>
    with SingleTickerProviderStateMixin {
  static const _hiddenVisuals = _ScrollbarVisuals(
    thickness: 0,
    thumbColor: Colors.transparent,
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static const _idleVisuals = _ScrollbarVisuals(
    thickness: 4,
    thumbColor: Color(0x33FFFFFF),
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static const _hoveredVisuals = _ScrollbarVisuals(
    thickness: 8,
    thumbColor: Color(0x88FFFFFF),
    trackColor: Colors.transparent,
    trackBorderColor: Colors.transparent,
  );
  static const _draggedVisuals = _ScrollbarVisuals(
    thickness: 8,
    thumbColor: Color(0xCCFFFFFF),
    trackColor: Color(0x16FFFFFF),
    trackBorderColor: Colors.transparent,
  );
  static const Duration _hoverDuration = Duration(milliseconds: 120);
  static const Duration _showDuration = Durations.long1;
  static const Duration _hideDuration = Duration(seconds: 2);
  static const _hoverHitExtent = 16.0;

  late final AnimationController _controller;

  late Animation<double> _thicknessAnimation;
  late Animation<Color?> _thumbColorAnimation;
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _trackBorderColorAnimation;

  bool _isInsideScrollable = false;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _showDuration);
    _setAnimations(_hiddenVisuals, _hiddenVisuals);
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() {
      _isHovered = value;
      _animateToCurrentState();
    });
  }

  void _setInsideScrollable(bool value) {
    if (_isInsideScrollable == value) return;
    setState(() {
      _isInsideScrollable = value;
      if (!value) _isHovered = false;
      _animateToCurrentState();
    });
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() {
      _isPressed = value;
      _animateToCurrentState();
    });
  }

  void _animateToCurrentState() {
    final begin = _currentVisuals();
    final end = _targetVisuals();
    _controller.duration = _animationDuration(begin, end);
    _setAnimations(begin, end);
    unawaited(_controller.forward(from: 0));
  }

  Duration _animationDuration(
    _ScrollbarVisuals begin,
    _ScrollbarVisuals end,
  ) {
    if (end.sameAs(_hiddenVisuals)) return _hideDuration;
    if (begin.sameAs(_idleVisuals) && end.sameAs(_hoveredVisuals)) {
      return _hoverDuration;
    }
    return _showDuration;
  }

  _ScrollbarVisuals _currentVisuals() {
    return _ScrollbarVisuals(
      thickness: _thicknessAnimation.value,
      thumbColor: _thumbColorAnimation.value ?? _hiddenVisuals.thumbColor,
      trackColor: _trackColorAnimation.value ?? _hiddenVisuals.trackColor,
      trackBorderColor:
          _trackBorderColorAnimation.value ?? _hiddenVisuals.trackBorderColor,
    );
  }

  _ScrollbarVisuals _targetVisuals() {
    if (!_isInsideScrollable && !_isPressed) return _hiddenVisuals;
    if (_isPressed) return _draggedVisuals;
    if (_isHovered) return _hoveredVisuals;
    return _idleVisuals;
  }

  void _setAnimations(_ScrollbarVisuals begin, _ScrollbarVisuals end) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _thicknessAnimation = Tween<double>(
      begin: begin.thickness,
      end: end.thickness,
    ).animate(curve);
    _thumbColorAnimation = ColorTween(
      begin: begin.thumbColor,
      end: end.thumbColor,
    ).animate(curve);
    _trackColorAnimation = ColorTween(
      begin: begin.trackColor,
      end: end.trackColor,
    ).animate(curve);
    _trackBorderColorAnimation = ColorTween(
      begin: begin.trackBorderColor,
      end: end.trackBorderColor,
    ).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = switch (widget.direction) {
      AxisDirection.up || AxisDirection.down => true,
      AxisDirection.left || AxisDirection.right => false,
    };

    return MouseRegion(
      onEnter: (_) => _setInsideScrollable(true),
      onExit: (_) => _setInsideScrollable(false),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return RawScrollbar(
                controller: widget.controller,
                thumbVisibility: true,
                thickness: _thicknessAnimation.value,
                radius: Radius.zero,
                trackVisibility: true,
                thumbColor: _thumbColorAnimation.value,
                trackColor: _trackColorAnimation.value,
                trackBorderColor: _trackBorderColorAnimation.value,
                child: child!,
              );
            },
            child: widget.child,
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: false,
              child: _ScrollbarInteractionRegion(
                isVertical: isVertical,
                hitExtent: _hoverHitExtent,
                onHoverChanged: _setHovered,
                onPressedChanged: _setPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  bool sameAs(_ScrollbarVisuals other) {
    return thickness == other.thickness &&
        thumbColor == other.thumbColor &&
        trackColor == other.trackColor &&
        trackBorderColor == other.trackBorderColor;
  }
}
