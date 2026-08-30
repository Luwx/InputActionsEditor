import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/domain/misc/keyboard_physical_key_map.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';

class KeyboardRecorder {
  const KeyboardRecorder({
    required this.isRecording,
    required this.tokens,
    required this.start,
    required this.stop,
    required this.clear,
  });

  final bool isRecording;
  final List<InputToken> tokens;
  final VoidCallback start;
  final void Function({required bool append, bool convertToShortcut}) stop;
  final VoidCallback clear;
}

/// Captures raw key presses while recording and hands the finished sequence
/// to [onCaptured] as sequence text.
KeyboardRecorder useKeyboardRecorder(ValueChanged<String> onCaptured) {
  final isRecording = useState(false);
  final tokens = useState<List<InputToken>>([]);
  // Held in a ref so cleanup always unregisters the handler it added.
  final handler = useRef<bool Function(KeyEvent)?>(null);

  useEffect(() {
    return () {
      final registered = handler.value;
      if (registered != null) {
        HardwareKeyboard.instance.removeHandler(registered);
      }
    };
  }, const []);

  bool onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyUpEvent) return true;
    final scancode = physicalKeyToScancode[event.physicalKey];
    if (scancode != null) {
      tokens.value = [
        ...tokens.value,
        if (event is KeyDownEvent)
          InputToken.press(scancode)
        else
          InputToken.release(scancode),
      ];
    }
    return true;
  }

  void start() {
    isRecording.value = true;
    tokens.value = [];
    handler.value = onKeyEvent;
    HardwareKeyboard.instance.addHandler(onKeyEvent);
  }

  void stop({required bool append, bool convertToShortcut = false}) {
    final registered = handler.value;
    if (registered != null) {
      HardwareKeyboard.instance.removeHandler(registered);
      handler.value = null;
    }
    if (append && tokens.value.isNotEmpty) {
      onCaptured(
        convertToShortcut
            ? KeySequenceParser.tokensToShortcutString(tokens.value)
            : tokens.value.map(inputTokenText).join(', '),
      );
    }
    isRecording.value = false;
    tokens.value = [];
  }

  return KeyboardRecorder(
    isRecording: isRecording.value,
    tokens: tokens.value,
    start: start,
    stop: stop,
    clear: () => tokens.value = [],
  );
}
