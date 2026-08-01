import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    as schema;
import 'package:input_actions_editor/model/config.dart';

/// In-memory identity for gestures and group nodes: keys undo history, edit
/// locations, and UI state; never serialized. One sequence covers both kinds
/// so keys never collide across the two location types. The tree walks live
/// in the generated schema; only the id policy is defined here.
int _editIdSequence = 0;

/// Ensures every gesture and group node carries a unique, non-null editId.
/// Fills nulls (freshly parsed or added) and de-duplicates collisions (a
/// duplicated gesture initially shares its source's id). Returns the same
/// [config] instance when no assignment was needed.
Config assignEditIds(Config config) =>
    schema.assignGestureKeys(config, () => ++_editIdSequence);

/// Carries editIds from [from] onto [to] by tree position. Used after a save
/// round-trip (write + reload), which rebuilds the trees without ids: since
/// save never restructures, positional matching keeps undo history and group
/// UI state valid. Unmatched positions get fresh ids.
Config preserveEditIds({required Config from, required Config to}) =>
    assignEditIds(schema.preserveGestureKeys(from: from, to: to));
