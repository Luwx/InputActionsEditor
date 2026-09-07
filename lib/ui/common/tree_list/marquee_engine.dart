import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/common/tree_list/auto_scroller.dart';
import 'package:input_actions_editor/ui/common/tree_list/marquee_overlay.dart';

/// The box marquee coordinates are measured in, and the scroll offset folded
/// into them. A list that owns its viewport measures against the viewport and
/// folds in its scroll offset, so a row that scrolls away keeps its place; a
/// list nested in a foreign viewport measures against its own box, which moves
/// with the content, and folds in nothing.
typedef MarqueeFrame = ({RenderBox? box, double offset});

/// Rubber-band selection over a list of rows, independent of how the list is
/// assembled: the host tags each selectable row with [measureKeyFor] and feeds
/// pointer-downs to [handlePointerDown]; the engine reports the ids the box
/// covers and drives [rect]/[sweepCorner] for [MarqueeSelectionOverlay].
class MarqueeSelectionEngine<Id> {
  MarqueeSelectionEngine({
    required this.autoScroller,
    required this.frame,
    required this.isBlocked,
    this.topInset,
    this.trailingInset = 0,
    this.onStart,
    this.onUpdate,
    this.onEnd,
  });

  /// Travel before a press becomes a marquee, so a click stays a row tap.
  static const _startThreshold = 44.0;

  final ListAutoScroller autoScroller;

  /// The current coordinate frame, resolved per use.
  final MarqueeFrame Function() frame;

  /// Height of a pinned leading header; presses above it are ignored.
  final ValueGetter<double>? topInset;

  /// Width of a trailing band that belongs to something else (a scrollbar).
  final double trailingInset;

  /// Whether the host already owns [pointer] (a row drag in progress).
  final bool Function(int pointer) isBlocked;

  final void Function(bool additive)? onStart;
  final void Function(Set<Id> covered)? onUpdate;
  final void Function(Set<Id> covered, {required bool canceled})? onEnd;

  final ValueNotifier<Rect?> rect = ValueNotifier(null);
  final ValueNotifier<MarqueeSweepCorner> sweepCorner = ValueNotifier(
    MarqueeSweepCorner.bottomLeft,
  );

  final Map<Id, GlobalKey> _measureKeys = {};
  final Map<Id, Rect> _contentRects = {};

  bool _pending = false;
  bool _active = false;
  bool _additive = false;
  int? _routedPointer;
  Offset? _downGlobal;
  Offset? _anchorContent;
  Offset? _lastGlobal;
  Set<Id>? _lastCovered;

  bool get isActive => _active;

  /// The pointer this engine has claimed, so the host can cancel it (escape).
  int? get activePointer => _routedPointer;

  GlobalKey measureKeyFor(Id id) => _measureKeys.putIfAbsent(id, GlobalKey.new);

  /// Forgets keys and cached rects for ids no longer in the list. Rows merely
  /// scrolled out of view must stay in [liveIds] to keep their cached rect.
  void pruneKeys(Set<Id> liveIds) {
    _measureKeys.removeWhere((id, _) => !liveIds.contains(id));
    _contentRects.removeWhere((id, _) => !liveIds.contains(id));
  }

  void handlePointerDown(PointerDownEvent event) {
    if (_active || _pending) return;
    if (event.kind != PointerDeviceKind.mouse) return;
    if (event.buttons != kPrimaryButton) return;
    if (isBlocked(event.pointer)) return;
    final box = autoScroller.viewportBox;
    if (box == null) return;
    final local = box.globalToLocal(event.position);
    if (local.dy < (topInset?.call() ?? 0)) return;
    if (local.dx > box.size.width - trailingInset) return;

    _pending = true;
    _downGlobal = event.position;
    _additive = _hasSelectionModifier;
    _routedPointer = event.pointer;
    GestureBinding.instance.pointerRouter.addRoute(event.pointer, _handleRoute);
  }

  /// Recomputes the box after the viewport scrolled under a stationary pointer.
  void refresh() {
    final last = _lastGlobal;
    if (_active && last != null) _update(last);
  }

  void dispose() {
    _removeRoute();
    rect.dispose();
    sweepCorner.dispose();
  }

  bool get _hasSelectionModifier {
    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    return keys.contains(LogicalKeyboardKey.shiftLeft) ||
        keys.contains(LogicalKeyboardKey.shiftRight) ||
        keys.contains(LogicalKeyboardKey.controlLeft) ||
        keys.contains(LogicalKeyboardKey.controlRight) ||
        keys.contains(LogicalKeyboardKey.metaLeft) ||
        keys.contains(LogicalKeyboardKey.metaRight);
  }

  void _handleRoute(PointerEvent event) {
    if (event is PointerMoveEvent) {
      if (_active) {
        _update(event.position);
        return;
      }
      if (!_pending) return;
      if (isBlocked(event.pointer)) {
        _cancelPending();
        return;
      }
      final down = _downGlobal;
      if (down != null && (event.position - down).distance >= _startThreshold) {
        _activate();
        _update(event.position);
      }
    } else if (event is PointerUpEvent) {
      if (_active) {
        _end(canceled: false);
      } else {
        _cancelPending();
      }
    } else if (event is PointerCancelEvent) {
      if (_active) {
        _end(canceled: true);
      } else {
        _cancelPending();
      }
    }
  }

  void _activate() {
    final (:box, :offset) = frame();
    final down = _downGlobal;
    if (box == null || down == null) {
      _cancelPending();
      return;
    }
    final local = box.globalToLocal(down);
    _anchorContent = Offset(local.dx, local.dy + offset);
    _pending = false;
    _active = true;
    _contentRects.clear();
    _lastCovered = null;
    onStart?.call(_additive);
  }

  void _update(Offset globalPosition) {
    final (:box, offset: pixels) = frame();
    final anchor = _anchorContent;
    if (box == null || anchor == null) return;
    _lastGlobal = globalPosition;
    final local = box.globalToLocal(globalPosition);
    final current = Offset(local.dx, local.dy + pixels);
    final contentRect = Rect.fromPoints(anchor, current);
    sweepCorner.value = _sweepCornerFor(anchor, current);

    _measure(box, pixels);
    final covered = _coveredBy(contentRect);

    rect.value = contentRect.translate(0, -pixels);

    if (_lastCovered == null || !setEquals(_lastCovered, covered)) {
      _lastCovered = covered;
      onUpdate?.call(covered);
    }
    autoScroller.update(globalPosition);
  }

  void _end({required bool canceled}) {
    final anchor = _anchorContent;
    final last = _lastGlobal;
    final (:box, :offset) = frame();
    var covered = <Id>{};
    if (box != null && anchor != null && last != null) {
      final local = box.globalToLocal(last);
      covered = _coveredBy(
        Rect.fromPoints(anchor, Offset(local.dx, local.dy + offset)),
      );
    }

    autoScroller.stop();
    _removeRoute();
    _active = false;
    _pending = false;
    _anchorContent = null;
    _downGlobal = null;
    _lastGlobal = null;
    _lastCovered = null;
    _contentRects.clear();
    rect.value = null;
    onEnd?.call(covered, canceled: canceled);
  }

  void _cancelPending() {
    _pending = false;
    _downGlobal = null;
    _removeRoute();
  }

  void _removeRoute() {
    final pointer = _routedPointer;
    if (pointer == null) return;
    _routedPointer = null;
    GestureBinding.instance.pointerRouter.removeRoute(pointer, _handleRoute);
  }

  void _measure(RenderBox frameBox, double pixels) {
    final origin = frameBox.localToGlobal(Offset.zero);
    for (final entry in _measureKeys.entries) {
      final context = entry.value.currentContext;
      if (context == null) continue;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize) continue;
      final topLeft = box.localToGlobal(Offset.zero);
      _contentRects[entry.key] = Rect.fromLTWH(
        topLeft.dx - origin.dx,
        topLeft.dy - origin.dy + pixels,
        box.size.width,
        box.size.height,
      );
    }
  }

  Set<Id> _coveredBy(Rect box) => {
    for (final entry in _contentRects.entries)
      if (_overlaps(box, entry.value)) entry.key,
  };

  // Inclusive, so a zero-width box (a straight vertical drag) still catches the
  // full-width rows it runs through.
  bool _overlaps(Rect a, Rect b) =>
      a.left <= b.right &&
      a.right >= b.left &&
      a.top <= b.bottom &&
      a.bottom >= b.top;

  MarqueeSweepCorner _sweepCornerFor(Offset anchor, Offset current) {
    final movedRight = current.dx >= anchor.dx;
    final movedDown = current.dy >= anchor.dy;
    return switch ((movedRight, movedDown)) {
      (true, true) => MarqueeSweepCorner.bottomRight,
      (true, false) => MarqueeSweepCorner.topRight,
      (false, true) => MarqueeSweepCorner.bottomLeft,
      (false, false) => MarqueeSweepCorner.topLeft,
    };
  }
}
