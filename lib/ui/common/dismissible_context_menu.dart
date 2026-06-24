import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

extension DismissibleContextMenuController on FPopoverController {
  bool get isShown => status.isForwardOrCompleted;
}

/// [FContextMenu.builder] that closes the menu on Esc and on a second
/// right-click. The owning menu must use a managed [control] with [controller]
/// and set `secondaryPress: !controller.isShown` (rebuilt via
/// `useListenable(controller)`).
Widget dismissibleContextMenuBuilder(
  BuildContext context,
  FPopoverController controller,
  Widget? child,
) => _DismissibleContextMenuTrigger(
  controller: controller,
  child: child ?? const SizedBox.shrink(),
);

class _DismissibleContextMenuTrigger extends HookWidget {
  const _DismissibleContextMenuTrigger({
    required this.controller,
    required this.child,
  });

  final FPopoverController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // FPortal does no focus routing, so Forui's built-in Esc handling never
    // fires for a point-anchored menu; handle it here instead.
    useEffect(() {
      bool handleKey(KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            controller.isShown) {
          unawaited(controller.hide());
          return true;
        }
        return false;
      }

      HardwareKeyboard.instance.addHandler(handleKey);
      return () => HardwareKeyboard.instance.removeHandler(handleKey);
    }, [controller]);

    return Listener(
      onPointerDown: (event) {
        if (event.buttons & kSecondaryButton != 0 && controller.isShown) {
          unawaited(controller.hide());
        }
      },
      child: child,
    );
  }
}
