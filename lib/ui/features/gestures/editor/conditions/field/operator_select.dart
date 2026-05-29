import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

class OperatorSelect extends StatefulWidget {
  const OperatorSelect({
    required this.operators,
    required this.current,
    required this.onChanged,
    super.key,
  });

  final List<String> operators;
  final String current;
  final void Function(String) onChanged;

  @override
  State<OperatorSelect> createState() => _OperatorSelectState();
}

class _OperatorSelectState extends State<OperatorSelect> {
  late final FocusNode _focusNode;
  bool _hovered = false;
  bool _focused = false;
  Timer? _idleDelayTimer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focused = true;
    } else {
      _focused = false;
    }
  }

  @override
  void dispose() {
    _idleDelayTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  // TODO(me): propper style it without idle hack
  static final _idleStyle = FSelectStyleDelta.delta(
    fieldStyles: .delta([
      .all(
        .delta(
          border: .delta([
            .base(
              OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ]),
          color: .delta([.all(Colors.transparent)]),
        ),
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final active = _focused || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: FSelect<String>.rich(
        format: operatorLabel,
        textAlign: TextAlign.center,
        autofocus: true,
        focusNode: _focusNode,
        prefixBuilder: (_, style, variants) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            operatorIcons[widget.current] ?? FLucideIcons.equal,
            size: 14,
          ),
        ),
        control: FSelectControl<String>.lifted(
          value: widget.current,
          onChange: (value) {
            if (value != null) widget.onChanged(value);
          },
        ),
        contentConstraints: const FPortalConstraints(
          maxWidth: 260,
          maxHeight: 280,
        ),
        style: active ? const FSelectStyleDelta.delta() : _idleStyle,
        children: [
          for (final operator in widget.operators)
            FSelectItem<String>.item(
              value: operator,
              title: Text(
                operatorLabel(operator),
                overflow: TextOverflow.ellipsis,
              ),
              prefix: Icon(
                operatorIcons[operator] ?? FLucideIcons.equal,
                size: 14,
              ),
            ),
        ],
      ),
    );
  }
}
