import 'package:collection/collection.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show ConfigDirtyField, GestureGroupLocation, GestureLocation;
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/finger_range.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

/// A group key the editor models; the codec hands the unmodelled ones down.
enum SharedTriggerProperty {
  id,
  threshold,
  resumeTimeout,
  accelerated,
  blockEvents,
  clearModifiers,
  setLastTrigger,
  endConditions,
  mouseButtons,
  mouseButtonsExactOrder,
  fingers,
  speed,
  instant,
  lockPointer;

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
    SharedTriggerProperty.mouseButtons =>
      group.mouseButtons?.isEmpty ?? true ? null : group.mouseButtons,
    SharedTriggerProperty.mouseButtonsExactOrder =>
      group.mouseButtonsExactOrder,
    SharedTriggerProperty.fingers => group.fingers,
    SharedTriggerProperty.speed => group.speed,
    SharedTriggerProperty.instant => group.instant,
    SharedTriggerProperty.lockPointer => group.lockPointer,
  };

  /// Null when the gesture leaves the property to its groups.
  Object? readOn(Gesture gesture) {
    final common = gesture.common;
    return switch (this) {
      SharedTriggerProperty.id => common.id,
      SharedTriggerProperty.threshold => common.threshold,
      SharedTriggerProperty.resumeTimeout => common.resumeTimeout,
      SharedTriggerProperty.accelerated => common.accelerated,
      SharedTriggerProperty.blockEvents => common.blockEvents,
      SharedTriggerProperty.clearModifiers => common.clearModifiers,
      SharedTriggerProperty.setLastTrigger => common.setLastTrigger,
      SharedTriggerProperty.endConditions => common.endConditions,
      SharedTriggerProperty.mouseButtons =>
        common.mouseButtons.isEmpty ? null : common.mouseButtons,
      SharedTriggerProperty.mouseButtonsExactOrder =>
        common.mouseButtonsExactOrder ? true : null,
      SharedTriggerProperty.fingers => switch (gesture) {
        TouchpadGesture(:final fingers) => fingers,
        TouchscreenGesture(:final fingers) => fingers,
        _ => null,
      },
      SharedTriggerProperty.speed => _motionOf(gesture)?.speed,
      SharedTriggerProperty.instant => switch (gesture) {
        PressGesture(:final instant) => instant,
        _ => null,
      },
      SharedTriggerProperty.lockPointer => _motionOf(gesture)?.lockPointer,
    };
  }

  /// A null [value] leaves the property to the gesture's groups.
  Gesture writeOn(Gesture gesture, Object? value) {
    final common = gesture.common;
    Gesture withCommon(TriggerCommon next) => gesture.withCommon(next);
    Gesture withMotion(MotionCommon Function(MotionCommon) update) =>
        switch (_motionOf(gesture)) {
          final motion? => _withMotion(gesture, update(motion)),
          null => gesture,
        };
    return switch (this) {
      SharedTriggerProperty.id => withCommon(
        common.copyWith(id: value as String?),
      ),
      SharedTriggerProperty.threshold => withCommon(
        common.copyWith(threshold: value as String?),
      ),
      SharedTriggerProperty.resumeTimeout => withCommon(
        common.copyWith(resumeTimeout: value as int?),
      ),
      SharedTriggerProperty.accelerated => withCommon(
        common.copyWith(accelerated: value as bool?),
      ),
      SharedTriggerProperty.blockEvents => withCommon(
        common.copyWith(blockEvents: value as bool?),
      ),
      SharedTriggerProperty.clearModifiers => withCommon(
        common.copyWith(clearModifiers: value as bool?),
      ),
      SharedTriggerProperty.setLastTrigger => withCommon(
        common.copyWith(setLastTrigger: value as bool?),
      ),
      SharedTriggerProperty.endConditions => withCommon(
        common.copyWith(endConditions: value as Condition?),
      ),
      SharedTriggerProperty.mouseButtons => withCommon(
        common.copyWith(
          mouseButtons: value as List<MouseButtonValue>? ?? const [],
        ),
      ),
      SharedTriggerProperty.mouseButtonsExactOrder => withCommon(
        common.copyWith(mouseButtonsExactOrder: value as bool? ?? false),
      ),
      SharedTriggerProperty.fingers => switch (gesture) {
        TouchpadGesture() => gesture.withFingers(value as FingerRange?),
        TouchscreenGesture() => gesture.withFingers(value as FingerRange?),
        _ => gesture,
      },
      SharedTriggerProperty.speed => withMotion(
        (m) => m.copyWith(speed: value as TriggerSpeed?),
      ),
      SharedTriggerProperty.instant => switch (gesture) {
        PressGesture() => gesture.copyWith(instant: value as bool?),
        _ => gesture,
      },
      SharedTriggerProperty.lockPointer => withMotion(
        (m) => m.copyWith(lockPointer: value as bool?),
      ),
    };
  }
}

/// Gesture fields absent here never inherit.
const Map<ConfigDirtyField, SharedTriggerProperty> sharedPropertyOfField = {
  ConfigDirtyField.gestureId: SharedTriggerProperty.id,
  ConfigDirtyField.gestureThreshold: SharedTriggerProperty.threshold,
  ConfigDirtyField.gestureResumeTimeout: SharedTriggerProperty.resumeTimeout,
  ConfigDirtyField.gestureAccelerated: SharedTriggerProperty.accelerated,
  ConfigDirtyField.gestureBlockEvents: SharedTriggerProperty.blockEvents,
  ConfigDirtyField.gestureClearModifiers: SharedTriggerProperty.clearModifiers,
  ConfigDirtyField.gestureSetLastTrigger: SharedTriggerProperty.setLastTrigger,
  ConfigDirtyField.gestureEndConditions: SharedTriggerProperty.endConditions,
  ConfigDirtyField.gestureMouseButtons: SharedTriggerProperty.mouseButtons,
  ConfigDirtyField.gestureMouseButtonsExactOrder:
      SharedTriggerProperty.mouseButtonsExactOrder,
  ConfigDirtyField.touchpadFingers: SharedTriggerProperty.fingers,
  ConfigDirtyField.touchscreenFingers: SharedTriggerProperty.fingers,
  ConfigDirtyField.mouseGestureStrokeMotionSpeed: SharedTriggerProperty.speed,
  ConfigDirtyField.mouseGestureSwipeMotionSpeed: SharedTriggerProperty.speed,
  ConfigDirtyField.circleMotionSpeed: SharedTriggerProperty.speed,
  ConfigDirtyField.touchpadMotionSpeed: SharedTriggerProperty.speed,
  ConfigDirtyField.touchscreenMotionSpeed: SharedTriggerProperty.speed,
  ConfigDirtyField.pressInstant: SharedTriggerProperty.instant,
  ConfigDirtyField.mouseGestureStrokeMotionLockPointer:
      SharedTriggerProperty.lockPointer,
  ConfigDirtyField.mouseGestureSwipeMotionLockPointer:
      SharedTriggerProperty.lockPointer,
  ConfigDirtyField.circleMotionLockPointer: SharedTriggerProperty.lockPointer,
};

MotionCommon? _motionOf(Gesture gesture) => switch (gesture) {
  MouseGesture(:final motion) => motion,
  TouchpadGesture() => gesture.motionOrNull,
  TouchscreenGesture() => gesture.motionOrNull,
  _ => null,
};

Gesture _withMotion(Gesture gesture, MotionCommon motion) => switch (gesture) {
  MouseGesture() => gesture.withMotion(motion),
  TouchpadGesture() => gesture.withMotion(motion),
  TouchscreenGesture() => gesture.withMotion(motion),
  _ => gesture,
};

/// One property a gesture picks up from an ancestor group.
class InheritedProperty {
  const InheritedProperty({
    required this.property,
    required this.value,
    required this.groupName,
    required this.groupEditId,
  });

  final SharedTriggerProperty property;

  /// The nearest ancestor's value when several set it.
  final Object? value;

  final String groupName;

  /// Identifies the group for [GestureGroupLocation]-based navigation. Null
  /// only before `assignEditIds` has run.
  final int? groupEditId;
}

/// Resolves, per gesture editId, the properties that gesture inherits from its
/// ancestor groups on [device].
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
          final inherited = <InheritedProperty>[];
          for (final property in SharedTriggerProperty.values) {
            final source = ancestors.lastWhereOrNull(
              (ancestor) => property.read(ancestor) != null,
            );
            if (source == null) continue;
            inherited.add(
              InheritedProperty(
                property: property,
                value: property.read(source),
                groupName: source.name,
                groupEditId: source.editId,
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

/// Where a gesture sets a value its groups also set, the group's replaces it.
Config withGroupValues(Config config) => _mapLeaves(
  config,
  (gesture, handed) {
    var next = gesture;
    for (final property in handed.keys) {
      if (property.readOn(next) != null) next = property.writeOn(next, null);
    }
    return next;
  },
);

/// [config] as the daemon runs it, group values filled into each gesture.
Config withInheritedValues(Config config) => _mapLeaves(
  config,
  (gesture, handed) {
    var next = gesture;
    for (final MapEntry(key: property, :value) in handed.entries) {
      if (property.readOn(next) == null) next = property.writeOn(next, value);
    }
    return next;
  },
);

Config _mapLeaves(
  Config config,
  Gesture Function(Gesture gesture, Map<SharedTriggerProperty, Object> handed)
  map,
) {
  List<GestureNode>? walk(
    List<GestureNode> nodes,
    Map<SharedTriggerProperty, Object> handed,
  ) {
    var changed = false;
    final out = <GestureNode>[];
    for (final node in nodes) {
      switch (node) {
        case GestureGroupNode(:final children):
          final below = walk(children, {
            ...handed,
            for (final property in SharedTriggerProperty.values)
              property: ?property.read(node),
          });
          changed |= below != null;
          out.add(below == null ? node : node.copyWith(children: below));
        case GestureLeaf(:final gesture):
          final next = handed.isEmpty ? gesture : map(gesture, handed);
          changed |= next != gesture;
          out.add(next == gesture ? node : GestureNode.leaf(next));
      }
    }
    return changed ? out : null;
  }

  var result = config;
  for (final device in DeviceType.values) {
    final nodes = walk(config.nodesForDevice(device), const {});
    if (nodes != null) result = result.withNodesForDevice(device, nodes);
  }
  return result;
}
