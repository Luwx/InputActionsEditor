import 'package:flutter/material.dart' show Colors, OutlineInputBorder;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class TextValueInput extends StatefulWidget {
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
  State<TextValueInput> createState() => _TextValueInputState();
}

class _TextValueInputState extends State<TextValueInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() => _focused = _focusNode.hasFocus);

  @override
  void didUpdateWidget(TextValueInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  // TODO(me): propper style it without idle hack
  static final _idleStyle = FTextFieldStyleDelta.delta(
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

  @override
  Widget build(BuildContext context) {
    final active = _focused || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: FTextField(
        focusNode: _focusNode,
        style: active ? const FTextFieldStyleDelta.delta() : _idleStyle,
        control: FTextFieldControl.lifted(
          value: _controller.value,
          onChange: (value) {
            _controller.value = value;
            widget.onChanged(value.text);
          },
        ),
        autofocus: widget.autofocus,
        hint: widget.hint,
      ),
    );
  }
}
