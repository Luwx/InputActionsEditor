part of 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

/// Transient, render-coupled choreography for the gesture list: auto-selecting
/// the first gesture when entering the screen / switching device filter, and
/// scrolling a gesture into view after add / redirect / history navigation.
final class _GestureListChoreography {
  const _GestureListChoreography({
    required this.scrollTargetKey,
    required this.scrollTarget,
    required this.prepare,
    required this.scrollToGesture,
  });

  /// Attached to the row currently being scrolled to, so
  /// [Scrollable.ensureVisible] can find it once it is laid out.
  final GlobalKey scrollTargetKey;

  /// The gesture a scroll is currently targeting, or null. The matching row
  /// wears [scrollTargetKey].
  final GestureLocation? scrollTarget;

  /// Call during build, after the view model is available: runs any pending
  /// auto-select and prepares a queued scroll target now that the flat list is
  /// known.
  final void Function(_GestureListViewModel viewModel) prepare;

  /// Immediately scroll a freshly-known gesture (e.g. just added) into view.
  final void Function(GestureLocation target) scrollToGesture;
}

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
  final scrollTargetFlatIndex = useRef<int?>(null);
  final scrollTargetQueued = useRef(false);
  final scrollTargetAnimated = useRef(true);
  final scrollTargetKey = useMemoized(GlobalKey.new);

  void clearScrollTarget() {
    scrollTarget.value = null;
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
      final ctx = scrollTargetKey.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          alignment: 1,
          duration: Durations.medium2,
          curve: Curves.easeOutCubic,
        );
        clearScrollTarget();
        return;
      }
      final position = scrollController.position;
      final flatIndex = scrollTargetFlatIndex.value;
      if (attempt < 12 && flatIndex != null) {
        final viewport = position.viewportDimension;
        final targetOffset =
            GestureListSection._headerHeight + flatIndex * 62.0 - viewport / 3;
        final clamped = targetOffset.clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        );
        if (!animated) {
          // Jump to a few items above the target, then glide the rest.
          final jumpOffset = (targetOffset - 1 * 62.0).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          scrollController.jumpTo(jumpOffset);
          await scrollController.animateTo(
            clamped,
            duration: Durations.extralong1,
            curve: Easing.emphasizedDecelerate,
          );
          clearScrollTarget();
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
    scrollTargetFlatIndex.value = null;
    scrollTargetQueued.value = false;
    scrollTargetAnimated.value = animated;
  }

  void prepareScrollTarget(_GestureListViewModel viewModel) {
    final target = scrollTarget.value;
    if (target == null) return;
    final flatIndex = viewModel.flatItems.indexWhere(
      (item) => item is _GestureRowItem && item.location == target,
    );
    if (flatIndex < 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) => clearScrollTarget());
      return;
    }
    final item = viewModel.flatItems[flatIndex] as _GestureRowItem;
    final editId = item.editId;
    if (!item.isVisible && editId != null) {
      // Expand the whole ancestor chain; a collapsed ancestor would keep the
      // row hidden even with its own group open.
      final ancestors = _ancestorGroupKeys(
        ref.read(draftConfigProvider).nodesForDevice(item.device),
        editId,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
    prepare: (viewModel) {
      tryAutoSelectFirstGesture();
      prepareScrollTarget(viewModel);
    },
    scrollToGesture: (target) {
      scrollTarget.value = target;
      scrollToTarget();
    },
  );
}
