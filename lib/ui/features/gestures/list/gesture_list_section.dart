import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart'
    hide gestureCommon, gestureDisplayName, gestureTypeLabel;
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/added_gesture_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/collapsed_groups_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_list_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';

part 'gesture_list_section/dialogs/rename_dialog.dart';
part 'gesture_list_section/flat_list.dart';
part 'gesture_list_section/models.dart';
part 'gesture_list_section/reordering.dart';
part 'gesture_list_section/view_model.dart';
part 'gesture_list_section/widgets/gesture_item_widgets.dart';
part 'gesture_list_section/widgets/group_widgets.dart';
part 'gesture_list_section/widgets/header.dart';

// ---------------------------------------------------------------------------
// Section widget
// ---------------------------------------------------------------------------

class GestureListSection extends HookConsumerWidget {
  const GestureListSection({super.key});

  static const _headerHeight = 65.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final pendingAutoSelect = useRef(false);
    final pendingAutoSelectFilter = useRef<DeviceType?>(null);
    final scrollTarget = useState<GestureLocation?>(null);
    final scrollTargetFlatIndex = useRef<int?>(null);
    final scrollTargetQueued = useRef(false);
    final scrollTargetKey = useMemoized(GlobalKey.new);

    void clearScrollTarget() {
      scrollTarget.value = null;
      scrollTargetFlatIndex.value = null;
      scrollTargetQueued.value = false;
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
              GestureListSection._headerHeight +
              flatIndex * 62.0 -
              viewport / 3;
          await scrollController.animateTo(
            targetOffset.clamp(
              position.minScrollExtent,
              position.maxScrollExtent,
            ),
            duration: Durations.short3,
            curve: Curves.easeOut,
          );
          scrollToTarget(attempt + 1);
        } else if (attempt < 12 &&
            position.pixels < position.maxScrollExtent - 1) {
          await scrollController.animateTo(
            position.maxScrollExtent,
            duration: Durations.short3,
            curve: Curves.easeOut,
          );
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

    void queueScrollToGesture(GestureLocation target) {
      scrollTarget.value = target;
      scrollTargetFlatIndex.value = null;
      scrollTargetQueued.value = false;
    }

    void prepareScrollTarget(_GestureListViewModel viewModel) {
      final target = scrollTarget.value;
      if (target == null) return;
      final flatIndex = viewModel.flatItems.indexWhere(
        (item) =>
            item is _GestureRowItem &&
            item.device == target.device &&
            item.configIndex == target.index,
      );
      if (flatIndex < 0) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => clearScrollTarget(),
        );
        return;
      }
      final item = viewModel.flatItems[flatIndex] as _GestureRowItem;
      final groupId = item.groupId;
      if (!item.isVisible && groupId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(collapsedGroupsProvider.notifier).expand(groupId);
        });
        return;
      }
      scrollTargetFlatIndex.value = flatIndex;
      if (scrollTargetQueued.value) return;
      scrollTargetQueued.value = true;
      scrollToTarget();
    }

    void tryAutoSelectFirstGesture({
      required Config config,
      required Set<String> collapsedGroups,
    }) {
      if (!pendingAutoSelect.value) return;
      final filter = pendingAutoSelectFilter.value;
      final items = _buildFlatList(config, filter, collapsedGroups);
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
        context.selectGesture(first.device, first.configIndex);
      });
    }

    void handleGestureAdded(DeviceType device, Object gesture) {
      final config = ref.read(gestureListProvider).config;
      if (config == null) return;
      final existingGestures = config.gesturesForDevice(device);
      final newIndex = existingGestures.length;
      final l10n = context.l10n;
      final typeLabel = gestureTypeLabel(gesture, l10n);
      final sameTypeCount = existingGestures
          .where((g) => gestureTypeLabel(g, l10n) == typeLabel)
          .length;
      final defaultName = '$typeLabel #${sameTypeCount + 1}';
      final named = gestureWithCommon(
        gesture,
        gestureCommon(gesture).copyWith(name: defaultName),
      );
      ref.read(gestureListProvider.notifier).addGesture(device, named);
      ref.read(addedGestureProvider.notifier).markAdded(newIndex);
      context.selectGesture(device, newIndex);
      scrollTarget.value = GestureLocation(device: device, index: newIndex);
      scrollToTarget();
    }

    Future<void> addGroupDialog(DeviceType device) {
      return _showRenameDialog(
        context,
        title: 'New Group',
        initial: '',
        onConfirm: (name) {
          if (name.trim().isEmpty) return;
          final id = _generateGroupId();
          ref
              .read(gestureListProvider.notifier)
              .addGroup(
                GestureGroup(id: id, name: name.trim(), device: device),
              );
        },
      );
    }

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

    final config = ref.watch(gestureListProvider).config;
    final selection = ref.watch(selectedGestureProvider);
    final multiSelect = ref.watch(multiSelectControllerProvider);
    final multiSelectNotifier = ref.read(
      multiSelectControllerProvider.notifier,
    );
    final listNotifier = ref.read(gestureListProvider.notifier);
    final deviceFilter = ref.watch(deviceFilterProvider);
    final addedMarker = ref.watch(addedGestureProvider);
    final conflicts = ref.watch(conflictReportProvider);
    final collapsedGroups = ref.watch(collapsedGroupsProvider);
    final collapsedNotifier = ref.read(collapsedGroupsProvider.notifier);
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isMultiSelectMode = multiSelect != null;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            isMultiSelectMode) {
          multiSelectNotifier.exit();
        }
      },
      child: config == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Builder(
              builder: (context) {
                tryAutoSelectFirstGesture(
                  config: config,
                  collapsedGroups: collapsedGroups,
                );

                final viewModel = _GestureListViewModel.fromConfig(
                  config: config,
                  deviceFilter: deviceFilter,
                  collapsedGroups: collapsedGroups,
                  isMultiSelectMode: isMultiSelectMode,
                  selectedCount: multiSelect?.length ?? 0,
                  l10n: context.l10n,
                );
                prepareScrollTarget(viewModel);
                final reorderEntries =
                    <ReorderableGroupableListEntry<GestureLocation, String>>[];
                final gestureItemsByKey = <GestureLocation, _GestureRowItem>{};
                final groupItemsById = <String, _GroupHeaderItem>{};
                for (final flatItem in viewModel.flatItems) {
                  switch (flatItem) {
                    case _GroupHeaderItem():
                      groupItemsById[flatItem.group.id] = flatItem;
                      reorderEntries.add(
                        ReorderableGroupableGroup<GestureLocation, String>(
                          key: ValueKey('group:${flatItem.group.id}'),
                          id: flatItem.group.id,
                        ),
                      );
                    case _GestureRowItem():
                      final key = GestureLocation(
                        device: flatItem.device,
                        index: flatItem.configIndex,
                      );
                      gestureItemsByKey[key] = flatItem;
                      reorderEntries.add(
                        ReorderableGroupableItem<GestureLocation, String>(
                          key: ValueKey(
                            '${flatItem.device.name}:${flatItem.configIndex}',
                          ),
                          id: key,
                          groupId: flatItem.groupId,
                          isFirstInGroup: flatItem.isFirstInGroup,
                          isLastInGroup: flatItem.isLastInGroup,
                          isVisible: flatItem.isVisible,
                        ),
                      );
                  }
                }

                return ScrollbarMediaPadding(
                  topInset: GestureListSection._headerHeight,
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: PinnedHeaderDelegate(
                          minExtentValue: GestureListSection._headerHeight,
                          maxExtentValue: GestureListSection._headerHeight,
                          child: _GestureListHeader(
                            title: viewModel.title,
                            countLabel: viewModel.countLabel,
                            deviceFilter: deviceFilter,
                            isMultiSelectMode: isMultiSelectMode,
                            onGestureAdded: handleGestureAdded,
                            onAddGroup: deviceFilter != null
                                ? () => addGroupDialog(deviceFilter)
                                : null,
                            onExitMultiSelect: multiSelectNotifier.exit,
                          ),
                        ),
                      ),
                      if (viewModel.flatItems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No gestures yet.',
                              style: typography.sm.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ),
                        )
                      else
                        ReorderableGroupableList<GestureLocation, String>(
                          entries: reorderEntries,
                          scrollController: scrollController,
                          borderColor: colors.border,
                          reorderEnabled: viewModel.reorderEnabled,
                          selectedItemIds:
                              multiSelect
                                  ?.where(
                                    (key) =>
                                        key.device == viewModel.deviceFilter,
                                  )
                                  .toSet() ??
                              const {},
                          showTrailingDropZone: viewModel.deviceFilter != null,
                          itemDragLabelBuilder: (_, count) => count == 1
                              ? 'Move gesture'
                              : 'Move $count gestures',
                          groupDragLabelBuilder: (group) =>
                              groupItemsById[group.id]?.group.name ??
                              'Move group',
                          onItemsReordered: (result) =>
                              _GestureListController(
                                ref,
                                context,
                              ).applyItemsReorder(
                                viewModel.deviceFilter!,
                                result,
                              ),
                          onGroupReordered: (from, to) =>
                              _GestureListController(
                                ref,
                                context,
                              ).applyGroupReorder(
                                viewModel.deviceFilter!,
                                from,
                                to,
                              ),
                          groupBuilder: (context, groupEntry, reorderHandle) {
                            final flatItem = groupItemsById[groupEntry.id]!;
                            return _GroupHeaderRow(
                              key: groupEntry.key,
                              index: viewModel.flatItems.indexOf(flatItem),
                              group: flatItem.group,
                              device: flatItem.device,
                              isCollapsed: flatItem.isCollapsed,
                              gestureCount: flatItem.gestureCount,
                              showTopBorder:
                                  viewModel.flatItems.indexOf(flatItem) > 0,
                              borderColor: colors.border,
                              reorderHandle: reorderHandle,
                              onToggleCollapse: () =>
                                  collapsedNotifier.toggle(flatItem.group.id),
                              onRename: () => _showRenameDialog(
                                context,
                                title: 'Rename Group',
                                initial: flatItem.group.name,
                                onConfirm: (name) {
                                  if (name.trim().isEmpty) return;
                                  listNotifier.updateGroup(
                                    flatItem.group.id,
                                    (g) => g.copyWith(name: name.trim()),
                                  );
                                },
                              ),
                              onToggleEnabled: () => listNotifier.updateGroup(
                                flatItem.group.id,
                                (g) => g.copyWith(enabled: !g.enabled),
                              ),
                              onBreakdown: () =>
                                  listNotifier.removeGroupAndUngroup(
                                    flatItem.group.id,
                                  ),
                              onDelete: () =>
                                  listNotifier.deleteGroupWithGestures(
                                    flatItem.group.id,
                                    flatItem.device,
                                  ),
                            );
                          },
                          itemOverlayBuilder: (context, itemEntry) {
                            final item = gestureItemsByKey[itemEntry.id]!;
                            final gestureConflicts = isMultiSelectMode
                                ? const <GestureConflict>[]
                                : conflicts.forGesture(
                                    item.device,
                                    item.configIndex,
                                  );
                            return gestureConflicts.isNotEmpty
                                ? _ConflictTileIcon(
                                    conflicts: gestureConflicts,
                                    focus: (
                                      device: item.device,
                                      index: item.configIndex,
                                    ),
                                  )
                                : null;
                          },
                          itemBuilder: (context, itemEntry, _, isDragging) {
                            final item = gestureItemsByKey[itemEntry.id]!;
                            final selectionKey = itemEntry.id;
                            final isSelected =
                                !isMultiSelectMode &&
                                selection?.device == item.device &&
                                selection?.index == item.configIndex;
                            final isMultiSelected =
                                multiSelect?.contains(selectionKey) ?? false;
                            final markerId =
                                (addedMarker?.index == item.configIndex &&
                                    deviceFilter != null &&
                                    addedMarker?.index == item.configIndex)
                                ? addedMarker?.id
                                : null;
                            final group = item.groupId != null
                                ? config.gestureGroups
                                      .where((g) => g.id == item.groupId)
                                      .firstOrNull
                                : null;
                            final groupDisabled = group?.enabled == false;
                            final row = AnimatedOpacity(
                              duration: Durations.short2,
                              opacity: isDragging ? 0.45 : 1,
                              child: _ContextMenuTile(
                                item: item,
                                newlyAddedMarkerId: markerId,
                                isSelected: isSelected,
                                isMultiSelectMode: isMultiSelectMode,
                                isMultiSelected: isMultiSelected,
                                groupDisabled: groupDisabled,
                                onTap: () {
                                  if (isMultiSelectMode) {
                                    multiSelectNotifier.toggle(selectionKey);
                                  } else {
                                    context.selectGesture(
                                      item.device,
                                      item.configIndex,
                                    );
                                  }
                                },
                                onLongPress: () {
                                  if (isMultiSelectMode) {
                                    multiSelectNotifier.toggle(selectionKey);
                                  } else {
                                    context.clearGestureSelection();
                                    multiSelectNotifier.enter(selectionKey);
                                  }
                                },
                                onDuplicate: () =>
                                    listNotifier.duplicateGesture(
                                      item.device,
                                      item.configIndex,
                                    ),
                                onDelete: () {
                                  listNotifier.removeGesture(
                                    item.device,
                                    item.configIndex,
                                  );
                                  ref
                                      .read(navProvider.notifier)
                                      .onGestureDeleted(
                                        item.device,
                                        item.configIndex,
                                      );
                                },
                              ),
                            );

                            final isScrollTarget =
                                scrollTarget.value?.device == item.device &&
                                scrollTarget.value?.index == item.configIndex;
                            return isScrollTarget
                                ? KeyedSubtree(
                                    key: scrollTargetKey,
                                    child: row,
                                  )
                                : row;
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conflict icon overlay shown to the left of the drag handle
// ---------------------------------------------------------------------------

class _ConflictTileIcon extends StatelessWidget {
  const _ConflictTileIcon({
    required this.conflicts,
    required this.focus,
  });

  final List<GestureConflict> conflicts;
  final GestureRef focus;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final names = conflicts.map((c) => c.otherLabel(focus)).join(', ');
    final tooltipText = conflicts.length == 1
        ? 'Conflicts with: $names'
        : 'Conflicts with: $names';

    return AppTooltip(
      tipBuilder: (context, _) => Text(tooltipText, style: typography.xs),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          FLucideIcons.triangleAlert,
          size: 13,
          color: kGestureWarningColor,
        ),
      ),
    );
  }
}
