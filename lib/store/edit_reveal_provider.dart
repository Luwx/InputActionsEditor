import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/edit_reveal.dart';

export 'package:input_actions_editor/domain/edit/edit_reveal.dart'
    show EditReveal;

class EditRevealController extends Notifier<EditReveal?> {
  int _tickets = 0;

  @override
  EditReveal? build() => null;

  void show(EditReveal? reveal) {
    if (reveal == null) return;
    state = reveal.withTicket(++_tickets);
  }

  void clear() => state = null;
}

/// What an undo or redo just changed, for the list and the action editor to
/// bring into view.
final editRevealProvider = NotifierProvider<EditRevealController, EditReveal?>(
  EditRevealController.new,
);
