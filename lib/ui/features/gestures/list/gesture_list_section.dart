import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:forui_hooks/forui_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart'
    hide gestureCommon, gestureDisplayName, gestureTypeLabel;
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/app_dialog.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/state/bulk_edit_active_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/added_gesture_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/collapsed_groups_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';
import 'package:scroll_animator/scroll_animator.dart';

part 'gesture_list_section/choreography.dart';
part 'gesture_list_section/dialogs/rename_dialog.dart';
part 'gesture_list_section/flat_list.dart';
part 'gesture_list_section/models.dart';
part 'gesture_list_section/reordering.dart';
part 'gesture_list_section/transitions.dart';
part 'gesture_list_section/view_model.dart';
part 'gesture_list_section/widgets/gesture_item_widgets.dart';
part 'gesture_list_section/widgets/group_widgets.dart';
part 'gesture_list_section/widgets/header.dart';

class GestureListSection extends HookConsumerWidget {
  const GestureListSection({super.key});

  static const _headerHeight = 65.0;
  static const _groupHeaderExtent = 38.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(
      () => AnimatedScrollController(
        animationFactory: const ChromiumEaseInOut(),
      ),
    );
    useEffect(() => scrollController.dispose, const []);
    final choreo = _useGestureListChoreography(ref, context, scrollController);
    final transitions = _useGestureTransitions(ref, context);
    // Selection captured when a marquee drag starts; covered rows are unioned
    // onto it (additive) or it stays empty (replace).
    final marqueeBase = useRef(<GestureLocation>{});

    void handleGestureAdded(
      DeviceType device,
      Gesture gesture, {
      int? groupKey,
    }) {
      final config = ref.read(draftConfigProvider);
      final existingGestures = config.gesturesForDevice(device);
      final existingIds = {
        for (final g in existingGestures) g.common.editId,
      };
      final l10n = context.l10n;
      final typeLabel = gestureTypeLabel(gesture, l10n);
      final sameTypeCount = existingGestures
          .where((g) => gestureTypeLabel(g, l10n) == typeLabel)
          .length;
      final defaultName = '$typeLabel #${sameTypeCount + 1}';
      final named = gesture.withCommon(
        gesture.common.copyWith(name: defaultName),
      );
      ref
          .read(gestureCommandsProvider)
          .addGesture(device, named, groupKey: groupKey);
      // The editId is assigned when the add lands in the draft, so the
      // identity location is only known after the dispatch — and with group
      // targets the new row is not necessarily last, so find it by fresh id.
      final draft = ref.read(draftConfigProvider);
      final newIndex = draft
          .gesturesForDevice(device)
          .indexWhere((g) => !existingIds.contains(g.common.editId));
      if (newIndex < 0) return;
      ref.read(addedGestureProvider.notifier).markAdded(newIndex);
      final location = gestureLocationAt(draft, device, newIndex);
      if (location == null) return;
      context.selectGesture(location);
      choreo.scrollToGesture(location);
    }

    Future<void> addGroupDialog(DeviceType device) {
      return _showRenameDialog(
        context,
        title: 'New Group',
        initial: '',
        onConfirm: (name) {
          if (name.trim().isEmpty) return;
          ref
              .read(gestureCommandsProvider)
              .addGroup(device, GestureGroupNode(name: name.trim()));
        },
      );
    }

    final viewModel = ref.watch(gestureListStructureProvider);
    final multiSelect = ref.watch(multiSelectControllerProvider);
    final multiSelectNotifier = ref.read(
      multiSelectControllerProvider.notifier,
    );
    final listNotifier = ref.read(gestureCommandsProvider);
    final deviceFilter = ref.watch(deviceFilterProvider);
    final addedMarker = ref.watch(addedGestureProvider);
    final conflicts = ref.watch(conflictReportProvider);
    final collapsedNotifier = ref.read(collapsedGroupsProvider.notifier);
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isMultiSelectMode = multiSelect != null;

    // Esc exits select mode regardless of where focus currently sits (a
    // focus-scoped shortcut only fires when the list happens to hold focus).
    useEffect(() {
      if (!isMultiSelectMode) return null;
      bool onKey(KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          multiSelectNotifier.exit();
          return true;
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(onKey);
      return () => HardwareKeyboard.instance.removeHandler(onKey);
    }, [isMultiSelectMode, multiSelectNotifier]);

    final title = isMultiSelectMode
        ? context.l10n.multiSelectCount(multiSelect.length)
        : (deviceFilter == null
              ? context.l10n.sidebarAllDevices
              : gestureDeviceLabel(deviceFilter, context.l10n));
    final countLabel = isMultiSelectMode
        ? null
        : '${viewModel.gestureCount} '
              'gesture${viewModel.gestureCount == 1 ? '' : 's'}';

    return Builder(
      builder: (context) {
        choreo.prepare(viewModel);
        final reorderEntries =
            <ReorderableGroupableListEntry<GestureLocation, int>>[];
        final gestureItemsByKey = <GestureLocation, _GestureRowItem>{};
        final groupItemsByKey = <int, _GroupHeaderItem>{};
        for (final flatItem in viewModel.flatItems) {
          switch (flatItem) {
            case _GroupHeaderItem():
              groupItemsByKey[flatItem.groupKey] = flatItem;
              reorderEntries.add(
                ReorderableGroupableGroup<GestureLocation, int>(
                  key: ValueKey('group:${flatItem.groupKey}'),
                  id: flatItem.groupKey,
                  parentId: flatItem.parentKey,
                  depth: flatItem.depth,
                  isVisible: flatItem.isVisible,
                  ancestorContinues: flatItem.ancestorContinues,
                ),
              );
            case _GestureRowItem():
              final key = flatItem.location;
              gestureItemsByKey[key] = flatItem;
              final editId = flatItem.editId;
              // A reordered row enters at its new slot from a fresh
              // element, so its key is bumped to force a remount and it
              // renders invisible for one frame so the expand starts at
              // height 0.
              final isEntering =
                  editId != null && transitions.entering.contains(editId);
              final isHidden =
                  editId != null && transitions.enteringHidden.contains(editId);
              reorderEntries.add(
                ReorderableGroupableItem<GestureLocation, int>(
                  // Keyed by stable identity (editId), not position, so
                  // a removed row disposes its own element instead of
                  // its collapsed cross-fade bleeding onto the row that
                  // shifts up. Falls back to position only for the
                  // impossible null editId.
                  key: ValueKey(
                    editId != null
                        ? (isEntering ? 'gid:$editId:enter' : 'gid:$editId')
                        : '${flatItem.device.name}:'
                              '${flatItem.configIndex}',
                  ),
                  id: key,
                  groupId: deviceFilter == null ? null : flatItem.groupKey,
                  depth: deviceFilter == null ? 0 : flatItem.depth,
                  isFirstInGroup: flatItem.isFirstInGroup,
                  isLastInGroup: flatItem.isLastInGroup,
                  isVisible: flatItem.isVisible && !isHidden,
                  ancestorContinues: flatItem.ancestorContinues,
                ),
              );
          }
        }

        // Insert collapsing ghosts at the slots their rows vacated,
        // from the highest anchor down so earlier inserts don't shift
        // later anchors.
        final ghostByKey = <Key, _GhostRow>{};
        final orderedGhosts = [...transitions.ghosts]
          ..sort((a, b) => b.anchorIndex.compareTo(a.anchorIndex));
        for (final ghost in orderedGhosts) {
          final ghostKey = ValueKey('ghost:${ghost.editId}');
          ghostByKey[ghostKey] = ghost;
          reorderEntries.insert(
            ghost.anchorIndex.clamp(0, reorderEntries.length),
            ReorderableGroupableItem<GestureLocation, int>(
              key: ghostKey,
              // Negative editIds are never assigned, so a ghost's id can
              // never collide with (or resolve to) a live gesture.
              id: GestureLocation(
                device: ghost.device,
                editId: -1 - ghost.editId,
              ),
              groupId: ghost.groupKey,
              depth: ghost.depth,
              isVisible: !ghost.collapsing,
              interactive: false,
            ),
          );
        }

        return ScrollbarMediaPadding(
          topInset: GestureListSection._headerHeight,
          child: ReorderableGroupableList<GestureLocation, int>(
            scrollController: scrollController,
            leadingSlivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedHeaderDelegate(
                  minExtentValue: GestureListSection._headerHeight,
                  maxExtentValue: GestureListSection._headerHeight,
                  child: _GestureListHeader(
                    title: title,
                    countLabel: countLabel,
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
            ],
            emptyPlaceholder: Center(
              child: Text(
                'No gestures yet.',
                style: typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
              ),
            ),
            entries: reorderEntries,
            borderColor: colors.border,
            groupHeaderExtent: GestureListSection._groupHeaderExtent,
            leadingPinnedExtent: GestureListSection._headerHeight,
            reorderEnabled: viewModel.reorderEnabled,
            selectedItemIds:
                multiSelect
                    ?.where(
                      (key) => key.device == viewModel.deviceFilter,
                    )
                    .toSet() ??
                const {},
            showTrailingDropZone: viewModel.deviceFilter != null,
            marqueeEnabled: true,
            marqueeColor: colors.primary,
            onMarqueeStart: (additive) {
              // Snapshot the base but don't enter multi-select yet: entering
              // is a heavy rebuild, so defer it until a row is actually
              // covered (keeps a drag starting on empty space cheap).
              marqueeBase.value = additive
                  ? {...?multiSelect}
                  : <GestureLocation>{};
            },
            onMarqueeUpdate: (covered) {
              final next = {...marqueeBase.value, ...covered};
              if (next.isEmpty) {
                if (multiSelectNotifier.state != null) {
                  multiSelectNotifier.exit();
                }
              } else {
                multiSelectNotifier.state = next;
              }
            },
            onMarqueeEnd: (covered, {required canceled}) {
              final next = canceled
                  ? marqueeBase.value
                  : {...marqueeBase.value, ...covered};
              if (next.isEmpty) {
                multiSelectNotifier.exit();
              } else {
                multiSelectNotifier.state = next;
              }
            },
            itemDragLabelBuilder: (_, count) =>
                count == 1 ? 'Move gesture' : 'Move $count gestures',
            groupDragLabelBuilder: (group) =>
                groupItemsByKey[group.id]?.name ?? 'Move group',
            onItemsReordered: (result) => transitions.requestItemsReorder(
              device: viewModel.deviceFilter!,
              result: result,
              flatItems: viewModel.flatItems,
            ),
            onGroupMoved: (move) => _GestureListController(
              ref,
              context,
            ).applyGroupMove(viewModel.deviceFilter!, move),
            groupBuilder:
                (
                  context,
                  groupEntry,
                  reorderHandle,
                  isPinned,
                  scrollBuilder,
                ) {
                  final flatItem = groupItemsByKey[groupEntry.id]!;
                  return _GroupHeaderRow(
                    key: groupEntry.key,
                    index: viewModel.flatItems.indexOf(flatItem),
                    name: flatItem.name,
                    enabled: flatItem.enabled,
                    device: flatItem.device,
                    isCollapsed: flatItem.isCollapsed,
                    scrollBuilder: scrollBuilder,
                    gestureCount: flatItem.gestureCount,
                    borderColor: colors.border,
                    reorderHandle: reorderHandle,
                    onToggleCollapse: () =>
                        collapsedNotifier.toggle(flatItem.groupKey),
                    onRename: () => _showRenameDialog(
                      context,
                      title: 'Rename Group',
                      initial: flatItem.name,
                      onConfirm: (name) {
                        if (name.trim().isEmpty) return;
                        listNotifier.updateGroup(
                          flatItem.location,
                          (g) => g.copyWith(name: name.trim()),
                        );
                      },
                    ),
                    onToggleEnabled: () => listNotifier.updateGroup(
                      flatItem.location,
                      (g) => g.copyWith(enabled: !g.enabled),
                    ),
                    onBulkEdit: () {
                      final locations = <GestureLocation>{
                        for (final item in viewModel.flatItems)
                          if (item is _GestureRowItem &&
                              item.groupKey == flatItem.groupKey)
                            item.location,
                      };
                      if (locations.isEmpty) return;
                      multiSelectNotifier.enterAll(locations);
                      ref.read(bulkEditActiveProvider.notifier).open();
                    },
                    onBreakdown: () => listNotifier.removeGroupAndUngroup(
                      flatItem.location,
                    ),
                    onDelete: () => listNotifier.deleteGroupWithGestures(
                      flatItem.location,
                    ),
                    onAddGesture: () => showAddGestureDialogForDevice(
                      context,
                      flatItem.device,
                      (device, gesture) => handleGestureAdded(
                        device,
                        gesture,
                        groupKey: flatItem.groupKey,
                      ),
                    ),
                  );
                },
            itemOverlayBuilder: (context, itemEntry) {
              final gestureConflicts = isMultiSelectMode
                  ? const <GestureConflict>[]
                  : conflicts.forGesture(itemEntry.id);
              return gestureConflicts.isNotEmpty
                  ? _ConflictTileIcon(
                      conflicts: gestureConflicts,
                      focus: itemEntry.id,
                    )
                  : null;
            },
            itemBuilder: (context, itemEntry, _, isDragging) {
              final ghost = ghostByKey[itemEntry.key];
              if (ghost != null) {
                return GestureListTile(
                  location: GestureLocation(
                    device: ghost.device,
                    editId: -1 - ghost.editId,
                  ),
                  gestureOverride: ghost.gesture,
                  newlyAddedMarkerId: null,
                  isSelected: false,
                  isMultiSelectMode: false,
                  isMultiSelected: false,
                  groupDisabled:
                      ghost.groupKey != null &&
                      viewModel.disabledGroupKeys.contains(
                        ghost.groupKey,
                      ),
                  onTap: () {},
                );
              }
              final item = gestureItemsByKey[itemEntry.id]!;
              final selectionKey = itemEntry.id;
              final markerId =
                  (addedMarker?.index == item.configIndex &&
                      deviceFilter != null &&
                      addedMarker?.index == item.configIndex)
                  ? addedMarker?.id
                  : null;
              final groupDisabled =
                  item.groupKey != null &&
                  viewModel.disabledGroupKeys.contains(
                    item.groupKey,
                  );
              final row = AnimatedOpacity(
                duration: Durations.short2,
                opacity: isDragging ? 0.45 : 1,
                child: _ContextMenuTile(
                  item: item,
                  newlyAddedMarkerId: markerId,
                  groupDisabled: groupDisabled,
                  onTap: () {
                    if (isMultiSelectMode) {
                      multiSelectNotifier.toggle(selectionKey);
                    } else {
                      context.selectGesture(selectionKey);
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
                  onRename: () {
                    final gesture = gestureAt(
                      ref.read(draftConfigProvider),
                      selectionKey,
                    );
                    if (gesture == null) return;
                    unawaited(
                      _showRenameDialog(
                        context,
                        title: context.l10n.renameDialogTitle,
                        initial: gesture.common.name ?? '',
                        onConfirm: (name) => listNotifier.renameGesture(
                          selectionKey,
                          name.trim(),
                        ),
                      ),
                    );
                  },
                  onDuplicate: () =>
                      listNotifier.duplicateGesture(selectionKey),
                  onToggleEnabled: () {
                    final isGestureEnabled =
                        gestureAt(
                          ref.read(draftConfigProvider),
                          selectionKey,
                        )?.common.enabled !=
                        false;
                    if (isGestureEnabled) {
                      listNotifier.disableGestures([selectionKey]);
                    } else {
                      listNotifier.enableGestures([selectionKey]);
                    }
                  },
                  onDelete: () => transitions.requestDelete(
                    location: selectionKey,
                    flatItems: viewModel.flatItems,
                  ),
                ),
              );

              final isScrollTarget = choreo.scrollTarget == itemEntry.id;
              return isScrollTarget
                  ? KeyedSubtree(
                      key: choreo.scrollTargetKey,
                      child: row,
                    )
                  : row;
            },
          ),
        );
      },
    );
  }
}

class _ConflictTileIcon extends ConsumerWidget {
  const _ConflictTileIcon({
    required this.conflicts,
    required this.focus,
  });

  final List<GestureConflict> conflicts;
  final GestureRef focus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;

    // Keep the indicator quiet when the user has only touched the *other* side
    // of the conflict
    final focusDirty = ref.watch(gestureDirtyProvider(focus));
    final visible = focusDirty
        ? conflicts
        : conflicts
              .where((c) => !ref.watch(gestureDirtyProvider(c.other(focus))))
              .toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final names = visible.map((c) => c.otherLabel(focus)).join(', ');
    final tooltipText = 'Conflicts with: $names';

    return AppTooltip(
      tipBuilder: (context, _) => Text(tooltipText, style: typography.body.xs),
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
