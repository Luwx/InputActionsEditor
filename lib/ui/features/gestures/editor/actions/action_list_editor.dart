import 'dart:async' show unawaited;

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/add_action_dialog.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';

/// An alternative to [ActionsEditor]: a reorderable list of collapsible action
/// rows. Collapsed rows show a one-line summary plus chips for any non-default
/// trigger options; expanding a row reveals the full editor.
class ActionListEditor extends StatefulWidget {
  const ActionListEditor({
    required this.gestureLocation,
    required this.common,
    required this.onCommonChanged,
    this.dirtyState,
    this.onRevert,
    super.key,
  });

  final GestureLocation gestureLocation;
  final TriggerCommon common;
  final void Function(TriggerCommon) onCommonChanged;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;

  @override
  State<ActionListEditor> createState() => _ActionListEditorState();
}

class _ActionListEditorState extends State<ActionListEditor> {
  final Set<int> _expanded = {};

  /// Marker placed just below the row currently being anchored. Its distance to
  /// [_bottomKey] gives the SliverSmartAnchor the constant "content below the
  /// anchor" extent it needs to locate the anchor as the row grows.
  final GlobalKey _anchorKey = GlobalKey();

  /// Marker at the very bottom of the editor body, used with [_anchorKey] to
  /// measure the content below the active anchor.
  final GlobalKey _bottomKey = GlobalKey();

  /// Index of the row that owns [_anchorKey]. Only this row gets the marker.
  int? _anchorIndex;

  ScrollAnchorController? _anchor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anchor = ScrollAnchorScope.maybeOf(context);
  }

  List<TriggerAction> get _actions => widget.common.actions;

  void _emit(List<TriggerAction> actions) =>
      widget.onCommonChanged(widget.common.copyWith(actions: actions));

  /// Marks [index] as the active anchor and arms the enclosing sliver so the
  /// row's bottom is kept visible while it grows. The below-anchor extent is
  /// measured after the next frame (it stays constant for the whole session, so
  /// a one-off measurement is enough and avoids reading sizes mid-layout).
  void _beginAnchor(int index) {
    setState(() => _anchorIndex = index);
    final anchor = _anchor;
    if (anchor == null) return;
    anchor
      ..belowExtent = null
      ..isAnchoring = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureBelowExtent());
  }

  /// Disarms anchoring once an expand animation settles.
  void _endAnchor() => _anchor?.isAnchoring = false;

  /// Forgets any pending anchor; used when the list structure changes.
  void _clearAnchor() {
    _anchorIndex = null;
    _anchor
      ?..isAnchoring = false
      ..belowExtent = null;
  }

  /// Records how much content sits below the active anchor inside the sliver's
  /// child. Both markers are zero-height, so the gap between their global tops
  /// is exactly that extent regardless of how far the row has expanded.
  void _measureBelowExtent() {
    if (!mounted) return;
    final anchorBox = _anchorKey.currentContext?.findRenderObject();
    final bottomBox = _bottomKey.currentContext?.findRenderObject();
    if (anchorBox is! RenderBox ||
        bottomBox is! RenderBox ||
        !anchorBox.attached ||
        !bottomBox.attached ||
        !anchorBox.hasSize ||
        !bottomBox.hasSize) {
      return;
    }
    final gap =
        bottomBox.localToGlobal(Offset.zero).dy -
        anchorBox.localToGlobal(Offset.zero).dy;
    _anchor?.belowExtent = gap < 0 ? 0 : gap;
  }

  void _toggle(int index) {
    final expanding = !_expanded.contains(index);
    setState(() {
      if (!_expanded.add(index)) {
        _expanded.remove(index);
        if (_anchorIndex == index) _clearAnchor();
      }
    });
    if (expanding) _beginAnchor(index);
  }

  void _update(int index, TriggerAction updated) {
    final actions = List<TriggerAction>.of(_actions);
    actions[index] = updated;
    _emit(actions);
  }

  void _remove(int index) {
    final actions = List<TriggerAction>.of(_actions)..removeAt(index);
    setState(() {
      final next = <int>{};
      for (final e in _expanded) {
        if (e == index) continue;
        next.add(e > index ? e - 1 : e);
      }
      _expanded
        ..clear()
        ..addAll(next);
      _clearAnchor();
    });
    _emit(actions);
  }

  void _duplicate(int index) {
    final actions = List<TriggerAction>.of(_actions)
      ..insert(index + 1, _actions[index].copyWith());
    setState(() {
      final next = <int>{};
      for (final e in _expanded) {
        next.add(e > index ? e + 1 : e);
      }
      _expanded
        ..clear()
        ..addAll(next);
      _clearAnchor();
    });
    _emit(actions);
  }

  void _add(Action action) {
    final newIndex = _actions.length;
    _emit([..._actions, TriggerAction(action: action)]);
    setState(() {
      _expanded.add(newIndex);
      _clearAnchor();
    });
    // AnimatedSize renders new rows at full size immediately (no prior state
    // to animate from), so the anchor mechanism won't fire. Scroll explicitly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _bottomKey.currentContext;
      if (ctx != null) {
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            alignment: 1,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
            duration: Durations.short4,
            curve: Easing.emphasizedDecelerate,
          ),
        );
      }
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    final actions = List<TriggerAction>.of(_actions);
    actions.insert(newIndex, actions.removeAt(oldIndex));
    setState(() {
      final next = <int>{};
      for (final e in _expanded) {
        next.add(_remapIndex(e, oldIndex, newIndex));
      }
      _expanded
        ..clear()
        ..addAll(next);
      _clearAnchor();
    });
    _emit(actions);
  }

  int _remapIndex(int e, int from, int to) {
    if (e == from) return to;
    if (from < to) {
      if (e > from && e <= to) return e - 1;
    } else if (e >= to && e < from) {
      return e + 1;
    }
    return e;
  }

  Future<void> _pickAndAdd() async {
    final action = await showAddActionDialog(context);
    if (action != null) _add(action);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final actions = _actions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            UnsavedLabel(
              state: widget.dirtyState,
              onRevert: widget.onRevert,
              child: Text(
                'Actions',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // const SizedBox(width: 8),
            // FBadge(
            //   variant: .secondary,
            //   child: Text('${actions.length}'),
            // ),
            const Spacer(),
            // FButton(
            //   variant: .outline,
            //   size: .sm,
            //   prefix: const Icon(FLucideIcons.plus),
            //   onPress: _pickAndAdd,
            //   child: const Text('Add action'),
            // ),
          ],
        ),
        const SizedBox(height: 8),
        if (actions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No actions configured yet.',
              style: typography.sm.copyWith(color: colors.mutedForeground),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: actions.length,
            onReorderItem: _reorder,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              return _ActionRow(
                key: ValueKey('action-row-$index'),
                index: index,
                gestureLocation: widget.gestureLocation,
                triggerAction: actions[index],
                expanded: _expanded.contains(index),
                onToggle: () => _toggle(index),
                onOptionsExpanded: () => _beginAnchor(index),
                onAnchorSettled: _endAnchor,
                anchorKey: index == _anchorIndex ? _anchorKey : null,
                onChanged: (updated) => _update(index, updated),
                onDuplicate: () => _duplicate(index),
                onDelete: () => _remove(index),
              );
            },
          ),
        const SizedBox(height: 4),
        FButton(
          variant: .outline,
          onPress: _pickAndAdd,
          prefix: const Icon(FLucideIcons.plus, size: 14),
          child: const Text('Add'),
        ),
        SizedBox(key: _bottomKey, height: 0),
      ],
    );
  }
}

class _ActionRow extends ConsumerWidget {
  const _ActionRow({
    required this.index,
    required this.gestureLocation,
    required this.triggerAction,
    required this.expanded,
    required this.onToggle,
    required this.onOptionsExpanded,
    required this.onAnchorSettled,
    required this.onChanged,
    required this.onDuplicate,
    required this.onDelete,
    this.anchorKey,
    super.key,
  });

  final int index;
  final GestureLocation gestureLocation;
  final TriggerAction triggerAction;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOptionsExpanded;

  /// Invoked when this row's expand animation settles, so the enclosing
  /// [SliverSmartAnchor] can stop correcting the scroll offset.
  final VoidCallback onAnchorSettled;

  /// Zero-height marker placed just below the growing region when this row is
  /// the active anchor; consumed by the [SliverSmartAnchor] above it.
  final GlobalKey? anchorKey;
  final void Function(TriggerAction) onChanged;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;
    final actionLocation = ActionLocation(
      gesture: gestureLocation,
      actionIndex: index,
    );
    final isDirty = ref.watch(actionDirtyProvider(actionLocation));
    final meta = actionMeta(triggerAction.action);
    final chips = actionMetaChips(triggerAction);

    return AnimatedContainer(
      duration: Durations.medium1,
      curve: Easing.standard,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: expanded ? colors.foreground.withValues(alpha: 0.03) : null,
        border: Border.all(
          color: colors.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _Header(
            index: index,
            meta: meta,
            isDirty: isDirty,
            triggerAction: triggerAction,
            chips: chips,
            expanded: expanded,
            onToggle: onToggle,
            onDuplicate: onDuplicate,
            onDelete: onDelete,
          ),
          AnimatedSize(
            duration: Durations.medium1,
            curve: Easing.standard,
            alignment: Alignment.topCenter,
            onEnd: expanded ? onAnchorSettled : null,
            child: expanded
                ? _ExpandedEditor(
                    actionLocation: actionLocation,
                    triggerAction: triggerAction,
                    onChanged: onChanged,
                    onOptionsExpanded: onOptionsExpanded,
                    footerKey: ValueKey('action-footer-$index'),
                  )
                : const SizedBox(width: double.infinity),
          ),
          // Sits outside the AnimatedSize so its position tracks the row's
          // animating bottom edge, giving the SliverSmartAnchor a live target.
          if (anchorKey != null) SizedBox(key: anchorKey, height: 0),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.index,
    required this.meta,
    required this.isDirty,
    required this.triggerAction,
    required this.chips,
    required this.expanded,
    required this.onToggle,
    required this.onDuplicate,
    required this.onDelete,
  });

  final int index;
  final ActionMetaInfo meta;
  final bool isDirty;
  final TriggerAction triggerAction;
  final List<({String label, String value})> chips;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 8,
                    ),
                    child: Icon(
                      FLucideIcons.gripVertical,
                      size: 14,
                      color: colors.mutedForeground.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${index + 1}',
                    style: context.theme.typography.xs,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Row(
                children: [
                  // _IndexBadge(index: index),
                  const SizedBox(width: 12),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      meta.icon,
                      size: 17,
                      color: colors.secondaryForeground,
                    ),
                  ),
                  const SizedBox(width: 12),
                  UnsavedLabel(
                    isDirty: isDirty,
                    child: Text(
                      actionRowTitle(triggerAction.action),
                      style: typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      actionValueSummary(triggerAction.action),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ),
                  if (chips.isNotEmpty) ...[
                    const SizedBox(width: 14),
                    _MetaChips(chips: chips),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          FButton.icon(
            variant: .ghost,
            onPress: onToggle,
            child: Icon(
              expanded ? FLucideIcons.chevronUp : FLucideIcons.chevronDown,
            ),
          ),
          FButton.icon(
            variant: .ghost,
            onPress: onDelete,
            child: const Icon(FLucideIcons.trash),
          ),
        ],
      ),
    );
  }
}

class _MetaChips extends StatelessWidget {
  const _MetaChips({required this.chips});

  final List<({String label, String value})> chips;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final chip in chips)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${chip.label}: ',
                    style: typography.xs.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                  TextSpan(
                    text: chip.value,
                    style: typography.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExpandedEditor extends StatefulWidget {
  const _ExpandedEditor({
    required this.actionLocation,
    required this.triggerAction,
    required this.onChanged,
    required this.footerKey,
    this.onOptionsExpanded,
  });

  final ActionLocation actionLocation;
  final TriggerAction triggerAction;
  final void Function(TriggerAction) onChanged;
  final Key footerKey;
  final VoidCallback? onOptionsExpanded;

  @override
  State<_ExpandedEditor> createState() => _ExpandedEditorState();
}

class _ExpandedEditorState extends State<_ExpandedEditor> {
  late bool _optionsExpanded;

  @override
  void initState() {
    super.initState();
    _optionsExpanded = ActionTriggerFields.hasNonDefaultFields(
      widget.triggerAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container(height: 1, color: colors.border),
          const SizedBox(height: 8),
          ActionFields(
            actionLocation: widget.actionLocation,
            action: widget.triggerAction.action,
            onActionChanged: (action) =>
                widget.onChanged(widget.triggerAction.copyWith(action: action)),
          ),
          const SizedBox(height: 16),
          FAccordion(
            key: ValueKey(widget.actionLocation.actionIndex),
            control: FAccordionControl.lifted(
              expanded: (index) => index == 0 && _optionsExpanded,
              onChange: (index, expanded) {
                if (index != 0 || _optionsExpanded == expanded) return;
                setState(() => _optionsExpanded = expanded);
                if (expanded) widget.onOptionsExpanded?.call();
              },
            ),
            style: const .delta(
              dividerStyle: .delta(
                color: Colors.transparent,
                padding: .value(EdgeInsets.zero),
              ),
            ),
            children: [
              FAccordionItem(
                title: const Text('Other Options'),
                child: ActionTriggerFields(
                  actionLocation: widget.actionLocation,
                  triggerAction: widget.triggerAction,
                  onChanged: widget.onChanged,
                ),
              ),
            ],
          ),
          SizedBox(key: widget.footerKey, height: 1),
        ],
      ),
    );
  }
}
