import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class FingerCountField extends ConsumerWidget {
  const FingerCountField({
    this.minFingers = 1,
    this.maxFingers = 4,
    super.key,
  });

  final int minFingers;
  final int maxFingers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;
    final field = ref.gestureField(
      context,
      switch (context.gestureLocation.device) {
        DeviceType.touchscreen => touchscreenFingersLens,
        _ => touchpadFingersLens,
      },
      fallbackValue: () => null,
    );
    final value = field.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWithTooltip(
          label: context.l10n.sectionFingersLabel,
          tooltip: context.l10n.sectionFingersTooltip,
          textStyle: typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 6,
          children: [
            FButton(
              variant: value == null ? .primary : .outline,
              size: .sm,
              onPress: () => field.onChanged(null),
              child: Text(context.l10n.sectionFingersAny),
            ),
            for (int n = minFingers; n <= maxFingers; n++)
              FButton(
                variant: value == n ? .primary : .outline,
                size: .sm,
                onPress: () => field.onChanged(n),
                child: Text('$n'),
              ),
          ],
        ),
      ],
    );
  }
}
