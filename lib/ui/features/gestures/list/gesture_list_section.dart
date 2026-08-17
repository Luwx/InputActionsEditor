import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart'
    hide gestureCommon, gestureDisplayName, gestureTypeLabel;
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/edit_shortcuts.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/rename_dialog.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_motion.dart';
import 'package:input_actions_editor/ui/common/tree_list/tree_move.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/state/bulk_edit_active_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/features/gestures/list/add_gesture_button.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/added_gesture_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/collapsed_groups_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_clipboard.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/list/widgets/gesture_context_menu_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/widgets/gesture_group_header_row.dart';
import 'package:input_actions_editor/ui/features/gestures/list/widgets/gesture_list_header.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';
import 'package:scroll_animator/scroll_animator.dart';

part 'gesture_list_section/choreography.dart';
part 'gesture_list_section/flat_list.dart';
part 'gesture_list_section/models.dart';
part 'gesture_list_section/transitions.dart';
part 'gesture_list_section/view_model.dart';

class GestureListSection extends HookConsumerWidget {
  const GestureListSection({super.key});

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
      // identity location is only known after the dispatch
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

    /// Adds a group and brings it into view. Its editId is only assigned once
    /// the edit lands, so the new node is found by diffing the keys.
    void addGroup(DeviceType device, String name, {int? parentKey}) {
      final before = {
        for (final key in _groupKeysOf(ref.read(draftConfigProvider), device))
          key,
      };
      ref
          .read(gestureCommandsProvider)
          .addGroup(device, GestureGroupNode(name: name), parentKey: parentKey);
      final added = _groupKeysOf(
        ref.read(draftConfigProvider),
        device,
      ).where((key) => !before.contains(key)).firstOrNull;
      if (added == null) return;
      if (parentKey != null) {
        ref.read(collapsedGroupsProvider.notifier).expand(parentKey);
      }
      choreo.scrollToGroup(added);
    }

    Future<void> addGroupDialog(DeviceType device) {
      return showRenameDialog(
        context,
        title: context.l10n.dialogNewGroupTitle,
        initial: '',
        confirmLabel: context.l10n.actionCreate,
        onConfirm: (name) => addGroup(device, name.trim()),
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
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isMultiSelectMode = multiSelect != null;

    List<GestureLocation> selectionInOrder() => [
      for (final item in viewModel.flatItems)
        if (item is _GestureRowItem &&
            (multiSelect?.contains(item.location) ?? false))
          item.location,
    ];

    /// The rows a row command applies to: the selection when [location] is
    /// part of it, otherwise just that row.
    List<GestureLocation> targetsFor(GestureLocation location) =>
        (multiSelect?.contains(location) ?? false)
        ? selectionInOrder()
        : [location];

    Future<void> copyGestures(List<GestureLocation> targets) async {
      final draft = ref.read(draftConfigProvider);
      final byDevice = <DeviceType, List<Gesture>>{};
      for (final target in targets) {
        final gesture = gestureAt(draft, target);
        if (gesture != null) (byDevice[target.device] ??= []).add(gesture);
      }
      if (byDevice.isNotEmpty) await GestureClipboard.write(byDevice);
    }

    Future<void> pasteGestures(GestureLocation anchor) async {
      final gestures = await GestureClipboard.read(anchor.device);
      if (!context.mounted) return;
      if (gestures.isEmpty) {
        showFToast(
          context: context,
          title: Text(context.l10n.gesturePasteEmpty),
          duration: const Duration(seconds: 3),
        );
        return;
      }
      listNotifier.insertGestures(anchor.device, gestures, after: anchor);
    }

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

        // Insert collapsing ghosts at the slots their rows vacated.
        final ghostByKey = <Key, ListGhost<_GhostRow>>{};
        final withGhosts = spliceListGhosts(
          reorderEntries,
          transitions.ghosts,
          (ghost) {
            final ghostKey = ValueKey('ghost:${ghost.id}');
            ghostByKey[ghostKey] = ghost;
            return ReorderableGroupableItem<GestureLocation, int>(
              key: ghostKey,
              // Negative editIds are never assigned, so a ghost's id can
              // never collide with (or resolve to) a live gesture.
              id: GestureLocation(
                device: ghost.payload.device,
                editId: -1 - ghost.id,
              ),
              groupId: ghost.payload.groupKey,
              depth: ghost.payload.depth,
              isVisible: !ghost.collapsing,
              interactive: false,
            );
          },
          idOf: (entry) => switch (entry) {
            ReorderableGroupableGroup<GestureLocation, int>(:final id) => id,
            // A ghost never anchors another ghost, so it names nothing.
            ReorderableGroupableItem<GestureLocation, int>(:final key)
                when ghostByKey.containsKey(key) =>
              null,
            ReorderableGroupableItem<GestureLocation, int>(:final id) => id,
          },
        );

        return SelectionShortcuts(
          active: isMultiSelectMode,
          selection: multiSelect,
          bindings: {
            copyShortcut: () => unawaited(copyGestures(selectionInOrder())),
            pasteShortcut: () {
              final anchor = selectionInOrder().lastOrNull;
              if (anchor != null) unawaited(pasteGestures(anchor));
            },
            duplicateShortcut: () =>
                selectionInOrder().forEach(listNotifier.duplicateGesture),
            deleteShortcut: () {
              final targets = selectionInOrder();
              if (targets.isEmpty) return;
              multiSelectNotifier.exit();
              transitions.requestDelete(
                locations: targets,
                flatItems: viewModel.flatItems,
              );
            },
          },
          child: ScrollbarMediaPadding(
            topInset: kGestureListHeaderHeight,
            child: ReorderableGroupableList<GestureLocation, int>(
              scrollController: scrollController,
              leadingSlivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: PinnedHeaderDelegate(
                    minExtentValue: kGestureListHeaderHeight,
                    maxExtentValue: kGestureListHeaderHeight,
                    child: GestureListHeader(
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
              entries: withGhosts,
              borderColor: colors.border,
              groupHeaderExtent: kGestureGroupHeaderExtent,
              leadingPinnedExtent: kGestureListHeaderHeight,
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
              ),
              onGroupMoved: (move) => listNotifier.moveGroup(
                GestureGroupLocation(
                  device: viewModel.deviceFilter!,
                  editId: move.groupId,
                ),
                beforeKey: move.beforeGroupId,
                newParentKey: move.newParentId,
              ),
              groupBuilder:
                  (_, groupEntry, reorderHandle, isPinned, scrollBuilder) =>
                      _buildGroupHeader(
                        context,
                        ref,
                        groupEntry: groupEntry,
                        item: groupItemsByKey[groupEntry.id]!,
                        reorderHandle: reorderHandle,
                        scrollBuilder: scrollBuilder,
                        viewModel: viewModel,
                        choreo: choreo,
                        addGroup: addGroup,
                        onGestureAdded: handleGestureAdded,
                      ),
              itemOverlayBuilder: (_, itemEntry) {
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
              itemBuilder: (_, itemEntry, _, isDragging) => _buildRow(
                context,
                ref,
                itemEntry: itemEntry,
                isDragging: isDragging,
                viewModel: viewModel,
                ghost: ghostByKey[itemEntry.key],
                item: gestureItemsByKey[itemEntry.id],
                choreo: choreo,
                transitions: transitions,
                addedMarker: addedMarker,
                isMultiSelectMode: isMultiSelectMode,
                targetsFor: targetsFor,
                copyGestures: copyGestures,
                pasteGestures: pasteGestures,
              ),
            ),
          ),
        );
      },
    );
  }

  /// One group header: the pinned row with its context menu.
  Widget _buildGroupHeader(
    BuildContext context,
    WidgetRef ref, {
    required ReorderableGroupableGroup<GestureLocation, int> groupEntry,
    required _GroupHeaderItem item,
    required Widget? reorderHandle,
    required ReorderableHeaderScrollBuilder scrollBuilder,
    required _GestureListViewModel viewModel,
    required _GestureListChoreography choreo,
    required void Function(DeviceType device, String name, {int? parentKey})
    addGroup,
    required void Function(DeviceType device, Gesture gesture, {int? groupKey})
    onGestureAdded,
  }) {
    final commands = ref.read(gestureCommandsProvider);
    final multiSelect = ref.read(multiSelectControllerProvider.notifier);
    final isScrollTarget = choreo.scrollTargetGroup == item.groupKey;

    return GestureGroupHeaderRow(
      key: groupEntry.key,
      flashTrigger: isScrollTarget ? item.groupKey : null,
      scrollKey: isScrollTarget ? choreo.scrollTargetKey : null,
      location: item.location,
      name: item.name,
      enabled: item.enabled,
      isCollapsed: item.isCollapsed,
      scrollBuilder: scrollBuilder,
      gestureCount: item.gestureCount,
      borderColor: context.theme.colors.border,
      reorderHandle: reorderHandle,
      onToggleCollapse: () =>
          ref.read(collapsedGroupsProvider.notifier).toggle(item.groupKey),
      onRename: () => showRenameDialog(
        context,
        title: context.l10n.dialogRenameGroupTitle,
        initial: item.name,
        confirmLabel: context.l10n.actionRename,
        onConfirm: (name) => commands.updateGroup(
          item.location,
          (g) => g.copyWith(name: name.trim()),
        ),
      ),
      onAddSubgroup: () => showRenameDialog(
        context,
        title: context.l10n.dialogNewSubgroupTitle,
        initial: '',
        confirmLabel: context.l10n.actionCreate,
        onConfirm: (name) =>
            addGroup(item.device, name.trim(), parentKey: item.groupKey),
      ),
      onToggleEnabled: () => commands.updateGroup(
        item.location,
        (g) => g.copyWith(enabled: !g.enabled),
      ),
      onBulkEdit: () {
        final locations = <GestureLocation>{
          for (final row in viewModel.flatItems)
            if (row is _GestureRowItem && row.groupKey == item.groupKey)
              row.location,
        };
        if (locations.isEmpty) return;
        multiSelect.enterAll(locations);
        ref.read(bulkEditActiveProvider.notifier).open();
      },
      onOpenSettings: () {
        multiSelect.exit();
        ref.read(selectedGroupProvider.notifier).open(item.location);
      },
      onBreakdown: () => commands.removeGroupAndUngroup(item.location),
      onDelete: () => commands.deleteGroupWithGestures(item.location),
      onAddGesture: () => showAddGestureDialogForDevice(
        context,
        item.device,
        (device, gesture) =>
            onGestureAdded(device, gesture, groupKey: item.groupKey),
      ),
    );
  }

  /// One row of the list: the tile with its context menu, or the display-only
  /// ghost standing in for a row that has already left this slot.
  Widget _buildRow(
    BuildContext context,
    WidgetRef ref, {
    required ReorderableGroupableItem<GestureLocation, int> itemEntry,
    required bool isDragging,
    required _GestureListViewModel viewModel,
    required ListGhost<_GhostRow>? ghost,
    required _GestureRowItem? item,
    required _GestureListChoreography choreo,
    required _GestureTransitions transitions,
    required AddedGestureMarker? addedMarker,
    required bool isMultiSelectMode,
    required List<GestureLocation> Function(GestureLocation) targetsFor,
    required Future<void> Function(List<GestureLocation>) copyGestures,
    required Future<void> Function(GestureLocation) pasteGestures,
  }) {
    if (ghost != null) {
      return GestureListTile(
        location: GestureLocation(
          device: ghost.payload.device,
          editId: -1 - ghost.id,
        ),
        gestureOverride: ghost.payload.gesture,
        newlyAddedMarkerId: null,
        isSelected: false,
        isMultiSelectMode: false,
        isMultiSelected: false,
        groupDisabled:
            ghost.payload.groupKey != null &&
            viewModel.disabledGroupKeys.contains(ghost.payload.groupKey),
        onTap: () {},
      );
    }

    final row = item!;
    final location = itemEntry.id;
    final commands = ref.read(gestureCommandsProvider);
    final multiSelect = ref.read(multiSelectControllerProvider.notifier);

    return AnimatedOpacity(
      duration: Durations.short2,
      opacity: isDragging ? 0.45 : 1,
      child: GestureContextMenuTile(
        location: location,
        newlyAddedMarkerId:
            addedMarker?.index == row.configIndex &&
                viewModel.deviceFilter != null
            ? addedMarker?.id
            : null,
        groupDisabled:
            row.groupKey != null &&
            viewModel.disabledGroupKeys.contains(row.groupKey),
        scrollKey: choreo.scrollTarget == location
            ? choreo.scrollTargetKey
            : null,
        onTap: () {
          if (isMultiSelectMode) {
            multiSelect.toggle(location);
          } else {
            context.selectGesture(location);
          }
        },
        onLongPress: () {
          if (isMultiSelectMode) {
            multiSelect.toggle(location);
          } else {
            context.clearGestureSelection();
            multiSelect.enter(location);
          }
        },
        onRename: () {
          final gesture = gestureAt(ref.read(draftConfigProvider), location);
          if (gesture == null) return;
          unawaited(
            showRenameDialog(
              context,
              title: context.l10n.renameDialogTitle,
              initial: gesture.common.name ?? '',
              confirmLabel: context.l10n.actionRename,
              allowEmpty: true,
              onConfirm: (name) =>
                  commands.renameGesture(location, name.trim()),
            ),
          );
        },
        onCopy: () => unawaited(copyGestures(targetsFor(location))),
        onPaste: () => unawaited(pasteGestures(location)),
        onDuplicate: () => commands.duplicateGesture(location),
        onToggleEnabled: () {
          final enabled =
              gestureAt(
                ref.read(draftConfigProvider),
                location,
              )?.common.enabled !=
              false;
          if (enabled) {
            commands.disableGestures([location]);
          } else {
            commands.enableGestures([location]);
          }
        },
        onDelete: () => transitions.requestDelete(
          locations: [location],
          flatItems: viewModel.flatItems,
        ),
      ),
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
