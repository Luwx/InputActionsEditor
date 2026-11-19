import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_category_selector.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_grid.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class IconBrowser extends HookWidget {
  const IconBrowser({
    required this.icons,
    required this.search,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<DesktopIcon> icons;
  final String search;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final category = useState(IconCategory.all);
    final categories = useMemoized(
      () => IconCategory.values
          .where(
            (category) =>
                category == IconCategory.all ||
                icons.any((icon) => icon.matches(category)),
          )
          .toList(),
      [icons],
    );
    final active = categories.contains(category.value)
        ? category.value
        : IconCategory.all;
    final filtered = icons
        .where(
          (icon) =>
              icon.matches(active) && icon.name.toLowerCase().contains(search),
        )
        .toList();
    final grid = filtered.isEmpty
        ? Center(child: Text(context.l10n.iconPickerNoResults))
        : IconGrid(
            key: ValueKey((search, active)),
            icons: filtered,
            selected: selected,
            onSelected: onSelected,
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth < 500;
        final selector = IconCategorySelector(
          categories: categories,
          selected: active,
          onSelected: (next) => category.value = next,
          horizontal: horizontal,
        );
        if (horizontal) {
          return Column(
            children: [
              SizedBox(height: 48, child: selector),
              Divider(height: 1, color: context.theme.colors.border),
              Expanded(child: grid),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: 160, child: selector),
            VerticalDivider(width: 1, color: context.theme.colors.border),
            Expanded(child: grid),
          ],
        );
      },
    );
  }
}
