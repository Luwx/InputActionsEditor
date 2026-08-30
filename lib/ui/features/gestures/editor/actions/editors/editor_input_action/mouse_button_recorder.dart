import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/model/action.dart';

const Map<int, String> _mouseButtonNames = {
  kPrimaryMouseButton: 'left',
  kSecondaryMouseButton: 'right',
  kMiddleMouseButton: 'middle',
  kBackMouseButton: 'back',
  kForwardMouseButton: 'forward',
};

class MouseButtonRecorder {
  const MouseButtonRecorder({
    required this.tokens,
    required this.onPointerDown,
    required this.onPointerUp,
    required this.clear,
  });

  final List<InputToken> tokens;
  final void Function(PointerDownEvent) onPointerDown;
  final void Function(PointerUpEvent) onPointerUp;
  final VoidCallback clear;
}

MouseButtonRecorder useMouseButtonRecorder() {
  final tokens = useState<List<InputToken>>([]);
  final buttonsDown = useRef(0);

  void emit(int mask, InputToken Function(String) token) {
    for (final button in _mouseButtonNames.entries) {
      if (mask & button.key != 0) {
        tokens.value = [...tokens.value, token(button.value)];
      }
    }
  }

  return MouseButtonRecorder(
    tokens: tokens.value,
    onPointerDown: (event) {
      if (event.kind != PointerDeviceKind.mouse) return;
      final pressed = event.buttons & ~buttonsDown.value;
      buttonsDown.value = event.buttons;
      emit(pressed, InputToken.press);
    },
    onPointerUp: (event) {
      final released = buttonsDown.value & ~event.buttons;
      buttonsDown.value = event.buttons;
      emit(released, InputToken.release);
    },
    clear: () => tokens.value = [],
  );
}
