import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/state/app/local_settings_provider.dart';
import 'package:input_actions_editor/ui/features/settings/settings_list_section.dart';
import 'package:kwin_blur/kwin_blur.dart';

/// Settings shell: settings sidebar + content area.
///
/// The [child] is the animated content surface MiniRouter supplies; this shell
/// only provides the sidebar chrome.
class SettingsShell extends ConsumerWidget {
  const SettingsShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(
      localSettingsProvider.select((s) => s.transparentSidebar),
    );
    return FScaffold(
      sidebar: Blurred(
        disabled: !transparent,
        expand: const EdgeInsets.only(right: 30),
        child: const SettingsListSection(),
      ),
      childPad: false,
      child: transparent
          ? ColoredBox(color: context.theme.colors.background, child: child)
          : child,
    );
  }
}
