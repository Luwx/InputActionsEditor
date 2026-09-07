import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_choreography.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';

class ActionDragData {
  const ActionDragData(this.editIds);

  /// The dragged rows, in document order.
  final List<int> editIds;
}

enum _ActionDropZone { none, before, into }

/// A card as a drop target. The whole card inserts the dragged rows before it;
/// a group card splits, with the top band inserting before and the rest
/// appending into the group. Zone tracking needs the hover position, which only
/// [DragTarget.onMove] carries.
class ActionRowDropTarget extends StatefulWidget {
  const ActionRowDropTarget({
    required this.row,
    required this.choreo,
    required this.child,
    super.key,
  });

  final ActionRow row;
  final ActionListChoreography choreo;
  final Widget child;

  @override
  State<ActionRowDropTarget> createState() => ActionRowDropTargetState();
}

class ActionRowDropTargetState extends State<ActionRowDropTarget> {
  /// The strip at the top of a group card that still means "drop before it".
  /// Everything below it, however tall the card has grown, drops into the
  /// group: landing inside is the common intent and should not need aim.
  static const double _beforeBand = actionCardGap + actionHeaderExtent / 4;

  _ActionDropZone _zone = _ActionDropZone.none;

  TreeMoveTarget<int>? _targetFor(_ActionDropZone zone) => switch (zone) {
    _ActionDropZone.before => MoveBeforeNode(widget.row.editId),
    _ActionDropZone.into => MoveIntoNode(widget.row.editId),
    _ActionDropZone.none => null,
  };

  bool _accepts(List<int> dragged, _ActionDropZone zone) {
    final target = _targetFor(zone);
    return target != null && widget.choreo.resolve(dragged, target) != null;
  }

  _ActionDropZone _zoneFor(List<int> dragged, Offset globalOffset) {
    if (!widget.row.isGroup) {
      return _accepts(dragged, _ActionDropZone.before)
          ? _ActionDropZone.before
          : _ActionDropZone.none;
    }
    var wantsBefore = true;
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize) {
      final dy = box.globalToLocal(globalOffset).dy;
      wantsBefore = dy < _beforeBand;
    }
    final canBefore = _accepts(dragged, _ActionDropZone.before);
    final canInto = _accepts(dragged, _ActionDropZone.into);
    if (wantsBefore) {
      if (canBefore) return _ActionDropZone.before;
      return canInto ? _ActionDropZone.into : _ActionDropZone.none;
    }
    if (canInto) return _ActionDropZone.into;
    return canBefore ? _ActionDropZone.before : _ActionDropZone.none;
  }

  void _setZone(_ActionDropZone zone) {
    if (zone != _zone) setState(() => _zone = zone);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<ActionDragData>(
      onWillAcceptWithDetails: (details) =>
          _accepts(details.data.editIds, _ActionDropZone.before) ||
          (widget.row.isGroup &&
              _accepts(details.data.editIds, _ActionDropZone.into)),
      onMove: (details) =>
          _setZone(_zoneFor(details.data.editIds, details.offset)),
      onLeave: (_) => _setZone(_ActionDropZone.none),
      onAcceptWithDetails: (details) {
        final zone = _zoneFor(details.data.editIds, details.offset);
        _setZone(_ActionDropZone.none);
        final target = _targetFor(zone);
        if (target == null) return;
        final move = widget.choreo.resolve(details.data.editIds, target);
        if (move != null) widget.choreo.move(details.data.editIds, move);
      },
      builder: (context, _, _) => _ActionDropDecoration(
        zone: _zone,
        child: widget.child,
      ),
    );
  }
}

/// The drop feedback for a card: a line that opens a slot above it for a
/// before-drop, a tint for an into-drop.
class _ActionDropDecoration extends StatelessWidget {
  const _ActionDropDecoration({required this.zone, required this.child});

  final _ActionDropZone zone;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = context.theme.colors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grows the row rather than painting over it, the way the gesture list
        // marks a drop: at three pixels a fade would barely read as anything.
        // It stays inside the row box, where the collapse animation's clip
        // cannot cut it off.
        AnimatedContainer(
          duration: Durations.short2,
          height: zone == _ActionDropZone.before ? 3 : 0,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        AnimatedContainer(
          duration: Durations.short2,
          curve: Easing.standard,
          decoration: BoxDecoration(
            color: zone == _ActionDropZone.into
                ? primary.withValues(alpha: 0.08)
                : primary.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(actionCardRadius),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// Catches drops past the last card, moving the dragged rows to the end of the
/// root level. Fixed height, so the list does not reflow while dragging.
class ActionListEndDropTarget extends StatelessWidget {
  const ActionListEndDropTarget({required this.choreo, super.key});

  final ActionListChoreography choreo;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ActionDragData>(
      onWillAcceptWithDetails: (details) =>
          choreo.resolve(details.data.editIds, const MoveToRootEnd()) != null,
      onAcceptWithDetails: (details) {
        final move = choreo.resolve(
          details.data.editIds,
          const MoveToRootEnd(),
        );
        if (move != null) choreo.move(details.data.editIds, move);
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

class ActionDragHandle extends StatelessWidget {
  const ActionDragHandle({
    required this.editIds,
    required this.label,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPointerDown,
    super.key,
  });

  final List<int> editIds;
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
      child: Draggable<ActionDragData>(
        data: ActionDragData(editIds),
        // The label rides the cursor instead of keeping the grab offset, which
        // also makes the offset a target reads the pointer itself: the handle
        // sits at the row's right edge, so the default anchor would report a
        // point half a row above and most of a row to the left of the cursor.
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
        childWhenDragging: const Opacity(opacity: 0.2, child: _GripIcon()),
        child: const MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: _GripIcon(),
        ),
      ),
    );
  }
}

class _GripIcon extends StatelessWidget {
  const _GripIcon();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Icon(
      FLucideIcons.gripVertical,
      size: 14,
      color: context.theme.colors.mutedForeground.withValues(alpha: 0.45),
    ),
  );
}
