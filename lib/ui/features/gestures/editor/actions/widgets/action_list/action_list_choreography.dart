/// Transient, render-coupled state for the action list: the expansion sets, the
/// per-row pinned trigger options, drag bookkeeping, and the tree mutations.
/// The [ActionScrollAnchor] slice it composes lives next door.
///
/// Everything is keyed by action editId, so nothing has to be remapped when the
/// tree changes shape.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/tree_list/auto_scroller.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/common/tree_list/marquee_engine.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_motion.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/common/use_drag_escape_cancel.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_rows.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_scroll_anchor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';

/// Where a revealed row parks, as a fraction of the viewport.
const double _revealAlignment = 0.1;

/// Outlasts the card expand it chases ([Durations.medium1]).
const Duration _revealScrollDuration = Duration(milliseconds: 420);

/// The full choreography for the action list: the expansion set, the per-row
/// pinned trigger-option fields, drag bookkeeping, and the tree mutations.
final class ActionListChoreography {
  const ActionListChoreography({
    required this.expanded,
    required this.collapsedGroups,
    required this.toggleGroup,
    required this.selected,
    required this.marquee,
    required this.transitions,
    required this.pinnedTriggerOptions,
    required this.anchor,
    required this.revealKey,
    required this.revealTarget,
    required this.flashTarget,
    required this.revealTick,
    required this.reveal,
    required this.draggingKeys,
    required this.setDragPointer,
    required this.beginDrag,
    required this.endDrag,
    required this.toggle,
    required this.select,
    required this.toggleSelected,
    required this.clearSelection,
    required this.copy,
    required this.paste,
    required this.selectionTarget,
    required this.blockMarquee,
    required this.setEnabled,
    required this.add,
    required this.remove,
    required this.duplicate,
    required this.move,
    required this.resolve,
  });

  /// EditIds of currently expanded rows.
  final Set<int> expanded;

  /// EditIds of groups whose children are hidden. Groups start expanded, so
  /// this is empty until one is collapsed.
  final Set<int> collapsedGroups;

  /// EditIds of currently selected rows. A drag on any of them carries the
  /// whole set, and so do delete and duplicate.
  final Set<int> selected;

  /// Rows [editIds] would drag: the selection when the row is part of it.
  List<int> dragBundle(int editId) =>
      selected.contains(editId) ? selected.toList() : [editId];

  /// Per-row trigger-option fields lifted out of the accordion into the always
  /// visible section, keyed by editId.
  final Map<int, Set<ActionTriggerOptionField>> pinnedTriggerOptions;

  final ActionScrollAnchor anchor;

  /// Zero-height marker at the top of the row [reveal] travels to.
  final GlobalKey revealKey;

  /// The row wearing [revealKey].
  final int? revealTarget;

  /// The row whose card the reveal is tinting, when it tints one at all.
  final int? flashTarget;

  /// Bumped per reveal, so the same row can flash twice.
  final int revealTick;

  /// Unfolds, opens and travels to a row.
  final Future<void> Function(int editId, {bool flash, bool scroll}) reveal;

  /// The rows currently being dragged; empty while idle. A multi-row drag
  /// carries the whole selection, so every one of them dims.
  final Set<int> draggingKeys;
  final ValueChanged<int?> setDragPointer;
  final void Function(int editId) beginDrag;
  final VoidCallback endDrag;
  final MarqueeSelectionEngine<int> marquee;
  final ActionTransitions transitions;
  final void Function(int editId) toggle;

  /// Shows or hides a group's nested rows.
  final void Function(int editId) toggleGroup;
  final void Function(Set<int> editIds) select;
  final void Function(int editId) toggleSelected;
  final VoidCallback clearSelection;

  /// Clipboard commands over the row, or the selection it belongs to.
  final Future<void> Function(ActionLocation location) copy;
  final Future<void> Function(ActionLocation location) paste;

  /// The row a command aimed at the whole selection addresses: the first
  /// selected one in tree order, or null while nothing is selected.
  final ActionLocation? Function() selectionTarget;

  /// Claims [pointer] so a press inside an editor never starts a marquee.
  final ValueChanged<int> blockMarquee;
  final void Function(ActionLocation location, {required bool enabled})
  setEnabled;
  final void Function(Action action, {int? parentKey}) add;
  final void Function(ActionLocation location) remove;
  final void Function(ActionLocation location) duplicate;
  final void Function(List<int> editIds, TreeMove<int> move) move;

  /// The move a drop would apply, or null when it would change nothing. Drop
  /// targets consult this so a dead slot shows no indicator.
  final TreeMove<int>? Function(List<int> editIds, TreeMoveTarget<int> target)
  resolve;
}

ActionListChoreography useActionListChoreography(
  WidgetRef ref,
  BuildContext context,
  GestureLocation location, {
  required GlobalKey listKey,
}) {
  final anchor = useActionScrollAnchor(context);
  final transitions = useListTransitions<ActionGhostRow>(context);
  ref.listen(actionListEditorProvider(location), (previous, next) {
    if (previous != null) captureActionMotion(transitions, previous, next);
  });
  final expanded = useState(<int>{});
  final collapsedGroups = useState(<int>{});
  // Groups whose children were unfolded by their card opening, so shutting the
  // card can put them back. A manual disclosure hands the fold back to the user
  // and drops the entry.
  final unfoldedByCard = useRef(<int>{});
  final timers = useRef<List<Timer>>([]);
  useEffect(() {
    return () {
      for (final timer in timers.value) {
        timer.cancel();
      }
    };
  }, const []);
  final selected = useState(<int>{});
  final revealTarget = useState<int?>(null);
  final flashTarget = useState<int?>(null);
  final revealTick = useState(0);
  final revealKey = useMemoized(GlobalKey.new);
  final revealScroll = useAnimationController(
    duration: _revealScrollDuration,
  );
  final draggingKeys = useState(<int>{});
  final pinnedTriggerOptions = useState(
    _initialPinnedActionTriggerOptions(
      ref.read(actionListEditorProvider(location)).actions,
    ),
  );
  final setDragPointer = useDragEscapeCancel();

  ActionListEditorNotifier notifier() =>
      ref.read(actionListEditorProvider(location).notifier);

  // Selection captured when a marquee starts; covered rows are unioned onto it
  // (additive) or it stays empty (replace).
  final marqueeBase = useRef(<int>{});
  // A press inside an expanded editor claims its pointer before the list's
  // listener sees it, so dragging over a field never draws a box.
  final blockedPointer = useRef<int?>(null);
  final marquee = useMemoized(() {
    late final MarqueeSelectionEngine<int> engine;
    final autoScroll = ListAutoScroller(
      position: () => Scrollable.maybeOf(context)?.position,
      onScrolled: () => engine.refresh(),
    );
    // The list does not scroll on its own, so its box is the frame and no
    // scroll offset is folded in: row rects stay valid while the page scrolls.
    return engine = MarqueeSelectionEngine<int>(
      autoScroller: autoScroll,
      frame: () {
        final box = listKey.currentContext?.findRenderObject();
        return (box: box is RenderBox && box.hasSize ? box : null, offset: 0.0);
      },
      isBlocked: (pointer) =>
          draggingKeys.value.isNotEmpty || blockedPointer.value == pointer,
      onStart: (additive) =>
          marqueeBase.value = additive ? {...selected.value} : <int>{},
      onUpdate: (covered) =>
          selected.value = {...marqueeBase.value, ...covered},
      onEnd: (covered, {required canceled}) => selected.value = canceled
          ? marqueeBase.value
          : {...marqueeBase.value, ...covered},
    );
  }, [listKey]);
  useEffect(() {
    return () {
      marquee.dispose();
      marquee.autoScroller.dispose();
    };
  }, [marquee]);

  // A row drag runs through the pointer router rather than the Draggable's own
  // callbacks, so the edge scroll keeps tracking even if the dragged row is
  // rebuilt mid-scroll.
  final routedPointer = useRef<int?>(null);
  // One handler for the widget's lifetime: the router matches routes by
  // identity, so a fresh closure per build could never be removed again.
  final onDragPointerEvent = useMemoized<void Function(PointerEvent)>(
    () => (event) {
      if (event is PointerMoveEvent) {
        if (draggingKeys.value.isNotEmpty) {
          marquee.autoScroller.update(event.position);
        }
      } else if (event is PointerUpEvent || event is PointerCancelEvent) {
        marquee.autoScroller.stop();
      }
    },
    [marquee],
  );

  void routeDragPointer(int? pointer) {
    setDragPointer(pointer);
    final previous = routedPointer.value;
    if (previous != null) {
      GestureBinding.instance.pointerRouter.removeRoute(
        previous,
        onDragPointerEvent,
      );
      routedPointer.value = null;
    }
    if (pointer == null) {
      marquee.autoScroller.stop();
      return;
    }
    routedPointer.value = pointer;
    GestureBinding.instance.pointerRouter.addRoute(pointer, onDragPointerEvent);
  }

  useEffect(() {
    return () {
      final pointer = routedPointer.value;
      if (pointer != null) {
        GestureBinding.instance.pointerRouter.removeRoute(
          pointer,
          onDragPointerEvent,
        );
      }
    };
  }, const []);

  void clearSelection() {
    if (selected.value.isNotEmpty) selected.value = const {};
  }

  // Escape cancels a running marquee, else drops the selection.
  useEffect(() {
    bool onKey(KeyEvent event) {
      if (event is! KeyDownEvent ||
          event.logicalKey != LogicalKeyboardKey.escape) {
        return false;
      }
      final pointer = marquee.activePointer;
      if (pointer != null) {
        GestureBinding.instance.handlePointerEvent(
          PointerCancelEvent(pointer: pointer),
        );
        return true;
      }
      if (selected.value.isEmpty) return false;
      clearSelection();
      return true;
    }

    HardwareKeyboard.instance.addHandler(onKey);
    return () => HardwareKeyboard.instance.removeHandler(onKey);
  }, [marquee]);

  void scrollTo(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = key.currentContext;
      if (context == null) return;
      unawaited(
        Scrollable.ensureVisible(
          context,
          alignment: 1,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: Durations.short4,
          curve: Easing.emphasizedDecelerate,
        ),
      );
    });
  }

  /// How far the content can scroll up before [editId] leaves the top of the
  /// viewport. It caps what the anchor may spend keeping a growing region's
  /// bottom in view: a fold taller than the space below it would otherwise
  /// take the row that owns it off the top of the screen.
  double? headroomAbove(int editId) {
    final row = marquee.measureKeyFor(editId).currentContext;
    final box = row?.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (box is! RenderBox ||
        !box.attached ||
        !box.hasSize ||
        position == null ||
        !position.hasContentDimensions) {
      return null;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return null;
    final atTop = viewport.getOffsetToReveal(box, 0).offset;
    final headroom = atTop - position.pixels;
    return headroom < 0 ? 0.0 : headroom;
  }

  void toggle(int editId) {
    final next = Set<int>.from(expanded.value);
    if (!next.add(editId)) {
      next.remove(editId);
      if (anchor.activeKey == editId) anchor.clear();
      if (unfoldedByCard.value.remove(editId)) {
        collapsedGroups.value = {...collapsedGroups.value, editId};
      }
      expanded.value = next;
      return;
    }
    // Opening a group's card shows what it holds.
    final unfolds = collapsedGroups.value.contains(editId);
    if (unfolds) {
      collapsedGroups.value = {...collapsedGroups.value}..remove(editId);
      unfoldedByCard.value.add(editId);
    }
    anchor.beginTwoPhase(
      editId,
      onMeasured: () => expanded.value = next,
      // A card opening on its own is worth chasing however far it grows. Only
      // the fold it drags open with it is capped.
      maxCorrection: unfolds ? headroomAbove(editId) : null,
    );
  }

  List<ActionRow> rows() => ref.read(actionListEditorProvider(location)).rows;

  /// The rows an action-level command applies to: the selection when [editId]
  /// is part of it, otherwise just that row.
  List<int> bundle(int editId) => selected.value.contains(editId)
      ? [
          for (final row in rows())
            if (selected.value.contains(row.editId)) row.editId,
        ]
      : [editId];

  void remove(ActionLocation target) {
    final keys = bundle(target.editId);
    expanded.value = {...expanded.value}..removeAll(keys);
    pinnedTriggerOptions.value = {...pinnedTriggerOptions.value}
      ..removeWhere((key, _) => keys.contains(key));
    selected.value = {...selected.value}..removeAll(keys);
    anchor.clear();
    captureActionGhosts(transitions, ref, location, keys);
    notifier().remove(keys);
  }

  /// The row a clipboard command applies to: the last of the selection when
  /// [target] is part of it, otherwise the row itself.
  int anchorKeyFor(int target) =>
      selected.value.contains(target) ? bundle(target).last : target;

  ActionLocation? selectionTarget() {
    if (selected.value.isEmpty) return null;
    for (final row in rows()) {
      if (selected.value.contains(row.editId)) return row.location;
    }
    return null;
  }

  Future<void> copy(ActionLocation target) =>
      notifier().copy(bundle(target.editId));

  Future<void> paste(ActionLocation target) async {
    final anchorKey = anchorKeyFor(target.editId);
    final before = {for (final row in rows()) row.editId};
    await notifier().paste(anchorKey);
    collapsedGroups.value = {
      ...collapsedGroups.value,
      // Pasted rows arrive shut, however open the rows they were copied from
      // were, so a paste never unpacks a tree into the list.
      for (final row in rows())
        if (!before.contains(row.editId) && row.isGroup) row.editId,
      // Pasting into a folded group would otherwise drop the rows out of sight.
    }..remove(anchorKey);
    clearSelection();
  }

  void duplicate(ActionLocation target) {
    final before = {for (final row in rows()) row.editId};
    notifier().duplicate(bundle(target.editId));
    final copy = rows()
        .where((row) => !before.contains(row.editId))
        .firstOrNull;
    if (copy == null) return;
    expanded.value = {...expanded.value, copy.editId};
    final sourceFields = pinnedTriggerOptions.value[target.editId];
    if (sourceFields != null) {
      pinnedTriggerOptions.value = {
        ...pinnedTriggerOptions.value,
        copy.editId: sourceFields,
      };
    }
    anchor.begin(copy.editId);
    scrollTo(anchor.anchorKey);
  }

  void add(Action action, {int? parentKey}) {
    final before = {for (final row in rows()) row.editId};
    notifier().add(action, parentKey: parentKey);
    // The new action's editId is only known once the add lands in the draft.
    final added = rows()
        .where((row) => !before.contains(row.editId))
        .firstOrNull;
    if (added != null) {
      expanded.value = {...expanded.value, added.editId, ?parentKey};
    }
    anchor.clear();
    // AnimatedSize renders new rows at full size immediately (no prior state
    // to animate from), so the anchor mechanism won't fire. Scroll explicitly.
    scrollTo(anchor.bottomKey);
  }

  /// Travels to the revealed row, re-aiming every frame: the card is still
  /// growing, and a fixed offset clamps to the shorter list and falls short.
  Future<void> scrollToReveal() async {
    final target = revealKey.currentContext;
    final box = target?.findRenderObject();
    if (target == null || box is! RenderBox) return;
    final position = Scrollable.maybeOf(target)?.position;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (position == null || viewport == null) return;

    double destination() => viewport
        .getOffsetToReveal(box, _revealAlignment)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    final start = position.pixels;
    void follow() {
      // The row can go away mid-travel: an undo rebuilds the list, and a
      // detached box has no offset in this viewport.
      if (!box.attached ||
          !box.hasSize ||
          !position.hasContentDimensions ||
          RenderAbstractViewport.maybeOf(box) != viewport) {
        return;
      }
      final t = Easing.standard.transform(revealScroll.value);
      position.jumpTo(start + (destination() - start) * t);
    }

    revealScroll.addListener(follow);
    try {
      await revealScroll.forward(from: 0);
    } finally {
      revealScroll.removeListener(follow);
    }
  }

  /// Brings a row into view. Fold, card and travel start in the same frame, so
  /// it reads as one movement. [flash] tints the whole card and [scroll] parks
  /// it near the top; both are wrong when the caller already marks, and aims
  /// at, the field that changed.
  Future<void> reveal(
    int editId, {
    bool flash = true,
    bool scroll = true,
  }) async {
    final parents = {for (final row in rows()) row.editId: row.parentKey};
    final ancestors = <int>{};
    for (var parent = parents[editId]; parent != null;) {
      ancestors.add(parent);
      parent = parents[parent];
    }
    final unfolding = collapsedGroups.value.any(ancestors.contains);
    if (unfolding) {
      // The fold is the user's now.
      unfoldedByCard.value.removeAll(ancestors);
      collapsedGroups.value = {...collapsedGroups.value}..removeAll(ancestors);
    }
    revealTarget.value = editId;
    if (flash) {
      flashTarget.value = editId;
      revealTick.value++;
    }

    if (!expanded.value.contains(editId)) {
      // The travel owns the scroll offset from here.
      anchor.clear();
      expanded.value = {...expanded.value, editId};
    }

    // The marker needs a frame.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    if (scroll) {
      await scrollToReveal();
      if (!context.mounted) return;
    }

    // Else it flashes again on reopen.
    revealTarget.value = null;
    flashTarget.value = null;
  }

  TreeMove<int>? resolve(List<int> editIds, TreeMoveTarget<int> target) =>
      moveTreeNodes(actionTreeNodes(rows()), editIds.toSet(), target);

  void move(List<int> editIds, TreeMove<int> result) {
    anchor.clear();
    notifier().move(
      [
        for (final id in result.orderedIds)
          if (result.movedIds.contains(id)) id,
      ],
      beforeKey: result.beforeId,
      newParentKey: result.newParentId,
    );
  }

  void toggleGroup(int editId) {
    unfoldedByCard.value.remove(editId);
    final next = {...collapsedGroups.value};
    if (next.add(editId)) {
      // Folding shut needs no correction; the sliver leaves it alone.
      anchor.clear();
      collapsedGroups.value = next;
      return;
    }

    next.remove(editId);
    final last = lastVisibleDescendant(
      rows(),
      editId,
      rowsHiddenByCollapse(rows(), next),
    );
    if (last == null) {
      collapsedGroups.value = next;
      return;
    }
    // Anchor on the group's last row before it opens, so the sliver keeps that
    // row's bottom in view as the fold grows instead of letting it run past
    // the viewport.
    anchor.beginTwoPhase(
      last,
      onMeasured: () => collapsedGroups.value = next,
      maxCorrection: headroomAbove(editId),
    );
    timers.value.add(
      Timer(Durations.medium1 + const Duration(milliseconds: 50), () {
        if (context.mounted) anchor.clear();
      }),
    );
  }

  final revealedTicket = useRef<int?>(null);
  final pending = ref.watch(editRevealProvider);
  useEffect(() {
    final target = pending;
    final actionEditId = target?.actionEditId;
    if (target == null ||
        actionEditId == null ||
        target.gesture != location ||
        revealedTicket.value == target.ticket) {
      return null;
    }
    revealedTicket.value = target.ticket;
    // A move shows itself where it lands; opening the card of the group it
    // shuffled would bury the row that travelled.
    if (_revealedAMove(target, location)) return null;
    // The rows for a freshly selected gesture land a frame later.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The field marks and aims at itself; this only has to open the card.
      if (context.mounted) {
        unawaited(reveal(actionEditId, flash: false, scroll: false));
      }
    });
    return null;
  }, [pending]);

  return ActionListChoreography(
    expanded: expanded.value,
    collapsedGroups: collapsedGroups.value,
    toggleGroup: toggleGroup,
    selected: selected.value,
    marquee: marquee,
    transitions: transitions,
    pinnedTriggerOptions: pinnedTriggerOptions.value,
    anchor: anchor,
    revealKey: revealKey,
    revealTarget: revealTarget.value,
    flashTarget: flashTarget.value,
    revealTick: revealTick.value,
    reveal: reveal,
    draggingKeys: draggingKeys.value,
    setDragPointer: routeDragPointer,
    beginDrag: (editId) => draggingKeys.value = bundle(editId).toSet(),
    endDrag: () => draggingKeys.value = const {},
    toggle: toggle,
    select: (editIds) => selected.value = editIds,
    toggleSelected: (editId) {
      final next = {...selected.value};
      if (!next.add(editId)) next.remove(editId);
      selected.value = next;
    },
    clearSelection: clearSelection,
    copy: copy,
    paste: paste,
    selectionTarget: selectionTarget,
    blockMarquee: (pointer) => blockedPointer.value = pointer,
    setEnabled: (target, {required enabled}) =>
        notifier().setEnabled(bundle(target.editId), enabled: enabled),
    add: add,
    remove: remove,
    duplicate: duplicate,
    move: move,
    resolve: resolve,
  );
}

bool _revealedAMove(EditReveal reveal, GestureLocation location) {
  List<TreeListNode<int>> nodes(Config config) => actionTreeNodes(
    flattenActionRows(
      location,
      gestureAt(config, location)?.common.actions ?? const [],
    ),
  );

  return findMovedNodes(
    nodes(reveal.before),
    nodes(reveal.after),
  ).isNotEmpty;
}

Map<int, Set<ActionTriggerOptionField>> _initialPinnedActionTriggerOptions(
  List<TriggerAction> actions,
) {
  final pinned = <int, Set<ActionTriggerOptionField>>{};
  void walk(List<TriggerAction> level) {
    for (final action in level) {
      final editId = action.editId;
      final fields = ActionTriggerFields.nonDefaultFields(action);
      if (editId != null && fields.isNotEmpty) pinned[editId] = fields;
      if (action.action case ActionGroup(actions: final children)) {
        walk(children);
      }
    }
  }

  walk(actions);
  return pinned;
}
