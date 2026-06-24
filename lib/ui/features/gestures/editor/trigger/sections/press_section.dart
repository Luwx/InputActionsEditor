import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class PressSection extends ConsumerWidget {
  const PressSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final instantField = ref.gestureField(
      context,
      pressInstantLens,
      fallbackValue: () => null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sectionPress,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        FCheckbox(
          label: LabelWithTooltip(
            label: l10n.pressInstantLabel,
            tooltip: l10n.pressInstantTooltip,
          ),
          value: instantField.value ?? false,
          onChange: (v) => instantField.onChanged(v ? true : null),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
