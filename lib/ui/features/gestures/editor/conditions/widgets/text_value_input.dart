import 'dart:async' show unawaited;

import 'package:flutter/material.dart' show Colors, OutlineInputBorder;
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

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

  /// When non-null, the input renders as a chip that opens a popover with the
  /// text field and a detect-window button.
  final Future<void> Function()? onDetect;

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

    return _TextValueChip(
      value: value,
      hint: hint,
      onChanged: onChanged,
      onDetect: onDetect!,
    );
  }
}

class _TextValueChip extends HookWidget {
  const _TextValueChip({
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.onDetect,
  });

  final String value;
  final String hint;
  final void Function(String) onChanged;
  final Future<void> Function() onDetect;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final isHovered = useState(false);
    final isOpen = useState(false);
    final detecting = useState(false);

    final isEmpty = value.isEmpty;
    final displayText = isEmpty ? hint : value;
    final textColor = isEmpty ? colors.mutedForeground : colors.foreground;
    final isActive = isHovered.value || isOpen.value;

    Future<void> handleDetect() async {
      detecting.value = true;
      try {
        await onDetect();
      } finally {
        detecting.value = false;
      }
    }

    return FPopover(
      control: FPopoverControl.lifted(
        shown: isOpen.value,
        onChange: (v) => isOpen.value = v,
      ),
      autofocus: false,
      constraints: const FPortalConstraints(maxWidth: 280),
      builder: (context, controller, child) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => isHovered.value = true,
        onExit: (_) => isHovered.value = false,
        child: GestureDetector(
          onTap: () => unawaited(controller.toggle()),
          behavior: HitTestBehavior.opaque,
          child: child,
        ),
      ),
      popoverBuilder: (context, controller) => _TextValuePopover(
        value: value,
        hint: hint,
        onChanged: onChanged,
        onDetect: handleDetect,
        detecting: detecting.value,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colors.card : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? colors.border : Colors.transparent,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Text(
          displayText,
          style: typography.sm.copyWith(color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _TextValuePopover extends HookWidget {
  const _TextValuePopover({
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.onDetect,
    required this.detecting,
  });

  final String value;
  final String hint;
  final void Function(String) onChanged;
  final Future<void> Function() onDetect;
  final bool detecting;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController.fromValue(
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      ),
    );

    final prevValue = usePrevious(value);
    if (prevValue != null && prevValue != value && value != controller.text) {
      final target = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.text != target) {
          controller.value = TextEditingValue(
            text: target,
            selection: TextSelection.collapsed(offset: target.length),
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FTextField(
            autofocus: true,
            maxLines: null,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'\n')),
            ],
            control: FTextFieldControl.managed(
              controller: controller,
              onChange: (v) {
                if (v.text != value) onChanged(v.text);
              },
            ),
            hint: hint,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              size: .sm,
              variant: .outline,
              onPress: detecting ? null : onDetect,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (detecting)
                    const FCircularProgress()
                  else
                    const Icon(FLucideIcons.crosshair, size: 14),
                  const SizedBox(width: 5),
                  const Text('Detect'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
