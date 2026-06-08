import 'package:flutter/material.dart' show Colors, OutlineInputBorder;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

// Approximate widths of the detect button variants and the gap between them
// and the text field. Used to decide which layout mode to enter.
const _kGap = 6.0;
const _kFullButtonWidth = 88.0;
const _kIconButtonWidth = 34.0;

// Horizontal padding inside FTextField (estimated from forui's desktop style).
const _kFieldPadding = 24.0;

enum _DetectLayout { rowFull, rowIcon, column }

_DetectLayout _computeLayout(double available, double textWidth) {
  final minField = (textWidth + _kFieldPadding).clamp(60.0, double.infinity);
  if (available >= minField + _kGap + _kFullButtonWidth) {
    return _DetectLayout.rowFull;
  }
  if (available >= minField + _kGap + _kIconButtonWidth) {
    return _DetectLayout.rowIcon;
  }
  return _DetectLayout.column;
}

double _measureText(String text, TextStyle style) {
  if (text.isEmpty) return 0;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  return painter.width;
}

class TextValueInput extends HookWidget {
  const TextValueInput({
    required this.value,
    required this.onChanged,
    required this.hint,
    this.autofocus = false,
    this.onDetect,
    super.key,
  });

  final String value;
  final void Function(String) onChanged;
  final String hint;
  final bool autofocus;

  /// When non-null, an adaptive detect-window button is shown alongside the
  /// field. The callback is invoked on tap and is expected to call [onChanged]
  /// if a window was picked (it may be a no-op if the user cancelled).
  final Future<void> Function()? onDetect;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value);
    final focusNode = useFocusNode();
    final isHovered = useState(false);
    final isFocused = useState(false);
    final detecting = useState(false);

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
    final textField = MouseRegion(
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

    if (onDetect == null) return textField;

    Future<void> handleDetect() async {
      detecting.value = true;
      try {
        await onDetect!();
      } finally {
        detecting.value = false;
      }
    }

    final textStyle = context.theme.typography.sm;
    final buttonIcon = detecting.value
        ? const FCircularProgress()
        : const Icon(FLucideIcons.crosshair, size: 14);
    final buttonOnPress = detecting.value ? null : handleDetect;

    Widget buildButton({required bool full}) {
      if (full) {
        return FButton(
          size: .sm,
          variant: .outline,
          onPress: buttonOnPress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              buttonIcon,
              const SizedBox(width: 5),
              const Text('Detect'),
            ],
          ),
        );
      }
      return FButton.icon(
        size: .sm,
        onPress: buttonOnPress,
        child: buttonIcon,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textWidth = _measureText(value, textStyle);
        final layout = _computeLayout(constraints.maxWidth, textWidth);
        return switch (layout) {
          _DetectLayout.rowFull => Row(
            children: [
              Expanded(child: textField),
              const SizedBox(width: _kGap),
              buildButton(full: true),
            ],
          ),
          _DetectLayout.rowIcon => Row(
            children: [
              Expanded(child: textField),
              const SizedBox(width: _kGap),
              buildButton(full: false),
            ],
          ),
          _DetectLayout.column => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textField,
              const SizedBox(height: _kGap),
              buildButton(full: true),
            ],
          ),
        };
      },
    );
  }
}
