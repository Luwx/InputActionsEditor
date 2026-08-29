import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/projections/inheritance_provider.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/card_footer.dart';
import 'package:input_actions_editor/ui/common/collapsible.dart';
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/common/extensions.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/common/staggered_build.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class TriggerEditor extends HookConsumerWidget {
  const TriggerEditor({
    required this.sections,
    required this.initialAdvancedFields,
    this.dirtyState,
    this.onRevert,
    super.key,
  });

  final List<Widget> sections;
  final Set<TriggerAdvancedField> initialAdvancedFields;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final inherited = _byField(
      ref.watch(gestureInheritedPropertiesProvider(location)),
    );
    final inheritedConditions = ref.watch(
      gestureInheritedConditionsProvider(location),
    );
    // An inherited property is worth seeing even when the gesture leaves it
    // unset, so it joins the pinned set rather than hiding in the accordion.
    final pinnedFields = useState({
      ...initialAdvancedFields,
      ...inherited.keys,
      if (inheritedConditions.isNotEmpty) TriggerAdvancedField.conditions,
    });
    final optionsExpanded = useState(false);
    final optionsEndKey = useMemoized(GlobalKey.new);
    final accordionFields = TriggerAdvancedField.values
        .where((field) => !pinnedFields.value.contains(field))
        .toList();
    final reveal = ref.watch(editRevealProvider);
    useEffect(() {
      if (reveal == null || reveal.gesture != location) return null;
      final changed = changedGestureFields(
        reveal.before,
        reveal.after,
        location,
      );
      if (accordionFields.any((field) => changed.contains(field.dirtyField))) {
        optionsExpanded.value = true;
      }
      return null;
    }, [reveal]);
    final conflicts = ref.watch(conflictReportProvider).forGesture(location);

    void openGroup(int editId) {
      ref
          .read(selectedGroupProvider.notifier)
          .open(
            GestureGroupLocation(device: location.device, editId: editId),
          );
    }

    return SectionCard(
      color: context.theme.colors.card.withValues(alpha: 0.55),
      titleWidget: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UnsavedLabel(
            state: dirtyState,
            onRevert: onRevert,
            child: Text(
              context.l10n.triggerConfigTitle,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _TriggerConflictBadge(
            key: ValueKey('trigger-conflict-${conflicts.length}'),
            conflicts: conflicts,
            focus: location,
            onJump: context.redirectToGesture,
          ).appearToggle(
            visible: conflicts.isNotEmpty,
            duration: Durations.short3,
            axis: Axis.horizontal,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      footer: CardFooter(
        expanded: optionsExpanded.value,
        child: CollapsibleSection(
          key: ValueKey(location.editId),
          title: Text(context.l10n.triggerOtherOptions),
          expanded: optionsExpanded.value,
          onExpanded: (expanded) {
            optionsExpanded.value = expanded;
            if (expanded) _revealOptionsEnd(optionsEndKey);
          },
          childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StaggeredBuild(
                immediate: optionsExpanded.value,
                delay: const Duration(milliseconds: 800),
                child: TriggerAdvancedFields(
                  fields: accordionFields,
                  inherited: inherited,
                  inheritedConditions: inheritedConditions,
                  onOpenGroup: openGroup,
                ),
              ),
              SizedBox(key: optionsEndKey, height: 16),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
        children: [
          // for (final section in sections) section,
          Column(
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: sections,
          ),
          if (pinnedFields.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: TriggerAdvancedFields(
                fields: pinnedFields.value,
                inherited: inherited,
                inheritedConditions: inheritedConditions,
                onOpenGroup: openGroup,
              ),
            ),
        ],
      ),
    );
  }
}

void _revealOptionsEnd(GlobalKey marker) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final end = marker.currentContext;
    if (end == null) return;
    unawaited(
      Scrollable.ensureVisible(
        end,
        alignment: 1,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        duration: collapsibleDuration,
        curve: Easing.standard,
      ),
    );
  });
}

/// Indexes inherited properties by the field that renders them. Conditions are
/// absent by construction: the daemon AND-merges those, so a group condition is
/// never in tension with a gesture's own.
Map<TriggerAdvancedField, InheritedProperty> _byField(
  List<InheritedProperty> inherited,
) => {
  for (final property in inherited)
    triggerAdvancedFieldFor(property.property): property,
};

class _TriggerConflictBadge extends StatelessWidget {
  const _TriggerConflictBadge({
    required this.conflicts,
    required this.focus,
    required this.onJump,
    super.key,
  });

  final List<GestureConflict> conflicts;
  final GestureRef focus;
  final void Function(GestureRef) onJump;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 340),
      builder: (context, controller, child) => GestureDetector(
        onTap: controller.toggle,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
      popoverBuilder: (context, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.conflictsTitle,
              style: typography.body.sm.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            for (final conflict in conflicts)
              _TriggerConflictRow(
                text: conflict.describeFrom(focus),
                onTap: () async {
                  onJump(conflict.other(focus));
                  await controller.hide();
                },
              ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: kGestureWarningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: kGestureWarningColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              FLucideIcons.triangleAlert,
              size: 12,
              color: kGestureWarningColor,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.conflictCount(conflicts.length),
              style: typography.body.xs.copyWith(
                fontWeight: FontWeight.w600,
                color: kGestureWarningColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriggerConflictRow extends StatelessWidget {
  const _TriggerConflictRow({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 8),
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: kGestureWarningColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                style: context.theme.typography.body.xs.copyWith(
                  color: colors.foreground,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              FLucideIcons.chevronRight,
              size: 13,
              color: colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
