import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/bounce_free_scroll_physics.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/marquee_overlay.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_controller.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/shrink_compensated_sliver.dart';
import 'package:pixel_snap/widgets.dart' as ps;

part 'list_state.dart';
part 'list_segments.dart';
part 'list_drag_handles.dart';
part 'list_item_frame.dart';
part 'list_header_scroll.dart';
part 'list_drop_zones.dart';

/// Horizontal inset applied to grouped rows (and aligned drop indicators) so
/// they sit under the group's bracket.
const _groupIndent = 16.0;

sealed class ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableListEntry();
}

final class ReorderableGroupableGroup<I, G>
    extends ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableGroup({
    required this.key,
    required this.id,
  });

  final Key key;
  final G id;
}

final class ReorderableGroupableItem<I, G>
    extends ReorderableGroupableListEntry<I, G> {
  const ReorderableGroupableItem({
    required this.key,
    required this.id,
    this.groupId,
    this.isFirstInGroup = false,
    this.isLastInGroup = false,
    this.isVisible = true,
    this.interactive = true,
  });

  final Key key;
  final I id;
  final G? groupId;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final bool isVisible;

  /// When false, the row renders with no drag handle, drop target, or overlay.
  /// used for a transient collapsing "ghost" that must not be interacted with.
  final bool interactive;
}

typedef ReorderableGroupableItemBuilder<I, G> =
    Widget Function(
      BuildContext context,
      ReorderableGroupableItem<I, G> item,
      Widget? dragHandle,
      bool isDragging,
    );

typedef ReorderableGroupableGroupBuilder<I, G> =
    Widget Function(
      BuildContext context,
      ReorderableGroupableGroup<I, G> group,
      Widget? dragHandle,
      bool isPinned,
      ReorderableHeaderScrollBuilder scrollBuilder,
    );

/// Scroll metrics for a group header, recomputed each frame. `scrolledUnder` is
/// 0..1, how far the header is behind the app header (a hand-off fade).
/// `pinOffsetPx` is the signed px of the header top vs the pin line: positive
/// below it, 0 pinned, negative once pushed behind.
typedef ReorderableHeaderScroll = ({double scrolledUnder, double pinOffsetPx});

/// Builds part of a group header that reacts to its scroll position. The list
/// rebuilds [builder] each frame with a [ReorderableHeaderScroll]; pass a
/// [child] that does not depend on the value so it is built once.
typedef ReorderableHeaderScrollBuilder =
    Widget Function(
      ValueWidgetBuilder<ReorderableHeaderScroll> builder, {
      Widget? child,
    });

typedef ReorderableGroupableItemOverlayBuilder<I, G> =
    Widget? Function(BuildContext context, ReorderableGroupableItem<I, G> item);

typedef ReorderableGroupableItemsReorderedCallback<I, G> =
    void Function(ReorderableItemsResult<I, G> result);

typedef ReorderableGroupableGroupReorderedCallback =
    void Function(int fromIndex, int toIndex);

class ReorderableGroupableList<I, G> extends StatefulWidget {
  const ReorderableGroupableList({
    required this.entries,
    required this.itemBuilder,
    required this.groupBuilder,
    required this.scrollController,
    required this.borderColor,
    required this.groupHeaderExtent,
    required this.onItemsReordered,
    required this.onGroupReordered,
    this.reorderEnabled = true,
    this.selectedItemIds = const {},
    this.itemOverlayBuilder,
    this.itemDragLabelBuilder,
    this.groupDragLabelBuilder,
    this.showTrailingDropZone = true,
    this.leadingSlivers = const [],
    this.leadingPinnedExtent = 0,
    this.emptyPlaceholder,
    this.marqueeEnabled = false,
    this.marqueeColor = const Color(0xFF3B82F6),
    this.onMarqueeStart,
    this.onMarqueeUpdate,
    this.onMarqueeEnd,
    super.key,
  });

  final List<ReorderableGroupableListEntry<I, G>> entries;
  final ReorderableGroupableItemBuilder<I, G> itemBuilder;
  final ReorderableGroupableGroupBuilder<I, G> groupBuilder;
  final ScrollController scrollController;
  final Color borderColor;

  /// Fixed pin extent for group headers. Pinned persistent headers require a
  /// declared extent, so each group's [groupBuilder] output must render at this
  /// height.
  final double groupHeaderExtent;
  final bool reorderEnabled;
  final Set<I> selectedItemIds;
  final ReorderableGroupableItemOverlayBuilder<I, G>? itemOverlayBuilder;
  final String Function(ReorderableGroupableItem<I, G> item, int count)?
  itemDragLabelBuilder;
  final String Function(ReorderableGroupableGroup<I, G> group)?
  groupDragLabelBuilder;
  final bool showTrailingDropZone;
  final ReorderableGroupableItemsReorderedCallback<I, G> onItemsReordered;
  final ReorderableGroupableGroupReorderedCallback onGroupReordered;

  /// Slivers placed before the list content (e.g. a pinned app header). This
  /// widget owns the [CustomScrollView], so they are supplied here rather than
  /// wrapped around it, letting each group be a direct sliver child.
  final List<Widget> leadingSlivers;

  /// Combined extent of the pinned [leadingSlivers] (the app header height),
  /// used as the pin line a group header fades against as it scrolls behind it.
  final double leadingPinnedExtent;

  /// Shown (filling the remaining viewport) when [entries] is empty.
  final Widget? emptyPlaceholder;

  /// Enables rubber-band (marquee) selection: a primary-mouse drag starting on
  /// empty list body draws a selection box that reports the item ids it covers.
  /// Mouse drags do not scroll on desktop, so this never fights the viewport.
  final bool marqueeEnabled;

  /// Fill/outline tint of the marquee box.
  final Color marqueeColor;

  /// Called once when a marquee drag begins. [additive] is true when a modifier
  /// (shift/ctrl/meta) is held, signalling the host to extend its existing
  /// selection rather than replace it.
  final void Function(bool additive)? onMarqueeStart;

  /// Called as the box moves with the set of item ids currently inside it.
  final void Function(Set<I> covered)? onMarqueeUpdate;

  /// Called when the marquee ends. [canceled] is true if it was aborted (escape
  /// or pointer cancel) and the host should restore its pre-marquee selection.
  final void Function(Set<I> covered, {required bool canceled})? onMarqueeEnd;

  @override
  State<ReorderableGroupableList<I, G>> createState() =>
      _ReorderableGroupableListState<I, G>();
}
