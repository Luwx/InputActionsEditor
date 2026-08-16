import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Renders an existing key binding as a menu hint, e.g. `Ctrl+Shift+S`.
///
/// Pass to [FItem.details]. This only displays a binding — the bindings
/// themselves are declared for the native menu in `application_menu.dart`.
class MenuShortcutHint extends StatelessWidget {
  const MenuShortcutHint(this.shortcut, {super.key});

  final SingleActivator shortcut;

  /// Widens FItem's 4px `middleSpacing` gutter.
  static const double _gutter = 20;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: _gutter),
    child: Text(
      [
        if (shortcut.control) 'Ctrl',
        if (shortcut.alt) 'Alt',
        if (shortcut.shift) 'Shift',
        if (shortcut.meta) 'Meta',
        shortcut.trigger.keyLabel,
      ].join('+'),
      // FItem centers title and details independently, so a smaller hint would
      // never share the title's baseline. The color stays FItem's own, which
      // fades with a disabled item.
      style: context.theme.typography.body.sm.copyWith(
        color: DefaultTextStyle.of(context).style.color,
      ),
    ),
  );
}
