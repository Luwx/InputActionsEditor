import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/branch_action_card.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

/// Editor for [ActionKind.one]: a first-match branch. Renders the
/// [BranchActionCard] for the [OneAction] addressed by this action location;
/// each case is edited through its own [BranchCaseLocation].
class EditorOne extends ConsumerWidget {
  const EditorOne({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BranchActionCard(parent: context.actionLocation);
  }
}
