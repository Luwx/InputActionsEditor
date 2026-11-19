import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class IconCategorySelector extends StatelessWidget {
  const IconCategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelected,
    this.horizontal = false,
    super.key,
  });

  final List<IconCategory> categories;
  final IconCategory selected;
  final ValueChanged<IconCategory> onSelected;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: categories.length,
      separatorBuilder: (_, _) => SizedBox(
        width: horizontal ? 4 : 0,
        height: horizontal ? 0 : 2,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final (label, icon) = switch (category) {
          IconCategory.all => (l10n.iconCategoryAll, FLucideIcons.layoutGrid),
          IconCategory.actions => (l10n.iconCategoryActions, FLucideIcons.zap),
          IconCategory.applications => (
            l10n.iconCategoryApplications,
            FLucideIcons.appWindow,
          ),
          IconCategory.categories => (
            l10n.iconCategoryCategories,
            FLucideIcons.shapes,
          ),
          IconCategory.devices => (
            l10n.iconCategoryDevices,
            FLucideIcons.monitor,
          ),
          IconCategory.emblems => (
            l10n.iconCategoryEmblems,
            FLucideIcons.badge,
          ),
          IconCategory.emotes => (l10n.iconCategoryEmotes, FLucideIcons.smile),
          IconCategory.mimetypes => (
            l10n.iconCategoryMimetypes,
            FLucideIcons.file,
          ),
          IconCategory.places => (l10n.iconCategoryPlaces, FLucideIcons.folder),
          IconCategory.status => (
            l10n.iconCategoryStatus,
            FLucideIcons.activity,
          ),
          IconCategory.animations => (
            l10n.iconCategoryAnimations,
            FLucideIcons.clapperboard,
          ),
          IconCategory.international => (
            l10n.iconCategoryInternational,
            FLucideIcons.globe,
          ),
          IconCategory.other => (l10n.iconCategoryOther, FLucideIcons.ellipsis),
        };
        return Semantics(
          selected: selected == category,
          child: FButton(
            style: const .delta(contentStyle: .delta(spacing: 12)),
            variant: selected == category ? .secondary : .ghost,
            size: .sm,
            mainAxisAlignment: MainAxisAlignment.start,
            onPress: () => onSelected(category),
            prefix: Icon(icon, size: 16),
            child: Text(label),
          ),
        );
      },
    );
  }
}
