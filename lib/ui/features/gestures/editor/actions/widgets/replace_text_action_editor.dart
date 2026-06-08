import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/action_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class ReplaceTextActionEditor extends ConsumerWidget {
  const ReplaceTextActionEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final location = context.actionLocation;
    final vm = ref.watch(actionEditorProvider(location));
    final action = vm.action?.action;
    final rules = action is ReplaceTextAction
        ? action.rules
        : const <TextSubstitutionRule>[];
    final notifier = ref.read(actionEditorProvider(location).notifier);

    void replaceRules(List<TextSubstitutionRule> next) {
      notifier.replaceTextRules(next);
    }

    void addRule() {
      replaceRules([
        ...rules,
        const TextSubstitutionRule(
          regex: '',
          replace: LiteralTextReplacementValue(text: ''),
        ),
      ]);
    }

    void setRule(int index, TextSubstitutionRule rule) {
      replaceRules([
        ...rules.take(index),
        rule,
        ...rules.skip(index + 1),
      ]);
    }

    void removeRule(int index) {
      replaceRules([
        ...rules.take(index),
        ...rules.skip(index + 1),
      ]);
    }

    void reorderRule(int oldIndex, int newIndex) {
      if (oldIndex < 0 ||
          oldIndex >= rules.length ||
          newIndex < 0 ||
          newIndex >= rules.length) {
        return;
      }
      final next = [...rules];
      next.insert(newIndex, next.removeAt(oldIndex));
      replaceRules(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: LabelWithTooltip(
                label: l10n.actionReplaceTextRulesLabel,
                tooltipContent: const ActionReplaceTextTooltip(),
              ),
            ),
            FButton(
              variant: .outline,
              size: .sm,
              onPress: addRule,
              prefix: const Icon(FLucideIcons.plus),
              child: Text(l10n.actionReplaceTextAddRule),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.actionReplaceTextRulesHelp,
          style: context.theme.typography.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: context.theme.colors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(12),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: rules.length,
            onReorderItem: reorderRule,
            proxyDecorator: (child, index, animation) =>
                Material(color: Colors.transparent, child: child),
            itemBuilder: (context, index) {
              return Column(
                key: ValueKey('replace-text-rule-$index-${rules[index]}'),
                children: [
                  _ReplaceTextRuleEditor(
                    index: index,
                    rule: rules[index],
                    onChanged: (rule) => setRule(index, rule),
                    onRemove: () => removeRule(index),
                  ),
                  if (index < rules.length - 1) const FDivider(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ReplaceTextRuleEditor extends StatelessWidget {
  const _ReplaceTextRuleEditor({
    required this.index,
    required this.rule,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final TextSubstitutionRule rule;
  final ValueChanged<TextSubstitutionRule> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final replace = rule.replace;
    final replacementText = switch (replace) {
      LiteralTextReplacementValue(:final text) => text,
      CommandTextReplacementValue(:final command) => command,
    };
    final replacementMode = switch (replace) {
      LiteralTextReplacementValue() => _ReplacementMode.literal,
      CommandTextReplacementValue() => _ReplacementMode.command,
    };
    final valueKey = [
      'replace-text-value',
      index,
      replacementMode,
      replacementText,
    ].join('-');

    return DecoratedBox(
      decoration: const BoxDecoration(
        // border: Border.all(color: colors.border),
        // border: Border(bottom: BorderSide(color: colors.border)),
        // borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: FTextField(
                  key: ValueKey('replace-text-regex-$index-${rule.regex}'),
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: rule.regex),
                    onChange: (value) =>
                        onChanged(rule.copyWith(regex: value.text)),
                  ),
                  label: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                                  horizontal: 2,
                                  vertical: 2,
                                ),
                                child: Icon(
                                  FLucideIcons.gripVertical,
                                  size: 14,
                                  color: colors.mutedForeground.withValues(
                                    alpha: 0.55,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 8,
                                  bottom: 4,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: context.theme.typography.xs,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.actionReplaceTextRegexLabel),
                    ],
                  ),
                  hint: l10n.actionReplaceTextRegexHint,
                  style: .delta(
                    contentTextStyle: FVariantsDelta.delta([
                      FVariantOperation.all(
                        const TextStyleDelta.delta(fontFamily: 'monospace'),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: FButton.icon(
                  variant: .ghost,
                  onPress: onRemove,
                  child: const Icon(FLucideIcons.trash2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 160,
                child: FSelect<_ReplacementMode>(
                  key: ValueKey(
                    'replace-text-mode-$index-$replacementMode',
                  ),
                  label: Text(l10n.actionReplaceTextReplacementLabel),
                  items: {
                    l10n.actionReplaceTextTextMode: _ReplacementMode.literal,
                    l10n.actionReplaceTextCommandMode: _ReplacementMode.command,
                  },
                  control: FSelectManagedControl<_ReplacementMode>(
                    initial: replacementMode,
                    onChange: (mode) {
                      if (mode == null) return;
                      onChanged(
                        rule.copyWith(
                          replace: mode == _ReplacementMode.literal
                              ? LiteralTextReplacementValue(
                                  text: replacementText,
                                )
                              : CommandTextReplacementValue(
                                  command: replacementText,
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FTextField(
                  key: ValueKey(valueKey),
                  control: FTextFieldControl.managed(
                    initial: TextEditingValue(text: replacementText),
                    onChange: (value) => onChanged(
                      rule.copyWith(
                        replace: replacementMode == _ReplacementMode.literal
                            ? LiteralTextReplacementValue(text: value.text)
                            : CommandTextReplacementValue(
                                command: value.text,
                              ),
                      ),
                    ),
                  ),
                  label: replacementMode == _ReplacementMode.literal
                      ? Text(l10n.actionReplaceTextTextMode)
                      : LabelWithTooltip(
                          label: l10n.actionReplaceTextCommandMode,
                          tooltipContent:
                              const ActionReplaceTextCommandTooltip(),
                        ),
                  hint: replacementMode == _ReplacementMode.literal
                      ? l10n.actionReplaceTextTextHint
                      : l10n.actionReplaceTextCommandHint,
                  style: .delta(
                    contentTextStyle: FVariantsDelta.delta([
                      FVariantOperation.all(
                        const TextStyleDelta.delta(fontFamily: 'monospace'),
                      ),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _ReplacementMode { literal, command }
