import 'dart:async' show unawaited;

import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/add_action_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// An alternative to [ActionsEditor]: a reorderable list of collapsible action
/// rows. Collapsed rows show a one-line summary plus chips for any non-default
/// trigger options; expanding a row reveals the full editor.
class ActionListEditor extends HookConsumerWidget {
  const ActionListEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(<int>{});
    final anchorKey = useMemoized(GlobalKey.new);
    final bottomKey = useMemoized(GlobalKey.new);
    final anchorIndex = useState<int?>(null);
    final anchorRef = useRef<ScrollAnchorController?>(null)
      ..value = ScrollAnchorScope.maybeOf(context);

    List<TriggerAction> actionsFromDraft() =>
        ref.read(actionListEditorProvider(context.gestureLocation)).actions;

    void measureBelowExtent() {
      final anchorBox = anchorKey.currentContext?.findRenderObject();
      final bottomBox = bottomKey.currentContext?.findRenderObject();
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
      anchorRef.value?.belowExtent = gap < 0 ? 0 : gap;
    }

    void clearAnchor() {
      anchorIndex.value = null;
      anchorRef.value
        ?..isAnchoring = false
        ..belowExtent = null;
    }

    void beginAnchor(int index) {
      anchorIndex.value = index;
      final anchor = anchorRef.value;
      if (anchor == null) return;
      anchor
        ..belowExtent = null
        ..isAnchoring = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => measureBelowExtent());
    }

    void endAnchor() => anchorRef.value?.isAnchoring = false;

    void toggle(int index) {
      final isExpanding = !expanded.value.contains(index);
      final next = Set<int>.from(expanded.value);
      if (!next.add(index)) {
        next.remove(index);
        if (anchorIndex.value == index) clearAnchor();
      }
      expanded.value = next;
      if (isExpanding) beginAnchor(index);
    }

    void remove(int index) {
      final actions = actionsFromDraft();
      if (index < 0 || index >= actions.length) return;
      final next = <int>{};
      for (final e in expanded.value) {
        if (e == index) continue;
        next.add(e > index ? e - 1 : e);
      }
      expanded.value = next;
      clearAnchor();
      ref
          .read(actionListEditorProvider(context.gestureLocation).notifier)
          .remove(index);
    }

    void duplicate(int index) {
      final current = actionsFromDraft();
      if (index < 0 || index >= current.length) return;
      final next = <int>{};
      for (final e in expanded.value) {
        next.add(e > index ? e + 1 : e);
      }
      expanded.value = next;
      clearAnchor();
      ref
          .read(actionListEditorProvider(context.gestureLocation).notifier)
          .duplicate(index);
    }

    void add(Action action) {
      final newIndex = actionsFromDraft().length;
      ref
          .read(actionListEditorProvider(context.gestureLocation).notifier)
          .add(action);
      expanded.value = {...expanded.value, newIndex};
      clearAnchor();
      // AnimatedSize renders new rows at full size immediately (no prior state
      // to animate from), so the anchor mechanism won't fire.
      // Scroll explicitly.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = bottomKey.currentContext;
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

    int remapIndex(int e, int from, int to) {
      if (e == from) return to;
      if (from < to) {
        if (e > from && e <= to) return e - 1;
      } else if (e >= to && e < from) {
        return e + 1;
      }
      return e;
    }

    void reorder(int oldIndex, int newIndex) {
      final actions = actionsFromDraft();
      if (oldIndex < 0 ||
          oldIndex >= actions.length ||
          newIndex < 0 ||
          newIndex >= actions.length) {
        return;
      }
      final next = <int>{};
      for (final e in expanded.value) {
        next.add(remapIndex(e, oldIndex, newIndex));
      }
      expanded.value = next;
      clearAnchor();
      ref
          .read(actionListEditorProvider(context.gestureLocation).notifier)
          .reorder(oldIndex, newIndex);
    }

    Future<void> pickAndAdd() async {
      final action = await showAddActionDialog(context);
      if (action != null) add(action);
    }

    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final gestureLocation = context.gestureLocation;
    final count = ref.watch(
      actionListEditorProvider(
        gestureLocation,
      ).select((vm) => vm.actions.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        _ActionsHeader(location: gestureLocation),
        const SizedBox(height: 8),
        if (count == 0)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.l10n.actionsEmpty,
              style: typography.sm.copyWith(color: colors.mutedForeground),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: count,
            onReorderItem: reorder,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              return _ActionRow(
                key: ValueKey('action-row-$index'),
                gestureLocation: gestureLocation,
                index: index,
                expanded: expanded.value.contains(index),
                onToggle: () => toggle(index),
                onOptionsExpanded: () => beginAnchor(index),
                onAnchorSettled: endAnchor,
                anchorKey: index == anchorIndex.value ? anchorKey : null,
                onDuplicate: () => duplicate(index),
                onDelete: () => remove(index),
              );
            },
          ),
        const SizedBox(height: 4),
        FButton(
          variant: .outline,
          onPress: pickAndAdd,
          prefix: const Icon(FLucideIcons.plus, size: 14),
          child: Text(context.l10n.actionAdd),
        ),
        SizedBox(key: bottomKey, height: 0),
      ],
    );
  }
}

class _ActionsHeader extends ConsumerWidget {
  const _ActionsHeader({required this.location});

  final GestureLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyState = ref.watch(
      actionListEditorProvider(location).select((vm) => vm.dirtyState),
    );
    final canRevert = ref.watch(
      actionListEditorProvider(
        location,
      ).select((vm) => vm.savedActions != null),
    );

    return Row(
      children: [
        UnsavedLabel(
          state: dirtyState,
          onRevert: !canRevert
              ? null
              : () => ref
                    .read(actionListEditorProvider(location).notifier)
                    .revert(),
          child: Text(
            context.l10n.actionsTitle,
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.gestureLocation,
    required this.index,
    required this.expanded,
    required this.onToggle,
    required this.onOptionsExpanded,
    required this.onAnchorSettled,
    required this.onDuplicate,
    required this.onDelete,
    this.anchorKey,
    super.key,
  });

  /// Passed explicitly rather than read from context: while a row is being
  /// dragged, [ReorderableListView] reparents it under the app [Overlay],
  /// detaching it from the [EditLocationScope] ancestor.
  final GestureLocation gestureLocation;
  final int index;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onOptionsExpanded;

  /// Invoked when this row's expand animation settles, so the enclosing
  /// [SliverSmartAnchor] can stop correcting the scroll offset.
  final VoidCallback onAnchorSettled;

  /// Zero-height marker placed just below the growing region when this row is
  /// the active anchor; consumed by the [SliverSmartAnchor] above it.
  final GlobalKey? anchorKey;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final actionLocation = ActionLocation(
      gesture: gestureLocation,
      actionIndex: index,
    );

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
            actionLocation: actionLocation,
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
                ? EditLocationScope(
                    action: actionLocation,
                    child: _ExpandedEditor(
                      onOptionsExpanded: onOptionsExpanded,
                      footerKey: ValueKey('action-footer-$index'),
                    ),
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

class _Header extends HookConsumerWidget {
  const _Header({
    required this.index,
    required this.actionLocation,
    required this.expanded,
    required this.onToggle,
    required this.onDuplicate,
    required this.onDelete,
  });

  final int index;
  final ActionLocation actionLocation;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTitleHovered = useState(false);
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final action = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.action),
    );
    final isDirty = ref.watch(actionDirtyProvider(actionLocation));
    if (action == null) return const SizedBox.shrink();
    final meta = actionMeta(action.action, l10n);
    final chips = actionMetaChips(action, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: MouseRegion(
        onEnter: (_) => isTitleHovered.value = true,
        onExit: (_) => isTitleHovered.value = false,
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
                        actionRowTitle(action.action, l10n),
                        style: typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: isTitleHovered.value
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          decorationColor: colors.foreground.withValues(
                            alpha: 0.5,
                          ),
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        actionValueSummary(action.action, l10n),
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
            // TODO(me): disable checkbox
            const FCheckbox(
              value: true,
              enabled: false,
            ),
          ],
        ),
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

class _ExpandedEditor extends HookConsumerWidget {
  const _ExpandedEditor({
    required this.footerKey,
    this.onOptionsExpanded,
  });

  final Key footerKey;
  final VoidCallback? onOptionsExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionLocation = context.actionLocation;
    final kind = ref.watch(
      actionEditorProvider(actionLocation).select((vm) => vm.kind),
    );
    final optionsExpanded = useState(
      ref
          .read(actionEditorProvider(actionLocation))
          .hasNonDefaultTriggerOptions,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          ActionFields(kind: kind),
          const SizedBox(height: 16),
          FAccordion(
            key: ValueKey(actionLocation.actionIndex),
            control: FAccordionControl.lifted(
              expanded: (index) => index == 0 && optionsExpanded.value,
              onChange: (index, exp) {
                if (index != 0 || optionsExpanded.value == exp) return;
                optionsExpanded.value = exp;
                if (exp) onOptionsExpanded?.call();
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
                title: Text(context.l10n.triggerOtherOptions),
                child: const ActionTriggerFields(),
              ),
            ],
          ),
          SizedBox(key: footerKey, height: 1),
        ],
      ),
    );
  }
}
