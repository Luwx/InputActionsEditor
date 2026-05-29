import 'package:flutter/material.dart'
    show Dialog, Divider, InputBorder, InputDecoration, TextField;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

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

class _VariablePickerDialog extends StatefulWidget {
  const _VariablePickerDialog({required this.groups, this.currentVariable});
  final List<VariableGroup> groups;
  final String? currentVariable;

  @override
  State<_VariablePickerDialog> createState() => _VariablePickerDialogState();
}

class _VariablePickerDialogState extends State<_VariablePickerDialog> {
  String _query = '';

  List<({VariableGroup group, List<VariableInfo> variables})> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (final g in widget.groups)
        () {
          final vars = q.isEmpty
              ? g.variables
              : g.variables
                    .where(
                      (v) =>
                          v.pickerName.toLowerCase().contains(q) ||
                          v.name.toLowerCase().contains(q) ||
                          v.description.toLowerCase().contains(q),
                    )
                    .toList();
          return (group: g, variables: vars);
        }(),
    ].where((e) => e.variables.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final filtered = _filtered;

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
              onChanged: (v) => setState(() => _query = v),
              colors: colors,
              typography: typography,
            ),
            Divider(color: colors.border, height: 1),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                itemCount: filtered.fold<int>(
                  0,
                  (sum, e) => sum + 1 + e.variables.length,
                ),
                itemBuilder: (ctx, index) {
                  var offset = 0;
                  for (final entry in filtered) {
                    if (index == offset) {
                      return _GroupHeader(
                        group: entry.group,
                        colors: colors,
                        typography: typography,
                      );
                    }
                    offset++;
                    if (index < offset + entry.variables.length) {
                      final v = entry.variables[index - offset];
                      return _VariableItem(
                        info: v,
                        groupIcon: entry.group.icon,
                        isSelected: v.name == widget.currentVariable,
                        onTap: () => Navigator.of(ctx).pop(v),
                        colors: colors,
                        typography: typography,
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
    required this.colors,
    required this.typography,
  });

  final ValueChanged<String> onChanged;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
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
              style: typography.sm.copyWith(color: colors.foreground),
              cursorColor: colors.primary,
              decoration: InputDecoration(
                hintText: 'Search variables...',
                hintStyle: typography.sm.copyWith(
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
  const _GroupHeader({
    required this.group,
    required this.colors,
    required this.typography,
  });

  final VariableGroup group;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(group.icon, size: 13, color: colors.mutedForeground),
          const SizedBox(width: 6),
          Text(
            group.name.toUpperCase(),
            style: typography.xs.copyWith(
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
    required this.colors,
    required this.typography,
  });

  final VariableInfo info;
  final IconData groupIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final FColors colors;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, controller) => Text(
        '${info.label}\nType: ${info.type.typeName}',
      ),
      child: FItem(
        prefix: _TypeBadge(type: info.type, typography: typography),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                info.pickerName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Text(
          info.description,
          style: typography.xs.copyWith(color: colors.mutedForeground),
        ),
        onPress: onTap,
        selected: isSelected,
        suffix: isSelected ? const Icon(FLucideIcons.check) : null,
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type, required this.typography});

  final VarType type;
  final FTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      width: 42,
      child: Text(
        type.badge,
        textAlign: TextAlign.center,
        style: typography.xs.copyWith(
          color: type.fgColor,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          fontSize: 10,
        ),
      ),
    );
  }
}
