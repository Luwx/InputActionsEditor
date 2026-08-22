part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Transient, render-coupled choreography for the gesture list.
final class _GestureListChoreography {
  const _GestureListChoreography({
    required this.scrollTargetKey,
    required this.scrollTarget,
    required this.scrollTargetGroup,
    required this.prepare,
    required this.scrollToGesture,
    required this.scrollToGroup,
  });

  final GlobalKey scrollTargetKey;

  /// Whichever row or header a scroll is targeting wears [scrollTargetKey].
  final GestureLocation? scrollTarget;
  final int? scrollTargetGroup;

  /// Call from build, once the view model is available.
  final void Function(_GestureListViewModel viewModel) prepare;

  final void Function(GestureLocation target) scrollToGesture;
  final void Function(int groupKey) scrollToGroup;
}

/// The slots the list's items take, which place a target it has not laid out
/// yet.
const double _rowExtent = 63;
const double _groupHeaderExtent = 38;

/// How far short of the target a restored session lands before gliding in.
const double _restoreGlide = 3 * _rowExtent;

/// A shorter one for arriving from another filter or view.
const double _arriveGlide = _restoreGlide / 4;

/// Time to cross [distance], so a nudge and a journey read at one speed.
Duration _travelTime(double distance, double viewport) {
  final t = viewport <= 0 ? 1.0 : (distance / (viewport * 2)).clamp(0.0, 1.0);
  return Durations.short4 + (Durations.long2 - Durations.short4) * t;
}

/// Where an item sits in the list's own coordinates. Rows under a collapsed
/// group take no space.
double _slotExtent(_FlatItem item) => switch (item) {
  _GroupHeaderItem() => _groupHeaderExtent,
  _GestureRowItem() => _rowExtent,
};

double _contentOffset(List<_FlatItem> items, int index) {
  var offset = 0.0;
  for (var i = 0; i < index; i++) {
    final item = items[i];
    if (!item.isVisible) continue;
    offset += _slotExtent(item);
  }
  return offset;
}

/// Must be called from the section's build: it registers [WidgetRef.listen]
/// subscriptions and uses hooks.
_GestureListChoreography _useGestureListChoreography(
  WidgetRef ref,
  BuildContext context,
  ScrollController scrollController,
) {
  final pendingAutoSelect = useRef(false);
  final pendingAutoSelectFilter = useRef<DeviceType?>(null);
  final scrollTarget = useState<GestureLocation?>(null);
  final scrollTargetGroup = useState<int?>(null);
  final scrollTargetOffset = useRef<double?>(null);
  final scrollTargetExtent = useRef<double>(_rowExtent);
  final scrollTargetInset = useRef<double>(0);
  final scrollTargetPark = useRef(true);
  final scrollTargetQueued = useRef(false);
  final scrollTargetExpanded = useRef(false);
  final scrollTargetGlide = useRef(false);
  final scrollTargetKey = useMemoized(GlobalKey.new);
  final arrival = useRef(0);
  final restingAt = useRef(<DeviceType?, double>{});

  /// How far the list has to scroll to bring the target row inside, or null
  /// when it is already whole. The row's own slot and those above it place it
  /// exactly, laid out or not, so nothing here waits for the list to build it.
  double? scrollDelta(
    ScrollPosition position,
    double target,
    double extent,
    double inset,
  ) {
    // [inset] is the group header pinned under the list's own.
    final atTop = target - inset;
    final atBottom =
        target + extent + kGestureListHeaderHeight - position.viewportDimension;
    // An arrival has already landed near the row, so it is on its way whether
    // the row is whole or not.
    if (!scrollTargetGlide.value &&
        position.pixels <= atTop &&
        position.pixels >= atBottom) {
      return null;
    }
    if (scrollTargetPark.value) return atTop - position.pixels;
    return position.pixels > atTop
        ? atTop - position.pixels
        : atBottom - position.pixels;
  }

  /// How far the target row is hidden behind the pinned header or past the
  /// bottom edge, as painted, and zero when it is whole. A row expanding in or
  /// a group opening leaves the slots ahead of what is really on screen.
  double hiddenExtent(ScrollPosition position) {
    final row = scrollTargetKey.currentContext?.findRenderObject();
    final viewport = row == null ? null : RenderAbstractViewport.maybeOf(row);
    if (row is! RenderBox ||
        !row.hasSize ||
        !row.attached ||
        row.size.height == 0 ||
        viewport == null) {
      return 0;
    }
    final top = row.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final bottom = top + row.size.height;
    final under = kGestureListHeaderHeight + scrollTargetInset.value;
    if (top < under) return top - under;
    if (bottom > position.viewportDimension) {
      return bottom - position.viewportDimension;
    }
    return 0;
  }

  void clearScrollTarget() {
    scrollTarget.value = null;
    scrollTargetGroup.value = null;
    scrollTargetOffset.value = null;
    scrollTargetQueued.value = false;
    scrollTargetExpanded.value = false;
    scrollTargetPark.value = true;
    scrollTargetGlide.value = false;
  }

  void scrollToTarget({int attempt = 0}) {
    Future<void> pass() async {
      if (!scrollController.hasClients) {
        if (attempt < 12) {
          scrollToTarget(attempt: attempt + 1);
        } else {
          clearScrollTarget();
        }
        return;
      }
      final glide = scrollTargetGlide.value;
      final position = scrollController.position;
      final target = scrollTargetOffset.value;
      if (target != null) {
        final delta = scrollDelta(
          position,
          target,
          scrollTargetExtent.value,
          scrollTargetInset.value,
        );
        if (delta == null) {
          clearScrollTarget();
          return;
        }
        // A row added at the end is aimed past an end the list only grows as
        // the row opens, so the scroll would stop into it and settle again.
        if (attempt == 0 &&
            !scrollTargetPark.value &&
            position.pixels + delta > position.maxScrollExtent + 1) {
          Future<void>.delayed(listTransitionLifetime, () {
            if (!context.mounted) return;
            WidgetsBinding.instance.ensureVisualUpdate();
            scrollToTarget(attempt: attempt + 1);
          });
          return;
        }
        final to = (position.pixels + delta + 1).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        // A pass that has already landed near the row is left where it is.
        if (glide && (to - position.pixels).abs() > _restoreGlide) {
          scrollController.jumpTo(
            (to - _restoreGlide).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            ),
          );
        }
        // The curve gets the distance there is to cover, not the one that was
        // asked for, so a landing against an end still eases out.
        await scrollController.animateTo(
          to,
          duration: glide
              ? Durations.long1
              : _travelTime(
                  (to - position.pixels).abs(),
                  position.viewportDimension,
                ),
          curve: Easing.emphasizedDecelerate,
        );
        for (var settle = 0; settle < 3; settle++) {
          // An animation ends inside the pipeline: reading a render box or
          // starting a scroll from there lands mid-frame.
          await WidgetsBinding.instance.endOfFrame;
          if (!scrollController.hasClients) break;
          final hidden = hiddenExtent(scrollController.position);
          if (hidden.abs() <= 1) break;
          await scrollController.animateTo(
            position.pixels + hidden,
            duration: Durations.short3,
            curve: Easing.emphasizedDecelerate,
          );
        }
        clearScrollTarget();
      } else if (attempt < 12 &&
          position.pixels < position.maxScrollExtent - 1) {
        if (!glide) {
          await scrollController.animateTo(
            position.maxScrollExtent,
            duration: Durations.short3,
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(position.maxScrollExtent);
        }
        scrollToTarget(attempt: attempt + 1);
      } else {
        clearScrollTarget();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => pass());
  }

  /// Brings the list to where [target] belongs under [filter], before the
  /// frame that opens it is drawn: the slots place the row without the list
  /// having laid it out.
  ///
  /// A row that was on screen under [from] keeps the place it had there, so
  /// the list changes around it rather than under it; failing that the list
  /// resumes where [filter] was left, and failing that the row parks at the
  /// top. False when it cannot place the row at all.
  bool arriveAt(GestureLocation target, DeviceType? from, DeviceType? filter) {
    if (!scrollController.hasClients) return false;
    final config = ref.read(draftConfigProvider);
    final collapsed = ref.read(collapsedGroupsProvider);
    final items = _buildFlatList(config, filter, collapsed);
    final index = items.indexWhere(
      (item) => item is _GestureRowItem && item.location == target,
    );
    if (index < 0) return false;

    final position = scrollController.position;
    restingAt.value[from] = position.pixels;
    final item = items[index] as _GestureRowItem;
    final offset = _contentOffset(items, index);
    final extent = _slotExtent(item);
    final inset = filter != null && item.groupKey != null
        ? _groupHeaderExtent
        : 0.0;

    // A row is at the header line when the list stands at its own offset,
    // which is what puts both lists on one scale.
    final was = _buildFlatList(config, from, collapsed);
    final wasIndex = was.indexWhere(
      (item) => item is _GestureRowItem && item.location == target,
    );
    final sat = wasIndex < 0
        ? null
        : kGestureListHeaderHeight +
              _contentOffset(was, wasIndex) -
              position.pixels;
    final held =
        sat != null &&
            sat >= kGestureListHeaderHeight + inset &&
            sat + extent <= position.viewportDimension
        ? sat
        : null;
    final resting = restingAt.value[filter];
    final restingTop = resting == null
        ? null
        : kGestureListHeaderHeight + offset - resting;
    final resumed =
        restingTop != null &&
            restingTop >= kGestureListHeaderHeight + inset &&
            restingTop + extent <= position.viewportDimension
        ? restingTop
        : null;
    final lands = held ?? resumed ?? kGestureListHeaderHeight + inset;
    final to = offset + kGestureListHeaderHeight - lands;

    // What the row moves caps the glide, however far the list underneath had
    // to travel.
    final moved = sat == null ? _arriveGlide : (lands - sat).abs();
    final glide = moved < _arriveGlide ? moved : _arriveGlide;
    // The lists differ, so what carries over is how far down each the row
    // sits: landing deeper glides forward, shallower glides back.
    final stoodDeep = position.maxScrollExtent <= 0
        ? 0.0
        : position.pixels / position.maxScrollExtent;
    final ends =
        _contentOffset(items, items.length) +
        kGestureListHeaderHeight -
        position.viewportDimension;
    final landsDeep = ends <= 0 ? 0.0 : to / ends;
    final approach = landsDeep >= stoodDeep ? to - glide : to + glide;
    final start = approach >= position.minScrollExtent ? approach : to + glide;
    // A glide still running would drive on to its own landing and undo the
    // correction below.
    scrollController.jumpTo(position.pixels);
    // The list this lands in has not been measured yet, so jumpTo would hold
    // the offset inside the outgoing list's extent and paint one frame there.
    // Correcting the pixels leaves the coming layout to bring it into range.
    position.correctPixels(
      start.clamp(position.minScrollExtent, double.infinity),
    );
    // A filter changed under a glide leaves that one settling towards a list
    // no longer on screen.
    final ticket = ++arrival.value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ticket != arrival.value || !scrollController.hasClients) return;
      final settled = scrollController.position;
      unawaited(
        settled.animateTo(
          to.clamp(settled.minScrollExtent, settled.maxScrollExtent),
          duration: Durations.long1,
          curve: Easing.emphasizedDecelerate,
        ),
      );
    });
    return true;
  }

  void queueAutoSelectFirstGesture(DeviceType? filter) {
    pendingAutoSelect.value = true;
    pendingAutoSelectFilter.value = filter;
  }

  void clearQueuedAutoSelect() {
    pendingAutoSelect.value = false;
    pendingAutoSelectFilter.value = null;
  }

  void queueScrollToGesture(
    GestureLocation target, {
    bool glide = false,
    bool park = true,
  }) {
    scrollTarget.value = target;
    scrollTargetGroup.value = null;
    scrollTargetOffset.value = null;
    scrollTargetQueued.value = false;
    scrollTargetGlide.value = glide;
    scrollTargetPark.value = park;
  }

  void prepareScrollTarget(_GestureListViewModel viewModel) {
    final gesture = scrollTarget.value;
    final group = scrollTargetGroup.value;
    if (gesture == null && group == null) return;
    final flatIndex = viewModel.flatItems.indexWhere(
      (item) => switch (item) {
        _GestureRowItem(:final location) => location == gesture,
        _GroupHeaderItem(:final groupKey) => groupKey == group,
      },
    );
    if (flatIndex < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => clearScrollTarget());
      return;
    }
    final item = viewModel.flatItems[flatIndex];
    if (!item.isVisible) {
      // Expand the whole ancestor chain; a collapsed ancestor would keep the
      // target hidden even with its own group open.
      final ancestors = _ancestorGroupKeys(viewModel.flatItems, flatIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ancestors.isEmpty) {
          clearScrollTarget();
          return;
        }
        scrollTargetExpanded.value = true;
        ancestors.forEach(ref.read(collapsedGroupsProvider.notifier).expand);
      });
      return;
    }
    scrollTargetOffset.value = _contentOffset(viewModel.flatItems, flatIndex);
    scrollTargetExtent.value = _slotExtent(item);
    // The all-devices view draws no group chrome, so nothing is pinned over a
    // row there.
    scrollTargetInset.value =
        viewModel.deviceFilter != null &&
            item is _GestureRowItem &&
            item.groupKey != null
        ? _groupHeaderExtent
        : 0;
    if (scrollTargetQueued.value) return;
    scrollTargetQueued.value = true;
    if (scrollTargetExpanded.value) {
      // A group's rows take their extent only as it opens, so the scroll waits
      // rather than aiming at slots the list has not made room for.
      scrollTargetExpanded.value = false;
      Future<void>.delayed(listTransitionLifetime, () {
        if (!context.mounted) return;
        WidgetsBinding.instance.ensureVisualUpdate();
        scrollToTarget();
      });
      return;
    }
    scrollToTarget();
  }

  void tryAutoSelectFirstGesture() {
    if (!pendingAutoSelect.value) return;
    final config = ref.read(draftConfigProvider);
    final filter = pendingAutoSelectFilter.value;
    final items = _buildFlatList(
      config,
      filter,
      ref.read(collapsedGroupsProvider),
    );
    final gestureItems = items.whereType<_GestureRowItem>();
    final first =
        gestureItems.where((item) => item.isVisible).firstOrNull ??
        gestureItems.firstOrNull;
    if (first == null) {
      clearQueuedAutoSelect();
      return;
    }
    clearQueuedAutoSelect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.selectGesture(first.location);
    });
  }

  useEffect(() {
    final initial = ref.read(selectedGestureProvider);
    if (initial != null) queueScrollToGesture(initial, glide: true);
    return null;
  }, const []);

  ref
    ..listen(currentViewProvider, (prevView, nextView) {
      if (nextView != AppView.gestures) {
        clearQueuedAutoSelect();
      } else if (prevView != AppView.gestures) {
        if (ref.read(selectedGestureProvider) == null) {
          queueAutoSelectFirstGesture(ref.read(deviceFilterProvider));
        }
      }
    })
    ..listen(deviceFilterProvider, (prevFilter, nextFilter) {
      if (ref.read(currentViewProvider) != AppView.gestures) return;
      if (prevFilter == nextFilter) return;
      if (ref.read(selectedGestureProvider) == null) {
        queueAutoSelectFirstGesture(nextFilter);
      } else {
        clearQueuedAutoSelect();
      }
    })
    ..listen(selectedGestureProvider, (_, next) {
      if (next != null) clearQueuedAutoSelect();
    })
    ..listen(gestureRedirectTargetProvider, (_, next) {
      if (next == null) return;
      queueScrollToGesture(next);
      ref.read(gestureRedirectTargetProvider.notifier).clear();
    })
    ..listen(editRevealProvider, (_, next) {
      if (next == null) return;
      final filter = ref.read(deviceFilterProvider);
      final group = next.group;
      if (group != null) {
        if (filter != null && filter != group.device) {
          ref
              .read(navProvider.notifier)
              .go(GesturesDestination(filter: group.device), replace: true);
        }
        ref.read(selectedGroupProvider.notifier).open(group);
        // The row and the header share one scroll key.
        scrollTarget.value = null;
        scrollTargetGroup.value = group.editId;
        return;
      }
      final target = next.gesture!;
      ref
          .read(navProvider.notifier)
          .go(
            GesturesDestination(
              open: target,
              filter: filter == null || filter == target.device
                  ? filter
                  : target.device,
            ),
            replace: true,
          );
      queueScrollToGesture(target);
    })
    ..listen(navProvider, (prev, next) {
      if (prev == null) return;
      if (next.current case GesturesDestination(open: final open?)) {
        // A replaced entry is the same stop patched in place, so whoever
        // replaced it owns whatever scrolling it wants.
        if (prev.history.length == next.history.length &&
            prev.cursor == next.cursor) {
          return;
        }
        final isHistoryCursorMove =
            prev.history.length == next.history.length &&
            prev.cursor != next.cursor;
        // Picking a gesture inside the list is not an arrival: it is already
        // in view.
        final arrived = switch (prev.current) {
          GesturesDestination(:final filter) =>
            filter != (next.current as GesturesDestination).filter,
          _ => true,
        };
        if (isHistoryCursorMove || arrived) {
          final filter = (next.current as GesturesDestination).filter;
          final from = switch (prev.current) {
            GesturesDestination(filter: final was) => was,
            // The list was showing this filter all along under another view.
            _ => filter,
          };
          if (!arriveAt(open, from, filter)) {
            queueScrollToGesture(open, glide: true);
          }
        }
      }
    });

  return _GestureListChoreography(
    scrollTargetKey: scrollTargetKey,
    scrollTarget: scrollTarget.value,
    scrollTargetGroup: scrollTargetGroup.value,
    prepare: (viewModel) {
      tryAutoSelectFirstGesture();
      prepareScrollTarget(viewModel);
    },
    scrollToGesture: (target) => queueScrollToGesture(target, park: false),
    scrollToGroup: (groupKey) {
      clearScrollTarget();
      scrollTargetGroup.value = groupKey;
      scrollTargetPark.value = false;
    },
  );
}
