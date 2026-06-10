import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/ui/common/extensions.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
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
    final pinnedFields = useState(initialAdvancedFields);
    final optionsExpanded = useState(false);
    final accordionFields = TriggerAdvancedField.values
        .where((field) => !pinnedFields.value.contains(field))
        .toList();
    final conflicts = ref.watch(conflictReportProvider).forGesture(location);

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
              style: context.theme.typography.sm.copyWith(
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
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
              child: TriggerAdvancedFields(fields: pinnedFields.value),
            ),
          FAccordion(
            key: ValueKey(location.editId),
            control: FAccordionControl.lifted(
              expanded: (index) => index == 0 && optionsExpanded.value,
              onChange: (index, exp) {
                if (index != 0 || optionsExpanded.value == exp) return;
                optionsExpanded.value = exp;
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
                child: TriggerAdvancedFields(
                  fields: accordionFields,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
              style: typography.sm.copyWith(fontWeight: FontWeight.w600),
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
              style: typography.xs.copyWith(
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
                style: context.theme.typography.xs.copyWith(
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
