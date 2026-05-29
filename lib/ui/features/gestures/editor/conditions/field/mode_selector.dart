import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    required this.mode,
    required this.onChanged,
    super.key,
  });

  final ConditionGroupMode mode;
  final void Function(ConditionGroupMode) onChanged;

  static String _format(ConditionGroupMode mode) => mode.name.toUpperCase();

  static String _subtitle(ConditionGroupMode mode) => switch (mode) {
    ConditionGroupMode.all => 'Every condition must match',
    ConditionGroupMode.any => 'At least one condition must match',
    ConditionGroupMode.none => 'No condition must match',
  };

  static IconData _icon(ConditionGroupMode mode) => switch (mode) {
    ConditionGroupMode.all => FLucideIcons.checkCheck,
    ConditionGroupMode.any => FLucideIcons.check,
    ConditionGroupMode.none => FLucideIcons.ban,
  };

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return SizedBox(
      width: 96,
      child: FSelect<ConditionGroupMode>.rich(
        format: _format,
        canRequestFocus: false,
        control: FSelectControl<ConditionGroupMode>.lifted(
          value: mode,
          onChange: (value) {
            if (value != null) onChanged(value);
          },
        ),
        contentConstraints: const FPortalConstraints(
          minWidth: 240,
          maxWidth: 320,
          maxHeight: 300,
        ),
        children: [
          for (final value in ConditionGroupMode.values)
            FSelectItem<ConditionGroupMode>.item(
              value: value,
              title: Text(
                _format(value),
                style: typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(_subtitle(value), style: typography.xs),
              prefix: Icon(_icon(value), size: 14),
            ),
        ],
      ),
    );
  }
}
