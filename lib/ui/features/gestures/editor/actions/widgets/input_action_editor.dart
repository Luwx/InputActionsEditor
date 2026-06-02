import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_entry_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

class InputEntriesEditor extends ConsumerWidget {
  const InputEntriesEditor({
    required this.entries,
    super.key,
  });

  final List<InputEntry> entries;

  static const Map<String, InputDevice> deviceOptions = {
    'Keyboard': InputDevice.keyboard,
    'Mouse': InputDevice.mouse,
  };

  void _addEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
  ) {
    onChanged([...current, const InputEntry(device: InputDevice.keyboard)]);
  }

  void _removeEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
    int index,
  ) {
    onChanged(List<InputEntry>.of(current)..removeAt(index));
  }

  void _updateEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
    int index,
    InputEntry updated,
  ) {
    final list = List<InputEntry>.of(current);
    list[index] = updated;
    onChanged(list);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesField = ref.actionField(
      context,
      actionInputEntriesLens,
      fallbackValue: () => entries,
    );
    final currentEntries = entriesField.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnsavedLabel(
          state: entriesField.dirty,
          onRevert: entriesField.onRevert,
          child: Text(
            'Input devices',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final (index, entry) in currentEntries.indexed)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputEntryEditor(
                index: index,
                entry: entry,
                deviceOptions: deviceOptions,
                onChanged: (updated) => _updateEntry(
                  currentEntries,
                  entriesField.onChanged,
                  index,
                  updated,
                ),
                onDelete: () => _removeEntry(
                  currentEntries,
                  entriesField.onChanged,
                  index,
                ),
              ),
              if (index != currentEntries.length - 1)
                const FDivider(
                  style: .delta(
                    padding: .value(EdgeInsets.only(bottom: 16, top: 4)),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 4),
        FButton(
          variant: .outline,
          size: .sm,
          onPress: () => _addEntry(currentEntries, entriesField.onChanged),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FLucideIcons.plus),
              SizedBox(width: 4),
              Text('Add device'),
            ],
          ),
        ),
      ],
    );
  }
}
