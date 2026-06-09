import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Registers a [HardwareKeyboard] handler for the widget's lifetime.
///
/// Returns a setter for the currently active drag pointer ID. Call it with
/// a non-null pointer when a drag starts, and null when it ends. While a
/// pointer is tracked, pressing ESC injects a [PointerCancelEvent] to cancel
/// the drag.
ValueChanged<int?> useDragEscapeCancel() {
  final pointer = useRef<int?>(null);

  useEffect(() {
    bool handleKey(KeyEvent event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.escape) {
        final p = pointer.value;
        if (p != null) {
          GestureBinding.instance.handlePointerEvent(
            PointerCancelEvent(pointer: p),
          );
          pointer.value = null;
          return true;
        }
      }
      return false;
    }

    HardwareKeyboard.instance.addHandler(handleKey);
    return () => HardwareKeyboard.instance.removeHandler(handleKey);
  }, const []);

  return (p) => pointer.value = p;
}
