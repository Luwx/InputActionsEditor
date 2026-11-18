import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Edits one menu item through the generated menu item lenses.
class MenuItemDetail extends ConsumerWidget {
  const MenuItemDetail({
    required this.location,
    required this.item,
    required this.onShowActions,
    this.focusText = false,
    super.key,
  });

  final MenuItemLocation location;
  final MenuItem? item;
  final VoidCallback onShowActions;
  final bool focusText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final muted = context.theme.typography.body.sm.copyWith(
      color: colors.mutedForeground,
    );

    EditableField<T> field<T>(Lens<Config, T> lens, T Function() fallback) =>
        ref.field<T>(
          lens,
          scope: const GesturesScope(),
          fallbackValue: fallback,
          canRead: (config) => menuItemAt(config, location) != null,
        );

    Widget textField(Lens<Config, String> lens) {
      final text = field<String>(lens, () => '');
      return _TextField(
        label: l10n.actionContextMenuTextLabel,
        text: text.value,
        onChanged: text.onChanged,
        autofocus: focusText,
      );
    }

    Widget iconField(Lens<Config, String?> lens) {
      final icon = field<String?>(lens, () => null);
      return _TextField(
        label: l10n.actionContextMenuIconLabel,
        hint: l10n.actionContextMenuIconHint,
        text: icon.value ?? '',
        onChanged: (value) => icon.onChanged(value.isEmpty ? null : value),
      );
    }

    return switch (item) {
      null => Text(l10n.actionContextMenuEmpty, style: muted),
      ActionMenuItem(:final actions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField(menuItemTextLens(location)),
          const SizedBox(height: 12),
          iconField(menuItemIconLens(location)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.actionContextMenuActionsLabel}: '
                  '${l10n.actionGroupSummary(actions.length)}',
                  style: muted,
                ),
              ),
              FButton(
                variant: .outline,
                size: .sm,
                onPress: onShowActions,
                prefix: const Icon(FLucideIcons.panelRight, size: 14),
                child: Text(l10n.actionContextMenuShowActions),
              ),
            ],
          ),
        ],
      ),
      SubMenuItem() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textField(menuItemSubMenuTextLens(location)),
          const SizedBox(height: 12),
          iconField(menuItemSubMenuIconLens(location)),
        ],
      ),
      SectionMenuItem() => textField(menuItemSectionTextLens(location)),
      SeparatorMenuItem() => Text(
        l10n.actionContextMenuSeparatorLabel,
        style: muted,
      ),
    };
  }
}

class _TextField extends HookWidget {
  const _TextField({
    required this.label,
    required this.text,
    required this.onChanged,
    this.hint,
    this.autofocus = false,
  });

  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  final String? hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final controller = useSyncedTextController(
      text,
      (value) => onChanged(value.text),
    );
    return FTextField(
      control: FTextFieldControl.managed(controller: controller),
      label: Text(label),
      hint: hint,
      autofocus: autofocus,
    );
  }
}
