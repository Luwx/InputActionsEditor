import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Editor for [ActionKind.raw]: the raw YAML for an action the typed editors
/// don't model.
class EditorRaw extends ConsumerWidget {
  const EditorRaw({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final schemaField = ref.actionSchemaField(context, actionRawField);
    return FTextField(
      control: FTextFieldControl.managed(
        initial: schemaField.textEditingValue,
        onChange: schemaField.onTextChanged,
      ),
      label: UnsavedLabel(
        state: schemaField.dirty,
        onRevert: schemaField.onRevert,
        child: Text(l10n.actionMetaRawLabel),
      ),
      maxLines: null,
    );
  }
}
