import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/common/file_icon.dart';

class MenuItemIcon extends ConsumerWidget {
  const MenuItemIcon({required this.name, required this.fallback, super.key});

  final String? name;
  final Widget fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = this.name;
    if (name == null) return fallback;
    final path = ref.watch(sizedIconPathProvider((name: name, size: 16))).value;
    if (path == null) return fallback;
    return FileIcon(
      path: path,
      size: 16,
      currentColor: context.theme.colors.foreground,
      fallback: fallback,
    );
  }
}
