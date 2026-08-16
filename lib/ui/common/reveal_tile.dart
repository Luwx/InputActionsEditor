import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/extensions.dart';

/// An [FTileGroup] child that only takes space while [visible]. The group
/// accepts nothing but [FTileMixin], so the toggle needs a tile of its own.
class RevealTile extends StatelessWidget with FTileMixin {
  const RevealTile({required this.visible, required this.child, super.key});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) => child.appearToggle(
    visible: visible,
    alignment: Alignment.topCenter,
  );
}
