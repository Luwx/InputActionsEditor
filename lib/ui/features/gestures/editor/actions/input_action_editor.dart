import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/input_entry_editor.dart';
import 'package:input_actions_editor/ui/widgets/unsaved_marker.dart';

class InputEntriesEditor extends ConsumerWidget {
  const InputEntriesEditor({
    required this.actionLocation,
    required this.entries,
    required this.onChanged,
    super.key,
  });

  final ActionLocation actionLocation;
  final List<InputEntry> entries;
  final void Function(List<InputEntry>) onChanged;

  static const Map<String, InputDevice> deviceOptions = {
    'Keyboard': InputDevice.keyboard,
    'Mouse': InputDevice.mouse,
  };

  void _addEntry() {
    onChanged([...entries, const InputEntry(device: InputDevice.keyboard)]);
  }

  void _removeEntry(int index) {
    onChanged(List<InputEntry>.of(entries)..removeAt(index));
  }

  void _updateEntry(int index, InputEntry updated) {
    final list = List<InputEntry>.of(entries);
    list[index] = updated;
    onChanged(list);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dirtyState = ref.watch(
      actionFieldDirtyStateProvider(
        ActionDirtyLocation(
          action: actionLocation,
          field: ActionDirtyField.inputEntries,
        ),
      ),
    );
    final savedAction = ref.watch(savedActionProvider(actionLocation));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnsavedLabel(
          state: dirtyState,
          onRevert: savedAction == null
              ? null
              : () => onChanged(
                  switch (savedAction.action) {
                    InputAction(:final entries) => entries,
                    _ => const <InputEntry>[],
                  },
                ),
          child: Text(
            'Input devices',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (final (index, entry) in entries.indexed)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InputEntryEditor(
                index: index,
                entry: entry,
                deviceOptions: deviceOptions,
                onChanged: (updated) => _updateEntry(index, updated),
                onDelete: () => _removeEntry(index),
              ),
              if (index != entries.length - 1)
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
          onPress: _addEntry,
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
