import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_browser.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

Future<void> showIconPickerDialog(
  BuildContext context, {
  required String? selected,
  required ValueChanged<String?> onSelected,
}) async {
  final container = ProviderScope.containerOf(context);
  final result = await showFDialog<({String? name})>(
    context: context,
    builder: (context, style, animation) => UncontrolledProviderScope(
      container: container,
      child: IconPickerDialog(
        selected: selected,
        animation: animation,
        onSelected: (name) => Navigator.of(context).pop((name: name)),
      ),
    ),
  );
  if (result != null && context.mounted) onSelected(result.name);
}

class IconPickerDialog extends HookConsumerWidget {
  const IconPickerDialog({
    required this.selected,
    required this.onSelected,
    this.animation,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = useTextEditingController();
    final search = useValueListenable(controller).text.trim().toLowerCase();
    final icons = ref.watch(desktopIconsProvider);

    final catalogue = icons.when(
      loading: () => const Center(child: FCircularProgress.loader()),
      error: (_, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.iconPickerLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FButton(
                variant: .outline,
                onPress: () => ref.invalidate(desktopIconsProvider),
                child: Text(l10n.actionRetry),
              ),
            ],
          ),
        ),
      ),
      data: (icons) => icons.isEmpty
          ? Center(
              child: Text(l10n.iconPickerEmpty, textAlign: TextAlign.center),
            )
          : IconBrowser(
              icons: icons,
              search: search,
              selected: selected,
              onSelected: onSelected,
            ),
    );

    return FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 800),
      clipBehavior: Clip.antiAlias,
      builder: (context, style) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.iconPickerTitle, style: style.titleTextStyle),
                const SizedBox(height: 5),
                FTextField(
                  control: FTextFieldControl.managed(controller: controller),
                  hint: l10n.iconPickerSearch,
                  clearable: (value) => value.text.isNotEmpty,
                  prefixBuilder: (context, style, states) => const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(FLucideIcons.search, size: 16),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.theme.colors.border),
          Flexible(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.6,
              child: DefaultTextStyle.merge(
                style: style.bodyTextStyle,
                child: catalogue,
              ),
            ),
          ),
          Divider(height: 1, color: context.theme.colors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              spacing: 8,
              children: [
                FButton(
                  variant: .outline,
                  onPress: () => onSelected(null),
                  child: Text(l10n.iconPickerNoIcon),
                ),
                const Spacer(),
                FButton(
                  variant: .ghost,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(l10n.actionCancel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
