// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_schema.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case, unused_element, invalid_null_aware_operator, unused_local_variable, unnecessary_type_check, avoid_equals_and_hash_code_on_mutable_classes, no_literal_bool_comparisons

Lens<Config, Config> _configRootLens() => Lens<Config, Config>(
  get: (root) => root as Config,
  set: (root, next) => next,
  name: 'config',
);

enum ConfigDirtyField {
  globalSettingsAutoreload,
  globalSettingsExternalVariableAccess,
  globalSettingsMouseStrokeOverlayEnabled,
  globalSettingsNotificationsConfigError,
  globalSettingsEmergencyCombination,
  gestureId,
  gestureMouseButtons,
  gestureMouseButtonsExactOrder,
  gestureConditions,
  gestureEndConditions,
  gestureBlockEvents,
  gestureClearModifiers,
  gestureResumeTimeout,
  gestureSetLastTrigger,
  gestureThreshold,
  gestureAccelerated,
  gestureExtra,
  actionCommand,
  actionWait,
  actionComponent,
  actionShortcut,
  actionWindowId,
  actionRules,
  actionDuration,
  actionExpression,
  menuItemText,
  menuItemIcon,
  menuItemActions,
  menuItemSubMenuText,
  menuItemSubMenuIcon,
  menuItemSectionText,
  actionRaw,
  actionInputEntries,
  actionInputDelay,
  actionTriggerOn,
  actionInterval,
  actionThreshold,
  actionLimit,
  actionEnabled,
  actionConflicting,
  actionConditions,
  actionId,
  mouseGestureStrokeMotionSpeed,
  mouseGestureStrokeMotionLockPointer,
  mouseGestureStrokeStrokes,
  mouseGestureSwipeMotionSpeed,
  mouseGestureSwipeMotionLockPointer,
  mouseGestureSwipeModeDirection,
  mouseGestureSwipeModeAngleMinAngle,
  mouseGestureSwipeModeAngleMaxAngle,
  mouseGestureSwipeModeAngleBidirectional,
  circleMotionSpeed,
  circleMotionLockPointer,
  circleDirection,
  pressMotionSpeed,
  pressMotionLockPointer,
  pressInstant,
  wheelMotionSpeed,
  wheelMotionLockPointer,
  wheelDirection,
  shortcutKeys,
  touchpadFingers,
  touchpadMotionSpeed,
  touchpadSwipeMode,
  touchpadPinchDirection,
  touchpadRotateDirection,
  touchpadCircleDirection,
  touchpadStrokeStrokes,
  touchscreenFingers,
  touchscreenMotionSpeed,
  touchscreenSwipeMode,
  touchscreenPinchDirection,
  touchscreenRotateDirection,
  touchscreenCircleDirection,
  touchscreenStrokeStrokes,
  gestureGroupName,
  gestureGroupEnabled,
  gestureGroupConditions,
  gestureGroupId,
  gestureGroupThreshold,
  gestureGroupResumeTimeout,
  gestureGroupAccelerated,
  gestureGroupBlockEvents,
  gestureGroupClearModifiers,
  gestureGroupSetLastTrigger,
  gestureGroupEndConditions,
  gestureGroupMouseButtons,
  gestureGroupMouseButtonsExactOrder,
  gestureGroupFingers,
  gestureGroupSpeed,
  gestureGroupInstant,
  gestureGroupLockPointer,
  deviceRuleConditions,
  deviceRulePropertiesIgnore,
  deviceRulePropertiesGrab,
  deviceRulePropertiesMotionTimeout,
  deviceRulePropertiesMotionThreshold,
  deviceRulePropertiesPressTimeout,
  deviceRulePropertiesSwipeAngleTolerance,
  deviceRulePropertiesUnblockButtonsOnTimeout,
  deviceRulePropertiesButtonpad,
  deviceRulePropertiesClickTimeout,
  deviceRulePropertiesHandleEvdevEvents,
  deviceRulePropertiesMotionThreshold2,
  deviceRulePropertiesMotionThreshold3,
  deviceRulePropertiesPressureRangesFinger,
  deviceRulePropertiesPressureRangesThumb,
  deviceRulePropertiesPressureRangesPalm,
  speedEvents,
  speedSwipeThreshold,
  speedPinchInThreshold,
  speedPinchOutThreshold,
  speedRotateThreshold,
}

final class DeviceRuleLocation {
  const DeviceRuleLocation({required this.deviceRuleIndex});

  final int deviceRuleIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceRuleLocation && other.deviceRuleIndex == deviceRuleIndex);

  @override
  int get hashCode => deviceRuleIndex.hashCode;
}

final class MenuItemLocation {
  const MenuItemLocation({required this.action, required this.itemId});

  final ActionLocation action;
  final int itemId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MenuItemLocation &&
          other.action == action &&
          other.itemId == itemId);

  @override
  int get hashCode => Object.hash(action, itemId);
}

final class GestureLocation {
  const GestureLocation({required this.device, required this.editId});

  final DeviceType device;
  final int editId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GestureLocation &&
          other.device == device &&
          other.editId == editId);

  @override
  int get hashCode => Object.hash(device, editId);
}

final class GestureGroupLocation {
  const GestureGroupLocation({required this.device, required this.editId});

  final DeviceType device;
  final int editId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GestureGroupLocation &&
          other.device == device &&
          other.editId == editId);

  @override
  int get hashCode => Object.hash(device, editId);
}

final _configGlobalSettingsPart = LensPart<Config, GlobalSettings>(
  get: (value) => value.globalSettings,
  set: (value, next) => value.copyWith(globalSettings: next),
  name: 'globalSettings',
);

final _configGlobalSettingsAutoreloadPart = LensPart<GlobalSettings, bool>(
  get: (value) => value.autoreload ?? true,
  set: (value, next) => value.copyWith(autoreload: next == true ? null : next),
  name: 'autoreload',
);

final _configGlobalSettingsExternalVariableAccessPart =
    LensPart<GlobalSettings, bool>(
      get: (value) => value.externalVariableAccess ?? true,
      set: (value, next) =>
          value.copyWith(externalVariableAccess: next == true ? null : next),
      name: 'externalVariableAccess',
    );

final _configGlobalSettingsMouseStrokeOverlayEnabledPart =
    LensPart<GlobalSettings, bool?>(
      get: (value) => value.mouseStrokeOverlayEnabled,
      set: (value, next) => value.copyWith(mouseStrokeOverlayEnabled: next),
      name: 'mouseStrokeOverlayEnabled',
    );

final _configGlobalSettingsNotificationsConfigErrorPart =
    LensPart<GlobalSettings, bool>(
      get: (value) => value.notificationsConfigError ?? true,
      set: (value, next) =>
          value.copyWith(notificationsConfigError: next == true ? null : next),
      name: 'notificationsConfigError',
    );

final _configGlobalSettingsEmergencyCombinationPart =
    LensPart<GlobalSettings, List<String>?>(
      get: (value) => value.emergencyCombination,
      set: (value, next) => value.copyWith(emergencyCombination: next),
      name: 'emergencyCombination',
    );

List<Gesture> _gestureLensLeafFlatten(List<GestureNode> nodes) {
  final out = <Gesture>[];
  for (final n in nodes) {
    final e = n is GestureLeaf ? n.gesture : null;
    if (e != null) out.add(e);
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) out.addAll(_gestureLensLeafFlatten(kids));
  }
  return out;
}

Gesture? _gestureLensLeafFindElement(List<GestureNode> nodes, int key) {
  for (final n in nodes) {
    if (n is GestureLeaf && n.gesture.common.editId == key) {
      final e = n is GestureLeaf ? n.gesture : null;
      if (e != null) return e;
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final nested = _gestureLensLeafFindElement(kids, key);
      if (nested != null) return nested;
    }
  }
  return null;
}

List<GestureNode>? _gestureLensLeafReplace(
  List<GestureNode> nodes,
  int key,
  GestureNode value,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n is GestureLeaf && n.gesture.common.editId == key) {
      return List<GestureNode>.of(nodes)..[i] = value;
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final next = _gestureLensLeafReplace(kids, key, value);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

List<GestureNode>? _gestureLensLeafRemove(List<GestureNode> nodes, int key) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n is GestureLeaf && n.gesture.common.editId == key) {
      return List<GestureNode>.of(nodes)..removeAt(i);
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final next = _gestureLensLeafRemove(kids, key);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

List<GestureNode>? _gestureLensLeafInsertAfter(
  List<GestureNode> nodes,
  int key,
  List<GestureNode> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n is GestureLeaf && n.gesture.common.editId == key) {
      return List<GestureNode>.of(nodes)..insertAll(i + 1, inserted);
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final next = _gestureLensLeafInsertAfter(kids, key, inserted);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

GestureGroupNode? _gestureLensGroupFindElement(
  List<GestureNode> nodes,
  int key,
) {
  for (final n in nodes) {
    if (n is GestureGroupNode && n.editId == key) {
      final e = n is GestureGroupNode ? n : null;
      if (e != null) return e;
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final nested = _gestureLensGroupFindElement(kids, key);
      if (nested != null) return nested;
    }
  }
  return null;
}

List<GestureNode>? _gestureLensGroupReplace(
  List<GestureNode> nodes,
  int key,
  GestureNode value,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n is GestureGroupNode && n.editId == key) {
      return List<GestureNode>.of(nodes)..[i] = value;
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final next = _gestureLensGroupReplace(kids, key, value);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

List<GestureNode>? _gestureLensGroupRemove(List<GestureNode> nodes, int key) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n is GestureGroupNode && n.editId == key) {
      return List<GestureNode>.of(nodes)..removeAt(i);
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final next = _gestureLensGroupRemove(kids, key);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

List<GestureNode>? _gestureLensGroupSplice(List<GestureNode> nodes, int key) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final kids = n is GestureGroupNode ? n.children : null;
    if (n is GestureGroupNode && n.editId == key) {
      if (kids == null) return null;
      return List<GestureNode>.of(nodes)
        ..removeAt(i)
        ..insertAll(i, kids);
    }
    if (kids != null) {
      final next = _gestureLensGroupSplice(kids, key);
      if (next != null) {
        return List<GestureNode>.of(nodes)
          ..[i] =
              (n as GestureGroupNode).copyWith(children: next) as GestureNode;
      }
    }
  }
  return null;
}

(bool, int?) _gestureLensGroupParentOf(
  List<GestureNode> nodes,
  int key,
  int? parent,
) {
  for (final n in nodes) {
    if (n is GestureGroupNode && n.editId == key) {
      return (true, parent);
    }
    final kids = n is GestureGroupNode ? n.children : null;
    if (kids != null) {
      final nested = _gestureLensGroupParentOf(
        kids,
        key,
        n is GestureGroupNode ? n.editId : null,
      );
      if (nested.$1) return nested;
    }
  }
  return (false, null);
}

Lens<Config, Gesture> gestureLens(
  GestureLocation location,
) => Lens<Config, Gesture>(
  get: (root) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse => _gestureLensLeafFindElement(
        container.mouseNodes,
        location.editId,
      )!,
      DeviceType.keyboard => _gestureLensLeafFindElement(
        container.keyboardNodes,
        location.editId,
      )!,
      DeviceType.pointer => _gestureLensLeafFindElement(
        container.pointerNodes,
        location.editId,
      )!,
      DeviceType.touchpad => _gestureLensLeafFindElement(
        container.touchpadNodes,
        location.editId,
      )!,
      DeviceType.touchscreen => _gestureLensLeafFindElement(
        container.touchscreenNodes,
        location.editId,
      )!,
    };
  },
  set: (root, nextValue) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse => () {
        final next = _gestureLensLeafReplace(
          container.mouseNodes,
          location.editId,
          GestureNode.leaf(nextValue as MouseGesture) as GestureNode,
        );
        if (next == null) return container;
        return container.copyWith(mouseNodes: next);
      }(),
      DeviceType.keyboard => () {
        final next = _gestureLensLeafReplace(
          container.keyboardNodes,
          location.editId,
          GestureNode.leaf(nextValue as KeyboardGesture) as GestureNode,
        );
        if (next == null) return container;
        return container.copyWith(keyboardNodes: next);
      }(),
      DeviceType.pointer => () {
        final next = _gestureLensLeafReplace(
          container.pointerNodes,
          location.editId,
          GestureNode.leaf(nextValue as PointerGesture) as GestureNode,
        );
        if (next == null) return container;
        return container.copyWith(pointerNodes: next);
      }(),
      DeviceType.touchpad => () {
        final next = _gestureLensLeafReplace(
          container.touchpadNodes,
          location.editId,
          GestureNode.leaf(nextValue as TouchpadGesture) as GestureNode,
        );
        if (next == null) return container;
        return container.copyWith(touchpadNodes: next);
      }(),
      DeviceType.touchscreen => () {
        final next = _gestureLensLeafReplace(
          container.touchscreenNodes,
          location.editId,
          GestureNode.leaf(nextValue as TouchscreenGesture) as GestureNode,
        );
        if (next == null) return container;
        return container.copyWith(touchscreenNodes: next);
      }(),
    };
  },
  canGet: (root) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse =>
        _gestureLensLeafFindElement(container.mouseNodes, location.editId) !=
            null,
      DeviceType.keyboard =>
        _gestureLensLeafFindElement(container.keyboardNodes, location.editId) !=
            null,
      DeviceType.pointer =>
        _gestureLensLeafFindElement(container.pointerNodes, location.editId) !=
            null,
      DeviceType.touchpad =>
        _gestureLensLeafFindElement(container.touchpadNodes, location.editId) !=
            null,
      DeviceType.touchscreen =>
        _gestureLensLeafFindElement(
              container.touchscreenNodes,
              location.editId,
            ) !=
            null,
    };
  },
  name: 'gesture[${location.device}/#${location.editId}]',
);

Lens<Config, GestureGroupNode> gestureGroupLens(
  GestureGroupLocation location,
) => Lens<Config, GestureGroupNode>(
  get: (root) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse => _gestureLensGroupFindElement(
        container.mouseNodes,
        location.editId,
      )!,
      DeviceType.keyboard => _gestureLensGroupFindElement(
        container.keyboardNodes,
        location.editId,
      )!,
      DeviceType.pointer => _gestureLensGroupFindElement(
        container.pointerNodes,
        location.editId,
      )!,
      DeviceType.touchpad => _gestureLensGroupFindElement(
        container.touchpadNodes,
        location.editId,
      )!,
      DeviceType.touchscreen => _gestureLensGroupFindElement(
        container.touchscreenNodes,
        location.editId,
      )!,
    };
  },
  set: (root, nextValue) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse => () {
        final next = _gestureLensGroupReplace(
          container.mouseNodes,
          location.editId,
          nextValue,
        );
        if (next == null) return container;
        return container.copyWith(mouseNodes: next);
      }(),
      DeviceType.keyboard => () {
        final next = _gestureLensGroupReplace(
          container.keyboardNodes,
          location.editId,
          nextValue,
        );
        if (next == null) return container;
        return container.copyWith(keyboardNodes: next);
      }(),
      DeviceType.pointer => () {
        final next = _gestureLensGroupReplace(
          container.pointerNodes,
          location.editId,
          nextValue,
        );
        if (next == null) return container;
        return container.copyWith(pointerNodes: next);
      }(),
      DeviceType.touchpad => () {
        final next = _gestureLensGroupReplace(
          container.touchpadNodes,
          location.editId,
          nextValue,
        );
        if (next == null) return container;
        return container.copyWith(touchpadNodes: next);
      }(),
      DeviceType.touchscreen => () {
        final next = _gestureLensGroupReplace(
          container.touchscreenNodes,
          location.editId,
          nextValue,
        );
        if (next == null) return container;
        return container.copyWith(touchscreenNodes: next);
      }(),
    };
  },
  canGet: (root) {
    final container = root as Config;
    return switch (location.device) {
      DeviceType.mouse =>
        _gestureLensGroupFindElement(container.mouseNodes, location.editId) !=
            null,
      DeviceType.keyboard =>
        _gestureLensGroupFindElement(
              container.keyboardNodes,
              location.editId,
            ) !=
            null,
      DeviceType.pointer =>
        _gestureLensGroupFindElement(container.pointerNodes, location.editId) !=
            null,
      DeviceType.touchpad =>
        _gestureLensGroupFindElement(
              container.touchpadNodes,
              location.editId,
            ) !=
            null,
      DeviceType.touchscreen =>
        _gestureLensGroupFindElement(
              container.touchscreenNodes,
              location.editId,
            ) !=
            null,
    };
  },
  name: 'gestureGroup[${location.device}/#${location.editId}]',
);

List<GestureNode> gestureNodesForDevice(Config root, DeviceType device) =>
    switch (device) {
      DeviceType.mouse => root.mouseNodes,
      DeviceType.keyboard => root.keyboardNodes,
      DeviceType.pointer => root.pointerNodes,
      DeviceType.touchpad => root.touchpadNodes,
      DeviceType.touchscreen => root.touchscreenNodes,
      _ => const <GestureNode>[],
    };

Config withGestureNodesForDevice(
  Config root,
  DeviceType device,
  List<GestureNode> nodes,
) => switch (device) {
  DeviceType.mouse => root.copyWith(mouseNodes: nodes),
  DeviceType.keyboard => root.copyWith(keyboardNodes: nodes),
  DeviceType.pointer => root.copyWith(pointerNodes: nodes),
  DeviceType.touchpad => root.copyWith(touchpadNodes: nodes),
  DeviceType.touchscreen => root.copyWith(touchscreenNodes: nodes),
  _ => root,
};

List<Gesture> gesturesForDevice(Config root, DeviceType device) =>
    _gestureLensLeafFlatten(gestureNodesForDevice(root, device));

Gesture? gestureAt(Config? root, GestureLocation location) {
  if (root == null) return null;
  return _gestureLensLeafFindElement(
    gestureNodesForDevice(root, location.device),
    location.editId,
  );
}

int? gestureIndexOf(Config? root, GestureLocation location) {
  if (root == null) return null;
  final list = gesturesForDevice(root, location.device);
  for (var i = 0; i < list.length; i++) {
    if (list[i].common.editId == location.editId) {
      return i;
    }
  }
  return null;
}

GestureLocation? gestureLocationAt(Config? root, DeviceType device, int index) {
  if (root == null) return null;
  final list = gesturesForDevice(root, device);
  if (index < 0 || index >= list.length) return null;
  final key = list[index].common.editId;
  if (key == null) return null;
  return GestureLocation(device: device, editId: key);
}

GestureLocation? gestureLocationOf(DeviceType device, Gesture value) {
  final key = value.common.editId;
  if (key == null) return null;
  return GestureLocation(device: device, editId: key);
}

Config addGesture(Config root, DeviceType device, Gesture value) =>
    withGestureNodesForDevice(root, device, [
      ...gestureNodesForDevice(root, device),
      GestureNode.leaf(value) as GestureNode,
    ]);

Config addGestureToGestureGroup(
  Config root,
  GestureGroupLocation location,
  Gesture value,
) {
  final nodes = gestureNodesForDevice(root, location.device);
  final target = _gestureLensGroupFindElement(nodes, location.editId);
  if (target == null) return root;
  final next = _gestureLensGroupReplace(
    nodes,
    location.editId,
    target.copyWith(
          children: [
            ...target.children,
            GestureNode.leaf(value) as GestureNode,
          ],
        )
        as GestureGroupNode,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

Config insertGestureAfter(
  Config root,
  GestureLocation location,
  Gesture value,
) {
  final next = _gestureLensLeafInsertAfter(
    gestureNodesForDevice(root, location.device),
    location.editId,
    [GestureNode.leaf(value) as GestureNode],
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

Config replaceGesture(Config root, GestureLocation location, Gesture value) {
  final next = _gestureLensLeafReplace(
    gestureNodesForDevice(root, location.device),
    location.editId,
    GestureNode.leaf(value) as GestureNode,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

Config updateGesture(
  Config root,
  GestureLocation location,
  Gesture Function(Gesture value) update,
) {
  final value = gestureAt(root, location);
  if (value == null) return root;
  return replaceGesture(root, location, update(value));
}

Config removeGesture(Config root, GestureLocation location) {
  final next = _gestureLensLeafRemove(
    gestureNodesForDevice(root, location.device),
    location.editId,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

GestureGroupNode? gestureGroupAt(Config? root, GestureGroupLocation location) {
  if (root == null) return null;
  return _gestureLensGroupFindElement(
    gestureNodesForDevice(root, location.device),
    location.editId,
  );
}

GestureGroupLocation? gestureGroupLocationOf(
  DeviceType device,
  GestureGroupNode value,
) {
  final key = value.editId;
  if (key == null) return null;
  return GestureGroupLocation(device: device, editId: key);
}

Config addGestureGroup(
  Config root,
  DeviceType device,
  GestureGroupNode value, {
  int? parentKey,
}) {
  final nodes = gestureNodesForDevice(root, device);
  if (parentKey == null) {
    return withGestureNodesForDevice(root, device, [
      ...nodes,
      value as GestureNode,
    ]);
  }
  final parent = _gestureLensGroupFindElement(nodes, parentKey);
  if (parent == null) return root;
  final next = _gestureLensGroupReplace(
    nodes,
    parentKey,
    parent.copyWith(children: [...parent.children, value as GestureNode])
        as GestureGroupNode,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, device, next);
}

Config removeGestureGroup(Config root, GestureGroupLocation location) {
  final next = _gestureLensGroupRemove(
    gestureNodesForDevice(root, location.device),
    location.editId,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

Config spliceGestureGroup(Config root, GestureGroupLocation location) {
  final next = _gestureLensGroupSplice(
    gestureNodesForDevice(root, location.device),
    location.editId,
  );
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

int? parentOfGestureGroup(Config root, GestureGroupLocation location) =>
    _gestureLensGroupParentOf(
      gestureNodesForDevice(root, location.device),
      location.editId,
      null,
    ).$2;

Config moveGestureGroup(
  Config root,
  GestureGroupLocation location, {
  int? beforeKey,
  int? newParentKey,
}) {
  final key = location.editId;
  if (beforeKey == key || newParentKey == key) return root;
  final nodes = gestureNodesForDevice(root, location.device);
  final moved = _gestureLensGroupFindElement(nodes, key);
  if (moved == null) return root;
  if (newParentKey != null) {
    if (_gestureLensGroupFindElement(moved.children, newParentKey) != null) {
      return root;
    }
    if (_gestureLensGroupFindElement(nodes, newParentKey) == null) {
      return root;
    }
  }
  final without = _gestureLensGroupRemove(nodes, key)!;
  List<GestureNode> insertAmong(List<GestureNode> level) {
    if (beforeKey != null) {
      for (var i = 0; i < level.length; i++) {
        final n = level[i];
        if (n is GestureGroupNode && n.editId == beforeKey) {
          return List<GestureNode>.of(level)..insert(i, moved as GestureNode);
        }
      }
    }
    return [...level, moved as GestureNode];
  }

  List<GestureNode>? next;
  if (newParentKey == null) {
    next = insertAmong(without);
  } else {
    final parent = _gestureLensGroupFindElement(without, newParentKey);
    if (parent == null) return root;
    next = _gestureLensGroupReplace(
      without,
      newParentKey,
      parent.copyWith(children: insertAmong(parent.children))
          as GestureGroupNode,
    );
  }
  if (next == null) return root;
  return withGestureNodesForDevice(root, location.device, next);
}

Config reorderGestures(
  Config root,
  DeviceType device,
  List<int> orderedKeys,
  Map<int, int?> reassigned,
) {
  final nodes = gestureNodesForDevice(root, device);
  final leaves = _gestureLensLeafFlatten(nodes);
  if (orderedKeys.length != leaves.length) return root;
  if (orderedKeys.toSet().length != orderedKeys.length) return root;
  final byKey = <int, Gesture>{};
  for (final leaf in leaves) {
    final k = leaf.common.editId;
    if (k == null) return root;
    byKey[k] = leaf;
  }
  if (byKey.length != leaves.length) return root;
  for (final k in orderedKeys) {
    if (!byKey.containsKey(k)) return root;
  }
  final membership = <int, int?>{};
  final groupKeys = <int>{};
  var valid = true;
  void collect(List<GestureNode> level, int? parent) {
    for (final n in level) {
      if (n is GestureLeaf) {
        final k = n.gesture.common.editId;
        if (k != null) membership[k] = parent;
      }
      if (n is GestureGroupNode) {
        final gk = n.editId;
        if (gk == null) {
          valid = false;
          return;
        }
        groupKeys.add(gk);
        collect(n.children, gk);
      }
    }
  }

  collect(nodes, null);
  if (!valid) return root;
  for (final entry in reassigned.entries) {
    if (!membership.containsKey(entry.key)) continue;
    final target = entry.value;
    if (target != null && !groupKeys.contains(target)) return root;
    membership[entry.key] = target;
  }
  final orderOf = <int, int>{
    for (var i = 0; i < orderedKeys.length; i++) orderedKeys[i]: i,
  };
  final membersOf = <int?, List<Gesture>>{};
  for (final k in orderedKeys) {
    membersOf.putIfAbsent(membership[k], () => []).add(byKey[k]!);
  }
  int subtreeFirst(GestureGroupNode g) {
    var first = orderedKeys.length + 1;
    void visit(GestureGroupNode v) {
      for (final leaf in membersOf[v.editId] ?? const <Gesture>[]) {
        final order = orderOf[leaf.common.editId];
        if (order != null && order < first) first = order;
      }
      for (final child in v.children) {
        if (child is GestureGroupNode) visit(child);
      }
    }

    visit(g);
    return first;
  }

  List<GestureNode> rebuild(int? parentKey, List<GestureNode> level) {
    final ordered = <(int, int, GestureNode)>[];
    var seq = 0;
    for (final leaf in membersOf[parentKey] ?? const <Gesture>[]) {
      ordered.add((
        orderOf[leaf.common.editId] ?? orderedKeys.length + 1,
        seq++,
        GestureNode.leaf(leaf) as GestureNode,
      ));
    }
    for (final n in level) {
      if (n is! GestureGroupNode) continue;
      ordered.add((
        subtreeFirst(n),
        seq++,
        n.copyWith(children: rebuild(n.editId, n.children)) as GestureNode,
      ));
    }
    ordered.sort((a, b) {
      final byOrder = a.$1.compareTo(b.$1);
      return byOrder != 0 ? byOrder : a.$2.compareTo(b.$2);
    });
    return [for (final e in ordered) e.$3];
  }

  return withGestureNodesForDevice(root, device, rebuild(null, nodes));
}

Config assignGestureKeys(Config root, int Function() nextKey) {
  final seen = <int>{};
  (List<GestureNode>, bool) walk(List<GestureNode> nodes) {
    var changed = false;
    final out = <GestureNode>[];
    for (final n in nodes) {
      if (n is GestureLeaf) {
        final e = n.gesture;
        final k = e.common.editId;
        if (k == null || !seen.add(k)) {
          final fresh = nextKey();
          seen.add(fresh);
          out.add(
            GestureNode.leaf(e.withCommon(e.common.copyWith(editId: fresh)))
                as GestureNode,
          );
          changed = true;
        } else {
          out.add(n);
        }
        continue;
      }
      if (n is GestureGroupNode) {
        var g = n;
        final k = n.editId;
        if (k == null || !seen.add(k)) {
          final fresh = nextKey();
          seen.add(fresh);
          g = g.copyWith(editId: fresh) as GestureGroupNode;
          changed = true;
        }
        final (children, childChanged) = walk(g.children);
        if (childChanged) {
          g = g.copyWith(children: children) as GestureGroupNode;
          changed = true;
        }
        out.add(g as GestureNode);
        continue;
      }
      out.add(n);
    }
    return (out, changed);
  }

  var next = root;
  var anyChanged = false;
  {
    final (nodes, changed) = walk(root.mouseNodes);
    if (changed) {
      next = next.copyWith(mouseNodes: nodes);
      anyChanged = true;
    }
  }
  {
    final (nodes, changed) = walk(root.keyboardNodes);
    if (changed) {
      next = next.copyWith(keyboardNodes: nodes);
      anyChanged = true;
    }
  }
  {
    final (nodes, changed) = walk(root.pointerNodes);
    if (changed) {
      next = next.copyWith(pointerNodes: nodes);
      anyChanged = true;
    }
  }
  {
    final (nodes, changed) = walk(root.touchpadNodes);
    if (changed) {
      next = next.copyWith(touchpadNodes: nodes);
      anyChanged = true;
    }
  }
  {
    final (nodes, changed) = walk(root.touchscreenNodes);
    if (changed) {
      next = next.copyWith(touchscreenNodes: nodes);
      anyChanged = true;
    }
  }
  return anyChanged ? next : root;
}

Config preserveGestureKeys({required Config from, required Config to}) {
  List<GestureNode> zip(List<GestureNode> source, List<GestureNode> target) {
    final out = <GestureNode>[];
    for (var i = 0; i < target.length; i++) {
      final t = target[i];
      final s = i < source.length ? source[i] : null;
      if (s is GestureLeaf && t is GestureLeaf) {
        final k = s.gesture.common.editId;
        if (k == null) {
          out.add(t);
        } else {
          final e = t.gesture;
          out.add(
            GestureNode.leaf(e.withCommon(e.common.copyWith(editId: k)))
                as GestureNode,
          );
        }
        continue;
      }
      if (s is GestureGroupNode && t is GestureGroupNode) {
        final k = s.editId;
        var g =
            t.copyWith(children: zip(s.children, t.children))
                as GestureGroupNode;
        if (k != null) g = g.copyWith(editId: k) as GestureGroupNode;
        out.add(g as GestureNode);
        continue;
      }
      out.add(t);
    }
    return out;
  }

  return to.copyWith(
    mouseNodes: zip(from.mouseNodes, to.mouseNodes),
    keyboardNodes: zip(from.keyboardNodes, to.keyboardNodes),
    pointerNodes: zip(from.pointerNodes, to.pointerNodes),
    touchpadNodes: zip(from.touchpadNodes, to.touchpadNodes),
    touchscreenNodes: zip(from.touchscreenNodes, to.touchscreenNodes),
  );
}

final _configGestureCommonPart = LensPart<Gesture, TriggerCommon>(
  get: (value) => value.common,
  set: (value, next) => value.withCommon(next),
  name: 'common',
);

final _configGesturecommonIdPart = LensPart<TriggerCommon, String?>(
  get: (value) => value.id,
  set: (value, next) => value.copyWith(id: next),
  name: 'id',
);

final _configGesturecommonMouseButtonsPart =
    LensPart<TriggerCommon, List<MouseButtonValue>>(
      get: (value) => value.mouseButtons,
      set: (value, next) => value.copyWith(mouseButtons: next),
      name: 'mouseButtons',
    );

final _configGesturecommonMouseButtonsExactOrderPart =
    LensPart<TriggerCommon, bool>(
      get: (value) => value.mouseButtonsExactOrder,
      set: (value, next) => value.copyWith(mouseButtonsExactOrder: next),
      name: 'mouseButtonsExactOrder',
    );

final _configGesturecommonConditionsPart = LensPart<TriggerCommon, Condition?>(
  get: (value) => value.conditions,
  set: (value, next) => value.copyWith(conditions: next),
  name: 'conditions',
);

final _configGesturecommonEndConditionsPart =
    LensPart<TriggerCommon, Condition?>(
      get: (value) => value.endConditions,
      set: (value, next) => value.copyWith(endConditions: next),
      name: 'endConditions',
    );

final _configGesturecommonBlockEventsPart = LensPart<TriggerCommon, bool>(
  get: (value) => value.blockEvents ?? true,
  set: (value, next) => value.copyWith(blockEvents: next == true ? null : next),
  name: 'blockEvents',
);

final _configGesturecommonClearModifiersPart = LensPart<TriggerCommon, bool>(
  get: (value) => value.clearModifiers ?? false,
  set: (value, next) =>
      value.copyWith(clearModifiers: next == false ? null : next),
  name: 'clearModifiers',
);

final _configGesturecommonResumeTimeoutPart = LensPart<TriggerCommon, int?>(
  get: (value) => value.resumeTimeout,
  set: (value, next) => value.copyWith(resumeTimeout: next),
  name: 'resumeTimeout',
);

final _configGesturecommonSetLastTriggerPart = LensPart<TriggerCommon, bool>(
  get: (value) => value.setLastTrigger ?? true,
  set: (value, next) =>
      value.copyWith(setLastTrigger: next == true ? null : next),
  name: 'setLastTrigger',
);

final _configGesturecommonThresholdPart = LensPart<TriggerCommon, String?>(
  get: (value) => value.threshold,
  set: (value, next) => value.copyWith(threshold: next),
  name: 'threshold',
);

final _configGesturecommonAcceleratedPart = LensPart<TriggerCommon, bool>(
  get: (value) => value.accelerated ?? false,
  set: (value, next) =>
      value.copyWith(accelerated: next == false ? null : next),
  name: 'accelerated',
);

final _configGesturecommonExtraPart =
    LensPart<TriggerCommon, Map<String, Object?>>(
      get: (value) => value.extra,
      set: (value, next) => value.copyWith(extra: next),
      name: 'extra',
    );

final _configGesturecommonActionsPart =
    LensPart<TriggerCommon, List<TriggerAction>>(
      get: (value) => value.actions,
      set: (value, next) => value.copyWith(actions: next),
      name: 'actions',
    );

List<TriggerAction> _triggerCommonActionsTreeFlatten(
  List<TriggerAction> nodes,
) {
  final out = <TriggerAction>[];
  for (final n in nodes) {
    out.add(n);
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) out.addAll(_triggerCommonActionsTreeFlatten(kids));
  }
  return out;
}

TriggerAction? _triggerCommonActionsTreeFindElement(
  List<TriggerAction> nodes,
  int key,
) {
  for (final n in nodes) {
    if (n.editId == key) {
      return n;
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final nested = _triggerCommonActionsTreeFindElement(kids, key);
      if (nested != null) return nested;
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeReplace(
  List<TriggerAction> nodes,
  int key,
  TriggerAction value,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<TriggerAction>.of(nodes)..[i] = value;
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final next = _triggerCommonActionsTreeReplace(kids, key, value);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeRemove(
  List<TriggerAction> nodes,
  int key,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<TriggerAction>.of(nodes)..removeAt(i);
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final next = _triggerCommonActionsTreeRemove(kids, key);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeInsertAfter(
  List<TriggerAction> nodes,
  int key,
  List<TriggerAction> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<TriggerAction>.of(nodes)..insertAll(i + 1, inserted);
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final next = _triggerCommonActionsTreeInsertAfter(kids, key, inserted);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeInsertBefore(
  List<TriggerAction> nodes,
  int key,
  List<TriggerAction> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<TriggerAction>.of(nodes)..insertAll(i, inserted);
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final next = _triggerCommonActionsTreeInsertBefore(kids, key, inserted);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeAppendTo(
  List<TriggerAction> nodes,
  int key,
  List<TriggerAction> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (n.editId == key) {
      if (kids == null) return null;
      return List<TriggerAction>.of(nodes)
        ..[i] = switch (n.action) {
          ActionGroup() => n.copyWith(
            action: ActionGroup(actions: [...kids, ...inserted]),
          ),
          _ => n,
        };
    }
    if (kids != null) {
      final next = _triggerCommonActionsTreeAppendTo(kids, key, inserted);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<TriggerAction>? _triggerCommonActionsTreeSplice(
  List<TriggerAction> nodes,
  int key,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (n.editId == key) {
      if (kids == null) return null;
      return List<TriggerAction>.of(nodes)
        ..removeAt(i)
        ..insertAll(i, kids);
    }
    if (kids != null) {
      final next = _triggerCommonActionsTreeSplice(kids, key);
      if (next != null) {
        return List<TriggerAction>.of(nodes)
          ..[i] = switch (n.action) {
            ActionGroup() => n.copyWith(action: ActionGroup(actions: next)),
            _ => n,
          };
      }
    }
  }
  return null;
}

(bool, int?) _triggerCommonActionsTreeParentOf(
  List<TriggerAction> nodes,
  int key,
  int? parent,
) {
  for (final n in nodes) {
    if (n.editId == key) {
      return (true, parent);
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null) {
      final nested = _triggerCommonActionsTreeParentOf(kids, key, n.editId);
      if (nested.$1) return nested;
    }
  }
  return (false, null);
}

bool _triggerCommonActionsTreeContains(List<TriggerAction> nodes, int key) {
  for (final n in nodes) {
    if (n.editId == key) {
      return true;
    }
    final kids = switch (n.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids != null && _triggerCommonActionsTreeContains(kids, key)) {
      return true;
    }
  }
  return false;
}

LensPart<TriggerCommon, TriggerAction> _configGesturecommonActionsItemPart(
  int key,
) => LensPart<TriggerCommon, TriggerAction>(
  get: (value) => _triggerCommonActionsTreeFindElement(value.actions, key)!,
  set: (value, nextValue) {
    final next = _triggerCommonActionsTreeReplace(
      value.actions,
      key,
      nextValue,
    );
    if (next == null) return value;
    return value.copyWith(actions: next);
  },
  canGet: (value) =>
      _triggerCommonActionsTreeFindElement(value.actions, key) != null,
  name: 'actions[#$key]',
);

List<TriggerAction> actionsOf(TriggerCommon root) =>
    _triggerCommonActionsTreeFlatten(root.actions);

TriggerAction? actionByKey(TriggerCommon? root, int key) {
  if (root == null) return null;
  return _triggerCommonActionsTreeFindElement(root.actions, key);
}

int? parentOfAction(TriggerCommon root, int key) =>
    _triggerCommonActionsTreeParentOf(root.actions, key, null).$2;

List<TriggerAction>? childrenOfAction(TriggerCommon root, int key) {
  final found = _triggerCommonActionsTreeFindElement(root.actions, key);
  if (found == null) return null;
  return switch (found.action) {
    ActionGroup(:final actions) => actions,
    _ => null,
  };
}

TriggerCommon addAction(TriggerCommon root, TriggerAction value) =>
    root.copyWith(actions: [...root.actions, value]);

TriggerCommon addActionToParent(
  TriggerCommon root,
  int parentKey,
  TriggerAction value,
) {
  final next = _triggerCommonActionsTreeAppendTo(root.actions, parentKey, [
    value,
  ]);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon insertActionAfter(
  TriggerCommon root,
  int key,
  TriggerAction value,
) {
  final next = _triggerCommonActionsTreeInsertAfter(root.actions, key, [value]);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon insertActionBefore(
  TriggerCommon root,
  int key,
  TriggerAction value,
) {
  final next = _triggerCommonActionsTreeInsertBefore(root.actions, key, [
    value,
  ]);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon replaceAction(TriggerCommon root, int key, TriggerAction value) {
  final next = _triggerCommonActionsTreeReplace(root.actions, key, value);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon updateAction(
  TriggerCommon root,
  int key,
  TriggerAction Function(TriggerAction value) update,
) {
  final current = _triggerCommonActionsTreeFindElement(root.actions, key);
  if (current == null) return root;
  return replaceAction(root, key, update(current));
}

TriggerCommon removeAction(TriggerCommon root, int key) {
  final next = _triggerCommonActionsTreeRemove(root.actions, key);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon spliceAction(TriggerCommon root, int key) {
  final next = _triggerCommonActionsTreeSplice(root.actions, key);
  if (next == null) return root;
  return root.copyWith(actions: next);
}

/// Moves [keys] together, in the order given, keeping each one's own subtree.
///
/// [beforeKey] lands the block directly before that element wherever it sits;
/// otherwise [newParentKey] appends it inside that container, and with neither
/// the block goes to the end of the root level. Anything that cannot apply
/// exactly — an unknown key, a duplicate, a target inside the block, a parent
/// that holds no children — leaves the owner untouched.
TriggerCommon moveActions(
  TriggerCommon root,
  List<int> keys, {
  int? beforeKey,
  int? newParentKey,
}) {
  if (keys.isEmpty) return root;
  final moving = keys.toSet();
  if (moving.length != keys.length) return root;
  final moved = <TriggerAction>[];
  for (final k in keys) {
    final found = _triggerCommonActionsTreeFindElement(root.actions, k);
    if (found == null) return root;
    moved.add(found);
  }
  if (beforeKey != null && moving.contains(beforeKey)) return root;
  if (newParentKey != null) {
    if (moving.contains(newParentKey)) return root;
    for (final node in moved) {
      final kids = switch (node.action) {
        ActionGroup(:final actions) => actions,
        _ => null,
      };
      if (kids != null &&
          _triggerCommonActionsTreeContains(kids, newParentKey)) {
        return root;
      }
    }
    final parent = _triggerCommonActionsTreeFindElement(
      root.actions,
      newParentKey,
    );
    if (parent == null) return root;
    if (switch (parent.action) {
          ActionGroup(:final actions) => actions,
          _ => null,
        } ==
        null) {
      return root;
    }
  }
  var level = root.actions;
  for (final k in keys) {
    final without = _triggerCommonActionsTreeRemove(level, k);
    if (without == null) return root;
    level = without;
  }
  final List<TriggerAction>? next;
  if (beforeKey != null) {
    next = _triggerCommonActionsTreeInsertBefore(level, beforeKey, moved);
  } else if (newParentKey != null) {
    next = _triggerCommonActionsTreeAppendTo(level, newParentKey, moved);
  } else {
    next = [...level, ...moved];
  }
  if (next == null) return root;
  return root.copyWith(actions: next);
}

TriggerCommon moveAction(
  TriggerCommon root,
  int key, {
  int? beforeKey,
  int? newParentKey,
}) =>
    moveActions(root, [key], beforeKey: beforeKey, newParentKey: newParentKey);

/// Reorders the direct children of [parentKey] (the root level when null) to
/// match [orderedKeys], which must name exactly that level's elements.
TriggerCommon reorderActions(
  TriggerCommon root,
  List<int> orderedKeys, {
  int? parentKey,
}) {
  if (orderedKeys.isEmpty) return root;
  final parent = parentKey == null
      ? null
      : _triggerCommonActionsTreeFindElement(root.actions, parentKey);
  final List<TriggerAction> level;
  if (parentKey == null) {
    level = root.actions;
  } else {
    if (parent == null) return root;
    final kids = switch (parent.action) {
      ActionGroup(:final actions) => actions,
      _ => null,
    };
    if (kids == null) return root;
    level = kids;
  }
  if (orderedKeys.length != level.length) return root;
  final byKey = <int, TriggerAction>{};
  for (final node in level) {
    final k = node.editId;
    if (k == null) return root;
    byKey[k] = node;
  }
  if (byKey.length != level.length) return root;
  final next = <TriggerAction>[];
  for (final k in orderedKeys) {
    final node = byKey[k];
    if (node == null) return root;
    next.add(node);
  }
  if (parent == null) {
    return root.copyWith(actions: next);
  }
  final rebuilt = _triggerCommonActionsTreeReplace(
    root.actions,
    parentKey!,
    switch (parent.action) {
      ActionGroup() => parent.copyWith(action: ActionGroup(actions: next)),
      _ => parent,
    },
  );
  if (rebuilt == null) return root;
  return root.copyWith(actions: rebuilt);
}

List<TriggerAction> assignActionKeysIn(
  List<TriggerAction> list,
  int Function() nextKey,
) {
  final seen = <int>{};
  (List<TriggerAction>, bool) walk(List<TriggerAction> nodes) {
    var changed = false;
    final out = <TriggerAction>[];
    for (final n in nodes) {
      var node = n;
      final k = n.editId;
      if (k == null || !seen.add(k)) {
        final fresh = nextKey();
        seen.add(fresh);
        node = node.copyWith(editId: fresh);
        changed = true;
      }
      final kids = switch (node.action) {
        ActionGroup(:final actions) => actions,
        _ => null,
      };
      if (kids != null) {
        final (nextKids, childChanged) = walk(kids);
        if (childChanged) {
          node = switch (node.action) {
            ActionGroup() => node.copyWith(
              action: ActionGroup(actions: nextKids),
            ),
            _ => node,
          };
          changed = true;
        }
      }
      {
        final deep = switch (node.action) {
          final ContextMenuAction v => () {
            final next = assignItemKeysIn(v.items, nextKey);
            return identical(next, v.items)
                ? node
                : node.copyWith(action: v.copyWith(items: next));
          }(),
          _ => node,
        };
        if (!identical(deep, node)) {
          node = deep;
          changed = true;
        }
      }
      out.add(node);
    }
    return (out, changed);
  }

  final (nodes, changed) = walk(list);
  return changed ? nodes : list;
}

TriggerCommon assignActionKeys(TriggerCommon root, int Function() nextKey) {
  final next = assignActionKeysIn(root.actions, nextKey);
  return identical(next, root.actions) ? root : root.copyWith(actions: next);
}

TriggerCommon preserveActionKeys({
  required TriggerCommon from,
  required TriggerCommon to,
}) {
  List<TriggerAction> zip(
    List<TriggerAction> source,
    List<TriggerAction> target,
  ) {
    final out = <TriggerAction>[];
    for (var i = 0; i < target.length; i++) {
      var node = target[i];
      final s = i < source.length ? source[i] : null;
      if (s != null) {
        final k = s.editId;
        if (k != null) node = node.copyWith(editId: k);
        final sourceKids = switch (s.action) {
          ActionGroup(:final actions) => actions,
          _ => null,
        };
        final targetKids = switch (node.action) {
          ActionGroup(:final actions) => actions,
          _ => null,
        };
        if (sourceKids != null && targetKids != null) {
          node = switch (node.action) {
            ActionGroup() => node.copyWith(
              action: ActionGroup(actions: zip(sourceKids, targetKids)),
            ),
            _ => node,
          };
        }
      }
      out.add(node);
    }
    return out;
  }

  return to.copyWith(actions: zip(from.actions, to.actions));
}

LensPart<List<TriggerAction>, TriggerAction>
_configGesturecommonActionsListItemPart(int key) =>
    LensPart<List<TriggerAction>, TriggerAction>(
      get: (list) => _triggerCommonActionsTreeFindElement(list, key)!,
      set: (list, nextValue) =>
          _triggerCommonActionsTreeReplace(list, key, nextValue) ?? list,
      canGet: (list) => _triggerCommonActionsTreeFindElement(list, key) != null,
      name: 'actions[#$key]',
    );

final class ActionLocation {
  const ActionLocation({required GestureLocation gesture, required this.editId})
    : _gesture = gesture,
      menuItem = null;
  const ActionLocation.menuItem(this.menuItem, this.editId) : _gesture = null;

  final GestureLocation? _gesture;
  final MenuItemLocation? menuItem;
  final int editId;

  GestureLocation get gesture => _gesture ?? (menuItem!.action.gesture);

  Lens<Config, TriggerAction> get lens => menuItem != null
      ? menuItemActionsLens(
          menuItem!,
        ).then(_configGesturecommonActionsListItemPart(editId))
      : gestureLens(gesture)
            .then(_configGestureCommonPart)
            .then(_configGesturecommonActionsItemPart(editId));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionLocation &&
          other._gesture == _gesture &&
          other.menuItem == menuItem &&
          other.editId == editId);

  @override
  int get hashCode => Object.hash(_gesture, menuItem, editId);
}

final class ActionSource {
  const ActionSource.gesture(GestureLocation gesture)
    : _gesture = gesture,
      menuItem = null;
  const ActionSource.menuItem(this.menuItem) : _gesture = null;

  final GestureLocation? _gesture;
  final MenuItemLocation? menuItem;

  GestureLocation get gesture => _gesture ?? (menuItem!.action.gesture);

  /// The list itself, wherever it lives.
  Lens<Config, List<TriggerAction>> get lens => menuItem != null
      ? menuItemActionsLens(menuItem!)
      : gestureActionsLens(gesture);

  ActionLocation locationOf(int editId) => menuItem != null
      ? ActionLocation.menuItem(menuItem, editId)
      : ActionLocation(gesture: gesture, editId: editId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionSource &&
          other._gesture == _gesture &&
          other.menuItem == menuItem);

  @override
  int get hashCode => Object.hash(_gesture, menuItem);
}

final _configGesturecommonactionActionPart = LensPart<TriggerAction, Action>(
  get: (value) => value.action,
  set: (value, next) => value.copyWith(action: next),
  name: 'action',
);

final _configGesturecommonactionAsCommandActionPart =
    LensPart<Action, CommandAction>(
      get: (value) => value as CommandAction,
      canGet: (value) => value is CommandAction,
      set: (value, next) => next,
      name: 'CommandAction',
    );

final _configGesturecommonactionactioncommandCommandPart =
    LensPart<CommandAction, String>(
      get: (value) => value.command,
      set: (value, next) => value.copyWith(command: next),
      name: 'command',
    );

final _configGesturecommonactionactioncommandWaitPart =
    LensPart<CommandAction, bool>(
      get: (value) => value.wait ?? false,
      set: (value, next) => value.copyWith(wait: next == false ? null : next),
      name: 'wait',
    );

final _configGesturecommonactionAsPlasmaShortcutActionPart =
    LensPart<Action, PlasmaShortcutAction>(
      get: (value) => value as PlasmaShortcutAction,
      canGet: (value) => value is PlasmaShortcutAction,
      set: (value, next) => next,
      name: 'PlasmaShortcutAction',
    );

final _configGesturecommonactionactionplasmaComponentPart =
    LensPart<PlasmaShortcutAction, String>(
      get: (value) => value.component,
      set: (value, next) => value.copyWith(component: next),
      name: 'component',
    );

final _configGesturecommonactionactionplasmaShortcutPart =
    LensPart<PlasmaShortcutAction, String>(
      get: (value) => value.shortcut,
      set: (value, next) => value.copyWith(shortcut: next),
      name: 'shortcut',
    );

final _configGesturecommonactionAsActivateWindowActionPart =
    LensPart<Action, ActivateWindowAction>(
      get: (value) => value as ActivateWindowAction,
      canGet: (value) => value is ActivateWindowAction,
      set: (value, next) => next,
      name: 'ActivateWindowAction',
    );

final _configGesturecommonactionactionactivateWindowWindowIdPart =
    LensPart<ActivateWindowAction, String>(
      get: (value) => value.windowId,
      set: (value, next) => value.copyWith(windowId: next),
      name: 'windowId',
    );

final _configGesturecommonactionAsReplaceTextActionPart =
    LensPart<Action, ReplaceTextAction>(
      get: (value) => value as ReplaceTextAction,
      canGet: (value) => value is ReplaceTextAction,
      set: (value, next) => next,
      name: 'ReplaceTextAction',
    );

final _configGesturecommonactionactionreplaceTextRulesPart =
    LensPart<ReplaceTextAction, List<TextSubstitutionRule>>(
      get: (value) => value.rules,
      set: (value, next) => value.copyWith(rules: next),
      name: 'rules',
    );

final _configGesturecommonactionAsSleepActionPart =
    LensPart<Action, SleepAction>(
      get: (value) => value as SleepAction,
      canGet: (value) => value is SleepAction,
      set: (value, next) => next,
      name: 'SleepAction',
    );

final _configGesturecommonactionactionsleepDurationPart =
    LensPart<SleepAction, int>(
      get: (value) => value.milliseconds,
      set: (value, next) => value.copyWith(milliseconds: next),
      name: 'duration',
    );

final _configGesturecommonactionAsFunctionActionPart =
    LensPart<Action, FunctionAction>(
      get: (value) => value as FunctionAction,
      canGet: (value) => value is FunctionAction,
      set: (value, next) => next,
      name: 'FunctionAction',
    );

final _configGesturecommonactionactionfunctionExpressionPart =
    LensPart<FunctionAction, String>(
      get: (value) => value.expression,
      set: (value, next) => value.copyWith(expression: next),
      name: 'expression',
    );

final _configGesturecommonactionAsContextMenuActionPart =
    LensPart<Action, ContextMenuAction>(
      get: (value) => value as ContextMenuAction,
      canGet: (value) => value is ContextMenuAction,
      set: (value, next) => next,
      name: 'ContextMenuAction',
    );

final _configGesturecommonactionactioncontextMenuItemsPart =
    LensPart<ContextMenuAction, List<MenuItem>>(
      get: (value) => value.items,
      set: (value, next) => value.copyWith(items: next),
      name: 'items',
    );

List<MenuItem> _contextMenuActionItemsTreeFlatten(List<MenuItem> nodes) {
  final out = <MenuItem>[];
  for (final n in nodes) {
    out.add(n);
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) out.addAll(_contextMenuActionItemsTreeFlatten(kids));
  }
  return out;
}

MenuItem? _contextMenuActionItemsTreeFindElement(
  List<MenuItem> nodes,
  int key,
) {
  for (final n in nodes) {
    if (n.editId == key) {
      return n;
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final nested = _contextMenuActionItemsTreeFindElement(kids, key);
      if (nested != null) return nested;
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeReplace(
  List<MenuItem> nodes,
  int key,
  MenuItem value,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<MenuItem>.of(nodes)..[i] = value;
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final next = _contextMenuActionItemsTreeReplace(kids, key, value);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeRemove(
  List<MenuItem> nodes,
  int key,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<MenuItem>.of(nodes)..removeAt(i);
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final next = _contextMenuActionItemsTreeRemove(kids, key);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeInsertAfter(
  List<MenuItem> nodes,
  int key,
  List<MenuItem> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<MenuItem>.of(nodes)..insertAll(i + 1, inserted);
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final next = _contextMenuActionItemsTreeInsertAfter(kids, key, inserted);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeInsertBefore(
  List<MenuItem> nodes,
  int key,
  List<MenuItem> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    if (n.editId == key) {
      return List<MenuItem>.of(nodes)..insertAll(i, inserted);
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final next = _contextMenuActionItemsTreeInsertBefore(kids, key, inserted);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeAppendTo(
  List<MenuItem> nodes,
  int key,
  List<MenuItem> inserted,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (n.editId == key) {
      if (kids == null) return null;
      return List<MenuItem>.of(nodes)
        ..[i] = switch (n) {
          SubMenuItem() => n.copyWith(items: [...kids, ...inserted]),
          _ => n,
        };
    }
    if (kids != null) {
      final next = _contextMenuActionItemsTreeAppendTo(kids, key, inserted);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

List<MenuItem>? _contextMenuActionItemsTreeSplice(
  List<MenuItem> nodes,
  int key,
) {
  for (var i = 0; i < nodes.length; i++) {
    final n = nodes[i];
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (n.editId == key) {
      if (kids == null) return null;
      return List<MenuItem>.of(nodes)
        ..removeAt(i)
        ..insertAll(i, kids);
    }
    if (kids != null) {
      final next = _contextMenuActionItemsTreeSplice(kids, key);
      if (next != null) {
        return List<MenuItem>.of(nodes)
          ..[i] = switch (n) {
            SubMenuItem() => n.copyWith(items: next),
            _ => n,
          };
      }
    }
  }
  return null;
}

(bool, int?) _contextMenuActionItemsTreeParentOf(
  List<MenuItem> nodes,
  int key,
  int? parent,
) {
  for (final n in nodes) {
    if (n.editId == key) {
      return (true, parent);
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null) {
      final nested = _contextMenuActionItemsTreeParentOf(kids, key, n.editId);
      if (nested.$1) return nested;
    }
  }
  return (false, null);
}

bool _contextMenuActionItemsTreeContains(List<MenuItem> nodes, int key) {
  for (final n in nodes) {
    if (n.editId == key) {
      return true;
    }
    final kids = switch (n) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids != null && _contextMenuActionItemsTreeContains(kids, key)) {
      return true;
    }
  }
  return false;
}

LensPart<ContextMenuAction, MenuItem>
_configGesturecommonactionactioncontextMenuItemsItemPart(int key) =>
    LensPart<ContextMenuAction, MenuItem>(
      get: (value) => _contextMenuActionItemsTreeFindElement(value.items, key)!,
      set: (value, nextValue) {
        final next = _contextMenuActionItemsTreeReplace(
          value.items,
          key,
          nextValue,
        );
        if (next == null) return value;
        return value.copyWith(items: next);
      },
      canGet: (value) =>
          _contextMenuActionItemsTreeFindElement(value.items, key) != null,
      name: 'items[#$key]',
    );

List<MenuItem> itemsOf(ContextMenuAction root) =>
    _contextMenuActionItemsTreeFlatten(root.items);

MenuItem? itemByKey(ContextMenuAction? root, int key) {
  if (root == null) return null;
  return _contextMenuActionItemsTreeFindElement(root.items, key);
}

int? parentOfItem(ContextMenuAction root, int key) =>
    _contextMenuActionItemsTreeParentOf(root.items, key, null).$2;

List<MenuItem>? childrenOfItem(ContextMenuAction root, int key) {
  final found = _contextMenuActionItemsTreeFindElement(root.items, key);
  if (found == null) return null;
  return switch (found) {
    SubMenuItem(:final items) => items,
    _ => null,
  };
}

ContextMenuAction addItem(ContextMenuAction root, MenuItem value) =>
    root.copyWith(items: [...root.items, value]);

ContextMenuAction addItemToParent(
  ContextMenuAction root,
  int parentKey,
  MenuItem value,
) {
  final next = _contextMenuActionItemsTreeAppendTo(root.items, parentKey, [
    value,
  ]);
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction insertItemAfter(
  ContextMenuAction root,
  int key,
  MenuItem value,
) {
  final next = _contextMenuActionItemsTreeInsertAfter(root.items, key, [value]);
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction insertItemBefore(
  ContextMenuAction root,
  int key,
  MenuItem value,
) {
  final next = _contextMenuActionItemsTreeInsertBefore(root.items, key, [
    value,
  ]);
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction replaceItem(ContextMenuAction root, int key, MenuItem value) {
  final next = _contextMenuActionItemsTreeReplace(root.items, key, value);
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction updateItem(
  ContextMenuAction root,
  int key,
  MenuItem Function(MenuItem value) update,
) {
  final current = _contextMenuActionItemsTreeFindElement(root.items, key);
  if (current == null) return root;
  return replaceItem(root, key, update(current));
}

ContextMenuAction removeItem(ContextMenuAction root, int key) {
  final next = _contextMenuActionItemsTreeRemove(root.items, key);
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction spliceItem(ContextMenuAction root, int key) {
  final next = _contextMenuActionItemsTreeSplice(root.items, key);
  if (next == null) return root;
  return root.copyWith(items: next);
}

/// Moves [keys] together, in the order given, keeping each one's own subtree.
///
/// [beforeKey] lands the block directly before that element wherever it sits;
/// otherwise [newParentKey] appends it inside that container, and with neither
/// the block goes to the end of the root level. Anything that cannot apply
/// exactly — an unknown key, a duplicate, a target inside the block, a parent
/// that holds no children — leaves the owner untouched.
ContextMenuAction moveItems(
  ContextMenuAction root,
  List<int> keys, {
  int? beforeKey,
  int? newParentKey,
}) {
  if (keys.isEmpty) return root;
  final moving = keys.toSet();
  if (moving.length != keys.length) return root;
  final moved = <MenuItem>[];
  for (final k in keys) {
    final found = _contextMenuActionItemsTreeFindElement(root.items, k);
    if (found == null) return root;
    moved.add(found);
  }
  if (beforeKey != null && moving.contains(beforeKey)) return root;
  if (newParentKey != null) {
    if (moving.contains(newParentKey)) return root;
    for (final node in moved) {
      final kids = switch (node) {
        SubMenuItem(:final items) => items,
        _ => null,
      };
      if (kids != null &&
          _contextMenuActionItemsTreeContains(kids, newParentKey)) {
        return root;
      }
    }
    final parent = _contextMenuActionItemsTreeFindElement(
      root.items,
      newParentKey,
    );
    if (parent == null) return root;
    if (switch (parent) {
          SubMenuItem(:final items) => items,
          _ => null,
        } ==
        null) {
      return root;
    }
  }
  var level = root.items;
  for (final k in keys) {
    final without = _contextMenuActionItemsTreeRemove(level, k);
    if (without == null) return root;
    level = without;
  }
  final List<MenuItem>? next;
  if (beforeKey != null) {
    next = _contextMenuActionItemsTreeInsertBefore(level, beforeKey, moved);
  } else if (newParentKey != null) {
    next = _contextMenuActionItemsTreeAppendTo(level, newParentKey, moved);
  } else {
    next = [...level, ...moved];
  }
  if (next == null) return root;
  return root.copyWith(items: next);
}

ContextMenuAction moveItem(
  ContextMenuAction root,
  int key, {
  int? beforeKey,
  int? newParentKey,
}) => moveItems(root, [key], beforeKey: beforeKey, newParentKey: newParentKey);

/// Reorders the direct children of [parentKey] (the root level when null) to
/// match [orderedKeys], which must name exactly that level's elements.
ContextMenuAction reorderItems(
  ContextMenuAction root,
  List<int> orderedKeys, {
  int? parentKey,
}) {
  if (orderedKeys.isEmpty) return root;
  final parent = parentKey == null
      ? null
      : _contextMenuActionItemsTreeFindElement(root.items, parentKey);
  final List<MenuItem> level;
  if (parentKey == null) {
    level = root.items;
  } else {
    if (parent == null) return root;
    final kids = switch (parent) {
      SubMenuItem(:final items) => items,
      _ => null,
    };
    if (kids == null) return root;
    level = kids;
  }
  if (orderedKeys.length != level.length) return root;
  final byKey = <int, MenuItem>{};
  for (final node in level) {
    final k = node.editId;
    if (k == null) return root;
    byKey[k] = node;
  }
  if (byKey.length != level.length) return root;
  final next = <MenuItem>[];
  for (final k in orderedKeys) {
    final node = byKey[k];
    if (node == null) return root;
    next.add(node);
  }
  if (parent == null) {
    return root.copyWith(items: next);
  }
  final rebuilt = _contextMenuActionItemsTreeReplace(
    root.items,
    parentKey!,
    switch (parent) {
      SubMenuItem() => parent.copyWith(items: next),
      _ => parent,
    },
  );
  if (rebuilt == null) return root;
  return root.copyWith(items: rebuilt);
}

List<MenuItem> assignItemKeysIn(List<MenuItem> list, int Function() nextKey) {
  final seen = <int>{};
  (List<MenuItem>, bool) walk(List<MenuItem> nodes) {
    var changed = false;
    final out = <MenuItem>[];
    for (final n in nodes) {
      var node = n;
      final k = n.editId;
      if (k == null || !seen.add(k)) {
        final fresh = nextKey();
        seen.add(fresh);
        node = node.copyWith(editId: fresh);
        changed = true;
      }
      final kids = switch (node) {
        SubMenuItem(:final items) => items,
        _ => null,
      };
      if (kids != null) {
        final (nextKids, childChanged) = walk(kids);
        if (childChanged) {
          node = switch (node) {
            SubMenuItem() => node.copyWith(items: nextKids),
            _ => node,
          };
          changed = true;
        }
      }
      {
        final deep = switch (node) {
          final ActionMenuItem v => () {
            final next = assignActionKeysIn(v.actions, nextKey);
            return identical(next, v.actions)
                ? node
                : v.copyWith(actions: next);
          }(),
          _ => node,
        };
        if (!identical(deep, node)) {
          node = deep;
          changed = true;
        }
      }
      out.add(node);
    }
    return (out, changed);
  }

  final (nodes, changed) = walk(list);
  return changed ? nodes : list;
}

ContextMenuAction assignItemKeys(
  ContextMenuAction root,
  int Function() nextKey,
) {
  final next = assignItemKeysIn(root.items, nextKey);
  return identical(next, root.items) ? root : root.copyWith(items: next);
}

ContextMenuAction preserveItemKeys({
  required ContextMenuAction from,
  required ContextMenuAction to,
}) {
  List<MenuItem> zip(List<MenuItem> source, List<MenuItem> target) {
    final out = <MenuItem>[];
    for (var i = 0; i < target.length; i++) {
      var node = target[i];
      final s = i < source.length ? source[i] : null;
      if (s != null) {
        final k = s.editId;
        if (k != null) node = node.copyWith(editId: k);
        final sourceKids = switch (s) {
          SubMenuItem(:final items) => items,
          _ => null,
        };
        final targetKids = switch (node) {
          SubMenuItem(:final items) => items,
          _ => null,
        };
        if (sourceKids != null && targetKids != null) {
          node = switch (node) {
            SubMenuItem() => node.copyWith(items: zip(sourceKids, targetKids)),
            _ => node,
          };
        }
      }
      out.add(node);
    }
    return out;
  }

  return to.copyWith(items: zip(from.items, to.items));
}

final _configGesturecommonactionactioncontextMenuitemAsActionMenuItemPart =
    LensPart<MenuItem, ActionMenuItem>(
      get: (value) => value as ActionMenuItem,
      canGet: (value) => value is ActionMenuItem,
      set: (value, next) => next,
      name: 'ActionMenuItem',
    );

final _configGesturecommonactionactioncontextMenuitemactionTextPart =
    LensPart<ActionMenuItem, String>(
      get: (value) => value.text,
      set: (value, next) => value.copyWith(text: next),
      name: 'text',
    );

final _configGesturecommonactionactioncontextMenuitemactionIconPart =
    LensPart<ActionMenuItem, String?>(
      get: (value) => value.icon,
      set: (value, next) => value.copyWith(icon: next),
      name: 'icon',
    );

final _configGesturecommonactionactioncontextMenuitemactionActionsPart =
    LensPart<ActionMenuItem, List<TriggerAction>>(
      get: (value) => value.actions,
      set: (value, next) => value.copyWith(actions: next),
      name: 'actions',
    );

final _configGesturecommonactionactioncontextMenuitemAsSubMenuItemPart =
    LensPart<MenuItem, SubMenuItem>(
      get: (value) => value as SubMenuItem,
      canGet: (value) => value is SubMenuItem,
      set: (value, next) => next,
      name: 'SubMenuItem',
    );

final _configGesturecommonactionactioncontextMenuitemsubMenuSubMenuTextPart =
    LensPart<SubMenuItem, String>(
      get: (value) => value.text,
      set: (value, next) => value.copyWith(text: next),
      name: 'subMenuText',
    );

final _configGesturecommonactionactioncontextMenuitemsubMenuSubMenuIconPart =
    LensPart<SubMenuItem, String?>(
      get: (value) => value.icon,
      set: (value, next) => value.copyWith(icon: next),
      name: 'subMenuIcon',
    );

final _configGesturecommonactionactioncontextMenuitemAsSectionMenuItemPart =
    LensPart<MenuItem, SectionMenuItem>(
      get: (value) => value as SectionMenuItem,
      canGet: (value) => value is SectionMenuItem,
      set: (value, next) => next,
      name: 'SectionMenuItem',
    );

final _configGesturecommonactionactioncontextMenuitemsectionSectionTextPart =
    LensPart<SectionMenuItem, String>(
      get: (value) => value.text,
      set: (value, next) => value.copyWith(text: next),
      name: 'sectionText',
    );

final _configGesturecommonactionactioncontextMenuitemAsSeparatorMenuItemPart =
    LensPart<MenuItem, SeparatorMenuItem>(
      get: (value) => value as SeparatorMenuItem,
      canGet: (value) => value is SeparatorMenuItem,
      set: (value, next) => next,
      name: 'SeparatorMenuItem',
    );

final _configGesturecommonactionAsRawActionPart = LensPart<Action, RawAction>(
  get: (value) => value as RawAction,
  canGet: (value) => value is RawAction,
  set: (value, next) => next,
  name: 'RawAction',
);

final _configGesturecommonactionactionrawRawPart = LensPart<RawAction, String>(
  get: (value) => value.raw,
  set: (value, next) => value.copyWith(raw: next),
  name: 'raw',
);

final _configGesturecommonactionAsActionGroupPart =
    LensPart<Action, ActionGroup>(
      get: (value) => value as ActionGroup,
      canGet: (value) => value is ActionGroup,
      set: (value, next) => next,
      name: 'ActionGroup',
    );

final _configGesturecommonactionAsInputActionPart =
    LensPart<Action, InputAction>(
      get: (value) => value as InputAction,
      canGet: (value) => value is InputAction,
      set: (value, next) => next,
      name: 'InputAction',
    );

final _configGesturecommonactionactioninputInputEntriesPart =
    LensPart<InputAction, List<InputEntry>>(
      get: (value) => value.entries,
      set: (value, next) => value.copyWith(entries: next),
      name: 'inputEntries',
    );

final _configGesturecommonactionactioninputInputDelayPart =
    LensPart<InputAction, int?>(
      get: (value) => value.delay,
      set: (value, next) => value.copyWith(delay: next),
      name: 'inputDelay',
    );

final _configGesturecommonactionTriggerOnPart =
    LensPart<TriggerAction, TriggerOnValue>(
      get: (value) => value.on ?? TriggerOn.end,
      set: (value, next) =>
          value.copyWith(on: next == TriggerOn.end ? null : next),
      name: 'triggerOn',
    );

final _configGesturecommonactionIntervalPart = LensPart<TriggerAction, String?>(
  get: (value) => value.interval,
  set: (value, next) => value.copyWith(interval: next),
  name: 'interval',
);

final _configGesturecommonactionThresholdPart =
    LensPart<TriggerAction, String?>(
      get: (value) => value.threshold,
      set: (value, next) => value.copyWith(threshold: next),
      name: 'threshold',
    );

final _configGesturecommonactionLimitPart = LensPart<TriggerAction, int?>(
  get: (value) => value.limit,
  set: (value, next) => value.copyWith(limit: next),
  name: 'limit',
);

final _configGesturecommonactionEnabledPart = LensPart<TriggerAction, bool>(
  get: (value) => value.enabled ?? true,
  set: (value, next) => value.copyWith(enabled: next == true ? null : next),
  name: 'enabled',
);

final _configGesturecommonactionConflictingPart = LensPart<TriggerAction, bool>(
  get: (value) => value.conflicting,
  set: (value, next) => value.copyWith(conflicting: next),
  name: 'conflicting',
);

final _configGesturecommonactionConditionsPart =
    LensPart<TriggerAction, Condition?>(
      get: (value) => value.conditions,
      set: (value, next) => value.copyWith(conditions: next),
      name: 'conditions',
    );

final _configGesturecommonactionIdPart = LensPart<TriggerAction, String?>(
  get: (value) => value.id,
  set: (value, next) => value.copyWith(id: next),
  name: 'id',
);

final _configMouseGestureCastPart = LensPart<Gesture, MouseGesture>(
  get: (value) => value as MouseGesture,
  canGet: (value) => value is MouseGesture,
  set: (value, next) => next,
  name: 'MouseGesture',
);

final _configAsStrokeGesturePart = LensPart<MouseGesture, StrokeGesture>(
  get: (value) => value as StrokeGesture,
  canGet: (value) => value is StrokeGesture,
  set: (value, next) => next,
  name: 'StrokeGesture',
);

final _configMouseGesturestrokeMotionPart =
    LensPart<StrokeGesture, MotionCommon>(
      get: (value) => value.motion,
      set: (value, next) => value.copyWith(motion: next),
      name: 'motion',
    );

final _configMouseGesturestrokemotionSpeedPart =
    LensPart<MotionCommon, TriggerSpeed?>(
      get: (value) => value.speed,
      set: (value, next) => value.copyWith(speed: next),
      name: 'speed',
    );

final _configMouseGesturestrokemotionLockPointerPart =
    LensPart<MotionCommon, bool>(
      get: (value) => value.lockPointer ?? false,
      set: (value, next) =>
          value.copyWith(lockPointer: next == false ? null : next),
      name: 'lockPointer',
    );

final _configMouseGesturestrokeStrokesPart =
    LensPart<StrokeGesture, List<Stroke>>(
      get: (value) => value.strokes,
      set: (value, next) => value.copyWith(strokes: next),
      name: 'strokes',
    );

final _configAsSwipeGesturePart = LensPart<MouseGesture, SwipeGesture>(
  get: (value) => value as SwipeGesture,
  canGet: (value) => value is SwipeGesture,
  set: (value, next) => next,
  name: 'SwipeGesture',
);

final _configMouseGestureswipeMotionPart = LensPart<SwipeGesture, MotionCommon>(
  get: (value) => value.motion,
  set: (value, next) => value.copyWith(motion: next),
  name: 'motion',
);

final _configMouseGestureswipemotionSpeedPart =
    LensPart<MotionCommon, TriggerSpeed?>(
      get: (value) => value.speed,
      set: (value, next) => value.copyWith(speed: next),
      name: 'speed',
    );

final _configMouseGestureswipemotionLockPointerPart =
    LensPart<MotionCommon, bool>(
      get: (value) => value.lockPointer ?? false,
      set: (value, next) =>
          value.copyWith(lockPointer: next == false ? null : next),
      name: 'lockPointer',
    );

final _configMouseGestureswipeModePart = LensPart<SwipeGesture, SwipeMode>(
  get: (value) => value.mode,
  set: (value, next) => value.copyWith(mode: next),
  name: 'mode',
);

final _configMouseGestureswipemodeAsSwipeDirectionModePart =
    LensPart<SwipeMode, SwipeDirectionMode>(
      get: (value) => value as SwipeDirectionMode,
      canGet: (value) => value is SwipeDirectionMode,
      set: (value, next) => next,
      name: 'SwipeDirectionMode',
    );

final _configMouseGestureswipemodedirectionDirectionPart =
    LensPart<SwipeDirectionMode, SwipeDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'direction',
    );

final _configMouseGestureswipemodeAsSwipeAngleModePart =
    LensPart<SwipeMode, SwipeAngleMode>(
      get: (value) => value as SwipeAngleMode,
      canGet: (value) => value is SwipeAngleMode,
      set: (value, next) => next,
      name: 'SwipeAngleMode',
    );

final _configMouseGestureswipemodeangleMinAnglePart =
    LensPart<SwipeAngleMode, double>(
      get: (value) => value.minAngle,
      set: (value, next) => value.copyWith(minAngle: next),
      name: 'minAngle',
    );

final _configMouseGestureswipemodeangleMaxAnglePart =
    LensPart<SwipeAngleMode, double>(
      get: (value) => value.maxAngle,
      set: (value, next) => value.copyWith(maxAngle: next),
      name: 'maxAngle',
    );

final _configMouseGestureswipemodeangleBidirectionalPart =
    LensPart<SwipeAngleMode, bool>(
      get: (value) => value.bidirectional,
      set: (value, next) => value.copyWith(bidirectional: next),
      name: 'bidirectional',
    );

final _configAsCircleGesturePart = LensPart<MouseGesture, CircleGesture>(
  get: (value) => value as CircleGesture,
  canGet: (value) => value is CircleGesture,
  set: (value, next) => next,
  name: 'CircleGesture',
);

final _configMouseGesturecircleMotionPart =
    LensPart<CircleGesture, MotionCommon>(
      get: (value) => value.motion,
      set: (value, next) => value.copyWith(motion: next),
      name: 'motion',
    );

final _configMouseGesturecirclemotionSpeedPart =
    LensPart<MotionCommon, TriggerSpeed?>(
      get: (value) => value.speed,
      set: (value, next) => value.copyWith(speed: next),
      name: 'speed',
    );

final _configMouseGesturecirclemotionLockPointerPart =
    LensPart<MotionCommon, bool>(
      get: (value) => value.lockPointer ?? false,
      set: (value, next) =>
          value.copyWith(lockPointer: next == false ? null : next),
      name: 'lockPointer',
    );

final _configMouseGesturecircleDirectionPart =
    LensPart<CircleGesture, RotationDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'direction',
    );

final _configAsPressGesturePart = LensPart<MouseGesture, PressGesture>(
  get: (value) => value as PressGesture,
  canGet: (value) => value is PressGesture,
  set: (value, next) => next,
  name: 'PressGesture',
);

final _configMouseGesturepressMotionPart = LensPart<PressGesture, MotionCommon>(
  get: (value) => value.motion,
  set: (value, next) => value.copyWith(motion: next),
  name: 'motion',
);

final _configMouseGesturepressmotionSpeedPart =
    LensPart<MotionCommon, TriggerSpeed?>(
      get: (value) => value.speed,
      set: (value, next) => value.copyWith(speed: next),
      name: 'speed',
    );

final _configMouseGesturepressmotionLockPointerPart =
    LensPart<MotionCommon, bool>(
      get: (value) => value.lockPointer ?? false,
      set: (value, next) =>
          value.copyWith(lockPointer: next == false ? null : next),
      name: 'lockPointer',
    );

final _configMouseGesturepressInstantPart = LensPart<PressGesture, bool>(
  get: (value) => value.instant ?? false,
  set: (value, next) => value.copyWith(instant: next == false ? null : next),
  name: 'instant',
);

final _configAsWheelGesturePart = LensPart<MouseGesture, WheelGesture>(
  get: (value) => value as WheelGesture,
  canGet: (value) => value is WheelGesture,
  set: (value, next) => next,
  name: 'WheelGesture',
);

final _configMouseGesturewheelMotionPart = LensPart<WheelGesture, MotionCommon>(
  get: (value) => value.motion,
  set: (value, next) => value.copyWith(motion: next),
  name: 'motion',
);

final _configMouseGesturewheelmotionSpeedPart =
    LensPart<MotionCommon, TriggerSpeed?>(
      get: (value) => value.speed,
      set: (value, next) => value.copyWith(speed: next),
      name: 'speed',
    );

final _configMouseGesturewheelmotionLockPointerPart =
    LensPart<MotionCommon, bool>(
      get: (value) => value.lockPointer ?? false,
      set: (value, next) =>
          value.copyWith(lockPointer: next == false ? null : next),
      name: 'lockPointer',
    );

final _configMouseGesturewheelDirectionPart =
    LensPart<WheelGesture, WheelDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'direction',
    );

final _configKeyboardGestureCastPart = LensPart<Gesture, KeyboardGesture>(
  get: (value) => value as KeyboardGesture,
  canGet: (value) => value is KeyboardGesture,
  set: (value, next) => next,
  name: 'KeyboardGesture',
);

final _configAsShortcutGesturePart = LensPart<KeyboardGesture, ShortcutGesture>(
  get: (value) => value as ShortcutGesture,
  canGet: (value) => value is ShortcutGesture,
  set: (value, next) => next,
  name: 'ShortcutGesture',
);

final _configKeyboardGestureshortcutKeysPart =
    LensPart<ShortcutGesture, List<String>>(
      get: (value) => value.keys,
      set: (value, next) => value.copyWith(keys: next),
      name: 'keys',
    );

final _configPointerGestureCastPart = LensPart<Gesture, PointerGesture>(
  get: (value) => value as PointerGesture,
  canGet: (value) => value is PointerGesture,
  set: (value, next) => next,
  name: 'PointerGesture',
);

final _configAsHoverGesturePart = LensPart<PointerGesture, HoverGesture>(
  get: (value) => value as HoverGesture,
  canGet: (value) => value is HoverGesture,
  set: (value, next) => next,
  name: 'HoverGesture',
);

final _configTouchpadGestureCastPart = LensPart<Gesture, TouchpadGesture>(
  get: (value) => value as TouchpadGesture,
  canGet: (value) => value is TouchpadGesture,
  set: (value, next) => next,
  name: 'TouchpadGesture',
);

final _configTouchpadGestureFingersPart =
    LensPart<TouchpadGesture, FingerRange?>(
      get: (value) => _touchpadFingers(value),
      set: (value, next) => _setTouchpadFingers(value, next),
      name: 'fingers',
    );

final _configTouchpadGestureMotionSpeedPart =
    LensPart<TouchpadGesture, TriggerSpeed?>(
      get: (value) => _touchpadSpeed(value),
      set: (value, next) => _setTouchpadSpeed(value, next),
      name: 'motionSpeed',
    );

final _configAsTouchpadSwipeGesturePart =
    LensPart<TouchpadGesture, TouchpadSwipeGesture>(
      get: (value) => value as TouchpadSwipeGesture,
      canGet: (value) => value is TouchpadSwipeGesture,
      set: (value, next) => next,
      name: 'TouchpadSwipeGesture',
    );

final _configTouchpadGesturetouchpadSwipeSwipeModePart =
    LensPart<TouchpadSwipeGesture, SwipeMode>(
      get: (value) => value.mode,
      set: (value, next) => value.copyWith(mode: next),
      name: 'swipeMode',
    );

final _configAsTouchpadPinchGesturePart =
    LensPart<TouchpadGesture, TouchpadPinchGesture>(
      get: (value) => value as TouchpadPinchGesture,
      canGet: (value) => value is TouchpadPinchGesture,
      set: (value, next) => next,
      name: 'TouchpadPinchGesture',
    );

final _configTouchpadGesturetouchpadPinchPinchDirectionPart =
    LensPart<TouchpadPinchGesture, PinchDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'pinchDirection',
    );

final _configAsTouchpadRotateGesturePart =
    LensPart<TouchpadGesture, TouchpadRotateGesture>(
      get: (value) => value as TouchpadRotateGesture,
      canGet: (value) => value is TouchpadRotateGesture,
      set: (value, next) => next,
      name: 'TouchpadRotateGesture',
    );

final _configTouchpadGesturetouchpadRotateRotateDirectionPart =
    LensPart<TouchpadRotateGesture, RotationDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'rotateDirection',
    );

final _configAsTouchpadCircleGesturePart =
    LensPart<TouchpadGesture, TouchpadCircleGesture>(
      get: (value) => value as TouchpadCircleGesture,
      canGet: (value) => value is TouchpadCircleGesture,
      set: (value, next) => next,
      name: 'TouchpadCircleGesture',
    );

final _configTouchpadGesturetouchpadCircleCircleDirectionPart =
    LensPart<TouchpadCircleGesture, RotationDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'circleDirection',
    );

final _configAsTouchpadTapGesturePart =
    LensPart<TouchpadGesture, TouchpadTapGesture>(
      get: (value) => value as TouchpadTapGesture,
      canGet: (value) => value is TouchpadTapGesture,
      set: (value, next) => next,
      name: 'TouchpadTapGesture',
    );

final _configAsTouchpadClickGesturePart =
    LensPart<TouchpadGesture, TouchpadClickGesture>(
      get: (value) => value as TouchpadClickGesture,
      canGet: (value) => value is TouchpadClickGesture,
      set: (value, next) => next,
      name: 'TouchpadClickGesture',
    );

final _configAsTouchpadHoldGesturePart =
    LensPart<TouchpadGesture, TouchpadHoldGesture>(
      get: (value) => value as TouchpadHoldGesture,
      canGet: (value) => value is TouchpadHoldGesture,
      set: (value, next) => next,
      name: 'TouchpadHoldGesture',
    );

final _configAsTouchpadStrokeGesturePart =
    LensPart<TouchpadGesture, TouchpadStrokeGesture>(
      get: (value) => value as TouchpadStrokeGesture,
      canGet: (value) => value is TouchpadStrokeGesture,
      set: (value, next) => next,
      name: 'TouchpadStrokeGesture',
    );

final _configTouchpadGesturetouchpadStrokeStrokeStrokesPart =
    LensPart<TouchpadStrokeGesture, List<Stroke>>(
      get: (value) => value.strokes,
      set: (value, next) => value.copyWith(strokes: next),
      name: 'strokeStrokes',
    );

final _configTouchscreenGestureCastPart = LensPart<Gesture, TouchscreenGesture>(
  get: (value) => value as TouchscreenGesture,
  canGet: (value) => value is TouchscreenGesture,
  set: (value, next) => next,
  name: 'TouchscreenGesture',
);

final _configTouchscreenGestureFingersPart =
    LensPart<TouchscreenGesture, FingerRange?>(
      get: (value) => _touchscreenFingers(value),
      set: (value, next) => _setTouchscreenFingers(value, next),
      name: 'fingers',
    );

final _configTouchscreenGestureMotionSpeedPart =
    LensPart<TouchscreenGesture, TriggerSpeed?>(
      get: (value) => _touchscreenSpeed(value),
      set: (value, next) => _setTouchscreenSpeed(value, next),
      name: 'motionSpeed',
    );

final _configAsTouchscreenSwipeGesturePart =
    LensPart<TouchscreenGesture, TouchscreenSwipeGesture>(
      get: (value) => value as TouchscreenSwipeGesture,
      canGet: (value) => value is TouchscreenSwipeGesture,
      set: (value, next) => next,
      name: 'TouchscreenSwipeGesture',
    );

final _configTouchscreenGesturetouchscreenSwipeSwipeModePart =
    LensPart<TouchscreenSwipeGesture, SwipeMode>(
      get: (value) => value.mode,
      set: (value, next) => value.copyWith(mode: next),
      name: 'swipeMode',
    );

final _configAsTouchscreenPinchGesturePart =
    LensPart<TouchscreenGesture, TouchscreenPinchGesture>(
      get: (value) => value as TouchscreenPinchGesture,
      canGet: (value) => value is TouchscreenPinchGesture,
      set: (value, next) => next,
      name: 'TouchscreenPinchGesture',
    );

final _configTouchscreenGesturetouchscreenPinchPinchDirectionPart =
    LensPart<TouchscreenPinchGesture, PinchDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'pinchDirection',
    );

final _configAsTouchscreenRotateGesturePart =
    LensPart<TouchscreenGesture, TouchscreenRotateGesture>(
      get: (value) => value as TouchscreenRotateGesture,
      canGet: (value) => value is TouchscreenRotateGesture,
      set: (value, next) => next,
      name: 'TouchscreenRotateGesture',
    );

final _configTouchscreenGesturetouchscreenRotateRotateDirectionPart =
    LensPart<TouchscreenRotateGesture, RotationDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'rotateDirection',
    );

final _configAsTouchscreenCircleGesturePart =
    LensPart<TouchscreenGesture, TouchscreenCircleGesture>(
      get: (value) => value as TouchscreenCircleGesture,
      canGet: (value) => value is TouchscreenCircleGesture,
      set: (value, next) => next,
      name: 'TouchscreenCircleGesture',
    );

final _configTouchscreenGesturetouchscreenCircleCircleDirectionPart =
    LensPart<TouchscreenCircleGesture, RotationDirection>(
      get: (value) => value.direction,
      set: (value, next) => value.copyWith(direction: next),
      name: 'circleDirection',
    );

final _configAsTouchscreenTapGesturePart =
    LensPart<TouchscreenGesture, TouchscreenTapGesture>(
      get: (value) => value as TouchscreenTapGesture,
      canGet: (value) => value is TouchscreenTapGesture,
      set: (value, next) => next,
      name: 'TouchscreenTapGesture',
    );

final _configAsTouchscreenHoldGesturePart =
    LensPart<TouchscreenGesture, TouchscreenHoldGesture>(
      get: (value) => value as TouchscreenHoldGesture,
      canGet: (value) => value is TouchscreenHoldGesture,
      set: (value, next) => next,
      name: 'TouchscreenHoldGesture',
    );

final _configAsTouchscreenStrokeGesturePart =
    LensPart<TouchscreenGesture, TouchscreenStrokeGesture>(
      get: (value) => value as TouchscreenStrokeGesture,
      canGet: (value) => value is TouchscreenStrokeGesture,
      set: (value, next) => next,
      name: 'TouchscreenStrokeGesture',
    );

final _configTouchscreenGesturetouchscreenStrokeStrokeStrokesPart =
    LensPart<TouchscreenStrokeGesture, List<Stroke>>(
      get: (value) => value.strokes,
      set: (value, next) => value.copyWith(strokes: next),
      name: 'strokeStrokes',
    );

Object? comparableGestureNodeValue(GestureNode? value) => switch (value) {
  GestureLeaf() && final l => switch (l.gesture) {
    MouseGesture() && final e => comparableMouseGestureValue(e),
    KeyboardGesture() && final e => comparableKeyboardGestureValue(e),
    PointerGesture() && final e => comparablePointerGestureValue(e),
    TouchpadGesture() && final e => comparableTouchpadGestureValue(e),
    TouchscreenGesture() && final e => comparableTouchscreenGestureValue(e),
    _ => null,
  },
  GestureGroupNode() && final g => [
    comparableGestureGroupNodeValue(g),
    g.children.map(comparableGestureNodeValue).toList(),
  ],
  _ => null,
};

final _configGestureGroupNamePart = LensPart<GestureGroupNode, String>(
  get: (value) => value.name,
  set: (value, next) => value.copyWith(name: next),
  name: 'name',
);

final _configGestureGroupEnabledPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.enabled,
  set: (value, next) => value.copyWith(enabled: next),
  name: 'enabled',
);

final _configGestureGroupConditionsPart =
    LensPart<GestureGroupNode, Condition?>(
      get: (value) => value.conditions,
      set: (value, next) => value.copyWith(conditions: next),
      name: 'conditions',
    );

final _configGestureGroupIdPart = LensPart<GestureGroupNode, String?>(
  get: (value) => value.id,
  set: (value, next) => value.copyWith(id: next),
  name: 'id',
);

final _configGestureGroupThresholdPart = LensPart<GestureGroupNode, String?>(
  get: (value) => value.threshold,
  set: (value, next) => value.copyWith(threshold: next),
  name: 'threshold',
);

final _configGestureGroupResumeTimeoutPart = LensPart<GestureGroupNode, int?>(
  get: (value) => value.resumeTimeout,
  set: (value, next) => value.copyWith(resumeTimeout: next),
  name: 'resumeTimeout',
);

final _configGestureGroupAcceleratedPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.accelerated ?? false,
  set: (value, next) =>
      value.copyWith(accelerated: next == false ? null : next),
  name: 'accelerated',
);

final _configGestureGroupBlockEventsPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.blockEvents ?? true,
  set: (value, next) => value.copyWith(blockEvents: next == true ? null : next),
  name: 'blockEvents',
);

final _configGestureGroupClearModifiersPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.clearModifiers ?? false,
  set: (value, next) =>
      value.copyWith(clearModifiers: next == false ? null : next),
  name: 'clearModifiers',
);

final _configGestureGroupSetLastTriggerPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.setLastTrigger ?? true,
  set: (value, next) =>
      value.copyWith(setLastTrigger: next == true ? null : next),
  name: 'setLastTrigger',
);

final _configGestureGroupEndConditionsPart =
    LensPart<GestureGroupNode, Condition?>(
      get: (value) => value.endConditions,
      set: (value, next) => value.copyWith(endConditions: next),
      name: 'endConditions',
    );

final _configGestureGroupMouseButtonsPart =
    LensPart<GestureGroupNode, List<MouseButtonValue>>(
      get: (value) => value.mouseButtons ?? const <MouseButtonValue>[],
      set: (value, next) => value.copyWith(
        mouseButtons: next == const <MouseButtonValue>[] ? null : next,
      ),
      name: 'mouseButtons',
    );

final _configGestureGroupMouseButtonsExactOrderPart =
    LensPart<GestureGroupNode, bool>(
      get: (value) => value.mouseButtonsExactOrder ?? false,
      set: (value, next) =>
          value.copyWith(mouseButtonsExactOrder: next == false ? null : next),
      name: 'mouseButtonsExactOrder',
    );

final _configGestureGroupFingersPart = LensPart<GestureGroupNode, FingerRange?>(
  get: (value) => value.fingers,
  set: (value, next) => value.copyWith(fingers: next),
  name: 'fingers',
);

final _configGestureGroupSpeedPart = LensPart<GestureGroupNode, TriggerSpeed?>(
  get: (value) => value.speed,
  set: (value, next) => value.copyWith(speed: next),
  name: 'speed',
);

final _configGestureGroupInstantPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.instant ?? false,
  set: (value, next) => value.copyWith(instant: next == false ? null : next),
  name: 'instant',
);

final _configGestureGroupLockPointerPart = LensPart<GestureGroupNode, bool>(
  get: (value) => value.lockPointer ?? false,
  set: (value, next) =>
      value.copyWith(lockPointer: next == false ? null : next),
  name: 'lockPointer',
);

final _configDeviceRulesPart = LensPart<Config, List<DeviceRule>>(
  get: (value) => value.deviceRules,
  set: (value, next) => value.copyWith(deviceRules: next),
  name: 'deviceRules',
);

LensPart<Config, DeviceRule> _configDeviceRulesItemPart(int index) =>
    LensPart<Config, DeviceRule>(
      get: (value) => value.deviceRules[index],
      set: (value, nextValue) {
        if (index < 0 || index >= value.deviceRules.length) {
          return value;
        }
        final next = List<DeviceRule>.of(value.deviceRules);
        next[index] = nextValue;
        return value.copyWith(deviceRules: next);
      },
      canGet: (value) => index >= 0 && index < value.deviceRules.length,
      name: 'deviceRules[$index]',
    );

Config replaceDeviceRuleAt(Config root, int index, DeviceRule value) {
  final list = root.deviceRules;
  if (index < 0 || index >= list.length) return root;
  final next = List<DeviceRule>.of(list);
  next[index] = value;
  return root.copyWith(deviceRules: next);
}

Config updateDeviceRuleAt(
  Config root,
  int index,
  DeviceRule Function(DeviceRule value) update,
) {
  final list = root.deviceRules;
  if (index < 0 || index >= list.length) return root;
  final next = List<DeviceRule>.of(list);
  next[index] = update(next[index]);
  return root.copyWith(deviceRules: next);
}

Config insertDeviceRuleAt(Config root, int index, DeviceRule value) {
  final list = root.deviceRules;
  if (index < 0 || index > list.length) return root;
  final next = List<DeviceRule>.of(list)..insert(index, value);
  return root.copyWith(deviceRules: next);
}

Config addDeviceRule(Config root, DeviceRule value) {
  final next = List<DeviceRule>.of(root.deviceRules)..add(value);
  return root.copyWith(deviceRules: next);
}

Config removeDeviceRuleAt(Config root, int index) {
  final list = root.deviceRules;
  if (index < 0 || index >= list.length) return root;
  final next = List<DeviceRule>.of(list)..removeAt(index);
  return root.copyWith(deviceRules: next);
}

Config duplicateDeviceRuleAt(Config root, int index) {
  final list = root.deviceRules;
  if (index < 0 || index >= list.length) return root;
  final next = List<DeviceRule>.of(list)..insert(index + 1, list[index]);
  return root.copyWith(deviceRules: next);
}

Config moveDeviceRule(Config root, int from, int to) {
  final list = root.deviceRules;
  if (from < 0 || from >= list.length) return root;
  final next = List<DeviceRule>.of(list);
  final item = next.removeAt(from);
  next.insert(to.clamp(0, next.length), item);
  return root.copyWith(deviceRules: next);
}

final _configDeviceRuleConditionsPart = LensPart<DeviceRule, Condition?>(
  get: (value) => value.conditions,
  set: (value, next) => value.copyWith(conditions: next),
  name: 'conditions',
);

final _configDeviceRulePropertiesPart =
    LensPart<DeviceRule, DeviceRuleProperties>(
      get: (value) => value.properties,
      set: (value, next) => value.copyWith(properties: next),
      name: 'properties',
    );

final _configDeviceRulepropertiesIgnorePart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.ignore,
      set: (value, next) => value.copyWith(ignore: next),
      name: 'ignore',
    );

final _configDeviceRulepropertiesGrabPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.grab,
      set: (value, next) => value.copyWith(grab: next),
      name: 'grab',
    );

final _configDeviceRulepropertiesMotionTimeoutPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.motionTimeout,
      set: (value, next) => value.copyWith(motionTimeout: next),
      name: 'motionTimeout',
    );

final _configDeviceRulepropertiesMotionThresholdPart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold,
      set: (value, next) => value.copyWith(motionThreshold: next),
      name: 'motionThreshold',
    );

final _configDeviceRulepropertiesPressTimeoutPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressTimeout,
      set: (value, next) => value.copyWith(pressTimeout: next),
      name: 'pressTimeout',
    );

final _configDeviceRulepropertiesSwipeAngleTolerancePart =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.swipeAngleTolerance,
      set: (value, next) => value.copyWith(swipeAngleTolerance: next),
      name: 'swipeAngleTolerance',
    );

final _configDeviceRulepropertiesUnblockButtonsOnTimeoutPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.unblockButtonsOnTimeout,
      set: (value, next) => value.copyWith(unblockButtonsOnTimeout: next),
      name: 'unblockButtonsOnTimeout',
    );

final _configDeviceRulepropertiesButtonpadPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.buttonpad,
      set: (value, next) => value.copyWith(buttonpad: next),
      name: 'buttonpad',
    );

final _configDeviceRulepropertiesClickTimeoutPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.clickTimeout,
      set: (value, next) => value.copyWith(clickTimeout: next),
      name: 'clickTimeout',
    );

final _configDeviceRulepropertiesHandleEvdevEventsPart =
    LensPart<DeviceRuleProperties, bool?>(
      get: (value) => value.handleEvdevEvents,
      set: (value, next) => value.copyWith(handleEvdevEvents: next),
      name: 'handleEvdevEvents',
    );

final _configDeviceRulepropertiesMotionThreshold2Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold2,
      set: (value, next) => value.copyWith(motionThreshold2: next),
      name: 'motionThreshold2',
    );

final _configDeviceRulepropertiesMotionThreshold3Part =
    LensPart<DeviceRuleProperties, double?>(
      get: (value) => value.motionThreshold3,
      set: (value, next) => value.copyWith(motionThreshold3: next),
      name: 'motionThreshold3',
    );

final _configDeviceRulepropertiesPressureRangesFingerPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesFinger,
      set: (value, next) => value.copyWith(pressureRangesFinger: next),
      name: 'pressureRangesFinger',
    );

final _configDeviceRulepropertiesPressureRangesThumbPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesThumb,
      set: (value, next) => value.copyWith(pressureRangesThumb: next),
      name: 'pressureRangesThumb',
    );

final _configDeviceRulepropertiesPressureRangesPalmPart =
    LensPart<DeviceRuleProperties, int?>(
      get: (value) => value.pressureRangesPalm,
      set: (value, next) => value.copyWith(pressureRangesPalm: next),
      name: 'pressureRangesPalm',
    );

Lens<Config, SpeedSettings> speedSettingsLens(DeviceType device) =>
    Lens<Config, SpeedSettings>(
      get: (root) {
        final container = root as Config;
        return switch (device) {
          DeviceType.mouse => container.mouseSpeed ?? const SpeedSettings(),
          DeviceType.touchpad =>
            container.touchpadSpeed ?? const SpeedSettings(),
          DeviceType.touchscreen =>
            container.touchscreenSpeed ?? const SpeedSettings(),
          _ => const SpeedSettings(),
        };
      },
      set: (root, next) {
        final container = root as Config;
        return switch (device) {
          DeviceType.mouse =>
            next.isEmpty
                ? container.copyWith(mouseSpeed: null)
                : container.copyWith(mouseSpeed: next),
          DeviceType.touchpad =>
            next.isEmpty
                ? container.copyWith(touchpadSpeed: null)
                : container.copyWith(touchpadSpeed: next),
          DeviceType.touchscreen =>
            next.isEmpty
                ? container.copyWith(touchscreenSpeed: null)
                : container.copyWith(touchscreenSpeed: next),
          _ => container,
        };
      },
      name: 'speed[${device.name}]',
    );

final _configSpeedEventsPart = LensPart<SpeedSettings, int?>(
  get: (value) => value.events,
  set: (value, next) => value.copyWith(events: next),
  name: 'events',
);

final _configSpeedSwipeThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.swipeThreshold,
  set: (value, next) => value.copyWith(swipeThreshold: next),
  name: 'swipeThreshold',
);

final _configSpeedPinchInThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.pinchInThreshold,
  set: (value, next) => value.copyWith(pinchInThreshold: next),
  name: 'pinchInThreshold',
);

final _configSpeedPinchOutThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.pinchOutThreshold,
  set: (value, next) => value.copyWith(pinchOutThreshold: next),
  name: 'pinchOutThreshold',
);

final _configSpeedRotateThresholdPart = LensPart<SpeedSettings, double?>(
  get: (value) => value.rotateThreshold,
  set: (value, next) => value.copyWith(rotateThreshold: next),
  name: 'rotateThreshold',
);

Lens<Config, GlobalSettings> globalSettingsLens() =>
    _configRootLens().then(_configGlobalSettingsPart);

GlobalSettings? globalSettingsAt(Config? root) {
  if (root == null) return null;
  final lens = globalSettingsLens();
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, List<TriggerAction>> gestureActionsLens(
  GestureLocation location,
) => gestureLens(
  location,
).then(_configGestureCommonPart).then(_configGesturecommonActionsPart);

List<TriggerAction>? gestureActionsAt(Config? root, GestureLocation location) {
  if (root == null) return null;
  final lens = gestureActionsLens(location);
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, TriggerAction> actionLens(ActionLocation location) =>
    location.lens;

TriggerAction? actionAt(Config? root, ActionLocation location) {
  if (root == null) return null;
  final lens = actionLens(location);
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, List<MenuItem>> actionItemsLens(ActionLocation location) =>
    location.lens
        .then(_configGesturecommonactionActionPart)
        .then(_configGesturecommonactionAsContextMenuActionPart)
        .then(_configGesturecommonactionactioncontextMenuItemsPart);

List<MenuItem>? actionItemsAt(Config? root, ActionLocation location) {
  if (root == null) return null;
  final lens = actionItemsLens(location);
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, MenuItem> menuItemLens(MenuItemLocation location) => location
    .action
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsContextMenuActionPart)
    .then(
      _configGesturecommonactionactioncontextMenuItemsItemPart(location.itemId),
    );

MenuItem? menuItemAt(Config? root, MenuItemLocation location) {
  if (root == null) return null;
  final lens = menuItemLens(location);
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, List<DeviceRule>> deviceRulesLens() =>
    _configRootLens().then(_configDeviceRulesPart);

List<DeviceRule>? deviceRulesAt(Config? root) {
  if (root == null) return null;
  final lens = deviceRulesLens();
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, DeviceRule> deviceRuleLens(DeviceRuleLocation location) =>
    _configRootLens().then(
      _configDeviceRulesItemPart(location.deviceRuleIndex),
    );

DeviceRule? deviceRuleAt(Config? root, DeviceRuleLocation location) {
  if (root == null) return null;
  final lens = deviceRuleLens(location);
  try {
    if (!lens.canGet(root)) return null;
    return lens.get(root);
  } on Object catch (_) {
    return null;
  }
}

Lens<Config, bool> globalSettingsAutoreloadLens() => _configRootLens()
    .then(_configGlobalSettingsPart)
    .then(_configGlobalSettingsAutoreloadPart);

Lens<Config, bool> globalSettingsExternalVariableAccessLens() =>
    _configRootLens()
        .then(_configGlobalSettingsPart)
        .then(_configGlobalSettingsExternalVariableAccessPart);

Lens<Config, bool?> globalSettingsMouseStrokeOverlayEnabledLens() =>
    _configRootLens()
        .then(_configGlobalSettingsPart)
        .then(_configGlobalSettingsMouseStrokeOverlayEnabledPart);

Lens<Config, bool> globalSettingsNotificationsConfigErrorLens() =>
    _configRootLens()
        .then(_configGlobalSettingsPart)
        .then(_configGlobalSettingsNotificationsConfigErrorPart);

Lens<Config, List<String>?> globalSettingsEmergencyCombinationLens() =>
    _configRootLens()
        .then(_configGlobalSettingsPart)
        .then(_configGlobalSettingsEmergencyCombinationPart);

Lens<Config, String?> gestureIdLens(GestureLocation location) => gestureLens(
  location,
).then(_configGestureCommonPart).then(_configGesturecommonIdPart);

Lens<Config, List<MouseButtonValue>> gestureMouseButtonsLens(
  GestureLocation location,
) => gestureLens(
  location,
).then(_configGestureCommonPart).then(_configGesturecommonMouseButtonsPart);

Lens<Config, bool> gestureMouseButtonsExactOrderLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configGestureCommonPart)
    .then(_configGesturecommonMouseButtonsExactOrderPart);

Lens<Config, Condition?> gestureConditionsLens(GestureLocation location) =>
    gestureLens(
      location,
    ).then(_configGestureCommonPart).then(_configGesturecommonConditionsPart);

Lens<Config, Condition?> gestureEndConditionsLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configGestureCommonPart)
        .then(_configGesturecommonEndConditionsPart);

Lens<Config, bool> gestureBlockEventsLens(GestureLocation location) =>
    gestureLens(
      location,
    ).then(_configGestureCommonPart).then(_configGesturecommonBlockEventsPart);

Lens<Config, bool> gestureClearModifiersLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configGestureCommonPart)
        .then(_configGesturecommonClearModifiersPart);

Lens<Config, int?> gestureResumeTimeoutLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configGestureCommonPart)
        .then(_configGesturecommonResumeTimeoutPart);

Lens<Config, bool> gestureSetLastTriggerLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configGestureCommonPart)
        .then(_configGesturecommonSetLastTriggerPart);

Lens<Config, String?> gestureThresholdLens(GestureLocation location) =>
    gestureLens(
      location,
    ).then(_configGestureCommonPart).then(_configGesturecommonThresholdPart);

Lens<Config, bool> gestureAcceleratedLens(GestureLocation location) =>
    gestureLens(
      location,
    ).then(_configGestureCommonPart).then(_configGesturecommonAcceleratedPart);

Lens<Config, Map<String, Object?>> gestureExtraLens(GestureLocation location) =>
    gestureLens(
      location,
    ).then(_configGestureCommonPart).then(_configGesturecommonExtraPart);

Lens<Config, String> actionCommandLens(ActionLocation location) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsCommandActionPart)
    .then(_configGesturecommonactionactioncommandCommandPart);

Lens<Config, bool> actionWaitLens(ActionLocation location) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsCommandActionPart)
    .then(_configGesturecommonactionactioncommandWaitPart);

Lens<Config, String> actionComponentLens(ActionLocation location) => location
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsPlasmaShortcutActionPart)
    .then(_configGesturecommonactionactionplasmaComponentPart);

Lens<Config, String> actionShortcutLens(ActionLocation location) => location
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsPlasmaShortcutActionPart)
    .then(_configGesturecommonactionactionplasmaShortcutPart);

Lens<Config, String> actionWindowIdLens(ActionLocation location) => location
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsActivateWindowActionPart)
    .then(_configGesturecommonactionactionactivateWindowWindowIdPart);

Lens<Config, List<TextSubstitutionRule>> actionRulesLens(
  ActionLocation location,
) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsReplaceTextActionPart)
    .then(_configGesturecommonactionactionreplaceTextRulesPart);

Lens<Config, int> actionDurationLens(ActionLocation location) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsSleepActionPart)
    .then(_configGesturecommonactionactionsleepDurationPart);

Lens<Config, String> actionExpressionLens(ActionLocation location) => location
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsFunctionActionPart)
    .then(_configGesturecommonactionactionfunctionExpressionPart);

Lens<Config, String> menuItemTextLens(MenuItemLocation location) => location
    .action
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsContextMenuActionPart)
    .then(
      _configGesturecommonactionactioncontextMenuItemsItemPart(location.itemId),
    )
    .then(_configGesturecommonactionactioncontextMenuitemAsActionMenuItemPart)
    .then(_configGesturecommonactionactioncontextMenuitemactionTextPart);

Lens<Config, String?> menuItemIconLens(MenuItemLocation location) => location
    .action
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsContextMenuActionPart)
    .then(
      _configGesturecommonactionactioncontextMenuItemsItemPart(location.itemId),
    )
    .then(_configGesturecommonactionactioncontextMenuitemAsActionMenuItemPart)
    .then(_configGesturecommonactionactioncontextMenuitemactionIconPart);

Lens<Config, List<TriggerAction>> menuItemActionsLens(
  MenuItemLocation location,
) => location.action.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsContextMenuActionPart)
    .then(
      _configGesturecommonactionactioncontextMenuItemsItemPart(location.itemId),
    )
    .then(_configGesturecommonactionactioncontextMenuitemAsActionMenuItemPart)
    .then(_configGesturecommonactionactioncontextMenuitemactionActionsPart);

Lens<Config, String> menuItemSubMenuTextLens(MenuItemLocation location) =>
    location.action.lens
        .then(_configGesturecommonactionActionPart)
        .then(_configGesturecommonactionAsContextMenuActionPart)
        .then(
          _configGesturecommonactionactioncontextMenuItemsItemPart(
            location.itemId,
          ),
        )
        .then(_configGesturecommonactionactioncontextMenuitemAsSubMenuItemPart)
        .then(
          _configGesturecommonactionactioncontextMenuitemsubMenuSubMenuTextPart,
        );

Lens<Config, String?> menuItemSubMenuIconLens(MenuItemLocation location) =>
    location.action.lens
        .then(_configGesturecommonactionActionPart)
        .then(_configGesturecommonactionAsContextMenuActionPart)
        .then(
          _configGesturecommonactionactioncontextMenuItemsItemPart(
            location.itemId,
          ),
        )
        .then(_configGesturecommonactionactioncontextMenuitemAsSubMenuItemPart)
        .then(
          _configGesturecommonactionactioncontextMenuitemsubMenuSubMenuIconPart,
        );

Lens<Config, String> menuItemSectionTextLens(
  MenuItemLocation location,
) => location.action.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsContextMenuActionPart)
    .then(
      _configGesturecommonactionactioncontextMenuItemsItemPart(location.itemId),
    )
    .then(_configGesturecommonactionactioncontextMenuitemAsSectionMenuItemPart)
    .then(
      _configGesturecommonactionactioncontextMenuitemsectionSectionTextPart,
    );

Lens<Config, String> actionRawLens(ActionLocation location) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsRawActionPart)
    .then(_configGesturecommonactionactionrawRawPart);

Lens<Config, List<InputEntry>> actionInputEntriesLens(
  ActionLocation location,
) => location.lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsInputActionPart)
    .then(_configGesturecommonactionactioninputInputEntriesPart);

Lens<Config, int?> actionInputDelayLens(ActionLocation location) => location
    .lens
    .then(_configGesturecommonactionActionPart)
    .then(_configGesturecommonactionAsInputActionPart)
    .then(_configGesturecommonactionactioninputInputDelayPart);

Lens<Config, TriggerOnValue> actionTriggerOnLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionTriggerOnPart);

Lens<Config, String?> actionIntervalLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionIntervalPart);

Lens<Config, String?> actionThresholdLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionThresholdPart);

Lens<Config, int?> actionLimitLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionLimitPart);

Lens<Config, bool> actionEnabledLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionEnabledPart);

Lens<Config, bool> actionConflictingLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionConflictingPart);

Lens<Config, Condition?> actionConditionsLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionConditionsPart);

Lens<Config, String?> actionIdLens(ActionLocation location) =>
    location.lens.then(_configGesturecommonactionIdPart);

Lens<Config, TriggerSpeed?> mouseGestureStrokeMotionSpeedLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsStrokeGesturePart)
    .then(_configMouseGesturestrokeMotionPart)
    .then(_configMouseGesturestrokemotionSpeedPart);

Lens<Config, bool> mouseGestureStrokeMotionLockPointerLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsStrokeGesturePart)
    .then(_configMouseGesturestrokeMotionPart)
    .then(_configMouseGesturestrokemotionLockPointerPart);

Lens<Config, List<Stroke>> mouseGestureStrokeStrokesLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsStrokeGesturePart)
    .then(_configMouseGesturestrokeStrokesPart);

Lens<Config, TriggerSpeed?> mouseGestureSwipeMotionSpeedLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeMotionPart)
    .then(_configMouseGestureswipemotionSpeedPart);

Lens<Config, bool> mouseGestureSwipeMotionLockPointerLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeMotionPart)
    .then(_configMouseGestureswipemotionLockPointerPart);

Lens<Config, SwipeDirection> mouseGestureSwipeModeDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeModePart)
    .then(_configMouseGestureswipemodeAsSwipeDirectionModePart)
    .then(_configMouseGestureswipemodedirectionDirectionPart);

Lens<Config, double> mouseGestureSwipeModeAngleMinAngleLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeModePart)
    .then(_configMouseGestureswipemodeAsSwipeAngleModePart)
    .then(_configMouseGestureswipemodeangleMinAnglePart);

Lens<Config, double> mouseGestureSwipeModeAngleMaxAngleLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeModePart)
    .then(_configMouseGestureswipemodeAsSwipeAngleModePart)
    .then(_configMouseGestureswipemodeangleMaxAnglePart);

Lens<Config, bool> mouseGestureSwipeModeAngleBidirectionalLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configMouseGestureCastPart)
    .then(_configAsSwipeGesturePart)
    .then(_configMouseGestureswipeModePart)
    .then(_configMouseGestureswipemodeAsSwipeAngleModePart)
    .then(_configMouseGestureswipemodeangleBidirectionalPart);

Lens<Config, TriggerSpeed?> circleMotionSpeedLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsCircleGesturePart)
        .then(_configMouseGesturecircleMotionPart)
        .then(_configMouseGesturecirclemotionSpeedPart);

Lens<Config, bool> circleMotionLockPointerLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsCircleGesturePart)
        .then(_configMouseGesturecircleMotionPart)
        .then(_configMouseGesturecirclemotionLockPointerPart);

Lens<Config, RotationDirection> circleDirectionLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsCircleGesturePart)
        .then(_configMouseGesturecircleDirectionPart);

Lens<Config, TriggerSpeed?> pressMotionSpeedLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsPressGesturePart)
        .then(_configMouseGesturepressMotionPart)
        .then(_configMouseGesturepressmotionSpeedPart);

Lens<Config, bool> pressMotionLockPointerLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsPressGesturePart)
        .then(_configMouseGesturepressMotionPart)
        .then(_configMouseGesturepressmotionLockPointerPart);

Lens<Config, bool> pressInstantLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsPressGesturePart)
        .then(_configMouseGesturepressInstantPart);

Lens<Config, TriggerSpeed?> wheelMotionSpeedLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsWheelGesturePart)
        .then(_configMouseGesturewheelMotionPart)
        .then(_configMouseGesturewheelmotionSpeedPart);

Lens<Config, bool> wheelMotionLockPointerLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsWheelGesturePart)
        .then(_configMouseGesturewheelMotionPart)
        .then(_configMouseGesturewheelmotionLockPointerPart);

Lens<Config, WheelDirection> wheelDirectionLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configMouseGestureCastPart)
        .then(_configAsWheelGesturePart)
        .then(_configMouseGesturewheelDirectionPart);

Lens<Config, List<String>> shortcutKeysLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configKeyboardGestureCastPart)
        .then(_configAsShortcutGesturePart)
        .then(_configKeyboardGestureshortcutKeysPart);

Lens<Config, FingerRange?> touchpadFingersLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configTouchpadGestureCastPart)
        .then(_configTouchpadGestureFingersPart);

Lens<Config, TriggerSpeed?> touchpadMotionSpeedLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configTouchpadGestureCastPart)
        .then(_configTouchpadGestureMotionSpeedPart);

Lens<Config, SwipeMode> touchpadSwipeModeLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configTouchpadGestureCastPart)
        .then(_configAsTouchpadSwipeGesturePart)
        .then(_configTouchpadGesturetouchpadSwipeSwipeModePart);

Lens<Config, PinchDirection> touchpadPinchDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchpadGestureCastPart)
    .then(_configAsTouchpadPinchGesturePart)
    .then(_configTouchpadGesturetouchpadPinchPinchDirectionPart);

Lens<Config, RotationDirection> touchpadRotateDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchpadGestureCastPart)
    .then(_configAsTouchpadRotateGesturePart)
    .then(_configTouchpadGesturetouchpadRotateRotateDirectionPart);

Lens<Config, RotationDirection> touchpadCircleDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchpadGestureCastPart)
    .then(_configAsTouchpadCircleGesturePart)
    .then(_configTouchpadGesturetouchpadCircleCircleDirectionPart);

Lens<Config, List<Stroke>> touchpadStrokeStrokesLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchpadGestureCastPart)
    .then(_configAsTouchpadStrokeGesturePart)
    .then(_configTouchpadGesturetouchpadStrokeStrokeStrokesPart);

Lens<Config, FingerRange?> touchscreenFingersLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configTouchscreenGestureCastPart)
        .then(_configTouchscreenGestureFingersPart);

Lens<Config, TriggerSpeed?> touchscreenMotionSpeedLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchscreenGestureCastPart)
    .then(_configTouchscreenGestureMotionSpeedPart);

Lens<Config, SwipeMode> touchscreenSwipeModeLens(GestureLocation location) =>
    gestureLens(location)
        .then(_configTouchscreenGestureCastPart)
        .then(_configAsTouchscreenSwipeGesturePart)
        .then(_configTouchscreenGesturetouchscreenSwipeSwipeModePart);

Lens<Config, PinchDirection> touchscreenPinchDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchscreenGestureCastPart)
    .then(_configAsTouchscreenPinchGesturePart)
    .then(_configTouchscreenGesturetouchscreenPinchPinchDirectionPart);

Lens<Config, RotationDirection> touchscreenRotateDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchscreenGestureCastPart)
    .then(_configAsTouchscreenRotateGesturePart)
    .then(_configTouchscreenGesturetouchscreenRotateRotateDirectionPart);

Lens<Config, RotationDirection> touchscreenCircleDirectionLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchscreenGestureCastPart)
    .then(_configAsTouchscreenCircleGesturePart)
    .then(_configTouchscreenGesturetouchscreenCircleCircleDirectionPart);

Lens<Config, List<Stroke>> touchscreenStrokeStrokesLens(
  GestureLocation location,
) => gestureLens(location)
    .then(_configTouchscreenGestureCastPart)
    .then(_configAsTouchscreenStrokeGesturePart)
    .then(_configTouchscreenGesturetouchscreenStrokeStrokeStrokesPart);

Lens<Config, String> gestureGroupNameLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupNamePart);

Lens<Config, bool> gestureGroupEnabledLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupEnabledPart);

Lens<Config, Condition?> gestureGroupConditionsLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupConditionsPart);

Lens<Config, String?> gestureGroupIdLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupIdPart);

Lens<Config, String?> gestureGroupThresholdLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupThresholdPart);

Lens<Config, int?> gestureGroupResumeTimeoutLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupResumeTimeoutPart);

Lens<Config, bool> gestureGroupAcceleratedLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupAcceleratedPart);

Lens<Config, bool> gestureGroupBlockEventsLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupBlockEventsPart);

Lens<Config, bool> gestureGroupClearModifiersLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupClearModifiersPart);

Lens<Config, bool> gestureGroupSetLastTriggerLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupSetLastTriggerPart);

Lens<Config, Condition?> gestureGroupEndConditionsLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupEndConditionsPart);

Lens<Config, List<MouseButtonValue>> gestureGroupMouseButtonsLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupMouseButtonsPart);

Lens<Config, bool> gestureGroupMouseButtonsExactOrderLens(
  GestureGroupLocation location,
) => gestureGroupLens(
  location,
).then(_configGestureGroupMouseButtonsExactOrderPart);

Lens<Config, FingerRange?> gestureGroupFingersLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupFingersPart);

Lens<Config, TriggerSpeed?> gestureGroupSpeedLens(
  GestureGroupLocation location,
) => gestureGroupLens(location).then(_configGestureGroupSpeedPart);

Lens<Config, bool> gestureGroupInstantLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupInstantPart);

Lens<Config, bool> gestureGroupLockPointerLens(GestureGroupLocation location) =>
    gestureGroupLens(location).then(_configGestureGroupLockPointerPart);

Lens<Config, Condition?> deviceRuleConditionsLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRuleConditionsPart);

Lens<Config, bool?> deviceRulePropertiesIgnoreLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesIgnorePart);

Lens<Config, bool?> deviceRulePropertiesGrabLens(DeviceRuleLocation location) =>
    _configRootLens()
        .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
        .then(_configDeviceRulePropertiesPart)
        .then(_configDeviceRulepropertiesGrabPart);

Lens<Config, int?> deviceRulePropertiesMotionTimeoutLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesMotionTimeoutPart);

Lens<Config, double?> deviceRulePropertiesMotionThresholdLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesMotionThresholdPart);

Lens<Config, int?> deviceRulePropertiesPressTimeoutLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesPressTimeoutPart);

Lens<Config, double?> deviceRulePropertiesSwipeAngleToleranceLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesSwipeAngleTolerancePart);

Lens<Config, bool?> deviceRulePropertiesUnblockButtonsOnTimeoutLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesUnblockButtonsOnTimeoutPart);

Lens<Config, bool?> deviceRulePropertiesButtonpadLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesButtonpadPart);

Lens<Config, int?> deviceRulePropertiesClickTimeoutLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesClickTimeoutPart);

Lens<Config, bool?> deviceRulePropertiesHandleEvdevEventsLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesHandleEvdevEventsPart);

Lens<Config, double?> deviceRulePropertiesMotionThreshold2Lens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesMotionThreshold2Part);

Lens<Config, double?> deviceRulePropertiesMotionThreshold3Lens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesMotionThreshold3Part);

Lens<Config, int?> deviceRulePropertiesPressureRangesFingerLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesPressureRangesFingerPart);

Lens<Config, int?> deviceRulePropertiesPressureRangesThumbLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesPressureRangesThumbPart);

Lens<Config, int?> deviceRulePropertiesPressureRangesPalmLens(
  DeviceRuleLocation location,
) => _configRootLens()
    .then(_configDeviceRulesItemPart(location.deviceRuleIndex))
    .then(_configDeviceRulePropertiesPart)
    .then(_configDeviceRulepropertiesPressureRangesPalmPart);

Lens<Config, int?> speedEventsLens(DeviceType device) =>
    speedSettingsLens(device).then(_configSpeedEventsPart);

Lens<Config, double?> speedSwipeThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(_configSpeedSwipeThresholdPart);

Lens<Config, double?> speedPinchInThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(_configSpeedPinchInThresholdPart);

Lens<Config, double?> speedPinchOutThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(_configSpeedPinchOutThresholdPart);

Lens<Config, double?> speedRotateThresholdLens(DeviceType device) =>
    speedSettingsLens(device).then(_configSpeedRotateThresholdPart);

bool globalSettingsAutoreloadHasSavedBacking(Config? saved) {
  if (saved == null) return false;
  try {
    globalSettingsAutoreloadLens().get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final globalSettingsAutoreloadField =
    GeneratedEditField<Config, (), bool, Lens<Config, bool>>(
      id: 'globalSettingsAutoreload',
      dirtyField: ConfigDirtyField.globalSettingsAutoreload,
      lens: (location) => globalSettingsAutoreloadLens(),
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool globalSettingsExternalVariableAccessHasSavedBacking(Config? saved) {
  if (saved == null) return false;
  try {
    globalSettingsExternalVariableAccessLens().get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final globalSettingsExternalVariableAccessField =
    GeneratedEditField<Config, (), bool, Lens<Config, bool>>(
      id: 'globalSettingsExternalVariableAccess',
      dirtyField: ConfigDirtyField.globalSettingsExternalVariableAccess,
      lens: (location) => globalSettingsExternalVariableAccessLens(),
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool globalSettingsMouseStrokeOverlayEnabledHasSavedBacking(Config? saved) {
  if (saved == null) return false;
  try {
    globalSettingsMouseStrokeOverlayEnabledLens().get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final globalSettingsMouseStrokeOverlayEnabledField =
    GeneratedEditField<Config, (), bool?, Lens<Config, bool?>>(
      id: 'globalSettingsMouseStrokeOverlayEnabled',
      dirtyField: ConfigDirtyField.globalSettingsMouseStrokeOverlayEnabled,
      lens: (location) => globalSettingsMouseStrokeOverlayEnabledLens(),
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool globalSettingsNotificationsConfigErrorHasSavedBacking(Config? saved) {
  if (saved == null) return false;
  try {
    globalSettingsNotificationsConfigErrorLens().get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final globalSettingsNotificationsConfigErrorField =
    GeneratedEditField<Config, (), bool, Lens<Config, bool>>(
      id: 'globalSettingsNotificationsConfigError',
      dirtyField: ConfigDirtyField.globalSettingsNotificationsConfigError,
      lens: (location) => globalSettingsNotificationsConfigErrorLens(),
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool globalSettingsEmergencyCombinationHasSavedBacking(Config? saved) {
  if (saved == null) return false;
  try {
    globalSettingsEmergencyCombinationLens().get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final globalSettingsEmergencyCombinationField =
    GeneratedEditField<Config, (), List<String>?, Lens<Config, List<String>?>>(
      id: 'globalSettingsEmergencyCombination',
      dirtyField: ConfigDirtyField.globalSettingsEmergencyCombination,
      lens: (location) => globalSettingsEmergencyCombinationLens(),
      fallback: null,
      adapter: FieldAdapterSpec<List<String>?>.identity(),
    );

bool gestureIdHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    gestureIdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureIdField =
    GeneratedEditField<Config, GestureLocation, String?, Lens<Config, String?>>(
      id: 'gestureId',
      dirtyField: ConfigDirtyField.gestureId,
      lens: gestureIdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool gestureMouseButtonsHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureMouseButtonsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureMouseButtonsField =
    GeneratedEditField<
      Config,
      GestureLocation,
      List<MouseButtonValue>,
      Lens<Config, List<MouseButtonValue>>
    >(
      id: 'gestureMouseButtons',
      dirtyField: ConfigDirtyField.gestureMouseButtons,
      lens: gestureMouseButtonsLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<MouseButtonValue>>.identity(),
    );

bool gestureMouseButtonsExactOrderHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureMouseButtonsExactOrderLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureMouseButtonsExactOrderField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'gestureMouseButtonsExactOrder',
      dirtyField: ConfigDirtyField.gestureMouseButtonsExactOrder,
      lens: gestureMouseButtonsExactOrderLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureConditionsHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    gestureConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureConditionsField =
    GeneratedEditField<
      Config,
      GestureLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'gestureConditions',
      dirtyField: ConfigDirtyField.gestureConditions,
      lens: gestureConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool gestureEndConditionsHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureEndConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureEndConditionsField =
    GeneratedEditField<
      Config,
      GestureLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'gestureEndConditions',
      dirtyField: ConfigDirtyField.gestureEndConditions,
      lens: gestureEndConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool gestureBlockEventsHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureBlockEventsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureBlockEventsField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'gestureBlockEvents',
      dirtyField: ConfigDirtyField.gestureBlockEvents,
      lens: gestureBlockEventsLens,
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureClearModifiersHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureClearModifiersLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureClearModifiersField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'gestureClearModifiers',
      dirtyField: ConfigDirtyField.gestureClearModifiers,
      lens: gestureClearModifiersLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureResumeTimeoutHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureResumeTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureResumeTimeoutField =
    GeneratedEditField<Config, GestureLocation, int?, Lens<Config, int?>>(
      id: 'gestureResumeTimeout',
      dirtyField: ConfigDirtyField.gestureResumeTimeout,
      lens: gestureResumeTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool gestureSetLastTriggerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureSetLastTriggerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureSetLastTriggerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'gestureSetLastTrigger',
      dirtyField: ConfigDirtyField.gestureSetLastTrigger,
      lens: gestureSetLastTriggerLens,
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureThresholdHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    gestureThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureThresholdField =
    GeneratedEditField<Config, GestureLocation, String?, Lens<Config, String?>>(
      id: 'gestureThreshold',
      dirtyField: ConfigDirtyField.gestureThreshold,
      lens: gestureThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool gestureAcceleratedHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    gestureAcceleratedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureAcceleratedField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'gestureAccelerated',
      dirtyField: ConfigDirtyField.gestureAccelerated,
      lens: gestureAcceleratedLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureExtraHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    gestureExtraLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureExtraField =
    GeneratedEditField<
      Config,
      GestureLocation,
      Map<String, Object?>,
      Lens<Config, Map<String, Object?>>
    >(
      id: 'gestureExtra',
      dirtyField: ConfigDirtyField.gestureExtra,
      lens: gestureExtraLens,
      fallback: null,
      adapter: FieldAdapterSpec<Map<String, Object?>>.identity(),
    );

bool actionCommandHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionCommandLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionCommandField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionCommand',
      dirtyField: ConfigDirtyField.actionCommand,
      lens: actionCommandLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionWaitHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionWaitLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionWaitField =
    GeneratedEditField<Config, ActionLocation, bool, Lens<Config, bool>>(
      id: 'actionWait',
      dirtyField: ConfigDirtyField.actionWait,
      lens: actionWaitLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool actionComponentHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionComponentLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionComponentField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionComponent',
      dirtyField: ConfigDirtyField.actionComponent,
      lens: actionComponentLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionShortcutHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionShortcutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionShortcutField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionShortcut',
      dirtyField: ConfigDirtyField.actionShortcut,
      lens: actionShortcutLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionWindowIdHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionWindowIdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionWindowIdField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionWindowId',
      dirtyField: ConfigDirtyField.actionWindowId,
      lens: actionWindowIdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionRulesHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionRulesLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionRulesField =
    GeneratedEditField<
      Config,
      ActionLocation,
      List<TextSubstitutionRule>,
      Lens<Config, List<TextSubstitutionRule>>
    >(
      id: 'actionRules',
      dirtyField: ConfigDirtyField.actionRules,
      lens: actionRulesLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<TextSubstitutionRule>>.identity(),
    );

bool actionDurationHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionDurationLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionDurationField =
    GeneratedEditField<Config, ActionLocation, int, Lens<Config, int>>(
      id: 'actionDuration',
      dirtyField: ConfigDirtyField.actionDuration,
      lens: actionDurationLens,
      fallback: null,
      adapter: FieldAdapterSpec<int>.identity(),
    );

bool actionExpressionHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionExpressionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionExpressionField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionExpression',
      dirtyField: ConfigDirtyField.actionExpression,
      lens: actionExpressionLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool menuItemTextHasSavedBacking(Config? saved, MenuItemLocation location) {
  if (saved == null) return false;
  try {
    menuItemTextLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemTextField =
    GeneratedEditField<Config, MenuItemLocation, String, Lens<Config, String>>(
      id: 'menuItemText',
      dirtyField: ConfigDirtyField.menuItemText,
      lens: menuItemTextLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool menuItemIconHasSavedBacking(Config? saved, MenuItemLocation location) {
  if (saved == null) return false;
  try {
    menuItemIconLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemIconField =
    GeneratedEditField<
      Config,
      MenuItemLocation,
      String?,
      Lens<Config, String?>
    >(
      id: 'menuItemIcon',
      dirtyField: ConfigDirtyField.menuItemIcon,
      lens: menuItemIconLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool menuItemActionsHasSavedBacking(Config? saved, MenuItemLocation location) {
  if (saved == null) return false;
  try {
    menuItemActionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemActionsField =
    GeneratedEditField<
      Config,
      MenuItemLocation,
      List<TriggerAction>,
      Lens<Config, List<TriggerAction>>
    >(
      id: 'menuItemActions',
      dirtyField: ConfigDirtyField.menuItemActions,
      lens: menuItemActionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<TriggerAction>>.identity(),
    );

bool menuItemSubMenuTextHasSavedBacking(
  Config? saved,
  MenuItemLocation location,
) {
  if (saved == null) return false;
  try {
    menuItemSubMenuTextLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemSubMenuTextField =
    GeneratedEditField<Config, MenuItemLocation, String, Lens<Config, String>>(
      id: 'menuItemSubMenuText',
      dirtyField: ConfigDirtyField.menuItemSubMenuText,
      lens: menuItemSubMenuTextLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool menuItemSubMenuIconHasSavedBacking(
  Config? saved,
  MenuItemLocation location,
) {
  if (saved == null) return false;
  try {
    menuItemSubMenuIconLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemSubMenuIconField =
    GeneratedEditField<
      Config,
      MenuItemLocation,
      String?,
      Lens<Config, String?>
    >(
      id: 'menuItemSubMenuIcon',
      dirtyField: ConfigDirtyField.menuItemSubMenuIcon,
      lens: menuItemSubMenuIconLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool menuItemSectionTextHasSavedBacking(
  Config? saved,
  MenuItemLocation location,
) {
  if (saved == null) return false;
  try {
    menuItemSectionTextLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final menuItemSectionTextField =
    GeneratedEditField<Config, MenuItemLocation, String, Lens<Config, String>>(
      id: 'menuItemSectionText',
      dirtyField: ConfigDirtyField.menuItemSectionText,
      lens: menuItemSectionTextLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionRawHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionRawLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionRawField =
    GeneratedEditField<Config, ActionLocation, String, Lens<Config, String>>(
      id: 'actionRaw',
      dirtyField: ConfigDirtyField.actionRaw,
      lens: actionRawLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool actionInputEntriesHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionInputEntriesLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionInputEntriesField =
    GeneratedEditField<
      Config,
      ActionLocation,
      List<InputEntry>,
      Lens<Config, List<InputEntry>>
    >(
      id: 'actionInputEntries',
      dirtyField: ConfigDirtyField.actionInputEntries,
      lens: actionInputEntriesLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<InputEntry>>.identity(),
    );

bool actionInputDelayHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionInputDelayLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionInputDelayField =
    GeneratedEditField<Config, ActionLocation, int?, Lens<Config, int?>>(
      id: 'actionInputDelay',
      dirtyField: ConfigDirtyField.actionInputDelay,
      lens: actionInputDelayLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool actionTriggerOnHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionTriggerOnLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionTriggerOnField =
    GeneratedEditField<
      Config,
      ActionLocation,
      TriggerOnValue,
      Lens<Config, TriggerOnValue>
    >(
      id: 'actionTriggerOn',
      dirtyField: ConfigDirtyField.actionTriggerOn,
      lens: actionTriggerOnLens,
      fallback: null,
      defaultValue: TriggerOn.end,
      adapter: FieldAdapterSpec<TriggerOnValue>.identity(),
    );

bool actionIntervalHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionIntervalLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionIntervalField =
    GeneratedEditField<Config, ActionLocation, String?, Lens<Config, String?>>(
      id: 'actionInterval',
      dirtyField: ConfigDirtyField.actionInterval,
      lens: actionIntervalLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool actionThresholdHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionThresholdField =
    GeneratedEditField<Config, ActionLocation, String?, Lens<Config, String?>>(
      id: 'actionThreshold',
      dirtyField: ConfigDirtyField.actionThreshold,
      lens: actionThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool actionLimitHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionLimitLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionLimitField =
    GeneratedEditField<Config, ActionLocation, int?, Lens<Config, int?>>(
      id: 'actionLimit',
      dirtyField: ConfigDirtyField.actionLimit,
      lens: actionLimitLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool actionEnabledHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionEnabledLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionEnabledField =
    GeneratedEditField<Config, ActionLocation, bool, Lens<Config, bool>>(
      id: 'actionEnabled',
      dirtyField: ConfigDirtyField.actionEnabled,
      lens: actionEnabledLens,
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool actionConflictingHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionConflictingLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionConflictingField =
    GeneratedEditField<Config, ActionLocation, bool, Lens<Config, bool>>(
      id: 'actionConflicting',
      dirtyField: ConfigDirtyField.actionConflicting,
      lens: actionConflictingLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool actionConditionsHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionConditionsField =
    GeneratedEditField<
      Config,
      ActionLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'actionConditions',
      dirtyField: ConfigDirtyField.actionConditions,
      lens: actionConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool actionIdHasSavedBacking(Config? saved, ActionLocation location) {
  if (saved == null) return false;
  try {
    actionIdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final actionIdField =
    GeneratedEditField<Config, ActionLocation, String?, Lens<Config, String?>>(
      id: 'actionId',
      dirtyField: ConfigDirtyField.actionId,
      lens: actionIdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool mouseGestureStrokeMotionSpeedHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureStrokeMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureStrokeMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'mouseGestureStrokeMotionSpeed',
      dirtyField: ConfigDirtyField.mouseGestureStrokeMotionSpeed,
      lens: mouseGestureStrokeMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool mouseGestureStrokeMotionLockPointerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureStrokeMotionLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureStrokeMotionLockPointerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'mouseGestureStrokeMotionLockPointer',
      dirtyField: ConfigDirtyField.mouseGestureStrokeMotionLockPointer,
      lens: mouseGestureStrokeMotionLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool mouseGestureStrokeStrokesHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureStrokeStrokesLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureStrokeStrokesField =
    GeneratedEditField<
      Config,
      GestureLocation,
      List<Stroke>,
      Lens<Config, List<Stroke>>
    >(
      id: 'mouseGestureStrokeStrokes',
      dirtyField: ConfigDirtyField.mouseGestureStrokeStrokes,
      lens: mouseGestureStrokeStrokesLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<Stroke>>.identity(),
    );

bool mouseGestureSwipeMotionSpeedHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'mouseGestureSwipeMotionSpeed',
      dirtyField: ConfigDirtyField.mouseGestureSwipeMotionSpeed,
      lens: mouseGestureSwipeMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool mouseGestureSwipeMotionLockPointerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeMotionLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeMotionLockPointerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'mouseGestureSwipeMotionLockPointer',
      dirtyField: ConfigDirtyField.mouseGestureSwipeMotionLockPointer,
      lens: mouseGestureSwipeMotionLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool mouseGestureSwipeModeDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeModeDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeModeDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      SwipeDirection,
      Lens<Config, SwipeDirection>
    >(
      id: 'mouseGestureSwipeModeDirection',
      dirtyField: ConfigDirtyField.mouseGestureSwipeModeDirection,
      lens: mouseGestureSwipeModeDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<SwipeDirection>.identity(),
    );

bool mouseGestureSwipeModeAngleMinAngleHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeModeAngleMinAngleLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeModeAngleMinAngleField =
    GeneratedEditField<Config, GestureLocation, double, Lens<Config, double>>(
      id: 'mouseGestureSwipeModeAngleMinAngle',
      dirtyField: ConfigDirtyField.mouseGestureSwipeModeAngleMinAngle,
      lens: mouseGestureSwipeModeAngleMinAngleLens,
      fallback: null,
      adapter: FieldAdapterSpec<double>.identity(),
    );

bool mouseGestureSwipeModeAngleMaxAngleHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeModeAngleMaxAngleLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeModeAngleMaxAngleField =
    GeneratedEditField<Config, GestureLocation, double, Lens<Config, double>>(
      id: 'mouseGestureSwipeModeAngleMaxAngle',
      dirtyField: ConfigDirtyField.mouseGestureSwipeModeAngleMaxAngle,
      lens: mouseGestureSwipeModeAngleMaxAngleLens,
      fallback: null,
      adapter: FieldAdapterSpec<double>.identity(),
    );

bool mouseGestureSwipeModeAngleBidirectionalHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    mouseGestureSwipeModeAngleBidirectionalLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final mouseGestureSwipeModeAngleBidirectionalField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'mouseGestureSwipeModeAngleBidirectional',
      dirtyField: ConfigDirtyField.mouseGestureSwipeModeAngleBidirectional,
      lens: mouseGestureSwipeModeAngleBidirectionalLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool circleMotionSpeedHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    circleMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final circleMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'circleMotionSpeed',
      dirtyField: ConfigDirtyField.circleMotionSpeed,
      lens: circleMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool circleMotionLockPointerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    circleMotionLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final circleMotionLockPointerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'circleMotionLockPointer',
      dirtyField: ConfigDirtyField.circleMotionLockPointer,
      lens: circleMotionLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool circleDirectionHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    circleDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final circleDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      RotationDirection,
      Lens<Config, RotationDirection>
    >(
      id: 'circleDirection',
      dirtyField: ConfigDirtyField.circleDirection,
      lens: circleDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<RotationDirection>.identity(),
    );

bool pressMotionSpeedHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    pressMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final pressMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'pressMotionSpeed',
      dirtyField: ConfigDirtyField.pressMotionSpeed,
      lens: pressMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool pressMotionLockPointerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    pressMotionLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final pressMotionLockPointerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'pressMotionLockPointer',
      dirtyField: ConfigDirtyField.pressMotionLockPointer,
      lens: pressMotionLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool pressInstantHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    pressInstantLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final pressInstantField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'pressInstant',
      dirtyField: ConfigDirtyField.pressInstant,
      lens: pressInstantLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool wheelMotionSpeedHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    wheelMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final wheelMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'wheelMotionSpeed',
      dirtyField: ConfigDirtyField.wheelMotionSpeed,
      lens: wheelMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool wheelMotionLockPointerHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    wheelMotionLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final wheelMotionLockPointerField =
    GeneratedEditField<Config, GestureLocation, bool, Lens<Config, bool>>(
      id: 'wheelMotionLockPointer',
      dirtyField: ConfigDirtyField.wheelMotionLockPointer,
      lens: wheelMotionLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool wheelDirectionHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    wheelDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final wheelDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      WheelDirection,
      Lens<Config, WheelDirection>
    >(
      id: 'wheelDirection',
      dirtyField: ConfigDirtyField.wheelDirection,
      lens: wheelDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<WheelDirection>.identity(),
    );

bool shortcutKeysHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    shortcutKeysLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final shortcutKeysField =
    GeneratedEditField<
      Config,
      GestureLocation,
      List<String>,
      Lens<Config, List<String>>
    >(
      id: 'shortcutKeys',
      dirtyField: ConfigDirtyField.shortcutKeys,
      lens: shortcutKeysLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<String>>.identity(),
    );

bool touchpadFingersHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    touchpadFingersLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadFingersField =
    GeneratedEditField<
      Config,
      GestureLocation,
      FingerRange?,
      Lens<Config, FingerRange?>
    >(
      id: 'touchpadFingers',
      dirtyField: ConfigDirtyField.touchpadFingers,
      lens: touchpadFingersLens,
      fallback: null,
      adapter: FieldAdapterSpec<FingerRange?>.identity(),
    );

bool touchpadMotionSpeedHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchpadMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'touchpadMotionSpeed',
      dirtyField: ConfigDirtyField.touchpadMotionSpeed,
      lens: touchpadMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool touchpadSwipeModeHasSavedBacking(Config? saved, GestureLocation location) {
  if (saved == null) return false;
  try {
    touchpadSwipeModeLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadSwipeModeField =
    GeneratedEditField<
      Config,
      GestureLocation,
      SwipeMode,
      Lens<Config, SwipeMode>
    >(
      id: 'touchpadSwipeMode',
      dirtyField: ConfigDirtyField.touchpadSwipeMode,
      lens: touchpadSwipeModeLens,
      fallback: null,
      adapter: FieldAdapterSpec<SwipeMode>.identity(),
    );

bool touchpadPinchDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchpadPinchDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadPinchDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      PinchDirection,
      Lens<Config, PinchDirection>
    >(
      id: 'touchpadPinchDirection',
      dirtyField: ConfigDirtyField.touchpadPinchDirection,
      lens: touchpadPinchDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<PinchDirection>.identity(),
    );

bool touchpadRotateDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchpadRotateDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadRotateDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      RotationDirection,
      Lens<Config, RotationDirection>
    >(
      id: 'touchpadRotateDirection',
      dirtyField: ConfigDirtyField.touchpadRotateDirection,
      lens: touchpadRotateDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<RotationDirection>.identity(),
    );

bool touchpadCircleDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchpadCircleDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadCircleDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      RotationDirection,
      Lens<Config, RotationDirection>
    >(
      id: 'touchpadCircleDirection',
      dirtyField: ConfigDirtyField.touchpadCircleDirection,
      lens: touchpadCircleDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<RotationDirection>.identity(),
    );

bool touchpadStrokeStrokesHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchpadStrokeStrokesLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchpadStrokeStrokesField =
    GeneratedEditField<
      Config,
      GestureLocation,
      List<Stroke>,
      Lens<Config, List<Stroke>>
    >(
      id: 'touchpadStrokeStrokes',
      dirtyField: ConfigDirtyField.touchpadStrokeStrokes,
      lens: touchpadStrokeStrokesLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<Stroke>>.identity(),
    );

bool touchscreenFingersHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenFingersLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenFingersField =
    GeneratedEditField<
      Config,
      GestureLocation,
      FingerRange?,
      Lens<Config, FingerRange?>
    >(
      id: 'touchscreenFingers',
      dirtyField: ConfigDirtyField.touchscreenFingers,
      lens: touchscreenFingersLens,
      fallback: null,
      adapter: FieldAdapterSpec<FingerRange?>.identity(),
    );

bool touchscreenMotionSpeedHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenMotionSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenMotionSpeedField =
    GeneratedEditField<
      Config,
      GestureLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'touchscreenMotionSpeed',
      dirtyField: ConfigDirtyField.touchscreenMotionSpeed,
      lens: touchscreenMotionSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool touchscreenSwipeModeHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenSwipeModeLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenSwipeModeField =
    GeneratedEditField<
      Config,
      GestureLocation,
      SwipeMode,
      Lens<Config, SwipeMode>
    >(
      id: 'touchscreenSwipeMode',
      dirtyField: ConfigDirtyField.touchscreenSwipeMode,
      lens: touchscreenSwipeModeLens,
      fallback: null,
      adapter: FieldAdapterSpec<SwipeMode>.identity(),
    );

bool touchscreenPinchDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenPinchDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenPinchDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      PinchDirection,
      Lens<Config, PinchDirection>
    >(
      id: 'touchscreenPinchDirection',
      dirtyField: ConfigDirtyField.touchscreenPinchDirection,
      lens: touchscreenPinchDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<PinchDirection>.identity(),
    );

bool touchscreenRotateDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenRotateDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenRotateDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      RotationDirection,
      Lens<Config, RotationDirection>
    >(
      id: 'touchscreenRotateDirection',
      dirtyField: ConfigDirtyField.touchscreenRotateDirection,
      lens: touchscreenRotateDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<RotationDirection>.identity(),
    );

bool touchscreenCircleDirectionHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenCircleDirectionLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenCircleDirectionField =
    GeneratedEditField<
      Config,
      GestureLocation,
      RotationDirection,
      Lens<Config, RotationDirection>
    >(
      id: 'touchscreenCircleDirection',
      dirtyField: ConfigDirtyField.touchscreenCircleDirection,
      lens: touchscreenCircleDirectionLens,
      fallback: null,
      adapter: FieldAdapterSpec<RotationDirection>.identity(),
    );

bool touchscreenStrokeStrokesHasSavedBacking(
  Config? saved,
  GestureLocation location,
) {
  if (saved == null) return false;
  try {
    touchscreenStrokeStrokesLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final touchscreenStrokeStrokesField =
    GeneratedEditField<
      Config,
      GestureLocation,
      List<Stroke>,
      Lens<Config, List<Stroke>>
    >(
      id: 'touchscreenStrokeStrokes',
      dirtyField: ConfigDirtyField.touchscreenStrokeStrokes,
      lens: touchscreenStrokeStrokesLens,
      fallback: null,
      adapter: FieldAdapterSpec<List<Stroke>>.identity(),
    );

bool gestureGroupNameHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupNameLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupNameField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      String,
      Lens<Config, String>
    >(
      id: 'gestureGroupName',
      dirtyField: ConfigDirtyField.gestureGroupName,
      lens: gestureGroupNameLens,
      fallback: null,
      adapter: FieldAdapterSpec<String>.identity(),
    );

bool gestureGroupEnabledHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupEnabledLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupEnabledField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupEnabled',
      dirtyField: ConfigDirtyField.gestureGroupEnabled,
      lens: gestureGroupEnabledLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupConditionsHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupConditionsField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'gestureGroupConditions',
      dirtyField: ConfigDirtyField.gestureGroupConditions,
      lens: gestureGroupConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool gestureGroupIdHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupIdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupIdField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      String?,
      Lens<Config, String?>
    >(
      id: 'gestureGroupId',
      dirtyField: ConfigDirtyField.gestureGroupId,
      lens: gestureGroupIdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool gestureGroupThresholdHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupThresholdField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      String?,
      Lens<Config, String?>
    >(
      id: 'gestureGroupThreshold',
      dirtyField: ConfigDirtyField.gestureGroupThreshold,
      lens: gestureGroupThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

bool gestureGroupResumeTimeoutHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupResumeTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupResumeTimeoutField =
    GeneratedEditField<Config, GestureGroupLocation, int?, Lens<Config, int?>>(
      id: 'gestureGroupResumeTimeout',
      dirtyField: ConfigDirtyField.gestureGroupResumeTimeout,
      lens: gestureGroupResumeTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool gestureGroupAcceleratedHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupAcceleratedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupAcceleratedField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupAccelerated',
      dirtyField: ConfigDirtyField.gestureGroupAccelerated,
      lens: gestureGroupAcceleratedLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupBlockEventsHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupBlockEventsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupBlockEventsField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupBlockEvents',
      dirtyField: ConfigDirtyField.gestureGroupBlockEvents,
      lens: gestureGroupBlockEventsLens,
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupClearModifiersHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupClearModifiersLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupClearModifiersField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupClearModifiers',
      dirtyField: ConfigDirtyField.gestureGroupClearModifiers,
      lens: gestureGroupClearModifiersLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupSetLastTriggerHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupSetLastTriggerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupSetLastTriggerField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupSetLastTrigger',
      dirtyField: ConfigDirtyField.gestureGroupSetLastTrigger,
      lens: gestureGroupSetLastTriggerLens,
      fallback: null,
      defaultValue: true,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupEndConditionsHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupEndConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupEndConditionsField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'gestureGroupEndConditions',
      dirtyField: ConfigDirtyField.gestureGroupEndConditions,
      lens: gestureGroupEndConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool gestureGroupMouseButtonsHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupMouseButtonsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupMouseButtonsField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      List<MouseButtonValue>,
      Lens<Config, List<MouseButtonValue>>
    >(
      id: 'gestureGroupMouseButtons',
      dirtyField: ConfigDirtyField.gestureGroupMouseButtons,
      lens: gestureGroupMouseButtonsLens,
      fallback: null,
      defaultValue: const <MouseButtonValue>[],
      adapter: FieldAdapterSpec<List<MouseButtonValue>>.identity(),
    );

bool gestureGroupMouseButtonsExactOrderHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupMouseButtonsExactOrderLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupMouseButtonsExactOrderField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupMouseButtonsExactOrder',
      dirtyField: ConfigDirtyField.gestureGroupMouseButtonsExactOrder,
      lens: gestureGroupMouseButtonsExactOrderLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupFingersHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupFingersLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupFingersField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      FingerRange?,
      Lens<Config, FingerRange?>
    >(
      id: 'gestureGroupFingers',
      dirtyField: ConfigDirtyField.gestureGroupFingers,
      lens: gestureGroupFingersLens,
      fallback: null,
      adapter: FieldAdapterSpec<FingerRange?>.identity(),
    );

bool gestureGroupSpeedHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupSpeedLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupSpeedField =
    GeneratedEditField<
      Config,
      GestureGroupLocation,
      TriggerSpeed?,
      Lens<Config, TriggerSpeed?>
    >(
      id: 'gestureGroupSpeed',
      dirtyField: ConfigDirtyField.gestureGroupSpeed,
      lens: gestureGroupSpeedLens,
      fallback: null,
      adapter: FieldAdapterSpec<TriggerSpeed?>.identity(),
    );

bool gestureGroupInstantHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupInstantLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupInstantField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupInstant',
      dirtyField: ConfigDirtyField.gestureGroupInstant,
      lens: gestureGroupInstantLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool gestureGroupLockPointerHasSavedBacking(
  Config? saved,
  GestureGroupLocation location,
) {
  if (saved == null) return false;
  try {
    gestureGroupLockPointerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final gestureGroupLockPointerField =
    GeneratedEditField<Config, GestureGroupLocation, bool, Lens<Config, bool>>(
      id: 'gestureGroupLockPointer',
      dirtyField: ConfigDirtyField.gestureGroupLockPointer,
      lens: gestureGroupLockPointerLens,
      fallback: null,
      defaultValue: false,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

bool deviceRuleConditionsHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRuleConditionsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRuleConditionsField =
    GeneratedEditField<
      Config,
      DeviceRuleLocation,
      Condition?,
      Lens<Config, Condition?>
    >(
      id: 'deviceRuleConditions',
      dirtyField: ConfigDirtyField.deviceRuleConditions,
      lens: deviceRuleConditionsLens,
      fallback: null,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

bool deviceRulePropertiesIgnoreHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesIgnoreLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesIgnoreField =
    GeneratedEditField<Config, DeviceRuleLocation, bool?, Lens<Config, bool?>>(
      id: 'deviceRulePropertiesIgnore',
      dirtyField: ConfigDirtyField.deviceRulePropertiesIgnore,
      lens: deviceRulePropertiesIgnoreLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool deviceRulePropertiesGrabHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesGrabLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesGrabField =
    GeneratedEditField<Config, DeviceRuleLocation, bool?, Lens<Config, bool?>>(
      id: 'deviceRulePropertiesGrab',
      dirtyField: ConfigDirtyField.deviceRulePropertiesGrab,
      lens: deviceRulePropertiesGrabLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool deviceRulePropertiesMotionTimeoutHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesMotionTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesMotionTimeoutField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesMotionTimeout',
      dirtyField: ConfigDirtyField.deviceRulePropertiesMotionTimeout,
      lens: deviceRulePropertiesMotionTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool deviceRulePropertiesMotionThresholdHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesMotionThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesMotionThresholdField =
    GeneratedEditField<
      Config,
      DeviceRuleLocation,
      double?,
      Lens<Config, double?>
    >(
      id: 'deviceRulePropertiesMotionThreshold',
      dirtyField: ConfigDirtyField.deviceRulePropertiesMotionThreshold,
      lens: deviceRulePropertiesMotionThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool deviceRulePropertiesPressTimeoutHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesPressTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesPressTimeoutField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesPressTimeout',
      dirtyField: ConfigDirtyField.deviceRulePropertiesPressTimeout,
      lens: deviceRulePropertiesPressTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool deviceRulePropertiesSwipeAngleToleranceHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesSwipeAngleToleranceLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesSwipeAngleToleranceField =
    GeneratedEditField<
      Config,
      DeviceRuleLocation,
      double?,
      Lens<Config, double?>
    >(
      id: 'deviceRulePropertiesSwipeAngleTolerance',
      dirtyField: ConfigDirtyField.deviceRulePropertiesSwipeAngleTolerance,
      lens: deviceRulePropertiesSwipeAngleToleranceLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool deviceRulePropertiesUnblockButtonsOnTimeoutHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesUnblockButtonsOnTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesUnblockButtonsOnTimeoutField =
    GeneratedEditField<Config, DeviceRuleLocation, bool?, Lens<Config, bool?>>(
      id: 'deviceRulePropertiesUnblockButtonsOnTimeout',
      dirtyField: ConfigDirtyField.deviceRulePropertiesUnblockButtonsOnTimeout,
      lens: deviceRulePropertiesUnblockButtonsOnTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool deviceRulePropertiesButtonpadHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesButtonpadLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesButtonpadField =
    GeneratedEditField<Config, DeviceRuleLocation, bool?, Lens<Config, bool?>>(
      id: 'deviceRulePropertiesButtonpad',
      dirtyField: ConfigDirtyField.deviceRulePropertiesButtonpad,
      lens: deviceRulePropertiesButtonpadLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool deviceRulePropertiesClickTimeoutHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesClickTimeoutLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesClickTimeoutField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesClickTimeout',
      dirtyField: ConfigDirtyField.deviceRulePropertiesClickTimeout,
      lens: deviceRulePropertiesClickTimeoutLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool deviceRulePropertiesHandleEvdevEventsHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesHandleEvdevEventsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesHandleEvdevEventsField =
    GeneratedEditField<Config, DeviceRuleLocation, bool?, Lens<Config, bool?>>(
      id: 'deviceRulePropertiesHandleEvdevEvents',
      dirtyField: ConfigDirtyField.deviceRulePropertiesHandleEvdevEvents,
      lens: deviceRulePropertiesHandleEvdevEventsLens,
      fallback: null,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

bool deviceRulePropertiesMotionThreshold2HasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesMotionThreshold2Lens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesMotionThreshold2Field =
    GeneratedEditField<
      Config,
      DeviceRuleLocation,
      double?,
      Lens<Config, double?>
    >(
      id: 'deviceRulePropertiesMotionThreshold2',
      dirtyField: ConfigDirtyField.deviceRulePropertiesMotionThreshold2,
      lens: deviceRulePropertiesMotionThreshold2Lens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool deviceRulePropertiesMotionThreshold3HasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesMotionThreshold3Lens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesMotionThreshold3Field =
    GeneratedEditField<
      Config,
      DeviceRuleLocation,
      double?,
      Lens<Config, double?>
    >(
      id: 'deviceRulePropertiesMotionThreshold3',
      dirtyField: ConfigDirtyField.deviceRulePropertiesMotionThreshold3,
      lens: deviceRulePropertiesMotionThreshold3Lens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool deviceRulePropertiesPressureRangesFingerHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesPressureRangesFingerLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesPressureRangesFingerField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesPressureRangesFinger',
      dirtyField: ConfigDirtyField.deviceRulePropertiesPressureRangesFinger,
      lens: deviceRulePropertiesPressureRangesFingerLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool deviceRulePropertiesPressureRangesThumbHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesPressureRangesThumbLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesPressureRangesThumbField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesPressureRangesThumb',
      dirtyField: ConfigDirtyField.deviceRulePropertiesPressureRangesThumb,
      lens: deviceRulePropertiesPressureRangesThumbLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool deviceRulePropertiesPressureRangesPalmHasSavedBacking(
  Config? saved,
  DeviceRuleLocation location,
) {
  if (saved == null) return false;
  try {
    deviceRulePropertiesPressureRangesPalmLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final deviceRulePropertiesPressureRangesPalmField =
    GeneratedEditField<Config, DeviceRuleLocation, int?, Lens<Config, int?>>(
      id: 'deviceRulePropertiesPressureRangesPalm',
      dirtyField: ConfigDirtyField.deviceRulePropertiesPressureRangesPalm,
      lens: deviceRulePropertiesPressureRangesPalmLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool speedEventsHasSavedBacking(Config? saved, DeviceType location) {
  if (saved == null) return false;
  try {
    speedEventsLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final speedEventsField =
    GeneratedEditField<Config, DeviceType, int?, Lens<Config, int?>>(
      id: 'speedEvents',
      dirtyField: ConfigDirtyField.speedEvents,
      lens: speedEventsLens,
      fallback: null,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

bool speedSwipeThresholdHasSavedBacking(Config? saved, DeviceType location) {
  if (saved == null) return false;
  try {
    speedSwipeThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final speedSwipeThresholdField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'speedSwipeThreshold',
      dirtyField: ConfigDirtyField.speedSwipeThreshold,
      lens: speedSwipeThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool speedPinchInThresholdHasSavedBacking(Config? saved, DeviceType location) {
  if (saved == null) return false;
  try {
    speedPinchInThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final speedPinchInThresholdField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'speedPinchInThreshold',
      dirtyField: ConfigDirtyField.speedPinchInThreshold,
      lens: speedPinchInThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool speedPinchOutThresholdHasSavedBacking(Config? saved, DeviceType location) {
  if (saved == null) return false;
  try {
    speedPinchOutThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final speedPinchOutThresholdField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'speedPinchOutThreshold',
      dirtyField: ConfigDirtyField.speedPinchOutThreshold,
      lens: speedPinchOutThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

bool speedRotateThresholdHasSavedBacking(Config? saved, DeviceType location) {
  if (saved == null) return false;
  try {
    speedRotateThresholdLens(location).get(saved);
    return true;
  } on Object catch (_) {
    return false;
  }
}

final speedRotateThresholdField =
    GeneratedEditField<Config, DeviceType, double?, Lens<Config, double?>>(
      id: 'speedRotateThreshold',
      dirtyField: ConfigDirtyField.speedRotateThreshold,
      lens: speedRotateThresholdLens,
      fallback: null,
      adapter: FieldAdapterSpec<double?>.nullableDouble(),
    );

final gestureFields =
    <
      GeneratedEditField<
        Config,
        GestureLocation,
        Object?,
        Lens<Config, Object?>
      >
    >[
      gestureIdField,
      gestureMouseButtonsField,
      gestureMouseButtonsExactOrderField,
      gestureConditionsField,
      gestureEndConditionsField,
      gestureBlockEventsField,
      gestureClearModifiersField,
      gestureResumeTimeoutField,
      gestureSetLastTriggerField,
      gestureThresholdField,
      gestureAcceleratedField,
      gestureExtraField,
      mouseGestureStrokeMotionSpeedField,
      mouseGestureStrokeMotionLockPointerField,
      mouseGestureStrokeStrokesField,
      mouseGestureSwipeMotionSpeedField,
      mouseGestureSwipeMotionLockPointerField,
      mouseGestureSwipeModeDirectionField,
      mouseGestureSwipeModeAngleMinAngleField,
      mouseGestureSwipeModeAngleMaxAngleField,
      mouseGestureSwipeModeAngleBidirectionalField,
      circleMotionSpeedField,
      circleMotionLockPointerField,
      circleDirectionField,
      pressMotionSpeedField,
      pressMotionLockPointerField,
      pressInstantField,
      wheelMotionSpeedField,
      wheelMotionLockPointerField,
      wheelDirectionField,
      shortcutKeysField,
      touchpadFingersField,
      touchpadMotionSpeedField,
      touchpadSwipeModeField,
      touchpadPinchDirectionField,
      touchpadRotateDirectionField,
      touchpadCircleDirectionField,
      touchpadStrokeStrokesField,
      touchscreenFingersField,
      touchscreenMotionSpeedField,
      touchscreenSwipeModeField,
      touchscreenPinchDirectionField,
      touchscreenRotateDirectionField,
      touchscreenCircleDirectionField,
      touchscreenStrokeStrokesField,
    ];

Set<ConfigDirtyField> changedGestureFields(
  Config before,
  Config after,
  GestureLocation location,
) => {
  if (gestureIdLens(location).canGet(before) &&
      gestureIdLens(location).canGet(after) &&
      gestureIdLens(location).get(before) != gestureIdLens(location).get(after))
    ConfigDirtyField.gestureId,
  if (gestureMouseButtonsLens(location).canGet(before) &&
      gestureMouseButtonsLens(location).canGet(after) &&
      gestureMouseButtonsLens(location).get(before) !=
          gestureMouseButtonsLens(location).get(after))
    ConfigDirtyField.gestureMouseButtons,
  if (gestureMouseButtonsExactOrderLens(location).canGet(before) &&
      gestureMouseButtonsExactOrderLens(location).canGet(after) &&
      gestureMouseButtonsExactOrderLens(location).get(before) !=
          gestureMouseButtonsExactOrderLens(location).get(after))
    ConfigDirtyField.gestureMouseButtonsExactOrder,
  if (gestureConditionsLens(location).canGet(before) &&
      gestureConditionsLens(location).canGet(after) &&
      gestureConditionsLens(location).get(before) !=
          gestureConditionsLens(location).get(after))
    ConfigDirtyField.gestureConditions,
  if (gestureEndConditionsLens(location).canGet(before) &&
      gestureEndConditionsLens(location).canGet(after) &&
      gestureEndConditionsLens(location).get(before) !=
          gestureEndConditionsLens(location).get(after))
    ConfigDirtyField.gestureEndConditions,
  if (gestureBlockEventsLens(location).canGet(before) &&
      gestureBlockEventsLens(location).canGet(after) &&
      gestureBlockEventsLens(location).get(before) !=
          gestureBlockEventsLens(location).get(after))
    ConfigDirtyField.gestureBlockEvents,
  if (gestureClearModifiersLens(location).canGet(before) &&
      gestureClearModifiersLens(location).canGet(after) &&
      gestureClearModifiersLens(location).get(before) !=
          gestureClearModifiersLens(location).get(after))
    ConfigDirtyField.gestureClearModifiers,
  if (gestureResumeTimeoutLens(location).canGet(before) &&
      gestureResumeTimeoutLens(location).canGet(after) &&
      gestureResumeTimeoutLens(location).get(before) !=
          gestureResumeTimeoutLens(location).get(after))
    ConfigDirtyField.gestureResumeTimeout,
  if (gestureSetLastTriggerLens(location).canGet(before) &&
      gestureSetLastTriggerLens(location).canGet(after) &&
      gestureSetLastTriggerLens(location).get(before) !=
          gestureSetLastTriggerLens(location).get(after))
    ConfigDirtyField.gestureSetLastTrigger,
  if (gestureThresholdLens(location).canGet(before) &&
      gestureThresholdLens(location).canGet(after) &&
      gestureThresholdLens(location).get(before) !=
          gestureThresholdLens(location).get(after))
    ConfigDirtyField.gestureThreshold,
  if (gestureAcceleratedLens(location).canGet(before) &&
      gestureAcceleratedLens(location).canGet(after) &&
      gestureAcceleratedLens(location).get(before) !=
          gestureAcceleratedLens(location).get(after))
    ConfigDirtyField.gestureAccelerated,
  if (gestureExtraLens(location).canGet(before) &&
      gestureExtraLens(location).canGet(after) &&
      gestureExtraLens(location).get(before) !=
          gestureExtraLens(location).get(after))
    ConfigDirtyField.gestureExtra,
  if (mouseGestureStrokeMotionSpeedLens(location).canGet(before) &&
      mouseGestureStrokeMotionSpeedLens(location).canGet(after) &&
      mouseGestureStrokeMotionSpeedLens(location).get(before) !=
          mouseGestureStrokeMotionSpeedLens(location).get(after))
    ConfigDirtyField.mouseGestureStrokeMotionSpeed,
  if (mouseGestureStrokeMotionLockPointerLens(location).canGet(before) &&
      mouseGestureStrokeMotionLockPointerLens(location).canGet(after) &&
      mouseGestureStrokeMotionLockPointerLens(location).get(before) !=
          mouseGestureStrokeMotionLockPointerLens(location).get(after))
    ConfigDirtyField.mouseGestureStrokeMotionLockPointer,
  if (mouseGestureStrokeStrokesLens(location).canGet(before) &&
      mouseGestureStrokeStrokesLens(location).canGet(after) &&
      mouseGestureStrokeStrokesLens(location).get(before) !=
          mouseGestureStrokeStrokesLens(location).get(after))
    ConfigDirtyField.mouseGestureStrokeStrokes,
  if (mouseGestureSwipeMotionSpeedLens(location).canGet(before) &&
      mouseGestureSwipeMotionSpeedLens(location).canGet(after) &&
      mouseGestureSwipeMotionSpeedLens(location).get(before) !=
          mouseGestureSwipeMotionSpeedLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeMotionSpeed,
  if (mouseGestureSwipeMotionLockPointerLens(location).canGet(before) &&
      mouseGestureSwipeMotionLockPointerLens(location).canGet(after) &&
      mouseGestureSwipeMotionLockPointerLens(location).get(before) !=
          mouseGestureSwipeMotionLockPointerLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeMotionLockPointer,
  if (mouseGestureSwipeModeDirectionLens(location).canGet(before) &&
      mouseGestureSwipeModeDirectionLens(location).canGet(after) &&
      mouseGestureSwipeModeDirectionLens(location).get(before) !=
          mouseGestureSwipeModeDirectionLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeModeDirection,
  if (mouseGestureSwipeModeAngleMinAngleLens(location).canGet(before) &&
      mouseGestureSwipeModeAngleMinAngleLens(location).canGet(after) &&
      mouseGestureSwipeModeAngleMinAngleLens(location).get(before) !=
          mouseGestureSwipeModeAngleMinAngleLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeModeAngleMinAngle,
  if (mouseGestureSwipeModeAngleMaxAngleLens(location).canGet(before) &&
      mouseGestureSwipeModeAngleMaxAngleLens(location).canGet(after) &&
      mouseGestureSwipeModeAngleMaxAngleLens(location).get(before) !=
          mouseGestureSwipeModeAngleMaxAngleLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeModeAngleMaxAngle,
  if (mouseGestureSwipeModeAngleBidirectionalLens(location).canGet(before) &&
      mouseGestureSwipeModeAngleBidirectionalLens(location).canGet(after) &&
      mouseGestureSwipeModeAngleBidirectionalLens(location).get(before) !=
          mouseGestureSwipeModeAngleBidirectionalLens(location).get(after))
    ConfigDirtyField.mouseGestureSwipeModeAngleBidirectional,
  if (circleMotionSpeedLens(location).canGet(before) &&
      circleMotionSpeedLens(location).canGet(after) &&
      circleMotionSpeedLens(location).get(before) !=
          circleMotionSpeedLens(location).get(after))
    ConfigDirtyField.circleMotionSpeed,
  if (circleMotionLockPointerLens(location).canGet(before) &&
      circleMotionLockPointerLens(location).canGet(after) &&
      circleMotionLockPointerLens(location).get(before) !=
          circleMotionLockPointerLens(location).get(after))
    ConfigDirtyField.circleMotionLockPointer,
  if (circleDirectionLens(location).canGet(before) &&
      circleDirectionLens(location).canGet(after) &&
      circleDirectionLens(location).get(before) !=
          circleDirectionLens(location).get(after))
    ConfigDirtyField.circleDirection,
  if (pressMotionSpeedLens(location).canGet(before) &&
      pressMotionSpeedLens(location).canGet(after) &&
      pressMotionSpeedLens(location).get(before) !=
          pressMotionSpeedLens(location).get(after))
    ConfigDirtyField.pressMotionSpeed,
  if (pressMotionLockPointerLens(location).canGet(before) &&
      pressMotionLockPointerLens(location).canGet(after) &&
      pressMotionLockPointerLens(location).get(before) !=
          pressMotionLockPointerLens(location).get(after))
    ConfigDirtyField.pressMotionLockPointer,
  if (pressInstantLens(location).canGet(before) &&
      pressInstantLens(location).canGet(after) &&
      pressInstantLens(location).get(before) !=
          pressInstantLens(location).get(after))
    ConfigDirtyField.pressInstant,
  if (wheelMotionSpeedLens(location).canGet(before) &&
      wheelMotionSpeedLens(location).canGet(after) &&
      wheelMotionSpeedLens(location).get(before) !=
          wheelMotionSpeedLens(location).get(after))
    ConfigDirtyField.wheelMotionSpeed,
  if (wheelMotionLockPointerLens(location).canGet(before) &&
      wheelMotionLockPointerLens(location).canGet(after) &&
      wheelMotionLockPointerLens(location).get(before) !=
          wheelMotionLockPointerLens(location).get(after))
    ConfigDirtyField.wheelMotionLockPointer,
  if (wheelDirectionLens(location).canGet(before) &&
      wheelDirectionLens(location).canGet(after) &&
      wheelDirectionLens(location).get(before) !=
          wheelDirectionLens(location).get(after))
    ConfigDirtyField.wheelDirection,
  if (shortcutKeysLens(location).canGet(before) &&
      shortcutKeysLens(location).canGet(after) &&
      shortcutKeysLens(location).get(before) !=
          shortcutKeysLens(location).get(after))
    ConfigDirtyField.shortcutKeys,
  if (touchpadFingersLens(location).canGet(before) &&
      touchpadFingersLens(location).canGet(after) &&
      touchpadFingersLens(location).get(before) !=
          touchpadFingersLens(location).get(after))
    ConfigDirtyField.touchpadFingers,
  if (touchpadMotionSpeedLens(location).canGet(before) &&
      touchpadMotionSpeedLens(location).canGet(after) &&
      touchpadMotionSpeedLens(location).get(before) !=
          touchpadMotionSpeedLens(location).get(after))
    ConfigDirtyField.touchpadMotionSpeed,
  if (touchpadSwipeModeLens(location).canGet(before) &&
      touchpadSwipeModeLens(location).canGet(after) &&
      touchpadSwipeModeLens(location).get(before) !=
          touchpadSwipeModeLens(location).get(after))
    ConfigDirtyField.touchpadSwipeMode,
  if (touchpadPinchDirectionLens(location).canGet(before) &&
      touchpadPinchDirectionLens(location).canGet(after) &&
      touchpadPinchDirectionLens(location).get(before) !=
          touchpadPinchDirectionLens(location).get(after))
    ConfigDirtyField.touchpadPinchDirection,
  if (touchpadRotateDirectionLens(location).canGet(before) &&
      touchpadRotateDirectionLens(location).canGet(after) &&
      touchpadRotateDirectionLens(location).get(before) !=
          touchpadRotateDirectionLens(location).get(after))
    ConfigDirtyField.touchpadRotateDirection,
  if (touchpadCircleDirectionLens(location).canGet(before) &&
      touchpadCircleDirectionLens(location).canGet(after) &&
      touchpadCircleDirectionLens(location).get(before) !=
          touchpadCircleDirectionLens(location).get(after))
    ConfigDirtyField.touchpadCircleDirection,
  if (touchpadStrokeStrokesLens(location).canGet(before) &&
      touchpadStrokeStrokesLens(location).canGet(after) &&
      touchpadStrokeStrokesLens(location).get(before) !=
          touchpadStrokeStrokesLens(location).get(after))
    ConfigDirtyField.touchpadStrokeStrokes,
  if (touchscreenFingersLens(location).canGet(before) &&
      touchscreenFingersLens(location).canGet(after) &&
      touchscreenFingersLens(location).get(before) !=
          touchscreenFingersLens(location).get(after))
    ConfigDirtyField.touchscreenFingers,
  if (touchscreenMotionSpeedLens(location).canGet(before) &&
      touchscreenMotionSpeedLens(location).canGet(after) &&
      touchscreenMotionSpeedLens(location).get(before) !=
          touchscreenMotionSpeedLens(location).get(after))
    ConfigDirtyField.touchscreenMotionSpeed,
  if (touchscreenSwipeModeLens(location).canGet(before) &&
      touchscreenSwipeModeLens(location).canGet(after) &&
      touchscreenSwipeModeLens(location).get(before) !=
          touchscreenSwipeModeLens(location).get(after))
    ConfigDirtyField.touchscreenSwipeMode,
  if (touchscreenPinchDirectionLens(location).canGet(before) &&
      touchscreenPinchDirectionLens(location).canGet(after) &&
      touchscreenPinchDirectionLens(location).get(before) !=
          touchscreenPinchDirectionLens(location).get(after))
    ConfigDirtyField.touchscreenPinchDirection,
  if (touchscreenRotateDirectionLens(location).canGet(before) &&
      touchscreenRotateDirectionLens(location).canGet(after) &&
      touchscreenRotateDirectionLens(location).get(before) !=
          touchscreenRotateDirectionLens(location).get(after))
    ConfigDirtyField.touchscreenRotateDirection,
  if (touchscreenCircleDirectionLens(location).canGet(before) &&
      touchscreenCircleDirectionLens(location).canGet(after) &&
      touchscreenCircleDirectionLens(location).get(before) !=
          touchscreenCircleDirectionLens(location).get(after))
    ConfigDirtyField.touchscreenCircleDirection,
  if (touchscreenStrokeStrokesLens(location).canGet(before) &&
      touchscreenStrokeStrokesLens(location).canGet(after) &&
      touchscreenStrokeStrokesLens(location).get(before) !=
          touchscreenStrokeStrokesLens(location).get(after))
    ConfigDirtyField.touchscreenStrokeStrokes,
};

final actionFields =
    <
      GeneratedEditField<Config, ActionLocation, Object?, Lens<Config, Object?>>
    >[
      actionCommandField,
      actionWaitField,
      actionComponentField,
      actionShortcutField,
      actionWindowIdField,
      actionRulesField,
      actionDurationField,
      actionExpressionField,
      actionRawField,
      actionInputEntriesField,
      actionInputDelayField,
      actionTriggerOnField,
      actionIntervalField,
      actionThresholdField,
      actionLimitField,
      actionEnabledField,
      actionConflictingField,
      actionConditionsField,
      actionIdField,
    ];

Set<ConfigDirtyField> changedActionFields(
  Config before,
  Config after,
  ActionLocation location,
) => {
  if (actionCommandLens(location).canGet(before) &&
      actionCommandLens(location).canGet(after) &&
      actionCommandLens(location).get(before) !=
          actionCommandLens(location).get(after))
    ConfigDirtyField.actionCommand,
  if (actionWaitLens(location).canGet(before) &&
      actionWaitLens(location).canGet(after) &&
      actionWaitLens(location).get(before) !=
          actionWaitLens(location).get(after))
    ConfigDirtyField.actionWait,
  if (actionComponentLens(location).canGet(before) &&
      actionComponentLens(location).canGet(after) &&
      actionComponentLens(location).get(before) !=
          actionComponentLens(location).get(after))
    ConfigDirtyField.actionComponent,
  if (actionShortcutLens(location).canGet(before) &&
      actionShortcutLens(location).canGet(after) &&
      actionShortcutLens(location).get(before) !=
          actionShortcutLens(location).get(after))
    ConfigDirtyField.actionShortcut,
  if (actionWindowIdLens(location).canGet(before) &&
      actionWindowIdLens(location).canGet(after) &&
      actionWindowIdLens(location).get(before) !=
          actionWindowIdLens(location).get(after))
    ConfigDirtyField.actionWindowId,
  if (actionRulesLens(location).canGet(before) &&
      actionRulesLens(location).canGet(after) &&
      actionRulesLens(location).get(before) !=
          actionRulesLens(location).get(after))
    ConfigDirtyField.actionRules,
  if (actionDurationLens(location).canGet(before) &&
      actionDurationLens(location).canGet(after) &&
      actionDurationLens(location).get(before) !=
          actionDurationLens(location).get(after))
    ConfigDirtyField.actionDuration,
  if (actionExpressionLens(location).canGet(before) &&
      actionExpressionLens(location).canGet(after) &&
      actionExpressionLens(location).get(before) !=
          actionExpressionLens(location).get(after))
    ConfigDirtyField.actionExpression,
  if (actionRawLens(location).canGet(before) &&
      actionRawLens(location).canGet(after) &&
      actionRawLens(location).get(before) != actionRawLens(location).get(after))
    ConfigDirtyField.actionRaw,
  if (actionInputEntriesLens(location).canGet(before) &&
      actionInputEntriesLens(location).canGet(after) &&
      actionInputEntriesLens(location).get(before) !=
          actionInputEntriesLens(location).get(after))
    ConfigDirtyField.actionInputEntries,
  if (actionInputDelayLens(location).canGet(before) &&
      actionInputDelayLens(location).canGet(after) &&
      actionInputDelayLens(location).get(before) !=
          actionInputDelayLens(location).get(after))
    ConfigDirtyField.actionInputDelay,
  if (actionTriggerOnLens(location).canGet(before) &&
      actionTriggerOnLens(location).canGet(after) &&
      actionTriggerOnLens(location).get(before) !=
          actionTriggerOnLens(location).get(after))
    ConfigDirtyField.actionTriggerOn,
  if (actionIntervalLens(location).canGet(before) &&
      actionIntervalLens(location).canGet(after) &&
      actionIntervalLens(location).get(before) !=
          actionIntervalLens(location).get(after))
    ConfigDirtyField.actionInterval,
  if (actionThresholdLens(location).canGet(before) &&
      actionThresholdLens(location).canGet(after) &&
      actionThresholdLens(location).get(before) !=
          actionThresholdLens(location).get(after))
    ConfigDirtyField.actionThreshold,
  if (actionLimitLens(location).canGet(before) &&
      actionLimitLens(location).canGet(after) &&
      actionLimitLens(location).get(before) !=
          actionLimitLens(location).get(after))
    ConfigDirtyField.actionLimit,
  if (actionEnabledLens(location).canGet(before) &&
      actionEnabledLens(location).canGet(after) &&
      actionEnabledLens(location).get(before) !=
          actionEnabledLens(location).get(after))
    ConfigDirtyField.actionEnabled,
  if (actionConflictingLens(location).canGet(before) &&
      actionConflictingLens(location).canGet(after) &&
      actionConflictingLens(location).get(before) !=
          actionConflictingLens(location).get(after))
    ConfigDirtyField.actionConflicting,
  if (actionConditionsLens(location).canGet(before) &&
      actionConditionsLens(location).canGet(after) &&
      actionConditionsLens(location).get(before) !=
          actionConditionsLens(location).get(after))
    ConfigDirtyField.actionConditions,
  if (actionIdLens(location).canGet(before) &&
      actionIdLens(location).canGet(after) &&
      actionIdLens(location).get(before) != actionIdLens(location).get(after))
    ConfigDirtyField.actionId,
};

final menuItemFields =
    <
      GeneratedEditField<
        Config,
        MenuItemLocation,
        Object?,
        Lens<Config, Object?>
      >
    >[
      menuItemTextField,
      menuItemIconField,
      menuItemActionsField,
      menuItemSubMenuTextField,
      menuItemSubMenuIconField,
      menuItemSectionTextField,
    ];

Set<ConfigDirtyField> changedMenuItemFields(
  Config before,
  Config after,
  MenuItemLocation location,
) => {
  if (menuItemTextLens(location).canGet(before) &&
      menuItemTextLens(location).canGet(after) &&
      menuItemTextLens(location).get(before) !=
          menuItemTextLens(location).get(after))
    ConfigDirtyField.menuItemText,
  if (menuItemIconLens(location).canGet(before) &&
      menuItemIconLens(location).canGet(after) &&
      menuItemIconLens(location).get(before) !=
          menuItemIconLens(location).get(after))
    ConfigDirtyField.menuItemIcon,
  if (menuItemActionsLens(location).canGet(before) &&
      menuItemActionsLens(location).canGet(after) &&
      menuItemActionsLens(location).get(before) !=
          menuItemActionsLens(location).get(after))
    ConfigDirtyField.menuItemActions,
  if (menuItemSubMenuTextLens(location).canGet(before) &&
      menuItemSubMenuTextLens(location).canGet(after) &&
      menuItemSubMenuTextLens(location).get(before) !=
          menuItemSubMenuTextLens(location).get(after))
    ConfigDirtyField.menuItemSubMenuText,
  if (menuItemSubMenuIconLens(location).canGet(before) &&
      menuItemSubMenuIconLens(location).canGet(after) &&
      menuItemSubMenuIconLens(location).get(before) !=
          menuItemSubMenuIconLens(location).get(after))
    ConfigDirtyField.menuItemSubMenuIcon,
  if (menuItemSectionTextLens(location).canGet(before) &&
      menuItemSectionTextLens(location).canGet(after) &&
      menuItemSectionTextLens(location).get(before) !=
          menuItemSectionTextLens(location).get(after))
    ConfigDirtyField.menuItemSectionText,
};

final gestureGroupFields =
    <
      GeneratedEditField<
        Config,
        GestureGroupLocation,
        Object?,
        Lens<Config, Object?>
      >
    >[
      gestureGroupNameField,
      gestureGroupEnabledField,
      gestureGroupConditionsField,
      gestureGroupIdField,
      gestureGroupThresholdField,
      gestureGroupResumeTimeoutField,
      gestureGroupAcceleratedField,
      gestureGroupBlockEventsField,
      gestureGroupClearModifiersField,
      gestureGroupSetLastTriggerField,
      gestureGroupEndConditionsField,
      gestureGroupMouseButtonsField,
      gestureGroupMouseButtonsExactOrderField,
      gestureGroupFingersField,
      gestureGroupSpeedField,
      gestureGroupInstantField,
      gestureGroupLockPointerField,
    ];

Set<ConfigDirtyField> changedGestureGroupFields(
  Config before,
  Config after,
  GestureGroupLocation location,
) => {
  if (gestureGroupNameLens(location).canGet(before) &&
      gestureGroupNameLens(location).canGet(after) &&
      gestureGroupNameLens(location).get(before) !=
          gestureGroupNameLens(location).get(after))
    ConfigDirtyField.gestureGroupName,
  if (gestureGroupEnabledLens(location).canGet(before) &&
      gestureGroupEnabledLens(location).canGet(after) &&
      gestureGroupEnabledLens(location).get(before) !=
          gestureGroupEnabledLens(location).get(after))
    ConfigDirtyField.gestureGroupEnabled,
  if (gestureGroupConditionsLens(location).canGet(before) &&
      gestureGroupConditionsLens(location).canGet(after) &&
      gestureGroupConditionsLens(location).get(before) !=
          gestureGroupConditionsLens(location).get(after))
    ConfigDirtyField.gestureGroupConditions,
  if (gestureGroupIdLens(location).canGet(before) &&
      gestureGroupIdLens(location).canGet(after) &&
      gestureGroupIdLens(location).get(before) !=
          gestureGroupIdLens(location).get(after))
    ConfigDirtyField.gestureGroupId,
  if (gestureGroupThresholdLens(location).canGet(before) &&
      gestureGroupThresholdLens(location).canGet(after) &&
      gestureGroupThresholdLens(location).get(before) !=
          gestureGroupThresholdLens(location).get(after))
    ConfigDirtyField.gestureGroupThreshold,
  if (gestureGroupResumeTimeoutLens(location).canGet(before) &&
      gestureGroupResumeTimeoutLens(location).canGet(after) &&
      gestureGroupResumeTimeoutLens(location).get(before) !=
          gestureGroupResumeTimeoutLens(location).get(after))
    ConfigDirtyField.gestureGroupResumeTimeout,
  if (gestureGroupAcceleratedLens(location).canGet(before) &&
      gestureGroupAcceleratedLens(location).canGet(after) &&
      gestureGroupAcceleratedLens(location).get(before) !=
          gestureGroupAcceleratedLens(location).get(after))
    ConfigDirtyField.gestureGroupAccelerated,
  if (gestureGroupBlockEventsLens(location).canGet(before) &&
      gestureGroupBlockEventsLens(location).canGet(after) &&
      gestureGroupBlockEventsLens(location).get(before) !=
          gestureGroupBlockEventsLens(location).get(after))
    ConfigDirtyField.gestureGroupBlockEvents,
  if (gestureGroupClearModifiersLens(location).canGet(before) &&
      gestureGroupClearModifiersLens(location).canGet(after) &&
      gestureGroupClearModifiersLens(location).get(before) !=
          gestureGroupClearModifiersLens(location).get(after))
    ConfigDirtyField.gestureGroupClearModifiers,
  if (gestureGroupSetLastTriggerLens(location).canGet(before) &&
      gestureGroupSetLastTriggerLens(location).canGet(after) &&
      gestureGroupSetLastTriggerLens(location).get(before) !=
          gestureGroupSetLastTriggerLens(location).get(after))
    ConfigDirtyField.gestureGroupSetLastTrigger,
  if (gestureGroupEndConditionsLens(location).canGet(before) &&
      gestureGroupEndConditionsLens(location).canGet(after) &&
      gestureGroupEndConditionsLens(location).get(before) !=
          gestureGroupEndConditionsLens(location).get(after))
    ConfigDirtyField.gestureGroupEndConditions,
  if (gestureGroupMouseButtonsLens(location).canGet(before) &&
      gestureGroupMouseButtonsLens(location).canGet(after) &&
      gestureGroupMouseButtonsLens(location).get(before) !=
          gestureGroupMouseButtonsLens(location).get(after))
    ConfigDirtyField.gestureGroupMouseButtons,
  if (gestureGroupMouseButtonsExactOrderLens(location).canGet(before) &&
      gestureGroupMouseButtonsExactOrderLens(location).canGet(after) &&
      gestureGroupMouseButtonsExactOrderLens(location).get(before) !=
          gestureGroupMouseButtonsExactOrderLens(location).get(after))
    ConfigDirtyField.gestureGroupMouseButtonsExactOrder,
  if (gestureGroupFingersLens(location).canGet(before) &&
      gestureGroupFingersLens(location).canGet(after) &&
      gestureGroupFingersLens(location).get(before) !=
          gestureGroupFingersLens(location).get(after))
    ConfigDirtyField.gestureGroupFingers,
  if (gestureGroupSpeedLens(location).canGet(before) &&
      gestureGroupSpeedLens(location).canGet(after) &&
      gestureGroupSpeedLens(location).get(before) !=
          gestureGroupSpeedLens(location).get(after))
    ConfigDirtyField.gestureGroupSpeed,
  if (gestureGroupInstantLens(location).canGet(before) &&
      gestureGroupInstantLens(location).canGet(after) &&
      gestureGroupInstantLens(location).get(before) !=
          gestureGroupInstantLens(location).get(after))
    ConfigDirtyField.gestureGroupInstant,
  if (gestureGroupLockPointerLens(location).canGet(before) &&
      gestureGroupLockPointerLens(location).canGet(after) &&
      gestureGroupLockPointerLens(location).get(before) !=
          gestureGroupLockPointerLens(location).get(after))
    ConfigDirtyField.gestureGroupLockPointer,
};

final deviceRuleFields =
    <
      GeneratedEditField<
        Config,
        DeviceRuleLocation,
        Object?,
        Lens<Config, Object?>
      >
    >[
      deviceRuleConditionsField,
      deviceRulePropertiesIgnoreField,
      deviceRulePropertiesGrabField,
      deviceRulePropertiesMotionTimeoutField,
      deviceRulePropertiesMotionThresholdField,
      deviceRulePropertiesPressTimeoutField,
      deviceRulePropertiesSwipeAngleToleranceField,
      deviceRulePropertiesUnblockButtonsOnTimeoutField,
      deviceRulePropertiesButtonpadField,
      deviceRulePropertiesClickTimeoutField,
      deviceRulePropertiesHandleEvdevEventsField,
      deviceRulePropertiesMotionThreshold2Field,
      deviceRulePropertiesMotionThreshold3Field,
      deviceRulePropertiesPressureRangesFingerField,
      deviceRulePropertiesPressureRangesThumbField,
      deviceRulePropertiesPressureRangesPalmField,
    ];

Set<ConfigDirtyField> changedDeviceRuleFields(
  Config before,
  Config after,
  DeviceRuleLocation location,
) => {
  if (deviceRuleConditionsLens(location).canGet(before) &&
      deviceRuleConditionsLens(location).canGet(after) &&
      deviceRuleConditionsLens(location).get(before) !=
          deviceRuleConditionsLens(location).get(after))
    ConfigDirtyField.deviceRuleConditions,
  if (deviceRulePropertiesIgnoreLens(location).canGet(before) &&
      deviceRulePropertiesIgnoreLens(location).canGet(after) &&
      deviceRulePropertiesIgnoreLens(location).get(before) !=
          deviceRulePropertiesIgnoreLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesIgnore,
  if (deviceRulePropertiesGrabLens(location).canGet(before) &&
      deviceRulePropertiesGrabLens(location).canGet(after) &&
      deviceRulePropertiesGrabLens(location).get(before) !=
          deviceRulePropertiesGrabLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesGrab,
  if (deviceRulePropertiesMotionTimeoutLens(location).canGet(before) &&
      deviceRulePropertiesMotionTimeoutLens(location).canGet(after) &&
      deviceRulePropertiesMotionTimeoutLens(location).get(before) !=
          deviceRulePropertiesMotionTimeoutLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesMotionTimeout,
  if (deviceRulePropertiesMotionThresholdLens(location).canGet(before) &&
      deviceRulePropertiesMotionThresholdLens(location).canGet(after) &&
      deviceRulePropertiesMotionThresholdLens(location).get(before) !=
          deviceRulePropertiesMotionThresholdLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesMotionThreshold,
  if (deviceRulePropertiesPressTimeoutLens(location).canGet(before) &&
      deviceRulePropertiesPressTimeoutLens(location).canGet(after) &&
      deviceRulePropertiesPressTimeoutLens(location).get(before) !=
          deviceRulePropertiesPressTimeoutLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesPressTimeout,
  if (deviceRulePropertiesSwipeAngleToleranceLens(location).canGet(before) &&
      deviceRulePropertiesSwipeAngleToleranceLens(location).canGet(after) &&
      deviceRulePropertiesSwipeAngleToleranceLens(location).get(before) !=
          deviceRulePropertiesSwipeAngleToleranceLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesSwipeAngleTolerance,
  if (deviceRulePropertiesUnblockButtonsOnTimeoutLens(
        location,
      ).canGet(before) &&
      deviceRulePropertiesUnblockButtonsOnTimeoutLens(location).canGet(after) &&
      deviceRulePropertiesUnblockButtonsOnTimeoutLens(location).get(before) !=
          deviceRulePropertiesUnblockButtonsOnTimeoutLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesUnblockButtonsOnTimeout,
  if (deviceRulePropertiesButtonpadLens(location).canGet(before) &&
      deviceRulePropertiesButtonpadLens(location).canGet(after) &&
      deviceRulePropertiesButtonpadLens(location).get(before) !=
          deviceRulePropertiesButtonpadLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesButtonpad,
  if (deviceRulePropertiesClickTimeoutLens(location).canGet(before) &&
      deviceRulePropertiesClickTimeoutLens(location).canGet(after) &&
      deviceRulePropertiesClickTimeoutLens(location).get(before) !=
          deviceRulePropertiesClickTimeoutLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesClickTimeout,
  if (deviceRulePropertiesHandleEvdevEventsLens(location).canGet(before) &&
      deviceRulePropertiesHandleEvdevEventsLens(location).canGet(after) &&
      deviceRulePropertiesHandleEvdevEventsLens(location).get(before) !=
          deviceRulePropertiesHandleEvdevEventsLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesHandleEvdevEvents,
  if (deviceRulePropertiesMotionThreshold2Lens(location).canGet(before) &&
      deviceRulePropertiesMotionThreshold2Lens(location).canGet(after) &&
      deviceRulePropertiesMotionThreshold2Lens(location).get(before) !=
          deviceRulePropertiesMotionThreshold2Lens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesMotionThreshold2,
  if (deviceRulePropertiesMotionThreshold3Lens(location).canGet(before) &&
      deviceRulePropertiesMotionThreshold3Lens(location).canGet(after) &&
      deviceRulePropertiesMotionThreshold3Lens(location).get(before) !=
          deviceRulePropertiesMotionThreshold3Lens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesMotionThreshold3,
  if (deviceRulePropertiesPressureRangesFingerLens(location).canGet(before) &&
      deviceRulePropertiesPressureRangesFingerLens(location).canGet(after) &&
      deviceRulePropertiesPressureRangesFingerLens(location).get(before) !=
          deviceRulePropertiesPressureRangesFingerLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesPressureRangesFinger,
  if (deviceRulePropertiesPressureRangesThumbLens(location).canGet(before) &&
      deviceRulePropertiesPressureRangesThumbLens(location).canGet(after) &&
      deviceRulePropertiesPressureRangesThumbLens(location).get(before) !=
          deviceRulePropertiesPressureRangesThumbLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesPressureRangesThumb,
  if (deviceRulePropertiesPressureRangesPalmLens(location).canGet(before) &&
      deviceRulePropertiesPressureRangesPalmLens(location).canGet(after) &&
      deviceRulePropertiesPressureRangesPalmLens(location).get(before) !=
          deviceRulePropertiesPressureRangesPalmLens(location).get(after))
    ConfigDirtyField.deviceRulePropertiesPressureRangesPalm,
};

final deviceTypeFields =
    <GeneratedEditField<Config, DeviceType, Object?, Lens<Config, Object?>>>[
      speedEventsField,
      speedSwipeThresholdField,
      speedPinchInThresholdField,
      speedPinchOutThresholdField,
      speedRotateThresholdField,
    ];

Set<ConfigDirtyField> changedDeviceTypeFields(
  Config before,
  Config after,
  DeviceType location,
) => {
  if (speedEventsLens(location).canGet(before) &&
      speedEventsLens(location).canGet(after) &&
      speedEventsLens(location).get(before) !=
          speedEventsLens(location).get(after))
    ConfigDirtyField.speedEvents,
  if (speedSwipeThresholdLens(location).canGet(before) &&
      speedSwipeThresholdLens(location).canGet(after) &&
      speedSwipeThresholdLens(location).get(before) !=
          speedSwipeThresholdLens(location).get(after))
    ConfigDirtyField.speedSwipeThreshold,
  if (speedPinchInThresholdLens(location).canGet(before) &&
      speedPinchInThresholdLens(location).canGet(after) &&
      speedPinchInThresholdLens(location).get(before) !=
          speedPinchInThresholdLens(location).get(after))
    ConfigDirtyField.speedPinchInThreshold,
  if (speedPinchOutThresholdLens(location).canGet(before) &&
      speedPinchOutThresholdLens(location).canGet(after) &&
      speedPinchOutThresholdLens(location).get(before) !=
          speedPinchOutThresholdLens(location).get(after))
    ConfigDirtyField.speedPinchOutThreshold,
  if (speedRotateThresholdLens(location).canGet(before) &&
      speedRotateThresholdLens(location).canGet(after) &&
      speedRotateThresholdLens(location).get(before) !=
          speedRotateThresholdLens(location).get(after))
    ConfigDirtyField.speedRotateThreshold,
};

Object? comparableConfigFieldValue(Config? value, ConfigDirtyField field) =>
    switch (field) {
      ConfigDirtyField.globalSettingsAutoreload =>
        value?.globalSettings?.autoreload ?? true,
      ConfigDirtyField.globalSettingsExternalVariableAccess =>
        value?.globalSettings?.externalVariableAccess ?? true,
      ConfigDirtyField.globalSettingsMouseStrokeOverlayEnabled =>
        value?.globalSettings?.mouseStrokeOverlayEnabled,
      ConfigDirtyField.globalSettingsNotificationsConfigError =>
        value?.globalSettings?.notificationsConfigError ?? true,
      ConfigDirtyField.globalSettingsEmergencyCombination =>
        value?.globalSettings?.emergencyCombination,
      ConfigDirtyField.gestureId => null,
      ConfigDirtyField.gestureMouseButtons => null,
      ConfigDirtyField.gestureMouseButtonsExactOrder => null,
      ConfigDirtyField.gestureConditions => null,
      ConfigDirtyField.gestureEndConditions => null,
      ConfigDirtyField.gestureBlockEvents => null,
      ConfigDirtyField.gestureClearModifiers => null,
      ConfigDirtyField.gestureResumeTimeout => null,
      ConfigDirtyField.gestureSetLastTrigger => null,
      ConfigDirtyField.gestureThreshold => null,
      ConfigDirtyField.gestureAccelerated => null,
      ConfigDirtyField.gestureExtra => null,
      ConfigDirtyField.actionCommand => null,
      ConfigDirtyField.actionWait => null,
      ConfigDirtyField.actionComponent => null,
      ConfigDirtyField.actionShortcut => null,
      ConfigDirtyField.actionWindowId => null,
      ConfigDirtyField.actionRules => null,
      ConfigDirtyField.actionDuration => null,
      ConfigDirtyField.actionExpression => null,
      ConfigDirtyField.menuItemText => null,
      ConfigDirtyField.menuItemIcon => null,
      ConfigDirtyField.menuItemActions => null,
      ConfigDirtyField.menuItemSubMenuText => null,
      ConfigDirtyField.menuItemSubMenuIcon => null,
      ConfigDirtyField.menuItemSectionText => null,
      ConfigDirtyField.actionRaw => null,
      ConfigDirtyField.actionInputEntries => null,
      ConfigDirtyField.actionInputDelay => null,
      ConfigDirtyField.actionTriggerOn => null,
      ConfigDirtyField.actionInterval => null,
      ConfigDirtyField.actionThreshold => null,
      ConfigDirtyField.actionLimit => null,
      ConfigDirtyField.actionEnabled => null,
      ConfigDirtyField.actionConflicting => null,
      ConfigDirtyField.actionConditions => null,
      ConfigDirtyField.actionId => null,
      ConfigDirtyField.mouseGestureStrokeMotionSpeed => null,
      ConfigDirtyField.mouseGestureStrokeMotionLockPointer => null,
      ConfigDirtyField.mouseGestureStrokeStrokes => null,
      ConfigDirtyField.mouseGestureSwipeMotionSpeed => null,
      ConfigDirtyField.mouseGestureSwipeMotionLockPointer => null,
      ConfigDirtyField.mouseGestureSwipeModeDirection => null,
      ConfigDirtyField.mouseGestureSwipeModeAngleMinAngle => null,
      ConfigDirtyField.mouseGestureSwipeModeAngleMaxAngle => null,
      ConfigDirtyField.mouseGestureSwipeModeAngleBidirectional => null,
      ConfigDirtyField.circleMotionSpeed => null,
      ConfigDirtyField.circleMotionLockPointer => null,
      ConfigDirtyField.circleDirection => null,
      ConfigDirtyField.pressMotionSpeed => null,
      ConfigDirtyField.pressMotionLockPointer => null,
      ConfigDirtyField.pressInstant => null,
      ConfigDirtyField.wheelMotionSpeed => null,
      ConfigDirtyField.wheelMotionLockPointer => null,
      ConfigDirtyField.wheelDirection => null,
      ConfigDirtyField.shortcutKeys => null,
      ConfigDirtyField.touchpadFingers => null,
      ConfigDirtyField.touchpadMotionSpeed => null,
      ConfigDirtyField.touchpadSwipeMode => null,
      ConfigDirtyField.touchpadPinchDirection => null,
      ConfigDirtyField.touchpadRotateDirection => null,
      ConfigDirtyField.touchpadCircleDirection => null,
      ConfigDirtyField.touchpadStrokeStrokes => null,
      ConfigDirtyField.touchscreenFingers => null,
      ConfigDirtyField.touchscreenMotionSpeed => null,
      ConfigDirtyField.touchscreenSwipeMode => null,
      ConfigDirtyField.touchscreenPinchDirection => null,
      ConfigDirtyField.touchscreenRotateDirection => null,
      ConfigDirtyField.touchscreenCircleDirection => null,
      ConfigDirtyField.touchscreenStrokeStrokes => null,
      ConfigDirtyField.gestureGroupName => null,
      ConfigDirtyField.gestureGroupEnabled => null,
      ConfigDirtyField.gestureGroupConditions => null,
      ConfigDirtyField.gestureGroupId => null,
      ConfigDirtyField.gestureGroupThreshold => null,
      ConfigDirtyField.gestureGroupResumeTimeout => null,
      ConfigDirtyField.gestureGroupAccelerated => null,
      ConfigDirtyField.gestureGroupBlockEvents => null,
      ConfigDirtyField.gestureGroupClearModifiers => null,
      ConfigDirtyField.gestureGroupSetLastTrigger => null,
      ConfigDirtyField.gestureGroupEndConditions => null,
      ConfigDirtyField.gestureGroupMouseButtons => null,
      ConfigDirtyField.gestureGroupMouseButtonsExactOrder => null,
      ConfigDirtyField.gestureGroupFingers => null,
      ConfigDirtyField.gestureGroupSpeed => null,
      ConfigDirtyField.gestureGroupInstant => null,
      ConfigDirtyField.gestureGroupLockPointer => null,
      ConfigDirtyField.deviceRuleConditions => null,
      ConfigDirtyField.deviceRulePropertiesIgnore => null,
      ConfigDirtyField.deviceRulePropertiesGrab => null,
      ConfigDirtyField.deviceRulePropertiesMotionTimeout => null,
      ConfigDirtyField.deviceRulePropertiesMotionThreshold => null,
      ConfigDirtyField.deviceRulePropertiesPressTimeout => null,
      ConfigDirtyField.deviceRulePropertiesSwipeAngleTolerance => null,
      ConfigDirtyField.deviceRulePropertiesUnblockButtonsOnTimeout => null,
      ConfigDirtyField.deviceRulePropertiesButtonpad => null,
      ConfigDirtyField.deviceRulePropertiesClickTimeout => null,
      ConfigDirtyField.deviceRulePropertiesHandleEvdevEvents => null,
      ConfigDirtyField.deviceRulePropertiesMotionThreshold2 => null,
      ConfigDirtyField.deviceRulePropertiesMotionThreshold3 => null,
      ConfigDirtyField.deviceRulePropertiesPressureRangesFinger => null,
      ConfigDirtyField.deviceRulePropertiesPressureRangesThumb => null,
      ConfigDirtyField.deviceRulePropertiesPressureRangesPalm => null,
      ConfigDirtyField.speedEvents => null,
      ConfigDirtyField.speedSwipeThreshold => null,
      ConfigDirtyField.speedPinchInThreshold => null,
      ConfigDirtyField.speedPinchOutThreshold => null,
      ConfigDirtyField.speedRotateThreshold => null,
    };

Object? comparableGlobalSettingsValue(GlobalSettings? value) => [
  value?.autoreload ?? true,
  value?.externalVariableAccess ?? true,
  value?.mouseStrokeOverlayEnabled,
  value?.notificationsConfigError ?? true,
  value?.emergencyCombination,
];

Object? comparableTriggerCommonValue(TriggerCommon? value) => [
  value?.name,
  value?.effectiveEnabled,
  value?.id,
  value?.mouseButtons,
  value?.mouseButtonsExactOrder,
  value?.conditions,
  value?.endConditions,
  value?.blockEvents ?? true,
  value?.clearModifiers ?? false,
  value?.resumeTimeout,
  value?.setLastTrigger ?? true,
  value?.threshold,
  value?.accelerated ?? false,
  value?.extra,
  (value?.actions ?? const <TriggerAction>[])
      .map(comparableTriggerActionValue)
      .toList(),
];

Object? comparableTriggerCommonMouseButtonsSectionValue(TriggerCommon? value) =>
    [value?.mouseButtons, value?.mouseButtonsExactOrder];

Object? comparableTriggerCommonTriggerConditionsValue(TriggerCommon? value) => [
  value?.conditions,
];

Object? comparableTriggerCommonActionsSectionValue(TriggerCommon? value) => [
  (value?.actions ?? const <TriggerAction>[])
      .map(comparableTriggerActionValue)
      .toList(),
];

Object? comparableTriggerCommonTriggerConfigValue(TriggerCommon? value) => [
  value?.mouseButtons,
  value?.mouseButtonsExactOrder,
  value?.conditions,
  value?.id,
  value?.threshold,
  value?.resumeTimeout,
  value?.accelerated ?? false,
  value?.blockEvents ?? true,
  value?.clearModifiers ?? false,
  value?.setLastTrigger ?? true,
  value?.endConditions,
  value?.extra,
];

Object? comparableTriggerActionValue(TriggerAction? value) => [
  comparableActionValue(value?.action),
  value?.on ?? TriggerOn.end,
  value?.interval,
  value?.threshold,
  value?.limit,
  value?.enabled ?? true,
  value?.conflicting,
  value?.conditions,
  value?.id,
  if (value == null)
    null
  else
    (switch (value.action) {
              ActionGroup(:final actions) => actions,
              _ => null,
            } ??
            const <TriggerAction>[])
        .map(comparableTriggerActionValue)
        .toList(),
];

Object? comparableActionValue(Action? value) => switch (value) {
  CommandAction() && final v => ['command', v.command, v.wait ?? false],
  PlasmaShortcutAction() && final v => ['plasma', v.component, v.shortcut],
  ActivateWindowAction() && final v => ['activateWindow', v.windowId],
  ReplaceTextAction() && final v => ['replaceText', v.rules],
  SleepAction() && final v => ['sleep', v.milliseconds],
  FunctionAction() && final v => ['function', v.expression],
  ContextMenuAction() && final v => [
    'contextMenu',
    (v?.items ?? const <MenuItem>[]).map(comparableMenuItemValue).toList(),
  ],
  RawAction() && final v => ['raw', v.raw],
  ActionGroup() && final v => ['group'],
  InputAction() && final v => ['input', v.entries, v.delay],
  _ => null,
};

Object? comparableMenuItemValue(MenuItem? value) => switch (value) {
  ActionMenuItem() && final v => [
    'action',
    v.text,
    v.icon,
    v.actions,
    (switch (v) {
              SubMenuItem(:final items) => items,
              _ => null,
            } ??
            const <MenuItem>[])
        .map(comparableMenuItemValue)
        .toList(),
  ],
  SubMenuItem() && final v => [
    'subMenu',
    v.text,
    v.icon,
    (switch (v) {
              SubMenuItem(:final items) => items,
              _ => null,
            } ??
            const <MenuItem>[])
        .map(comparableMenuItemValue)
        .toList(),
  ],
  SectionMenuItem() && final v => [
    'section',
    v.text,
    (switch (v) {
              SubMenuItem(:final items) => items,
              _ => null,
            } ??
            const <MenuItem>[])
        .map(comparableMenuItemValue)
        .toList(),
  ],
  SeparatorMenuItem() && final v => [
    'separator',
    (switch (v) {
              SubMenuItem(:final items) => items,
              _ => null,
            } ??
            const <MenuItem>[])
        .map(comparableMenuItemValue)
        .toList(),
  ],
  _ => null,
};

Object? comparableMouseGestureValue(MouseGesture? value) => switch (value) {
  StrokeGesture() && final v => [
    'stroke',
    comparableMotionCommonValue(v?.motion),
    v.strokes,
  ],
  SwipeGesture() && final v => [
    'swipe',
    comparableMotionCommonValue(v?.motion),
    comparableSwipeModeValue(v?.mode),
  ],
  CircleGesture() && final v => [
    'circle',
    comparableMotionCommonValue(v?.motion),
    v.direction,
  ],
  PressGesture() && final v => [
    'press',
    comparableMotionCommonValue(v?.motion),
    v.instant ?? false,
  ],
  WheelGesture() && final v => [
    'wheel',
    comparableMotionCommonValue(v?.motion),
    v.direction,
  ],
  _ => null,
};

Object? comparableMotionCommonValue(MotionCommon? value) => [
  value?.speed,
  value?.lockPointer ?? false,
];

Object? comparableSwipeModeValue(SwipeMode? value) => switch (value) {
  SwipeDirectionMode() && final v => ['direction', v.direction],
  SwipeAngleMode() && final v => [
    'angle',
    v.minAngle,
    v.maxAngle,
    v.bidirectional,
  ],
  _ => null,
};

Object? comparableKeyboardGestureValue(KeyboardGesture? value) =>
    switch (value) {
      ShortcutGesture() && final v => ['shortcut', v.keys],
      _ => null,
    };

Object? comparablePointerGestureValue(PointerGesture? value) => switch (value) {
  HoverGesture() && final v => ['hover'],
  _ => null,
};

Object? comparableTouchpadGestureValue(TouchpadGesture? value) =>
    switch (value) {
      TouchpadSwipeGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadSwipe',
        v.mode,
      ],
      TouchpadPinchGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadPinch',
        v.direction,
      ],
      TouchpadRotateGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadRotate',
        v.direction,
      ],
      TouchpadCircleGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadCircle',
        v.direction,
      ],
      TouchpadTapGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadTap',
      ],
      TouchpadClickGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadClick',
      ],
      TouchpadHoldGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadHold',
      ],
      TouchpadStrokeGesture() && final v => [
        _touchpadFingers(v),
        _touchpadSpeed(v),
        'touchpadStroke',
        v.strokes,
      ],
      _ => null,
    };

Object? comparableTouchscreenGestureValue(TouchscreenGesture? value) =>
    switch (value) {
      TouchscreenSwipeGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenSwipe',
        v.mode,
      ],
      TouchscreenPinchGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenPinch',
        v.direction,
      ],
      TouchscreenRotateGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenRotate',
        v.direction,
      ],
      TouchscreenCircleGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenCircle',
        v.direction,
      ],
      TouchscreenTapGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenTap',
      ],
      TouchscreenHoldGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenHold',
      ],
      TouchscreenStrokeGesture() && final v => [
        _touchscreenFingers(v),
        _touchscreenSpeed(v),
        'touchscreenStroke',
        v.strokes,
      ],
      _ => null,
    };

Object? comparableGestureGroupNodeValue(GestureGroupNode? value) => [
  value?.name,
  value?.enabled,
  value?.conditions,
  value?.id,
  value?.threshold,
  value?.resumeTimeout,
  value?.accelerated ?? false,
  value?.blockEvents ?? true,
  value?.clearModifiers ?? false,
  value?.setLastTrigger ?? true,
  value?.endConditions,
  value?.mouseButtons ?? const <MouseButtonValue>[],
  value?.mouseButtonsExactOrder ?? false,
  value?.fingers,
  value?.speed,
  value?.instant ?? false,
  value?.lockPointer ?? false,
];

Object? comparableDeviceRuleValue(DeviceRule? value) => [
  value?.conditions,
  comparableDeviceRulePropertiesValue(value?.properties),
];

Object? comparableDeviceRulePropertiesValue(DeviceRuleProperties? value) => [
  value?.ignore,
  value?.grab,
  value?.motionTimeout,
  value?.motionThreshold,
  value?.pressTimeout,
  value?.swipeAngleTolerance,
  value?.unblockButtonsOnTimeout,
  value?.buttonpad,
  value?.clickTimeout,
  value?.handleEvdevEvents,
  value?.motionThreshold2,
  value?.motionThreshold3,
  value?.pressureRangesFinger,
  value?.pressureRangesThumb,
  value?.pressureRangesPalm,
];

Object? comparableSpeedSettingsValue(SpeedSettings? value) => [
  value?.events,
  value?.swipeThreshold,
  value?.pinchInThreshold,
  value?.pinchOutThreshold,
  value?.rotateThreshold,
];

Object? comparableConfigValue(Config? value) => [
  comparableGlobalSettingsValue(value?.globalSettings),
  (value?.mouseNodes ?? const <GestureNode>[])
      .map(comparableGestureNodeValue)
      .toList(),
  (value?.keyboardNodes ?? const <GestureNode>[])
      .map(comparableGestureNodeValue)
      .toList(),
  (value?.pointerNodes ?? const <GestureNode>[])
      .map(comparableGestureNodeValue)
      .toList(),
  (value?.touchpadNodes ?? const <GestureNode>[])
      .map(comparableGestureNodeValue)
      .toList(),
  (value?.touchscreenNodes ?? const <GestureNode>[])
      .map(comparableGestureNodeValue)
      .toList(),
  (value?.deviceRules ?? const <DeviceRule>[])
      .map(comparableDeviceRuleValue)
      .toList(),
  comparableSpeedSettingsValue(value?.mouseSpeed),
  comparableSpeedSettingsValue(value?.touchpadSpeed),
  comparableSpeedSettingsValue(value?.touchscreenSpeed),
];
