import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart'
    hide gestureCommon, gestureTypeLabel;
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/state/added_gesture_provider.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/collapsed_groups_provider.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/conflict_provider.dart';
import 'package:input_actions_editor/state/multi_select_controller.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/widgets/reorderable_groupable_list.dart';

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

class GestureListSection extends ConsumerStatefulWidget {
  const GestureListSection({super.key});

  static const _headerHeight = 65.0;

  @override
  ConsumerState<GestureListSection> createState() => _GestureListSectionState();
}

class _GestureListSectionState extends ConsumerState<GestureListSection> {
  final ScrollController _scrollController = ScrollController();
  bool _pendingAutoSelect = false;
  DeviceType? _pendingAutoSelectFilter;

  /// A just-added gesture that should be scrolled into view, and the key
  /// attached to its row so we can locate it after the next layout pass.
  ({DeviceType device, int index})? _scrollTarget;
  final GlobalKey _scrollTargetKey = GlobalKey();

  _GestureListController get _listController =>
      _GestureListController(ref, context);

  void _queueAutoSelectFirstGesture(DeviceType? filter) {
    _pendingAutoSelect = true;
    _pendingAutoSelectFilter = filter;
  }

  void _clearQueuedAutoSelect() {
    _pendingAutoSelect = false;
    _pendingAutoSelectFilter = null;
  }

  // TODO(me): refactor out of here
  void _tryAutoSelectFirstGesture({
    required Config config,
    required Set<String> collapsedGroups,
  }) {
    if (!_pendingAutoSelect) return;

    final filter = _pendingAutoSelectFilter;
    final items = _buildFlatList(config, filter, collapsedGroups);
    final gestureItems = items.whereType<_GestureRowItem>();
    final first =
        gestureItems.where((item) => item.isVisible).firstOrNull ??
        gestureItems.firstOrNull;

    if (first == null) {
      _clearQueuedAutoSelect();
      return;
    }

    _clearQueuedAutoSelect();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.selectGesture(first.device, first.configIndex);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleGestureAdded(DeviceType device, Object gesture) {
    final config = ref.read(configControllerProvider).value;
    if (config == null) return;

    final existingGestures = config.gesturesForDevice(device);
    final newIndex = existingGestures.length;

    // Count gestures of the same type to build a default name.
    final typeLabel = gestureTypeLabel(gesture);
    final sameTypeCount = existingGestures
        .where((g) => gestureTypeLabel(g as Object) == typeLabel)
        .length;
    final defaultName = '$typeLabel #${sameTypeCount + 1}';
    final named = gestureWithCommon(
      gesture,
      gestureCommon(gesture).copyWith(name: defaultName),
    );

    ref
        .read(configControllerProvider.notifier)
        .addGestureForDevice(device, named);
    ref.read(addedGestureProvider.notifier).markAdded(newIndex);
    context.selectGesture(device, newIndex);

    setState(() => _scrollTarget = (device: device, index: newIndex));
    _scrollToTarget();
  }

  void _scrollToTarget([int attempt = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!_scrollController.hasClients) {
        if (attempt < 12) {
          _scrollToTarget(attempt + 1);
        } else {
          setState(() => _scrollTarget = null);
        }
        return;
      }

      final ctx = _scrollTargetKey.currentContext;
      if (ctx != null) {
        // The row is built — align it precisely and finish.
        await Scrollable.ensureVisible(
          ctx,
          alignment: 1,
          duration: Durations.medium2,
          curve: Curves.easeOutCubic,
        );
        if (mounted) setState(() => _scrollTarget = null);
        return;
      }

      // The row is below the viewport and the lazy SliverList hasn't built it
      // yet, so its key has no context. Drive the scroll toward the bottom so
      // the new (last) row gets built, then retry to align it precisely.
      final position = _scrollController.position;
      if (attempt < 12 && position.pixels < position.maxScrollExtent - 1) {
        await _scrollController.animateTo(
          position.maxScrollExtent,
          duration: Durations.short3,
          curve: Curves.easeOut,
        );
        _scrollToTarget(attempt + 1);
      } else if (mounted) {
        setState(() => _scrollTarget = null);
      }
    });
  }

  Future<void> _addGroup(DeviceType device) {
    return _showRenameDialog(
      context,
      title: 'New Group',
      initial: '',
      onConfirm: (name) {
        if (name.trim().isEmpty) return;
        final id = _generateGroupId();
        ref
            .read(configControllerProvider.notifier)
            .addGestureGroup(
              GestureGroup(id: id, name: name.trim(), device: device),
            );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(currentViewProvider, (prevView, nextView) {
        if (nextView != AppView.gestures) {
          _clearQueuedAutoSelect();
        } else if (prevView != AppView.gestures) {
          // Opened gestures view — auto-select if nothing is open.
          if (ref.read(selectedGestureProvider) == null) {
            _queueAutoSelectFirstGesture(ref.read(deviceFilterProvider));
          }
        }
      })
      ..listen(deviceFilterProvider, (prevFilter, nextFilter) {
        if (ref.read(currentViewProvider) != AppView.gestures) return;
        if (prevFilter == nextFilter) return;
        if (ref.read(selectedGestureProvider) == null) {
          _queueAutoSelectFirstGesture(nextFilter);
        } else {
          _clearQueuedAutoSelect();
        }
      })
      ..listen(selectedGestureProvider, (_, next) {
        if (next != null) _clearQueuedAutoSelect();
      });

    final configAsync = ref.watch(configControllerProvider);
    final selection = ref.watch(selectedGestureProvider);
    final multiSelect = ref.watch(multiSelectControllerProvider);
    final multiSelectNotifier = ref.read(
      multiSelectControllerProvider.notifier,
    );
    final configNotifier = ref.read(configControllerProvider.notifier);
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
      child: configAsync.when(
        data: (config) {
          _tryAutoSelectFirstGesture(
            config: config,
            collapsedGroups: collapsedGroups,
          );

          final viewModel = _GestureListViewModel.fromConfig(
            config: config,
            deviceFilter: deviceFilter,
            collapsedGroups: collapsedGroups,
            isMultiSelectMode: isMultiSelectMode,
            selectedCount: multiSelect?.length ?? 0,
          );
          final reorderEntries =
              <ReorderableGroupableListEntry<GestureKey, String>>[];
          final gestureItemsByKey = <GestureKey, _GestureRowItem>{};
          final groupItemsById = <String, _GroupHeaderItem>{};
          for (final flatItem in viewModel.flatItems) {
            switch (flatItem) {
              case _GroupHeaderItem():
                groupItemsById[flatItem.group.id] = flatItem;
                reorderEntries.add(
                  ReorderableGroupableGroup<GestureKey, String>(
                    key: ValueKey('group:${flatItem.group.id}'),
                    id: flatItem.group.id,
                  ),
                );
              case _GestureRowItem():
                final key = (
                  device: flatItem.device,
                  index: flatItem.configIndex,
                );
                gestureItemsByKey[key] = flatItem;
                reorderEntries.add(
                  ReorderableGroupableItem<GestureKey, String>(
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
              controller: _scrollController,
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
                      onGestureAdded: _handleGestureAdded,
                      onAddGroup: deviceFilter != null
                          ? () => _addGroup(deviceFilter)
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
                  ReorderableGroupableList<GestureKey, String>(
                    entries: reorderEntries,
                    scrollController: _scrollController,
                    borderColor: colors.border,
                    reorderEnabled: viewModel.reorderEnabled,
                    selectedItemIds:
                        multiSelect
                            ?.where(
                              (key) => key.device == viewModel.deviceFilter,
                            )
                            .toSet() ??
                        const {},
                    showTrailingDropZone: viewModel.deviceFilter != null,
                    itemDragLabelBuilder: (_, count) =>
                        count == 1 ? 'Move gesture' : 'Move $count gestures',
                    groupDragLabelBuilder: (group) =>
                        groupItemsById[group.id]?.group.name ?? 'Move group',
                    onMoveItemsToEnd: (itemIds) =>
                        _listController.moveGesturesToUngroupedEnd(
                          itemIds,
                          viewModel.fullFlatItems,
                          viewModel.deviceFilter!,
                        ),
                    onMoveItemsBeforeItem: (itemIds, targetItemId) =>
                        _listController.moveGesturesBeforeGesture(
                          itemIds,
                          targetItemId.index,
                          viewModel.fullFlatItems,
                          viewModel.deviceFilter!,
                        ),
                    onMoveItemsIntoGroup: (itemIds, groupId) =>
                        _listController.appendGesturesToGroup(
                          itemIds,
                          groupId,
                          viewModel.fullFlatItems,
                          viewModel.deviceFilter!,
                        ),
                    onMoveGroupToEnd: (groupId) =>
                        _listController.reorderGroupToEnd(
                          viewModel.deviceFilter!,
                          groupId,
                          config,
                        ),
                    onMoveGroupBeforeGroup: (draggedGroupId, targetGroupId) =>
                        _listController.reorderGroupBefore(
                          viewModel.deviceFilter!,
                          draggedGroupId,
                          targetGroupId,
                          config,
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
                            configNotifier.updateGestureGroup(
                              flatItem.group.id,
                              (g) => g.copyWith(name: name.trim()),
                            );
                          },
                        ),
                        onToggleEnabled: () =>
                            configNotifier.updateGestureGroup(
                              flatItem.group.id,
                              (g) => g.copyWith(enabled: !g.enabled),
                            ),
                        onBreakdown: () =>
                            configNotifier.removeGestureGroupAndUngroup(
                              flatItem.group.id,
                            ),
                        onDelete: () =>
                            configNotifier.deleteGestureGroupWithGestures(
                              flatItem.group.id,
                              flatItem.device,
                            ),
                      );
                    },
                    itemOverlayBuilder: (context, itemEntry) {
                      final item = gestureItemsByKey[itemEntry.id]!;
                      final gestureConflicts = isMultiSelectMode
                          ? const <GestureConflict>[]
                          : conflicts.forGesture(item.device, item.configIndex);
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
                              configNotifier.duplicateGestureForDevice(
                                item.device,
                                item.configIndex,
                              ),
                          onDelete: () {
                            configNotifier.removeGestureForDevice(
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
                          _scrollTarget?.device == item.device &&
                          _scrollTarget?.index == item.configIndex;
                      return isScrollTarget
                          ? KeyedSubtree(key: _scrollTargetKey, child: row)
                          : row;
                    },
                  ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (error, _) => Center(child: Text('Error: $error')),
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
