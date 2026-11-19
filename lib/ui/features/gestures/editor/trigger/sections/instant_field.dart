import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/inheritable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class InstantField extends StatelessWidget {
  const InstantField({super.key});

  @override
  Widget build(BuildContext context) => InheritableField(
    field: pressInstantField,
    groupField: gestureGroupInstantField,
    builder: (context, field) => FCheckbox(
      value: field.value,
      onChange: field.onChanged,
      label: UnsavedLabel(
        state: field.dirty,
        onRevert: field.onRevert,
        mixed: field.mixed,
        child: LabelWithTooltip(
          label: context.l10n.pressInstantLabel,
          tooltip: context.l10n.pressInstantTooltip,
        ),
      ),
    ),
  );
}
