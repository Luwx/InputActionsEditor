part of 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_editor.dart';

/// Transient, render-coupled state for [ActionListEditor], split by concern:
/// [_useActionScrollAnchor] owns the [SliverSmartAnchor] coordination, and
/// [_useActionListChoreography] owns the expansion set + pinned trigger-option
/// bookkeeping and the list mutations, composing the former.

/// The slice of choreography that coordinates with the enclosing
/// [SliverSmartAnchor]: it keeps a zero-height marker on the row that is
/// currently growing so the sliver can correct the scroll offset as the row
/// animates open.
final class _ActionScrollAnchor {
  const _ActionScrollAnchor({
    required this.anchorKey,
    required this.bottomKey,
    required this.activeIndex,
    required this.begin,
    required this.beginTwoPhase,
    required this.end,
    required this.clear,
  });

  /// Placed on the row that is the active anchor target.
  final GlobalKey anchorKey;

  /// Zero-height marker at the very bottom of the list, used both to measure
  /// the growing region and as a scroll target when adding an action.
  final GlobalKey bottomKey;

  /// Row index currently wearing [anchorKey], or null.
  final int? activeIndex;

  /// Start anchoring a row that is expanding its trigger-options accordion.
  final void Function(int index) begin;

  /// Two-phase expand: attach the anchor (row still collapsed), measure
  /// post-frame, then run [onMeasured] (which starts the size animation).
  final void Function(int index, {required VoidCallback onMeasured})
  beginTwoPhase;

  /// Stop correcting once the expand animation settles.
  final VoidCallback end;

  /// Drop the anchor entirely (row collapsed / removed / reordered).
  final VoidCallback clear;
}

_ActionScrollAnchor _useActionScrollAnchor(BuildContext context) {
  final anchorKey = useMemoized(GlobalKey.new);
  final bottomKey = useMemoized(GlobalKey.new);
  final anchorIndex = useState<int?>(null);
  final anchorRef = useRef<ScrollAnchorController?>(null)
    ..value = ScrollAnchorScope.maybeOf(context);

  void measureBelowExtent() {
    final anchorBox = anchorKey.currentContext?.findRenderObject();
    final bottomBox = bottomKey.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox ||
        bottomBox is! RenderBox ||
        !anchorBox.attached ||
        !bottomBox.attached ||
        !anchorBox.hasSize ||
        !bottomBox.hasSize) {
      return;
    }
    final gap =
        bottomBox.localToGlobal(Offset.zero).dy -
        anchorBox.localToGlobal(Offset.zero).dy;
    anchorRef.value?.belowExtent = gap < 0 ? 0.0 : gap;
  }

  void clear() {
    anchorIndex.value = null;
    anchorRef.value
      ?..isAnchoring = false
      ..belowExtent = null;
  }

  void begin(int index) {
    anchorIndex.value = index;
    final anchor = anchorRef.value;
    if (anchor == null) return;
    anchor
      ..belowExtent = null
      ..isAnchoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => measureBelowExtent());
  }

  void end() => anchorRef.value?.isAnchoring = false;

  void beginTwoPhase(int index, {required VoidCallback onMeasured}) {
    // Attach anchorKey first (row still collapsed), measure belowExtent
    // post-frame, then run onMeasured to start AnimatedSize. This ensures
    // SliverSmartAnchor can correct even a large first-frame delta caused by
    // shader-compilation jank.
    anchorIndex.value = index;
    final anchor = anchorRef.value;
    if (anchor == null) {
      onMeasured();
      return;
    }
    anchor
      ..belowExtent = null
      ..isAnchoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      measureBelowExtent();
      onMeasured();
    });
  }

  return _ActionScrollAnchor(
    anchorKey: anchorKey,
    bottomKey: bottomKey,
    activeIndex: anchorIndex.value,
    begin: begin,
    beginTwoPhase: beginTwoPhase,
    end: end,
    clear: clear,
  );
}

/// The full choreography for the action list: the expansion set, the per-row
/// pinned trigger-option fields, drag bookkeeping, and the list mutations that
/// must keep all of those in sync with the underlying draft as rows are added,
/// removed, duplicated and reordered.
final class _ActionListChoreography {
  const _ActionListChoreography({
    required this.expanded,
    required this.pinnedTriggerOptions,
    required this.anchor,
    required this.setDragPointer,
    required this.toggle,
    required this.add,
    required this.remove,
    required this.duplicate,
    required this.reorder,
  });

  /// Indices of currently expanded rows.
  final Set<int> expanded;

  /// Per-row trigger-option fields lifted out of the accordion into the always
  /// visible section.
  final Map<int, Set<ActionTriggerOptionField>> pinnedTriggerOptions;

  final _ActionScrollAnchor anchor;
  final ValueChanged<int?> setDragPointer;
  final void Function(int index) toggle;
  final void Function(Action action) add;
  final void Function(int index) remove;
  final void Function(int index) duplicate;
  final void Function(int oldIndex, int newIndex) reorder;
}

_ActionListChoreography _useActionListChoreography(
  WidgetRef ref,
  BuildContext context,
  GestureLocation location,
) {
  final anchor = _useActionScrollAnchor(context);
  final expanded = useState(<int>{});
  final pinnedTriggerOptions = useState(
    _initialPinnedActionTriggerOptions(
      ref.read(actionListEditorProvider(location)).actions,
    ),
  );
  final setDragPointer = useDragEscapeCancel();

  List<TriggerAction> actionsFromDraft() =>
      ref.read(actionListEditorProvider(location)).actions;

  void toggle(int index) {
    final isExpanding = !expanded.value.contains(index);
    final next = Set<int>.from(expanded.value);
    if (!next.add(index)) {
      next.remove(index);
      if (anchor.activeIndex == index) anchor.clear();
    }
    if (!isExpanding) {
      expanded.value = next;
      return;
    }
    anchor.beginTwoPhase(index, onMeasured: () => expanded.value = next);
  }

  void remove(int index) {
    final actions = actionsFromDraft();
    if (index < 0 || index >= actions.length) return;
    final next = <int>{};
    for (final e in expanded.value) {
      if (e == index) continue;
      next.add(e > index ? e - 1 : e);
    }
    expanded.value = next;
    pinnedTriggerOptions.value = {
      for (final entry in pinnedTriggerOptions.value.entries)
        if (entry.key != index)
          (entry.key > index ? entry.key - 1 : entry.key): entry.value,
    };
    anchor.clear();
    ref.read(actionListEditorProvider(location).notifier).remove(index);
  }

  void duplicate(int index) {
    final current = actionsFromDraft();
    if (index < 0 || index >= current.length) return;
    final next = <int>{};
    for (final e in expanded.value) {
      next.add(e > index ? e + 1 : e);
    }
    expanded.value = next;
    final nextPinnedTriggerOptions = {
      for (final entry in pinnedTriggerOptions.value.entries)
        (entry.key > index ? entry.key + 1 : entry.key): entry.value,
    };
    final sourceFields = pinnedTriggerOptions.value[index];
    if (sourceFields != null) {
      nextPinnedTriggerOptions[index + 1] = sourceFields;
    }
    pinnedTriggerOptions.value = nextPinnedTriggerOptions;
    anchor.clear();
    ref.read(actionListEditorProvider(location).notifier).duplicate(index);
  }

  void add(Action action) {
    final newIndex = actionsFromDraft().length;
    ref.read(actionListEditorProvider(location).notifier).add(action);
    expanded.value = {...expanded.value, newIndex};
    anchor.clear();
    // AnimatedSize renders new rows at full size immediately (no prior state
    // to animate from), so the anchor mechanism won't fire. Scroll explicitly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = anchor.bottomKey.currentContext;
      if (ctx != null) {
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            alignment: 1,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            duration: Durations.short4,
            curve: Easing.emphasizedDecelerate,
          ),
        );
      }
    });
  }

  void reorder(int oldIndex, int newIndex) {
    final actions = actionsFromDraft();
    if (oldIndex < 0 ||
        oldIndex >= actions.length ||
        newIndex < 0 ||
        newIndex >= actions.length) {
      return;
    }
    final next = <int>{};
    for (final e in expanded.value) {
      next.add(_remapIndex(e, oldIndex, newIndex));
    }
    expanded.value = next;
    pinnedTriggerOptions.value = {
      for (final entry in pinnedTriggerOptions.value.entries)
        _remapIndex(entry.key, oldIndex, newIndex): entry.value,
    };
    anchor.clear();
    ref
        .read(actionListEditorProvider(location).notifier)
        .reorder(
          oldIndex,
          newIndex,
        );
  }

  return _ActionListChoreography(
    expanded: expanded.value,
    pinnedTriggerOptions: pinnedTriggerOptions.value,
    anchor: anchor,
    setDragPointer: setDragPointer,
    toggle: toggle,
    add: add,
    remove: remove,
    duplicate: duplicate,
    reorder: reorder,
  );
}

/// Remaps an index tracked alongside the list when an item moves from [from] to
/// [to], so expansion / pinned-option keys follow their rows through a reorder.
int _remapIndex(int e, int from, int to) {
  if (e == from) return to;
  if (from < to) {
    if (e > from && e <= to) return e - 1;
  } else if (e >= to && e < from) {
    return e + 1;
  }
  return e;
}

Map<int, Set<ActionTriggerOptionField>> _initialPinnedActionTriggerOptions(
  List<TriggerAction> actions,
) => {
  for (final (index, action) in actions.indexed)
    if (ActionTriggerFields.nonDefaultFields(action) case final fields
        when fields.isNotEmpty)
      index: fields,
};
