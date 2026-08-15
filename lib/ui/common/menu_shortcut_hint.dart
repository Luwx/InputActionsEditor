import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Renders an existing key binding as a menu hint, e.g. `Ctrl+Shift+S`.
///
/// Pass to [FItem.details]. This only displays a binding — the bindings
/// themselves are declared for the native menu in `application_menu.dart`.
class MenuShortcutHint extends StatelessWidget {
  const MenuShortcutHint(this.shortcut, {super.key});

  final SingleActivator shortcut;

  @override
  Widget build(BuildContext context) => Text(
    [
      if (shortcut.control) 'Ctrl',
      if (shortcut.alt) 'Alt',
      if (shortcut.shift) 'Shift',
      if (shortcut.meta) 'Meta',
      shortcut.trigger.keyLabel,
    ].join('+'),
    // FItem centers title and details independently, so a smaller hint would
    // never share the title's baseline. Match the title's metrics, differ by
    // color only.
    style: context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    ),
  );
}
