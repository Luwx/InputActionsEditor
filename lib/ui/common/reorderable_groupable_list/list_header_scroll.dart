part of 'reorderable_groupable_list.dart';

/// Measures [measureKey] against the pin line each frame and rebuilds [builder]
/// with the resulting [ReorderableHeaderScroll]. [measureKey] is the
/// header box (a fixed reference) so consumer animations cannot feed back in.
class _HeaderScrollProgress extends StatefulWidget {
  const _HeaderScrollProgress({
    required this.scrollable,
    required this.leadingInset,
    required this.measureKey,
    required this.builder,
    required this.child,
  });

  final ScrollController scrollable;
  final double leadingInset;
  final GlobalKey measureKey;
  final ValueWidgetBuilder<ReorderableHeaderScroll> builder;
  final Widget? child;

  @override
  State<_HeaderScrollProgress> createState() => _HeaderScrollProgressState();
}

class _HeaderScrollProgressState extends State<_HeaderScrollProgress> {
  // Far below the pin line / not measurable yet: fully visible, no frost.
  static const ReorderableHeaderScroll _unmeasured = (
    scrolledUnder: 0.0,
    pinOffsetPx: 1e6,
  );

  final ValueNotifier<ReorderableHeaderScroll> _scroll = ValueNotifier(
    _unmeasured,
  );
  bool _recomputeScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollable.addListener(_scheduleRecompute);
    _scheduleRecompute();
  }

  @override
  void didUpdateWidget(covariant _HeaderScrollProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollable != widget.scrollable) {
      oldWidget.scrollable.removeListener(_scheduleRecompute);
      widget.scrollable.addListener(_scheduleRecompute);
    }
    _scheduleRecompute();
  }

  @override
  void dispose() {
    widget.scrollable.removeListener(_scheduleRecompute);
    _scroll.dispose();
    super.dispose();
  }

  // Recompute after the frame settles (reading geometry during build lags a
  // frame). If the value still moved, re-check next frame: an animation can
  // reach its final position via a frame with no scroll notification (a silent
  // end clamp), so settle until stable rather than trusting the last signal.
  void _scheduleRecompute() {
    if (_recomputeScheduled) return;
    _recomputeScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recomputeScheduled = false;
      if (!mounted) return;
      final next = _measure();
      if (next == _scroll.value) return;
      _scroll.value = next;
      _scheduleRecompute();
    });
  }

  ReorderableHeaderScroll _measure() {
    if (!widget.scrollable.hasClients) return _unmeasured;
    final box = widget.measureKey.currentContext?.findRenderObject();
    final viewport = widget.scrollable.position.context.notificationContext
        ?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return _unmeasured;
    if (viewport is! RenderBox || !viewport.hasSize) return _unmeasured;
    final height = box.size.height;
    if (height <= 0) return _unmeasured;
    final pinLine =
        viewport.localToGlobal(Offset.zero).dy + widget.leadingInset;
    final headerTop = box.localToGlobal(Offset.zero).dy;
    final pinOffsetPx = headerTop - pinLine;
    return (
      scrolledUnder: (-pinOffsetPx / height).clamp(0.0, 1.0),
      pinOffsetPx: pinOffsetPx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReorderableHeaderScroll>(
      valueListenable: _scroll,
      builder: (context, value, child) => widget.builder(context, value, child),
      child: widget.child,
    );
  }
}
