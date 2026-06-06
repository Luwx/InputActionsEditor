import 'package:flutter/material.dart' show Colors, OutlineInputBorder;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

class TextValueInput extends HookWidget {
  const TextValueInput({
    required this.value,
    required this.onChanged,
    required this.hint,
    required this.colors,
    this.autofocus = false,
    super.key,
  });

  final String value;
  final void Function(String) onChanged;
  final String hint;
  final FColors colors;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value);
    final focusNode = useFocusNode();
    final isHovered = useState(false);
    final isFocused = useState(false);

    // Sync controller when external value changes (didUpdateWidget).
    final prevValue = usePrevious(value);
    if (prevValue != null && prevValue != value && value != controller.text) {
      controller.text = value;
    }

    useEffect(() {
      void onFocusChange() => isFocused.value = focusNode.hasFocus;
      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, const []);

    // TODO(me): propper style it without idle hack
    final idleStyle = FTextFieldStyleDelta.delta(
      border: .delta([
        .base(
          OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ]),
      color: .delta([.all(Colors.transparent)]),
    );

    final active = isFocused.value || isHovered.value;
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: FTextField(
        focusNode: focusNode,
        style: active ? const FTextFieldStyleDelta.delta() : idleStyle,
        control: FTextFieldControl.lifted(
          value: controller.value,
          onChange: (v) {
            controller.value = v;
            onChanged(v.text);
          },
        ),
        autofocus: autofocus,
        hint: hint,
      ),
    );
  }
}
