import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/common/file_icon.dart';
import 'package:input_actions_editor/ui/helpers/use_revealed_list_item.dart';

class IconGrid extends HookWidget {
  const IconGrid({
    required this.icons,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<DesktopIcon> icons;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final reveal = useRevealedListItem(
      index: icons.indexWhere((icon) => icon.name == selected),
      itemCount: icons.length,
    );
    return GridView.builder(
      controller: reveal.controller,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 128,
        mainAxisExtent: 112,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = icon.name == selected;
        return Semantics(
          key: isSelected ? reveal.itemKey : null,
          selected: isSelected,
          child: FButton(
            variant: isSelected ? .secondary : .ghost,
            onPress: () => onSelected(icon.name),
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FileIcon(
                    path: icon.path,
                    size: 32,
                    currentColor: isSelected
                        ? context.theme.colors.secondaryForeground
                        : context.theme.colors.foreground,
                    fallback: const Icon(FLucideIcons.image, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    icon.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.theme.typography.body.xs.copyWith(
                      color: isSelected
                          ? context.theme.colors.secondaryForeground
                          : context.theme.colors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
