import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureLocation;
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/store/config_controller.dart';

/// Properties a gesture picks up from its ancestor groups.
///
/// Family-scoped per gesture rather than computed for the whole config: only
/// the open editor needs it, and the walk is cheap enough to redo when the
/// draft changes.
final ProviderFamily<List<InheritedProperty>, GestureLocation>
gestureInheritedPropertiesProvider =
    Provider.family<List<InheritedProperty>, GestureLocation>(
      (ref, location) =>
          inheritedPropertiesFor(ref.watch(draftConfigProvider), location),
    );
