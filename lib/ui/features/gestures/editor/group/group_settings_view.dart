import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/projections/inheritance_provider.dart';
import 'package:input_actions_editor/projections/reveal_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/card_footer.dart';
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/common/staggered_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_offers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/widgets/group_trigger_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/lock_pointer_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/speed_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/widgets/renameable_title.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for the properties every gesture in a group inherits.
class GroupSettingsView extends HookConsumerWidget {
  const GroupSettingsView({required this.location, super.key});

  final GestureGroupLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.theme.colors;

    ref.watch(revealPaneProvider(location));
    final group = ref.watch(
      draftConfigProvider.select((config) => gestureGroupAt(config, location)),
    );
    // The group can vanish under us (deleted, or broken down from the list).
    if (group == null) return const SizedBox.shrink();

    final inheritedConditions = ref.watch(
      groupInheritedConditionsProvider(location),
    );
    final pinned = useState({
      ...TriggerAdvancedFields.nonDefaultGroupFields(group),
      if (inheritedConditions.isNotEmpty) TriggerAdvancedField.conditions,
    });
    final optionsExpanded = useState(true);
    final speed = offersSpeed(group) ? const SpeedField() : null;
    final lockPointer = offersLockPointer(group)
        ? const LockPointerField()
        : null;
    final pinSpeed = useState(group.speed != null);
    final pinLockPointer = useState(group.lockPointer != null);
    final bodySpeed = pinSpeed.value ? speed : null;
    final bodyLockPointer = pinLockPointer.value ? lockPointer : null;
    final foldedSpeed = pinSpeed.value ? null : speed;
    final foldedLockPointer = pinLockPointer.value ? null : lockPointer;

    final pinnedFields = TriggerAdvancedField.values
        .where(pinned.value.contains)
        .toList();
    final accordionFields = TriggerAdvancedField.values
        .where((field) => !pinned.value.contains(field))
        .toList();
    final hasFolded =
        accordionFields.isNotEmpty ||
        foldedSpeed != null ||
        foldedLockPointer != null;

    final revealed = ref.watch(revealedGroupFieldsProvider(location));
    useEffect(() {
      if (accordionFields.any(
            (field) => revealed.contains(field.groupDirtyField),
          ) ||
          (foldedSpeed != null &&
              revealed.contains(ConfigDirtyField.gestureGroupSpeed)) ||
          (foldedLockPointer != null &&
              revealed.contains(ConfigDirtyField.gestureGroupLockPointer))) {
        optionsExpanded.value = true;
      }
      return null;
    }, [revealed]);

    final body = SectionCard(
      color: colors.card.withValues(alpha: 0.55),
      title: l10n.triggerConfigTitle,
      padding: const EdgeInsets.all(16),
      footer: !hasFolded
          ? null
          : CardFooter(
              expanded: optionsExpanded.value,
              child: CollapsibleSection(
                title: Text(l10n.triggerOtherOptions),
                expanded: optionsExpanded.value,
                onExpanded: (expanded) => optionsExpanded.value = expanded,
                child: StaggeredBuild(
                  immediate: optionsExpanded.value,
                  child: TriggerAdvancedFields(
                    fields: accordionFields,
                    inheritedConditions: inheritedConditions,
                    speed: foldedSpeed,
                    lockPointer: foldedLockPointer,
                  ),
                ),
              ),
            ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.groupSettingsDescription,
            style: context.theme.typography.body.xs.copyWith(
              color: colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          GroupTriggerFields(device: location.device, group: group),
          if (pinnedFields.isNotEmpty ||
              bodySpeed != null ||
              bodyLockPointer != null)
            TriggerAdvancedFields(
              fields: pinnedFields,
              inheritedConditions: inheritedConditions,
              speed: bodySpeed,
              lockPointer: bodyLockPointer,
            ),
        ],
      ),
    );

    return EditLocationScope(
      group: location,
      child: ScrollbarMediaPadding(
        topInset: GrowingFrostedHeaderDelegate.maxHeight,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: GrowingFrostedHeaderDelegate(
                titleBuilder: (style) => RenameableTitle(
                  name: group.name.isEmpty
                      ? l10n.gestureGroupUnnamed
                      : group.name,
                  editingName: group.name,
                  titleStyle: style,
                  onRename: (name) => ref
                      .read(gestureCommandsProvider)
                      .updateGroup(
                        location,
                        (g) => g.copyWith(name: name.trim()),
                      ),
                ),
                subtitle: l10n.groupSettingsSubtitle(
                  _gestureCount(group),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: FButton.icon(
                    variant: .ghost,
                    size: .sm,
                    onPress: ref.read(selectedGroupProvider.notifier).close,
                    child: const Icon(FLucideIcons.arrowLeft),
                  ),
                ),
                horizontalPadding: 8,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverToBoxAdapter(child: body),
            ),
          ],
        ),
      ),
    );
  }

  static int _gestureCount(GestureGroupNode group) => group.gestures.length;
}
