import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';

const SingleActivator copyShortcut = SingleActivator(
  LogicalKeyboardKey.keyC,
  control: true,
);
const SingleActivator pasteShortcut = SingleActivator(
  LogicalKeyboardKey.keyV,
  control: true,
);
const SingleActivator duplicateShortcut = SingleActivator(
  LogicalKeyboardKey.keyD,
  control: true,
);
const SingleActivator deleteShortcut = SingleActivator(
  LogicalKeyboardKey.delete,
);
const SingleActivator renameShortcut = SingleActivator(LogicalKeyboardKey.f2);
const SingleActivator copyYamlShortcut = SingleActivator(
  LogicalKeyboardKey.keyC,
  control: true,
  shift: true,
);

/// Runs [bindings] while [controller]'s menu is open, then closes it.
///
/// Routed through [HardwareKeyboard], which runs ahead of the focus tree, so an
/// open menu outranks whatever holds focus underneath it.
void useMenuShortcuts(
  FPopoverController controller,
  Map<SingleActivator, VoidCallback> bindings,
) {
  final latest = useRef(bindings)..value = bindings;

  useEffect(() {
    bool onKey(KeyEvent event) {
      if (!controller.isShown) return false;
      for (final MapEntry(key: activator, value: run) in latest.value.entries) {
        if (!activator.accepts(event, HardwareKeyboard.instance)) continue;
        unawaited(controller.hide());
        run();
        return true;
      }
      return false;
    }

    HardwareKeyboard.instance.addHandler(onKey);
    return () => HardwareKeyboard.instance.removeHandler(onKey);
  }, [controller]);
}

/// Binds [bindings] to the rows a list has selected, taking focus when the
/// selection opens.
///
/// The bindings sit above the rows in the focus chain, so a text field inside a
/// selected row keeps its own Ctrl+C.
class SelectionShortcuts extends HookWidget {
  const SelectionShortcuts({
    required this.active,
    required this.selection,
    required this.bindings,
    required this.child,
    super.key,
  });

  final bool active;

  /// The selection itself, only ever compared by identity: every change to it
  /// pulls focus back, so clicking a row after clicking away still arms the
  /// bindings.
  final Object? selection;
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final node = useFocusNode(debugLabel: 'SelectionShortcuts');

    useEffect(() {
      if (active && !node.hasFocus) node.requestFocus();
      return null;
    }, [active, selection, node]);

    return CallbackShortcuts(
      bindings: active ? bindings : const {},
      child: Focus(focusNode: node, child: child),
    );
  }
}
