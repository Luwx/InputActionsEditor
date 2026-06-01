import 'package:collection/collection.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/dirty/dirty_mark_state.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';

const _deepCollectionEquality = DeepCollectionEquality();

DirtyMarkState dirtyMarkState({
  required Object? current,
  required Object? saved,
  required bool hasSavedBacking,
}) {
  if (_deepCollectionEquality.equals(current, saved)) {
    return DirtyMarkState.clean;
  }
  return hasSavedBacking
      ? DirtyMarkState.changedFromSaved
      : DirtyMarkState.newUnsaved;
}

Object? comparableGesture(Object? gesture) => switch (gesture) {
  StrokeGesture(:final common, :final motion, :final strokes) => [
    'stroke',
    comparableTriggerCommon(common),
    comparableMotionCommon(motion),
    strokes,
  ],
  SwipeGesture(:final common, :final motion, :final mode) => [
    'swipe',
    comparableTriggerCommon(common),
    comparableMotionCommon(motion),
    comparableSwipeMode(mode),
  ],
  CircleGesture(:final common, :final motion, :final direction) => [
    'circle',
    comparableTriggerCommon(common),
    comparableMotionCommon(motion),
    direction,
  ],
  PressGesture(:final common, :final motion, :final instant) => [
    'press',
    comparableTriggerCommon(common),
    comparableMotionCommon(motion),
    instant ?? false,
  ],
  WheelGesture(:final common, :final motion, :final direction) => [
    'wheel',
    comparableTriggerCommon(common),
    comparableMotionCommon(motion),
    direction,
  ],
  ShortcutGesture(:final common, :final keys) => [
    'shortcut',
    comparableTriggerCommon(common),
    keys,
  ],
  HoverGesture(:final common) => ['hover', comparableTriggerCommon(common)],
  TouchpadSwipeGesture(
    :final common,
    :final fingers,
    :final mode,
    :final motion,
  ) =>
    [
      'touchpadSwipe',
      comparableTriggerCommon(common),
      fingers,
      comparableSwipeMode(mode),
      comparableMotionCommon(motion),
    ],
  TouchpadPinchGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchpadPinch',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchpadRotateGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchpadRotate',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchpadCircleGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchpadCircle',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchpadTapGesture(:final common, :final fingers) => [
    'touchpadTap',
    comparableTriggerCommon(common),
    fingers,
  ],
  TouchpadClickGesture(:final common, :final fingers) => [
    'touchpadClick',
    comparableTriggerCommon(common),
    fingers,
  ],
  TouchpadHoldGesture(:final common, :final fingers) => [
    'touchpadHold',
    comparableTriggerCommon(common),
    fingers,
  ],
  TouchpadStrokeGesture(
    :final common,
    :final fingers,
    :final strokes,
    :final motion,
  ) =>
    [
      'touchpadStroke',
      comparableTriggerCommon(common),
      fingers,
      strokes,
      comparableMotionCommon(motion),
    ],
  TouchscreenSwipeGesture(
    :final common,
    :final fingers,
    :final mode,
    :final motion,
  ) =>
    [
      'touchscreenSwipe',
      comparableTriggerCommon(common),
      fingers,
      comparableSwipeMode(mode),
      comparableMotionCommon(motion),
    ],
  TouchscreenPinchGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchscreenPinch',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchscreenRotateGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchscreenRotate',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchscreenCircleGesture(
    :final common,
    :final fingers,
    :final direction,
    :final motion,
  ) =>
    [
      'touchscreenCircle',
      comparableTriggerCommon(common),
      fingers,
      direction,
      comparableMotionCommon(motion),
    ],
  TouchscreenTapGesture(:final common, :final fingers) => [
    'touchscreenTap',
    comparableTriggerCommon(common),
    fingers,
  ],
  TouchscreenHoldGesture(:final common, :final fingers) => [
    'touchscreenHold',
    comparableTriggerCommon(common),
    fingers,
  ],
  TouchscreenStrokeGesture(
    :final common,
    :final fingers,
    :final strokes,
    :final motion,
  ) =>
    [
      'touchscreenStroke',
      comparableTriggerCommon(common),
      fingers,
      strokes,
      comparableMotionCommon(motion),
    ],
  _ => null,
};

Object? comparableGestureSectionValue(
  TriggerCommon? common,
  GestureSectionDirtyField field,
) => switch (field) {
  GestureSectionDirtyField.mouseButtons => [
    common?.mouseButtons ?? const <Object?>[],
    common?.mouseButtonsExactOrder ?? false,
  ],
  GestureSectionDirtyField.triggerConditions => common?.conditions,
  GestureSectionDirtyField.actions =>
    (common?.actions ?? const <TriggerAction>[])
        .map(comparableTriggerAction)
        .toList(),
};

Object? comparableTriggerCommon(TriggerCommon? common) => [
  common?.name,
  common?.effectiveEnabled,
  common?.id,
  common?.groupId,
  common?.mouseButtons ?? const <Object?>[],
  common?.mouseButtonsExactOrder ?? false,
  common?.conditions,
  common?.endConditions,
  common?.effectiveBlockEvents,
  common?.effectiveClearModifiers,
  common?.resumeTimeout,
  common?.effectiveSetLastTrigger,
  common?.threshold,
  common?.effectiveAccelerated,
  (common?.actions ?? const <TriggerAction>[])
      .map(comparableTriggerAction)
      .toList(),
];

Object? comparableTriggerConfigValue(TriggerCommon? common) => [
  common?.mouseButtons ?? const <Object?>[],
  common?.mouseButtonsExactOrder ?? false,
  common?.conditions,
  common?.id,
  common?.threshold,
  common?.resumeTimeout,
  common?.effectiveAccelerated,
  common?.effectiveBlockEvents,
  common?.effectiveClearModifiers,
  common?.effectiveSetLastTrigger,
  common?.endConditions,
];

Object? comparableTriggerAction(TriggerAction? triggerAction) {
  if (triggerAction == null) return null;
  return [
    triggerAction.on,
    comparableAction(triggerAction.action),
    triggerAction.conditions,
    triggerAction.interval,
    triggerAction.threshold,
    triggerAction.conflicting,
    triggerAction.id,
    triggerAction.limit,
  ];
}

Object? comparableAction(Action? action) => switch (action) {
  CommandAction(:final command) => ['command', command, action.effectiveWait],
  InputAction(:final entries) => ['input', entries],
  PlasmaShortcutAction(:final component, :final shortcut) => [
    'plasmaShortcut',
    component,
    shortcut,
  ],
  SleepAction(:final milliseconds) => ['sleep', milliseconds],
  RawAction(:final raw) => ['raw', raw],
  _ => null,
};

Object? comparableRootFieldValue(Config? config, RootConfigDirtyField field) =>
    switch (field) {
      RootConfigDirtyField.deviceRules =>
        config?.deviceRules ?? const <DeviceRule>[],
      RootConfigDirtyField.effectGeneral => [
        config?.globalSettings.effectiveAutoreload,
        config?.globalSettings.effectiveExternalVariableAccess,
      ],
      RootConfigDirtyField.effectNotifications =>
        config?.globalSettings.effectiveNotificationsConfigError,
      RootConfigDirtyField.effectEmergencyCombination =>
        config?.globalSettings.emergencyCombination,
      RootConfigDirtyField.mouseDeviceProperties => defaultDeviceRule(
        config,
        DeviceType.mouse,
      )?.properties,
      RootConfigDirtyField.keyboardDeviceProperties => defaultDeviceRule(
        config,
        DeviceType.keyboard,
      )?.properties,
      RootConfigDirtyField.touchpadDeviceProperties => defaultDeviceRule(
        config,
        DeviceType.touchpad,
      )?.properties,
      RootConfigDirtyField.touchscreenDeviceProperties => defaultDeviceRule(
        config,
        DeviceType.touchscreen,
      )?.properties,
      RootConfigDirtyField.mouseSpeed => config?.mouseSpeed,
      RootConfigDirtyField.touchpadSpeed => config?.touchpadSpeed,
      RootConfigDirtyField.touchscreenSpeed => config?.touchscreenSpeed,
    };

bool rootFieldHasSavedBacking(Config? config, RootConfigDirtyField field) =>
    switch (field) {
      RootConfigDirtyField.deviceRules =>
        (config?.deviceRules.isNotEmpty ?? false),
      RootConfigDirtyField.effectGeneral ||
      RootConfigDirtyField.effectNotifications ||
      RootConfigDirtyField.effectEmergencyCombination => config != null,
      RootConfigDirtyField.mouseDeviceProperties =>
        defaultDeviceRule(config, DeviceType.mouse) != null,
      RootConfigDirtyField.keyboardDeviceProperties =>
        defaultDeviceRule(config, DeviceType.keyboard) != null,
      RootConfigDirtyField.touchpadDeviceProperties =>
        defaultDeviceRule(config, DeviceType.touchpad) != null,
      RootConfigDirtyField.touchscreenDeviceProperties =>
        defaultDeviceRule(config, DeviceType.touchscreen) != null,
      RootConfigDirtyField.mouseSpeed => config?.mouseSpeed != null,
      RootConfigDirtyField.touchpadSpeed => config?.touchpadSpeed != null,
      RootConfigDirtyField.touchscreenSpeed => config?.touchscreenSpeed != null,
    };

Object? comparableMotionCommon(MotionCommon motion) => [
  motion.speed,
  motion.effectiveLockPointer,
];

Object? comparableSwipeMode(SwipeMode mode) => switch (mode) {
  SwipeDirectionMode(:final direction) => ['direction', direction],
  SwipeAngleMode(:final minAngle, :final maxAngle, :final bidirectional) => [
    'angle',
    minAngle,
    maxAngle,
    bidirectional,
  ],
};
