import 'package:flutter/material.dart'
    show Dialog, Divider, InputBorder, InputDecoration, TextField;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog_l10n.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/condition_labels.dart';

Future<VariableInfo?> showVariablePicker(
  BuildContext context, {
  String? currentVariable,
  List<VariableGroup>? groups,
}) {
  return showFDialog<VariableInfo>(
    context: context,
    useRootNavigator: true,
    builder: (ctx, _, _) => FTheme(
      data: FTheme.of(context),
      child: _VariablePickerDialog(
        groups: groups ?? kVariableGroups,
        currentVariable: currentVariable,
      ),
    ),
  );
}

class _VariablePickerDialog extends HookWidget {
  const _VariablePickerDialog({required this.groups, this.currentVariable});
  final List<VariableGroup> groups;
  final String? currentVariable;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = useState('');

    List<({VariableGroup group, List<VariableInfo> variables})> filtered() {
      final q = query.value.trim().toLowerCase();
      return [
        for (final g in groups)
          () {
            final vars = q.isEmpty
                ? g.variables
                : g.variables
                      .where(
                        (v) =>
                            v.localizedLabel(l10n).toLowerCase().contains(q) ||
                            v.name.toLowerCase().contains(q) ||
                            v.description.toLowerCase().contains(q),
                      )
                      .toList();
            return (group: g, variables: vars);
          }(),
      ].where((e) => e.variables.isNotEmpty).toList();
    }

    final colors = context.theme.colors;
    final filteredList = filtered();

    return Dialog(
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 580),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchBar(
              onChanged: (v) => query.value = v,
            ),
            Divider(color: colors.border, height: 1),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                itemCount: filteredList.fold<int>(
                  0,
                  (sum, e) => sum + 1 + e.variables.length,
                ),
                itemBuilder: (ctx, index) {
                  var offset = 0;
                  for (final entry in filteredList) {
                    if (index == offset) {
                      return _GroupHeader(group: entry.group);
                    }
                    offset++;
                    if (index < offset + entry.variables.length) {
                      final v = entry.variables[index - offset];
                      return _VariableItem(
                        info: v,
                        groupIcon: entry.group.icon,
                        isSelected: v.name == currentVariable,
                        onTap: () => Navigator.of(ctx).pop(v),
                      );
                    }
                    offset += entry.variables.length;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(FLucideIcons.search, size: 16, color: colors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              autofocus: true,
              onChanged: onChanged,
              style: typography.body.sm.copyWith(color: colors.foreground),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                hintText: 'Search variables...',
                hintStyle: typography.body.sm.copyWith(
                  color: colors.mutedForeground,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          FButton.icon(
            size: .xs,
            variant: .ghost,
            onPress: () => Navigator.of(context).pop(),
            child: const Icon(FLucideIcons.x, size: 16),
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group});

  final VariableGroup group;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(group.icon, size: 13, color: colors.mutedForeground),
          const SizedBox(width: 6),
          Text(
            group.localizedName(context.l10n).toUpperCase(),
            style: typography.body.xs.copyWith(
              color: colors.mutedForeground,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariableItem extends StatelessWidget {
  const _VariableItem({
    required this.info,
    required this.groupIcon,
    required this.isSelected,
    required this.onTap,
  });

  final VariableInfo info;
  final IconData groupIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return FTooltip(
      tipBuilder: (context, controller) => Text(
        '${info.localizedLabel(context.l10n)}\n'
        'Type: ${info.type.typeName(context.l10n)}',
      ),
      child: FItem(
        prefix: _TypeBadge(type: info.type),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                info.localizedLabel(context.l10n),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          info.description,
          style: typography.body.xs.copyWith(color: colors.mutedForeground),
        ),
        onPress: onTap,
        selected: isSelected,
        suffix: isSelected ? const Icon(FLucideIcons.check) : null,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final ConditionValueType type;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      width: 42,
      child: Text(
        type.badge(context.l10n),
        textAlign: TextAlign.center,
        style: typography.body.xs.copyWith(
          color: type.fgColor,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          fontSize: 10,
        ),
      ),
    );
  }
}
