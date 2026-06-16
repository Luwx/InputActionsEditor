import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/domain/edit/edits/device_rule_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/device_variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';
import 'package:input_actions_editor/ui/features/settings/device_rule_properties_form.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class DeviceRulesEditor extends ConsumerWidget {
  const DeviceRulesEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final config = ref.watch(draftConfigProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final controller = ref.read(configControllerProvider.notifier);

    final rules = config.deviceRules;
    final rulesDirtyState = ref.watch(
      rootConfigDirtyStateProvider(RootConfigDirtyField.deviceRules),
    );
    final savedConfig = ref.watch(savedConfigProvider);

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(
            title: l10n.deviceRulesTitle,
            titleBuilder: (style) => UnsavedLabel(
              state: rulesDirtyState,
              onRevert: savedConfig == null || savedConfig.deviceRules.isEmpty
                  ? null
                  : () => controller.add(
                      ReplaceDeviceRules(savedConfig.deviceRules),
                    ),
              child: Text(
                l10n.deviceRulesTitle,
                style: style,
              ),
            ),
            subtitle: l10n.deviceRulesSubtitle(rules.length),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                FButton(
                  variant: .outline,
                  size: .sm,
                  onPress: () =>
                      controller.add(AddDeviceRule(const DeviceRule())),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 6,
                    children: [
                      const Icon(FLucideIcons.plus),
                      Text(l10n.actionAddRule),
                    ],
                  ),
                ),
                const ScopedSaveActions(scope: SaveScope.settings),
              ],
            ),
          ),
          if (rules.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Text(
                      l10n.deviceRulesEmpty,
                      style: typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.deviceRulesEmptyDescription,
                      textAlign: TextAlign.center,
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FButton(
                      variant: .outline,
                      size: .sm,
                      onPress: () =>
                          controller.add(AddDeviceRule(const DeviceRule())),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 6,
                        children: [
                          const Icon(FLucideIcons.plus),
                          Text(l10n.actionAddRule),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList.separated(
                itemCount: rules.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _DeviceRuleCard(
                  key: ValueKey(i),
                  index: i,
                  rule: rules[i],
                  onChanged: (r) =>
                      controller.add(UpdateDeviceRule(i, (_) => r)),
                  onDelete: () => controller.add(RemoveDeviceRule(i)),
                  colors: colors,
                  typography: typography,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceRuleCard extends ConsumerWidget {
  const _DeviceRuleCard({
    required this.index,
    required this.rule,
    required this.onChanged,
    required this.onDelete,
    required this.colors,
    required this.typography,
    super.key,
  });

  final int index;
  final DeviceRule rule;
  final void Function(DeviceRule) onChanged;
  final VoidCallback onDelete;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final condLabel = _conditionLabel(rule.conditions, l10n);
    final conditionsField = ref.field(
      deviceRuleConditionsLens(DeviceRuleLocation(deviceRuleIndex: index)),
      fallbackValue: () => rule.conditions,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              children: [
                Text(
                  l10n.deviceRuleHeader(index + 1),
                  style: typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.mutedForeground,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    condLabel,
                    style: typography.sm,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FButton.icon(
                  variant: .ghost,
                  size: .sm,
                  onPress: onDelete,
                  child: Icon(FLucideIcons.trash2, color: colors.destructive),
                ),
              ],
            ),
          ),
          Container(height: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: ConditionEditor.generic(
              condition: conditionsField.value,
              onConditionChanged: conditionsField.onChanged,
              title: l10n.deviceConditionsTitle,
              groups: kDeviceVariableGroups,
            ),
          ),
          Container(height: 1, color: colors.border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: DeviceRulePropertiesForm(
              ruleIndex: index,
              properties: rule.properties,
              onChanged: (p) => onChanged(rule.copyWith(properties: p)),
              colors: colors,
              typography: typography,
            ),
          ),
        ],
      ),
    );
  }

  String _conditionLabel(Condition? c, AppLocalizations l10n) {
    if (c == null) return l10n.deviceRuleNoConditions;
    if (c is VariableCondition) {
      final value = conditionValueToText(c.value);
      return '${c.negate ? '!' : ''}\$${conditionVariableName(c.variable)} '
          '${conditionOperatorToken(c.operator)} $value';
    }
    if (c is ConditionGroup) {
      return '${c.mode.name} (${c.children.length} conditions)';
    }
    if (c is RawCondition) return c.raw;
    return l10n.deviceRuleConditionsSet;
  }
}
