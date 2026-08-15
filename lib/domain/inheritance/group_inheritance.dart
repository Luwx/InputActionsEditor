import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show GestureGroupLocation, GestureLocation;
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// A trigger property a group can share with everything in its subtree.
///
/// These are exactly the keys the daemon's trigger-group parser copies onto
/// child nodes (`parseTriggerList` in `config/parsers/triggers.h`), minus the
/// two it handles specially: `gestures` is the recursion, and `conditions`
/// AND-merges instead of being copied.
enum SharedTriggerProperty {
  id,
  threshold,
  resumeTimeout,
  accelerated,
  blockEvents,
  clearModifiers,
  setLastTrigger,
  endConditions;

  /// The group's value for this property, or null when the group does not
  /// share it.
  Object? read(GestureGroupNode group) => switch (this) {
    SharedTriggerProperty.id => group.id,
    SharedTriggerProperty.threshold => group.threshold,
    SharedTriggerProperty.resumeTimeout => group.resumeTimeout,
    SharedTriggerProperty.accelerated => group.accelerated,
    SharedTriggerProperty.blockEvents => group.blockEvents,
    SharedTriggerProperty.clearModifiers => group.clearModifiers,
    SharedTriggerProperty.setLastTrigger => group.setLastTrigger,
    SharedTriggerProperty.endConditions => group.endConditions,
  };
}

/// One property a gesture picks up from an ancestor group.
class InheritedProperty {
  const InheritedProperty({
    required this.property,
    required this.value,
    required this.groupName,
    required this.groupEditId,
    required this.overridden,
    required this.setLocally,
  });

  final SharedTriggerProperty property;

  /// The ancestor group's value. When more than one ancestor shares the
  /// property this is the nearest one's, but see [overridden]: the daemon does
  /// not actually resolve competing values in a defined way.
  final Object? value;

  final String groupName;

  /// Identifies the group for [GestureGroupLocation]-based navigation. Null
  /// only before `assignEditIds` has run.
  final int? groupEditId;

  /// True when the gesture (or a nearer group) also sets this property, so the
  /// config contains the same key twice on one merged node.
  ///
  /// The daemon does not treat this as an override. `parseTriggerList` appends
  /// the group's key to the child's map without checking for a collision, and
  /// `Node`'s map is keyed by node identity rather than key string, so the
  /// duplicate is resolved by `Node::at` taking whichever key node sorts first
  /// by heap address. The winner is not the child's, not the group's, and not
  /// stable between runs of the same file.
  final bool overridden;

  /// True when the gesture itself sets the key. Distinct from [overridden],
  /// which is also true when two ancestor groups collide over a gesture that
  /// sets nothing. Controls with no unset state (checkboxes) display [value]
  /// while this is false, so what they show is what the gesture will run with.
  final bool setLocally;
}

/// Resolves, per gesture editId, the properties that gesture inherits from its
/// ancestor groups on [device].
///
/// A property set by more than one ancestor, or by both an ancestor and the
/// gesture itself, is reported with [InheritedProperty.overridden] set. The
/// nearest ancestor that sets it supplies the reported value, which is what
/// the user most likely intended, not a prediction of what the daemon will do.
Map<int, List<InheritedProperty>> inheritedPropertiesForDevice(
  Config config,
  DeviceType device,
) {
  final result = <int, List<InheritedProperty>>{};

  void walk(List<GestureNode> level, List<GestureGroupNode> ancestors) {
    for (final node in level) {
      switch (node) {
        case GestureGroupNode(:final children):
          walk(children, [...ancestors, node]);
        case GestureLeaf(:final gesture):
          final editId = gesture.common.editId;
          if (editId == null || ancestors.isEmpty) continue;
          final common = gesture.common;
          final inherited = <InheritedProperty>[];
          for (final property in SharedTriggerProperty.values) {
            // Nearest ancestor wins the displayed value; any further ancestor
            // that also sets it is a collision, same as the gesture setting it.
            GestureGroupNode? source;
            var setters = 0;
            for (final ancestor in ancestors) {
              if (property.read(ancestor) == null) continue;
              setters++;
              source = ancestor;
            }
            if (source == null) continue;
            final setLocally = _isSetOnGesture(common, property);
            inherited.add(
              InheritedProperty(
                property: property,
                value: property.read(source),
                groupName: source.name,
                groupEditId: source.editId,
                overridden: setters > 1 || setLocally,
                setLocally: setLocally,
              ),
            );
          }
          if (inherited.isNotEmpty) result[editId] = inherited;
      }
    }
  }

  walk(config.nodesForDevice(device), const []);
  return result;
}

/// Convenience read for a single gesture.
List<InheritedProperty> inheritedPropertiesFor(
  Config config,
  GestureLocation location,
) =>
    inheritedPropertiesForDevice(config, location.device)[location.editId] ??
    const [];

/// One ancestor group's `conditions`, which the daemon AND-merges into every
/// node below it rather than copying like a [SharedTriggerProperty].
class InheritedCondition {
  const InheritedCondition({
    required this.condition,
    required this.groupName,
    required this.groupEditId,
  });

  final Condition condition;

  final String groupName;

  /// Identifies the group for [GestureGroupLocation]-based navigation. Null
  /// only before `assignEditIds` has run.
  final int? groupEditId;
}

/// Resolves, per node editId, the ancestor conditions merged into that node's
/// own, outermost group first.
///
/// Covers gestures and group nodes alike: both draw editIds from the single
/// sequence in `assignEditIds`, so the keys cannot collide.
Map<int, List<InheritedCondition>> inheritedConditionsForDevice(
  Config config,
  DeviceType device,
) {
  final result = <int, List<InheritedCondition>>{};

  void walk(List<GestureNode> level, List<InheritedCondition> ancestors) {
    for (final node in level) {
      switch (node) {
        case GestureGroupNode(:final children, :final conditions, :final name):
          final editId = node.editId;
          if (editId != null && ancestors.isNotEmpty) {
            result[editId] = ancestors;
          }
          walk(children, [
            ...ancestors,
            if (conditions != null)
              InheritedCondition(
                condition: conditions,
                groupName: name,
                groupEditId: editId,
              ),
          ]);
        case GestureLeaf(:final gesture):
          final editId = gesture.common.editId;
          if (editId == null || ancestors.isEmpty) continue;
          result[editId] = ancestors;
      }
    }
  }

  walk(config.nodesForDevice(device), const []);
  return result;
}

/// Convenience read for a single gesture.
List<InheritedCondition> inheritedConditionsFor(
  Config config,
  GestureLocation location,
) =>
    inheritedConditionsForDevice(config, location.device)[location.editId] ??
    const [];

/// Convenience read for a single group node, which inherits from the groups
/// above it exactly as a gesture does.
List<InheritedCondition> inheritedConditionsForGroup(
  Config config,
  GestureGroupLocation location,
) =>
    inheritedConditionsForDevice(config, location.device)[location.editId] ??
    const [];

bool _isSetOnGesture(TriggerCommon common, SharedTriggerProperty property) =>
    switch (property) {
      SharedTriggerProperty.id => common.id != null,
      SharedTriggerProperty.threshold => common.threshold != null,
      SharedTriggerProperty.resumeTimeout => common.resumeTimeout != null,
      SharedTriggerProperty.accelerated => common.accelerated != null,
      SharedTriggerProperty.blockEvents => common.blockEvents != null,
      SharedTriggerProperty.clearModifiers => common.clearModifiers != null,
      SharedTriggerProperty.setLastTrigger => common.setLastTrigger != null,
      SharedTriggerProperty.endConditions => common.endConditions != null,
    };
