import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

  void clearFor(Object pane) {
    if (!ref.mounted) return;
    if (state?.gesture == pane || state?.group == pane) clear();
  }

  void clear() => state = null;
}

/// What an undo or redo just changed, for the list and the action editor to
/// bring into view.
final editRevealProvider = NotifierProvider<EditRevealController, EditReveal?>(
  EditRevealController.new,
);

final ProviderFamily<void, Object> revealPaneProvider = Provider.autoDispose
    .family<void, Object>((ref, pane) {
      final reveal = ref.read(editRevealProvider.notifier);
      // Riverpod forbids touching another provider from inside a life-cycle.
      ref.onDispose(() => scheduleMicrotask(() => reveal.clearFor(pane)));
    });
