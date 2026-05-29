import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';

class TypeIconBadge extends StatelessWidget {
  const TypeIconBadge({required this.type, super.key});

  final VarType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: type.bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Icon(type.icon, size: 11, color: type.fgColor),
      ),
    );
  }
}
