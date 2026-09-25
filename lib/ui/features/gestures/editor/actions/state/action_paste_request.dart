import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';

typedef ActionPasteRequest = ({GestureLocation gesture, int ticket});

class ActionPasteRequestController extends Notifier<ActionPasteRequest?> {
  @override
  ActionPasteRequest? build() => null;

  void request(GestureLocation gesture) =>
      state = (gesture: gesture, ticket: (state?.ticket ?? 0) + 1);
}

/// Asks the open action list to paste the clipboard at its end.
final actionPasteRequestProvider =
    NotifierProvider<ActionPasteRequestController, ActionPasteRequest?>(
      ActionPasteRequestController.new,
    );
