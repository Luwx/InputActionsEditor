export 'package:input_actions_editor/state/dirty/dirty_locations.dart';
export 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
export 'package:input_actions_editor/state/dirty/dirty_providers.dart';
export 'package:input_actions_editor/state/dirty/dirty_saved_providers.dart';
export 'package:input_actions_editor/state/edit/lenses/config_schema.dart'
    show RootConfigDirtyField;

/// Describes whether a value is unchanged, newly introduced in the current
/// draft, or differs from something that existed in the last saved snapshot.
///
/// How to extend the dirty-marking system for a new UI field:
/// 1. Choose the narrowest location type that uniquely identifies the value.
