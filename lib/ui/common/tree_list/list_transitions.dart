import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Lifetime of a row transition, a little longer than [CollapsibleListRow]'s
/// cross-fade so a row reaches height 0 (or full height) before its
/// bookkeeping is torn down.
const Duration listTransitionLifetime = Duration(milliseconds: 300);

/// A display-only copy of a row that has already left its slot in the model
/// (deleted, or moved elsewhere). It keeps rendering [payload] at the old
/// position so the slot can collapse in place: the edit commits immediately,
/// the ghost is pure animation.
final class ListGhost<T> {
  const ListGhost({
    required this.id,
    required this.payload,
    required this.beforeId,
    this.collapsing = false,
  });

  /// Identity of the row this stands for, so it can be matched and dropped.
  final int id;

  /// Whatever the host needs to render the row without reading the model.
  final T payload;

  /// Identity of the row that followed this one, or null when it was last.
  ///
  /// The vacated slot is named by its neighbour rather than by an index: the
  /// edit has already landed by the time the ghost is placed, and a row that
  /// moved up shifts every index between its old and new slot.
  final Object? beforeId;

  /// Once true the ghost renders invisible, so its slot collapses.
  final bool collapsing;

  ListGhost<T> get collapsed => ListGhost<T>(
    id: id,
    payload: payload,
    beforeId: beforeId,
    collapsing: true,
  );
}

/// Row transitions shared by delete and move. Both commit to the model
/// *immediately*, then animate:
///
///  * **collapse-out** — a [ListGhost] collapses at the row's old slot. Delete
///    uses only this; a move uses it for the vacated slot.
///  * **expand-in** — for a move, the row enters at its new slot. Its key is
///    bumped (see [entering]) so a *fresh* element is built that starts hidden
///    and expands next frame; a preserved element would collapse instead.
///
/// For a move the two run together: the row expands from height 0 while its
/// ghost collapses from full, so the list height stays constant and the row
/// reads as gliding from one slot to the other.
final class ListTransitions<T> {
  const ListTransitions({
    required this.ghosts,
    required this.entering,
    required this.enteringHidden,
    required this.capture,
    required this.enter,
  });

  /// Ghosts collapsing out, each inserted at its [ListGhost.anchorIndex].
  final List<ListGhost<T>> ghosts;

  /// Ids expanding in at a new slot; the host bumps their row keys.
  final Set<int> entering;

  /// Ids that render invisible for one frame so the expand starts at 0.
  final Set<int> enteringHidden;

  /// Takes ownership of [ghosts] (built by the host from the *current* model,
  /// so call this before the edit lands). Set [reenters] when the rows stay in
  /// the list at a new position.
  final void Function(Iterable<ListGhost<T>> ghosts, {required bool reenters})
  capture;

  /// Expands rows in without a ghost, for ids the list did not hold before.
  /// Their keys are left alone: a row nothing built before has no element to
  /// replace.
  final void Function(Iterable<int> ids) enter;
}

ListTransitions<T> useListTransitions<T>(BuildContext context) {
  final ghosts = useState<List<ListGhost<T>>>(const []);
  final entering = useState<Set<int>>(const {});
  final enteringHidden = useState<Set<int>>(const {});
  final timers = useRef<List<Timer>>([]);

  useEffect(() {
    return () {
      for (final timer in timers.value) {
        timer.cancel();
      }
    };
  }, const []);

  void scheduleCollapseAndRemoval(Set<int> ids) {
    // Render at full height for one frame, then flip to collapsing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ghosts.value = [
        for (final ghost in ghosts.value)
          ids.contains(ghost.id) ? ghost.collapsed : ghost,
      ];
    });
    timers.value.add(
      Timer(listTransitionLifetime, () {
        if (!context.mounted) return;
        ghosts.value = [
          for (final ghost in ghosts.value)
            if (!ids.contains(ghost.id)) ghost,
        ];
      }),
    );
  }

  void hideForOneFrame(Set<int> ids) {
    if (ids.isEmpty) return;
    enteringHidden.value = {...enteringHidden.value, ...ids};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      enteringHidden.value = {...enteringHidden.value}..removeAll(ids);
    });
  }

  void markEntering(Set<int> ids) {
    entering.value = {...entering.value, ...ids};
    hideForOneFrame(ids);
    timers.value.add(
      Timer(listTransitionLifetime, () {
        if (!context.mounted) return;
        entering.value = {...entering.value}..removeAll(ids);
      }),
    );
  }

  void capture(Iterable<ListGhost<T>> captured, {required bool reenters}) {
    final added = captured.toList(growable: false);
    if (added.isEmpty) return;
    final ids = {for (final ghost in added) ghost.id};

    ghosts.value = [...ghosts.value, ...added];
    if (reenters) markEntering(ids);
    scheduleCollapseAndRemoval(ids);
  }

  return ListTransitions<T>(
    ghosts: ghosts.value,
    entering: entering.value,
    enteringHidden: enteringHidden.value,
    capture: capture,
    enter: (ids) => hideForOneFrame(ids.toSet()),
  );
}

/// Splices ghosts back into [entries] at the slots they vacated, each one just
/// before the row it used to precede. [idOf] reads an entry's identity, matched
/// against [ListGhost.beforeId]; a ghost whose neighbour is gone lands at the
/// end. Always returns a new list, never [entries] itself.
List<E> spliceListGhosts<T, E>(
  List<E> entries,
  List<ListGhost<T>> ghosts,
  E Function(ListGhost<T> ghost) build, {
  required Object? Function(E entry) idOf,
}) {
  final out = [...entries];
  for (final ghost in ghosts) {
    final before = ghost.beforeId;
    final at = before == null ? -1 : out.indexWhere((e) => idOf(e) == before);
    out.insert(at < 0 ? out.length : at, build(ghost));
  }
  return out;
}

/// Collapses a row to zero height when it goes invisible, and opens it back up
/// when it returns.
class CollapsibleListRow extends StatelessWidget {
  const CollapsibleListRow({
    required this.visible,
    required this.child,
    super.key,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: const SizedBox(width: double.infinity),
      crossFadeState: visible
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      duration: Durations.medium1,
      sizeCurve: Easing.standard,
      firstCurve: Curves.easeOutCubic,
      secondCurve: Curves.easeInCubic,
    );
  }
}
