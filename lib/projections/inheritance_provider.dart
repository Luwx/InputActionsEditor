import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureGroupLocation, GestureLocation;
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

/// Ancestor group conditions AND-merged into a gesture's own, outermost first.
final ProviderFamily<List<InheritedCondition>, GestureLocation>
gestureInheritedConditionsProvider =
    Provider.family<List<InheritedCondition>, GestureLocation>(
      (ref, location) =>
          inheritedConditionsFor(ref.watch(draftConfigProvider), location),
    );

/// The same, for a group node nested inside other groups.
final ProviderFamily<List<InheritedCondition>, GestureGroupLocation>
groupInheritedConditionsProvider =
    Provider.family<List<InheritedCondition>, GestureGroupLocation>(
      (ref, location) =>
          inheritedConditionsForGroup(ref.watch(draftConfigProvider), location),
    );
