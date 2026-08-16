part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Transient, render-coupled choreography for the gesture list: auto-selecting
/// the first gesture when entering the screen / switching device filter, and
/// scrolling a gesture into view after add / redirect / history navigation.
final class _GestureListChoreography {
  const _GestureListChoreography({
    required this.scrollTargetKey,
    required this.scrollTarget,
    required this.scrollTargetGroup,
    required this.prepare,
    required this.scrollToGesture,
    required this.scrollToGroup,
  });

  /// Attached to the row currently being scrolled to, so
  /// [Scrollable.ensureVisible] can find it once it is laid out.
  final GlobalKey scrollTargetKey;

  /// The gesture a scroll is currently targeting, or null. The matching row
  /// wears [scrollTargetKey].
  final GestureLocation? scrollTarget;

  /// The group header a scroll is currently targeting, or null.
  final int? scrollTargetGroup;

  /// Call during build, after the view model is available: runs any pending
  /// auto-select and prepares a queued scroll target now that the flat list is
  /// known.
  final void Function(_GestureListViewModel viewModel) prepare;

  /// Immediately scroll a freshly-known gesture (e.g. just added) into view.
  final void Function(GestureLocation target) scrollToGesture;

  /// Immediately scroll a freshly-added group into view.
  final void Function(int groupKey) scrollToGroup;
}

/// Rough height of a gesture row, for scroll estimates made before the target
/// row exists.
const double _rowExtent = 62;

/// How far short of the target a restored session lands before gliding in.
const double _restoreGlide = 3 * _rowExtent;

/// Wires up the gesture list's scroll / auto-select choreography. Must be called
/// from the section's build (it registers [WidgetRef.listen] subscriptions and
/// uses hooks).
_GestureListChoreography _useGestureListChoreography(
  WidgetRef ref,
  BuildContext context,
  ScrollController scrollController,
) {
  final pendingAutoSelect = useRef(false);
  final pendingAutoSelectFilter = useRef<DeviceType?>(null);
  final scrollTarget = useState<GestureLocation?>(null);
  final scrollTargetGroup = useState<int?>(null);
  final scrollTargetFlatIndex = useRef<int?>(null);
  final scrollTargetQueued = useRef(false);
  final scrollTargetAnimated = useRef(true);
  final scrollTargetKey = useMemoized(GlobalKey.new);

  void clearScrollTarget() {
    scrollTarget.value = null;
    scrollTargetGroup.value = null;
    scrollTargetFlatIndex.value = null;
    scrollTargetQueued.value = false;
    scrollTargetAnimated.value = true;
  }

  void scrollToTarget([int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!scrollController.hasClients) {
        if (attempt < 12) {
          scrollToTarget(attempt + 1);
        } else {
          clearScrollTarget();
        }
        return;
      }
      final animated = scrollTargetAnimated.value;
      final position = scrollController.position;
      final ctx = scrollTargetKey.currentContext;
      final box = ctx?.findRenderObject();
      final viewport = box == null ? null : RenderAbstractViewport.maybeOf(box);
      if (box != null && viewport != null) {
        // getOffsetToReveal already discounts the pinned headers, so the row
        // lands flush under them; back off one row for lead-in.
        final destination =
            (viewport.getOffsetToReveal(box, 0).offset - _rowExtent).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            );
        await scrollController.animateTo(
          destination,
          duration: animated ? Durations.medium3 : Durations.long1,
          curve: animated ? Easing.standard : Easing.emphasizedDecelerate,
        );
        clearScrollTarget();
        return;
      }
      final flatIndex = scrollTargetFlatIndex.value;
      if (attempt < 12 && flatIndex != null) {
        final targetOffset = (flatIndex - 1) * _rowExtent;
        final clamped = targetOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if (!animated) {
          // Jump short of the target, then let the pass that finds it glide
          // the rest — one motion, long enough to read as settling in.
          scrollController.jumpTo(
            (targetOffset - _restoreGlide).clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            ),
          );
          scrollToTarget(attempt + 1);
          return;
        }
        await scrollController.animateTo(
          clamped,
          duration: Durations.short3,
          curve: Curves.easeOut,
        );
        scrollToTarget(attempt + 1);
      } else if (attempt < 12 &&
          position.pixels < position.maxScrollExtent - 1) {
        if (animated) {
          await scrollController.animateTo(
            position.maxScrollExtent,
            duration: Durations.short3,
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(position.maxScrollExtent);
        }
        scrollToTarget(attempt + 1);
      } else {
        clearScrollTarget();
      }
    });
  }

  void queueAutoSelectFirstGesture(DeviceType? filter) {
    pendingAutoSelect.value = true;
    pendingAutoSelectFilter.value = filter;
  }

  void clearQueuedAutoSelect() {
    pendingAutoSelect.value = false;
    pendingAutoSelectFilter.value = null;
  }

  void queueScrollToGesture(GestureLocation target, {bool animated = true}) {
    scrollTarget.value = target;
    scrollTargetGroup.value = null;
    scrollTargetFlatIndex.value = null;
    scrollTargetQueued.value = false;
    scrollTargetAnimated.value = animated;
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
        ancestors.forEach(ref.read(collapsedGroupsProvider.notifier).expand);
      });
      return;
    }
    scrollTargetFlatIndex.value = flatIndex;
    if (scrollTargetQueued.value) return;
    scrollTargetQueued.value = true;
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
    if (initial != null) queueScrollToGesture(initial, animated: false);
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
    ..listen(navProvider, (prev, next) {
      if (prev == null) return;
      final isHistoryCursorMove =
          prev.history.length == next.history.length &&
          prev.cursor != next.cursor;
      if (!isHistoryCursorMove) return;
      if (next.current case GesturesDestination(open: final open?)) {
        queueScrollToGesture(open);
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
    scrollToGesture: (target) {
      scrollTarget.value = target;
      scrollToTarget();
    },
    scrollToGroup: (groupKey) {
      clearScrollTarget();
      scrollTargetGroup.value = groupKey;
    },
  );
}
