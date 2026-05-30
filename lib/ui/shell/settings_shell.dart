import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/state/navigation/nav_transition.dart';
import 'package:input_actions_editor/ui/features/settings/settings_split_layout.dart';
import 'package:input_actions_editor/ui/shell/nav_surface.dart';

/// Settings shell: settings sidebar + animated content area.
///
/// Lives at key `ValueKey('settings')` in the outer [NavSurface]. Its child is
/// wrapped in a [NavSurface] so settings sub-section transitions animate
/// vertically while the settings sidebar stays fixed.
class SettingsShell extends StatelessWidget {
  const SettingsShell({
    required this.contentSpec,
    required this.child,
    super.key,
  });

  final TransitionConfig contentSpec;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SettingsSplitLayout(
      child: NavSurface(
        spec: contentSpec,
        child: child,
      ),
    );
  }
}
