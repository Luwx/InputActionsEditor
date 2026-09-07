import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/trigger_editor.dart';

class GestureEditorLayout extends ConsumerWidget {
  const GestureEditorLayout({
    required this.location,
    required this.sections,
    super.key,
  });

  final GestureLocation location;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(4, 'gestureEditorLayout build');
    ref.watch(revealPaneProvider(location));
    final advancedFields = ref.watch(
      gestureEditorProvider(location).select(
        (s) => TriggerAdvancedFields.nonDefaultFields(
          s.common ?? const TriggerCommon(),
        ).lock,
      ),
    );
    final triggerDirtyState = ref.watch(
      gestureEditorProvider(location).select((s) => s.triggerDirtyState),
    );
    final savedGesture = ref.watch(
      gestureEditorProvider(location).select((s) => s.savedGesture),
    );
    final notifier = ref.read(gestureEditorProvider(location).notifier);

    return EditLocationScope(
      gesture: location,
      child: Column(
        children: [
          TriggerEditor(
            sections: sections,
            initialAdvancedFields: advancedFields.unlock,
            dirtyState: triggerDirtyState,
            onRevert: savedGesture == null
                ? null
                : () => notifier.revertTriggerConfig(savedGesture),
          ),
          const SizedBox(height: 16),
          const ActionListEditor(),
        ],
      ),
    );
  }
}
