import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class RawOptionBadge extends StatelessWidget {
  const RawOptionBadge({super.key});

  @override
  Widget build(BuildContext context) => AppTooltip(
    tipBuilder: (context, _) => Text(context.l10n.rawOptionTooltip),
    child: FBadge(variant: .outline, child: const Text('RAW')),
  );
}
