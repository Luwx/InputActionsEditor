import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

class OperatorSelect extends HookWidget {
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
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    final isHovered = useState(false);
    final isFocused = useState(false);

    useEffect(() {
      void onFocusChange() {
        isFocused.value = focusNode.hasFocus;
      }

      focusNode.addListener(onFocusChange);
      return () => focusNode.removeListener(onFocusChange);
    }, const []);

    // TODO(me): propper style it without idle hack
    final idleStyle = FSelectStyleDelta.delta(
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

    final active = isFocused.value || isHovered.value;
    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: FSelect<String>.rich(
        format: operatorLabel,
        textAlign: TextAlign.center,
        autofocus: true,
        focusNode: focusNode,
        prefixBuilder: (_, style, variants) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(
            operatorIcons[current] ?? FLucideIcons.equal,
            size: 14,
          ),
        ),
        control: FSelectControl<String>.lifted(
          value: current,
          onChange: (value) {
            if (value != null) onChanged(value);
          },
        ),
        contentConstraints: const FPortalConstraints(
          maxWidth: 260,
          maxHeight: 280,
        ),
        style: active ? const FSelectStyleDelta.delta() : idleStyle,
        children: [
          for (final operator in operators)
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
