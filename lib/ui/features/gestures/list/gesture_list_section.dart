import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
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
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart'
    hide gestureCommon, gestureDisplayName, gestureTypeLabel;
import 'package:input_actions_editor/model/gesture_group.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
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

// ---------------------------------------------------------------------------
// Section widget
// ---------------------------------------------------------------------------

class GestureListSection extends HookConsumerWidget {
  const GestureListSection({super.key});

  static const _headerHeight = 65.0;

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

    void handleGestureAdded(
      DeviceType device,
      Gesture gesture, {
      String? groupId,
    }) {
      final config = ref.read(draftConfigProvider);
      final existingGestures = config.gesturesForDevice(device);
      final newIndex = existingGestures.length;
      final l10n = context.l10n;
      final typeLabel = gestureTypeLabel(gesture, l10n);
      final sameTypeCount = existingGestures
          .where((g) => gestureTypeLabel(g, l10n) == typeLabel)
          .length;
      final defaultName = '$typeLabel #${sameTypeCount + 1}';
      final named = gesture.withCommon(
        gesture.common.copyWith(name: defaultName, groupId: groupId),
      );
      ref.read(gestureCommandsProvider).addGesture(device, named);
      ref.read(addedGestureProvider.notifier).markAdded(newIndex);
      context.selectGesture(device, newIndex);
      choreo.scrollToGesture(GestureLocation(device: device, index: newIndex));
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
              .read(gestureCommandsProvider)
              .addGroup(
                GestureGroup(id: id, name: name.trim(), device: device),
              );
        },
      );
    }

    // Structure only — content edits are absorbed by the provider's value
    // equality, so they rebuild the affected row (which reads its own gesture),
    // not this section.
    final viewModel = ref.watch(gestureListStructureProvider);
    final selection = ref.watch(selectedGestureProvider);
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

    final title = isMultiSelectMode
        ? context.l10n.multiSelectCount(multiSelect.length)
        : (deviceFilter == null
              ? context.l10n.sidebarAllDevices
              : gestureDeviceLabel(deviceFilter, context.l10n));
    final countLabel = isMultiSelectMode
        ? null
        : '${viewModel.gestureCount} '
              'gesture${viewModel.gestureCount == 1 ? '' : 's'}';

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            isMultiSelectMode) {
          multiSelectNotifier.exit();
        }
      },
      child: Builder(
        builder: (context) {
          choreo.prepare(viewModel);
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
                final editId = flatItem.editId;
                // A reordered row enters at its new slot from a fresh
                // element, so its key is bumped to force a remount and it
                // renders invisible for one frame so the expand starts at
                // height 0.
                final isEntering =
                    editId != null && transitions.entering.contains(editId);
                final isHidden =
                    editId != null &&
                    transitions.enteringHidden.contains(editId);
                reorderEntries.add(
                  ReorderableGroupableItem<GestureLocation, String>(
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
                    groupId: deviceFilter == null ? null : flatItem.groupId,
                    isFirstInGroup: flatItem.isFirstInGroup,
                    isLastInGroup: flatItem.isLastInGroup,
                    isVisible: flatItem.isVisible && !isHidden,
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
              ReorderableGroupableItem<GestureLocation, String>(
                key: ghostKey,
                id: GestureLocation(
                  device: ghost.device,
                  index: -1 - ghost.editId,
                ),
                groupId: ghost.groupId,
                isVisible: !ghost.collapsing,
                interactive: false,
              ),
            );
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
                              (key) => key.device == viewModel.deviceFilter,
                            )
                            .toSet() ??
                        const {},
                    showTrailingDropZone: viewModel.deviceFilter != null,
                    itemDragLabelBuilder: (_, count) =>
                        count == 1 ? 'Move gesture' : 'Move $count gestures',
                    groupDragLabelBuilder: (group) =>
                        groupItemsById[group.id]?.group.name ?? 'Move group',
                    onItemsReordered: (result) =>
                        transitions.requestItemsReorder(
                          device: viewModel.deviceFilter!,
                          result: result,
                          flatItems: viewModel.flatItems,
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
                        onBreakdown: () => listNotifier.removeGroupAndUngroup(
                          flatItem.group.id,
                        ),
                        onDelete: () => listNotifier.deleteGroupWithGestures(
                          flatItem.group.id,
                          flatItem.device,
                        ),
                        onAddGesture: () => showAddGestureDialogForDevice(
                          context,
                          flatItem.device,
                          (device, gesture) => handleGestureAdded(
                            device,
                            gesture,
                            groupId: flatItem.group.id,
                          ),
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
                      final ghost = ghostByKey[itemEntry.key];
                      if (ghost != null) {
                        return GestureListTile(
                          device: ghost.device,
                          index: -1,
                          gestureOverride: ghost.gesture,
                          newlyAddedMarkerId: null,
                          isSelected: false,
                          isMultiSelectMode: false,
                          isMultiSelected: false,
                          groupDisabled:
                              ghost.groupId != null &&
                              viewModel.disabledGroupIds.contains(
                                ghost.groupId,
                              ),
                          onTap: () {},
                        );
                      }
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
                      final groupDisabled =
                          item.groupId != null &&
                          viewModel.disabledGroupIds.contains(
                            item.groupId,
                          );
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
                          onDuplicate: () => listNotifier.duplicateGesture(
                            item.device,
                            item.configIndex,
                          ),
                          onDelete: () => transitions.requestDelete(
                            device: item.device,
                            configIndex: item.configIndex,
                            flatItems: viewModel.flatItems,
                          ),
                        ),
                      );

                      final isScrollTarget =
                          choreo.scrollTarget?.device == item.device &&
                          choreo.scrollTarget?.index == item.configIndex;
                      return isScrollTarget
                          ? KeyedSubtree(
                              key: choreo.scrollTargetKey,
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
    // of the conflict: an unmodified gesture shouldn't light up just because a
    // freshly edited neighbour now collides with it.
    final focusDirty = ref.watch(
      gestureDirtyProvider(
        GestureLocation(device: focus.device, index: focus.index),
      ),
    );
    final visible = focusDirty
        ? conflicts
        : conflicts.where((c) {
            final other = c.other(focus);
            return !ref.watch(
              gestureDirtyProvider(
                GestureLocation(device: other.device, index: other.index),
              ),
            );
          }).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final names = visible.map((c) => c.otherLabel(focus)).join(', ');
    final tooltipText = 'Conflicts with: $names';

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
