import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/input_entry_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class EditorInputAction extends HookConsumerWidget {
  const EditorInputAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesField = ref.actionField(
      context,
      actionInputEntriesLens,
      fallbackValue: () => const <InputEntry>[],
    );
    final entries = entriesField.value;

    void replace(int index, InputEntry updated) {
      entriesField.onChanged(List<InputEntry>.of(entries)..[index] = updated);
    }

    return RevealedField(
      field: ConfigDirtyField.actionInputEntries,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UnsavedLabel(
                state: entriesField.dirty,
                onRevert: entriesField.onRevert,
                child: Text(
                  context.l10n.inputDevicesLabel,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              FButton(
                variant: .outline,
                size: .sm,
                onPress: () => entriesField.onChanged([
                  ...entries,
                  const InputEntry(device: InputDevice.keyboard),
                ]),
                prefix: const Icon(FLucideIcons.plus, size: 14),
                child: Text(context.l10n.inputAddDevice),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, entry) in entries.indexed)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InputEntryEditor(
                        entry: entry,
                        onChanged: (updated) => replace(index, updated),
                        onDelete: () => entriesField.onChanged(
                          List<InputEntry>.of(entries)..removeAt(index),
                        ),
                      ),
                      if (index != entries.length - 1)
                        const FDivider(
                          style: .delta(
                            padding: .value(
                              EdgeInsets.only(bottom: 12, top: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
