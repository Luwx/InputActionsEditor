import 'package:flutter/material.dart' hide Action;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

Future<void> showMenuActionsSheet(
  BuildContext context, {
  required MenuItemLocation item,
}) {
  final container = ProviderScope.containerOf(context);
  return showFSheet<void>(
    context: context,
    side: FLayout.rtl,
    mainAxisMaxRatio: null,
    draggable: false,
    builder: (sheetContext) => UncontrolledProviderScope(
      container: container,
      child: _MenuActionsSheet(item: item),
    ),
  );
}

class _MenuActionsSheet extends StatelessWidget {
  const _MenuActionsSheet({required this.item});

  final MenuItemLocation item;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(left: BorderSide(color: colors.border)),
      ),
      child: SizedBox(
        width: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 12),
                const Icon(FLucideIcons.panelRight, size: 24),
                const SizedBox(width: 8),
                Text(
                  context.l10n.actionContextMenuActionsLabel,
                  style: context.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                FButton.icon(
                  variant: .ghost,
                  size: .xs,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Icon(FLucideIcons.x),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: EditLocationScope(
                  gesture: item.action.gesture,
                  child: ActionListScope(
                    source: ActionSource.menuItem(item),
                    child: const ActionListEditor(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
