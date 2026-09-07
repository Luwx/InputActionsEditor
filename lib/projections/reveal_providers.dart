import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';

/// The fields the last undo or redo changed on this gesture, or empty. Both
/// documents come from the reveal, so the set stays put as the draft moves on.
final ProviderFamily<Set<ConfigDirtyField>, GestureLocation>
revealedGestureFieldsProvider =
    Provider.family<Set<ConfigDirtyField>, GestureLocation>((ref, location) {
      final reveal = ref.watch(editRevealProvider);
      if (reveal == null || reveal.gesture != location) {
        return const {};
      }
      return changedGestureFields(reveal.before, reveal.after, location);
    });

/// Mirror of [revealedGestureFieldsProvider] for one group's own properties.
final ProviderFamily<Set<ConfigDirtyField>, GestureGroupLocation>
revealedGroupFieldsProvider =
    Provider.family<Set<ConfigDirtyField>, GestureGroupLocation>((
      ref,
      location,
    ) {
      final reveal = ref.watch(editRevealProvider);
      if (reveal == null || reveal.group != location) {
        return const {};
      }
      return changedGestureGroupFields(reveal.before, reveal.after, location);
    });

/// Mirror of [revealedGestureFieldsProvider] for one action.
final ProviderFamily<Set<ConfigDirtyField>, ActionLocation>
revealedActionFieldsProvider =
    Provider.family<Set<ConfigDirtyField>, ActionLocation>((ref, location) {
      final reveal = ref.watch(editRevealProvider);
      if (reveal == null ||
          reveal.gesture != location.gesture ||
          reveal.actionEditId != location.editId) {
        return const {};
      }
      return changedActionFields(reveal.before, reveal.after, location);
    });
