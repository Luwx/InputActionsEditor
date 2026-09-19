import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inheritable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class FingerCountField extends StatelessWidget {
  const FingerCountField({
    this.minFingers = 1,
    this.maxFingers = 4,
    super.key,
  });

  final int minFingers;
  final int maxFingers;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
    );
    return InheritableField(
      field: EditLocationScope.deviceOf(context) == DeviceType.touchscreen
          ? touchscreenFingersField
          : touchpadFingersField,
      groupField: gestureGroupFingersField,
      builder: (context, field) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          UnsavedLabel(
            state: field.dirty,
            onRevert: field.onRevert,
            mixed: field.mixed,
            child: LabelWithTooltip(
              label: context.l10n.sectionFingersLabel,
              tooltip: context.l10n.sectionFingersTooltip,
              textStyle: titleStyle,
            ),
          ),
          Row(
            spacing: 6,
            children: [
              FButton(
                variant: field.value == null ? .primary : .outline,
                size: .sm,
                onPress: () => field.onChanged(null),
                child: Text(context.l10n.sectionFingersAny),
              ),
              for (int n = minFingers; n <= maxFingers; n++)
                FButton(
                  variant: field.value == n ? .primary : .outline,
                  size: .sm,
                  onPress: () => field.onChanged(n),
                  child: Text('$n'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
