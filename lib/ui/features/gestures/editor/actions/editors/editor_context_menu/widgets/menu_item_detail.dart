import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/ui/common/icon_picker/icon_picker_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_item_icon.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_meta.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_summary.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

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
      return _IconPickerField(
        label: l10n.actionContextMenuIconLabel,
        hint: l10n.iconPickerNoIcon,
        name: icon.value,
        onPick: () => showIconPickerDialog(
          context,
          selected: icon.value,
          onSelected: icon.onChanged,
        ),
      );
    }

    Widget textAndIcon(
      Lens<Config, String> textLens,
      Lens<Config, String?> iconLens,
    ) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: iconField(iconLens)),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: textField(textLens)),
      ],
    );

    return switch (item) {
      null => Text(l10n.actionContextMenuEmpty, style: muted),
      ActionMenuItem(:final actions) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textAndIcon(menuItemTextLens(location), menuItemIconLens(location)),
          const SizedBox(height: 12),
          _ActionsTile(actions: actions, onPress: onShowActions),
        ],
      ),
      SubMenuItem() => textAndIcon(
        menuItemSubMenuTextLens(location),
        menuItemSubMenuIconLens(location),
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
    this.autofocus = false,
  });

  final String label;
  final String text;
  final ValueChanged<String> onChanged;
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
      autofocus: autofocus,
    );
  }
}

class _IconPickerField extends HookWidget {
  const _IconPickerField({
    required this.label,
    required this.hint,
    required this.name,
    required this.onPick,
  });

  final String label;
  final String hint;
  final String? name;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final controller = useSyncedTextController(name ?? '', (_) {});
    return FTextField(
      control: FTextFieldControl.managed(controller: controller),
      label: Text(label),
      hint: hint,
      readOnly: true,
      mouseCursor: SystemMouseCursors.click,
      onTap: onPick,
      prefixBuilder: (context, style, states) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 10),
        child: MenuItemIcon(
          name: name,
          fallback: const Icon(FLucideIcons.image, size: 16),
        ),
      ),
    );
  }
}

class _ActionsTile extends StatelessWidget {
  const _ActionsTile({required this.actions, required this.onPress});

  final List<TriggerAction> actions;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = context.theme.colors.mutedForeground;
    final subtitleStyle = context.theme.typography.body.xs.copyWith(
      color: muted,
    );
    return FTile(
      onPress: onPress,
      title: Text(l10n.actionGroupSummary(actions.length)),
      subtitle: actions.isEmpty
          ? Text(l10n.actionSummaryNoAction, style: subtitleStyle)
          : Text.rich(
              TextSpan(
                children: [
                  for (final (index, action) in actions.indexed) ...[
                    if (index > 0) const TextSpan(text: ', '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Icon(
                          actionMeta(action.action, l10n).icon,
                          size: 11,
                          color: muted,
                        ),
                      ),
                    ),
                    TextSpan(text: actionLineSummary(action.action, l10n)),
                  ],
                ],
              ),
              style: subtitleStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      suffix: const Icon(FLucideIcons.chevronRight),
    );
  }
}
