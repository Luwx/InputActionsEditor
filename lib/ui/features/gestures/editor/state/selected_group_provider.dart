import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';

/// The group whose shared properties the detail pane is editing, or null when
/// it is showing a gesture or the empty prompt.
///
/// Selecting a gesture clears this: the two are alternative contents of the
/// same pane, and the group header's settings button is the only way in.
class SelectedGroupController extends Notifier<GestureGroupLocation?> {
  @override
  GestureGroupLocation? build() {
    ref.listen(selectedGestureProvider, (previous, next) {
      if (next != null) state = null;
    });
    return null;
  }

  /// A command, not a property write: every call site reads as "open this
  /// group's settings".
  // ignore: use_setters_to_change_properties
  void open(GestureGroupLocation location) => state = location;

  void close() => state = null;
}

final selectedGroupProvider =
    NotifierProvider<SelectedGroupController, GestureGroupLocation?>(
      SelectedGroupController.new,
    );
