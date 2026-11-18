import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';

typedef MenuMoveResolver =
    TreeMove<int>? Function(int dragged, TreeMoveTarget<int> target);

typedef MenuMoveCallback = void Function(int dragged, TreeMove<int> move);

class MenuDragHandle extends StatelessWidget {
  const MenuDragHandle({
    required this.dragKey,
    required this.label,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPointerDown,
    super.key,
  });

  final int dragKey;
  final String label;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnded;
  final ValueChanged<int?> onPointerDown;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Listener(
      onPointerDown: (event) => onPointerDown(event.pointer),
      onPointerUp: (_) => onPointerDown(null),
      onPointerCancel: (_) => onPointerDown(null),
      child: Draggable<int>(
        data: dragKey,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        onDragStarted: onDragStarted,
        onDragEnd: (_) => onDragEnded(),
        onDraggableCanceled: (_, _) => onDragEnded(),
        onDragCompleted: onDragEnded,
        feedback: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(label, style: context.theme.typography.body.xs),
            ),
          ),
        ),
        childWhenDragging: const Opacity(opacity: 0.2, child: _Grip()),
        child: const MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: _Grip(),
        ),
      ),
    );
  }
}

class _Grip extends StatelessWidget {
  const _Grip();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 2, 8),
    child: Icon(
      FLucideIcons.gripVertical,
      size: 14,
      color: context.theme.colors.mutedForeground.withValues(alpha: 0.45),
    ),
  );
}

enum _Zone { none, before, into, after }

/// A row as a drop target. A submenu splits into before, into and (while
/// folded) after; any other row into before and after.
class MenuRowDropTarget extends StatefulWidget {
  const MenuRowDropTarget({
    required this.dragKey,
    required this.isSubMenu,
    required this.folded,
    required this.resolve,
    required this.onMove,
    required this.child,
    super.key,
  });

  final int dragKey;
  final bool isSubMenu;
  final bool folded;
  final MenuMoveResolver resolve;
  final MenuMoveCallback onMove;
  final Widget child;

  @override
  State<MenuRowDropTarget> createState() => _MenuRowDropTargetState();
}

class _MenuRowDropTargetState extends State<MenuRowDropTarget> {
  _Zone _zone = _Zone.none;

  TreeMoveTarget<int>? _targetFor(_Zone zone) => switch (zone) {
    _Zone.before => MoveBeforeNode(widget.dragKey),
    _Zone.into => MoveIntoNode(widget.dragKey),
    _Zone.after => MoveAfterSubtree(widget.dragKey),
    _Zone.none => null,
  };

  bool _accepts(int dragged, _Zone zone) {
    final target = _targetFor(zone);
    return target != null && widget.resolve(dragged, target) != null;
  }

  _Zone _zoneFor(int dragged, Offset globalOffset) {
    var fraction = 0.0;
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize && box.size.height > 0) {
      fraction = box.globalToLocal(globalOffset).dy / box.size.height;
    }
    final wanted = widget.isSubMenu
        ? fraction < 0.3
              ? _Zone.before
              : fraction > 0.7 && widget.folded
              ? _Zone.after
              : _Zone.into
        : fraction < 0.5
        ? _Zone.before
        : _Zone.after;
    if (_accepts(dragged, wanted)) return wanted;
    for (final fallback in const [_Zone.before, _Zone.into, _Zone.after]) {
      if (_accepts(dragged, fallback)) return fallback;
    }
    return _Zone.none;
  }

  void _setZone(_Zone zone) {
    if (zone != _zone) setState(() => _zone = zone);
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colors.primary;
    Widget line(bool visible) => AnimatedContainer(
      duration: Durations.short2,
      height: visible ? 3 : 0,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(2),
      ),
    );

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          _accepts(details.data, _Zone.before) ||
          _accepts(details.data, _Zone.after) ||
          (widget.isSubMenu && _accepts(details.data, _Zone.into)),
      onMove: (details) => _setZone(_zoneFor(details.data, details.offset)),
      onLeave: (_) => _setZone(_Zone.none),
      onAcceptWithDetails: (details) {
        final zone = _zoneFor(details.data, details.offset);
        _setZone(_Zone.none);
        final target = _targetFor(zone);
        if (target == null) return;
        final move = widget.resolve(details.data, target);
        if (move != null) widget.onMove(details.data, move);
      },
      builder: (context, _, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          line(_zone == _Zone.before),
          AnimatedContainer(
            duration: Durations.short2,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: _zone == _Zone.into ? 0.08 : 0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: widget.child,
          ),
          line(_zone == _Zone.after),
        ],
      ),
    );
  }
}

/// Catches drops past the last row, moving to the end of the root level.
class MenuEndDropTarget extends StatelessWidget {
  const MenuEndDropTarget({
    required this.resolve,
    required this.onMove,
    super.key,
  });

  final MenuMoveResolver resolve;
  final MenuMoveCallback onMove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) =>
          resolve(details.data, const MoveToRootEnd()) != null,
      onAcceptWithDetails: (details) {
        final move = resolve(details.data, const MoveToRootEnd());
        if (move != null) onMove(details.data, move);
      },
      builder: (context, candidates, _) => SizedBox(
        height: 12,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedContainer(
            duration: Durations.short2,
            height: candidates.isEmpty ? 0 : 3,
            decoration: BoxDecoration(
              color: context.theme.colors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
