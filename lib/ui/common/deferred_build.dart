import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Defers building an expensive, initially-hidden subtree so it stays off the
/// critical first frame(s) of a screen.
///
/// Until built, [placeholder] is shown. The real child ([builder]) is built
/// either:
///  * after a randomized delay in `[minDelay, maxDelay]` — the jitter spreads
///    many instances across frames instead of stampeding one frame, or
///  * immediately when [revealed] turns `true` (e.g. the user expands the
///    section that contains it), whichever happens first.
///
/// Once built it stays built — collapsing/re-expanding never tears it down.
///
/// Intended for content hidden behind a collapsible (e.g. a forui `FAccordion`,
/// which builds its child eagerly even while collapsed): deferring is invisible
/// because the content is clipped away until revealed.
class DeferredBuild extends StatefulWidget {
  const DeferredBuild({
    required this.builder,
    this.revealed,
    this.placeholder = const SizedBox.shrink(),
    this.minDelay = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 300),
    super.key,
  });

  final WidgetBuilder builder;

  /// When this turns `true`, the child is built immediately and the background
  /// delay is cancelled. Typically the enclosing section's expanded state.
  final ValueListenable<bool>? revealed;

  final Widget placeholder;
  final Duration minDelay;
  final Duration maxDelay;

  @override
  State<DeferredBuild> createState() => _DeferredBuildState();
}

class _DeferredBuildState extends State<DeferredBuild> {
  static final _random = Random();
  Timer? _timer;
  bool _built = false;

  @override
  void initState() {
    super.initState();
    if (widget.revealed?.value ?? false) {
      _built = true;
      return;
    }
    widget.revealed?.addListener(_onRevealed);
    _timer = Timer(_jitteredDelay(), _build);
  }

  Duration _jitteredDelay() {
    final lo = widget.minDelay.inMilliseconds;
    final hi = max(lo, widget.maxDelay.inMilliseconds);
    return Duration(milliseconds: lo + _random.nextInt(hi - lo + 1));
  }

  void _onRevealed() {
    if (widget.revealed?.value ?? false) _build();
  }

  void _build() {
    if (_built) return;
    _timer?.cancel();
    _timer = null;
    widget.revealed?.removeListener(_onRevealed);
    if (mounted) setState(() => _built = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.revealed?.removeListener(_onRevealed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _built ? widget.builder(context) : widget.placeholder;
}
