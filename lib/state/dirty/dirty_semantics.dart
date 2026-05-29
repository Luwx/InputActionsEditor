import 'package:collection/collection.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
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

Object? comparableGestureCommonFieldValue(
  TriggerCommon? common,
  GestureCommonDirtyField field,
) => switch (field) {
  GestureCommonDirtyField.id => common?.id,
  GestureCommonDirtyField.threshold => common?.threshold,
  GestureCommonDirtyField.resumeTimeout => common?.resumeTimeout,
  GestureCommonDirtyField.accelerated => common?.effectiveAccelerated,
  GestureCommonDirtyField.blockEvents => common?.effectiveBlockEvents,
  GestureCommonDirtyField.clearModifiers => common?.effectiveClearModifiers,
  GestureCommonDirtyField.setLastTrigger => common?.effectiveSetLastTrigger,
  GestureCommonDirtyField.endConditions => common?.endConditions,
};

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

Object? comparableActionFieldValue(
  TriggerAction? triggerAction,
  ActionDirtyField field,
) => switch (field) {
  ActionDirtyField.command => switch (triggerAction?.action) {
    CommandAction(:final command) => command,
    _ => null,
  },
  ActionDirtyField.wait => switch (triggerAction?.action) {
    CommandAction() => (triggerAction!.action as CommandAction).effectiveWait,
    _ => null,
  },
  ActionDirtyField.inputEntries => switch (triggerAction?.action) {
    InputAction(:final entries) => entries,
    _ => null,
  },
  ActionDirtyField.component => switch (triggerAction?.action) {
    PlasmaShortcutAction(:final component) => component,
    _ => null,
  },
  ActionDirtyField.shortcut => switch (triggerAction?.action) {
    PlasmaShortcutAction(:final shortcut) => shortcut,
    _ => null,
  },
  ActionDirtyField.duration => switch (triggerAction?.action) {
    SleepAction(:final milliseconds) => milliseconds,
    _ => null,
  },
  ActionDirtyField.raw => switch (triggerAction?.action) {
    RawAction(:final raw) => raw,
    _ => null,
  },
  ActionDirtyField.triggerOn => triggerAction?.on,
  ActionDirtyField.interval => triggerAction?.interval,
  ActionDirtyField.threshold => triggerAction?.threshold,
  ActionDirtyField.limit => triggerAction?.limit,
  ActionDirtyField.conflicting => triggerAction?.conflicting,
  ActionDirtyField.conditions => triggerAction?.conditions,
};

Action restoreSavedActionField({
  required Action current,
  required Action saved,
  required ActionDirtyField field,
}) => switch ((current, saved, field)) {
  (
    CommandAction() && final currentAction,
    CommandAction() && final savedAction,
    ActionDirtyField.command,
  ) =>
    currentAction.copyWith(
      command: savedAction.command,
    ),
  (
    CommandAction() && final currentAction,
    CommandAction() && final savedAction,
    ActionDirtyField.wait,
  ) =>
    currentAction.copyWith(wait: savedAction.wait),
  (
    InputAction() && final currentAction,
    InputAction() && final savedAction,
    ActionDirtyField.inputEntries,
  ) =>
    currentAction.copyWith(
      entries: savedAction.entries,
    ),
  (
    PlasmaShortcutAction() && final currentAction,
    PlasmaShortcutAction() && final savedAction,
    ActionDirtyField.component,
  ) =>
    currentAction.copyWith(component: savedAction.component),
  (
    PlasmaShortcutAction() && final currentAction,
    PlasmaShortcutAction() && final savedAction,
    ActionDirtyField.shortcut,
  ) =>
    currentAction.copyWith(shortcut: savedAction.shortcut),
  (
    SleepAction() && final currentAction,
    SleepAction() && final savedAction,
    ActionDirtyField.duration,
  ) =>
    currentAction.copyWith(
      milliseconds: savedAction.milliseconds,
    ),
  (RawAction(), RawAction(:final raw), ActionDirtyField.raw) => RawAction(
    raw: raw,
  ),
  _ => current,
};

TriggerAction restoreSavedTriggerActionField({
  required TriggerAction current,
  required TriggerAction saved,
  required ActionDirtyField field,
}) => switch (field) {
  ActionDirtyField.triggerOn => current.copyWith(on: saved.on),
  ActionDirtyField.interval => current.copyWith(interval: saved.interval),
  ActionDirtyField.threshold => current.copyWith(threshold: saved.threshold),
  ActionDirtyField.limit => current.copyWith(limit: saved.limit),
  ActionDirtyField.conflicting => current.copyWith(
    conflicting: saved.conflicting,
  ),
  ActionDirtyField.conditions => current.copyWith(conditions: saved.conditions),
  _ => current,
};

Object? comparableGlobalSettingsFieldValue(
  GlobalSettings? settings,
  GlobalSettingsDirtyField field,
) => switch (field) {
  GlobalSettingsDirtyField.autoreload => settings?.effectiveAutoreload,
  GlobalSettingsDirtyField.externalVariableAccess =>
    settings?.effectiveExternalVariableAccess,
  GlobalSettingsDirtyField.notificationsConfigError =>
    settings?.effectiveNotificationsConfigError,
  GlobalSettingsDirtyField.emergencyCombination =>
    settings?.emergencyCombination,
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

Object? comparableDevicePropertyFieldValue(
  DeviceRuleProperties? properties,
  DevicePropertyDirtyField field,
) => switch (field) {
  DevicePropertyDirtyField.ignore => properties?.ignore,
  DevicePropertyDirtyField.grab => properties?.grab,
  DevicePropertyDirtyField.motionTimeout => properties?.motionTimeout,
  DevicePropertyDirtyField.motionThreshold => properties?.motionThreshold,
  DevicePropertyDirtyField.pressTimeout => properties?.pressTimeout,
  DevicePropertyDirtyField.swipeAngleTolerance =>
    properties?.swipeAngleTolerance,
  DevicePropertyDirtyField.unblockButtonsOnTimeout =>
    properties?.unblockButtonsOnTimeout,
  DevicePropertyDirtyField.buttonpad => properties?.buttonpad,
  DevicePropertyDirtyField.clickTimeout => properties?.clickTimeout,
  DevicePropertyDirtyField.handleEvdevEvents => properties?.handleEvdevEvents,
  DevicePropertyDirtyField.motionThreshold2 => properties?.motionThreshold2,
  DevicePropertyDirtyField.motionThreshold3 => properties?.motionThreshold3,
  DevicePropertyDirtyField.pressureRangesFinger =>
    properties?.pressureRangesFinger,
  DevicePropertyDirtyField.pressureRangesThumb =>
    properties?.pressureRangesThumb,
  DevicePropertyDirtyField.pressureRangesPalm => properties?.pressureRangesPalm,
};

DeviceRuleProperties restoreSavedDeviceProperty(
  DeviceRuleProperties current,
  DeviceRuleProperties saved,
  DevicePropertyDirtyField field,
) => switch (field) {
  DevicePropertyDirtyField.ignore => current.copyWith(ignore: saved.ignore),
  DevicePropertyDirtyField.grab => current.copyWith(grab: saved.grab),
  DevicePropertyDirtyField.motionTimeout => current.copyWith(
    motionTimeout: saved.motionTimeout,
  ),
  DevicePropertyDirtyField.motionThreshold => current.copyWith(
    motionThreshold: saved.motionThreshold,
  ),
  DevicePropertyDirtyField.pressTimeout => current.copyWith(
    pressTimeout: saved.pressTimeout,
  ),
  DevicePropertyDirtyField.swipeAngleTolerance => current.copyWith(
    swipeAngleTolerance: saved.swipeAngleTolerance,
  ),
  DevicePropertyDirtyField.unblockButtonsOnTimeout => current.copyWith(
    unblockButtonsOnTimeout: saved.unblockButtonsOnTimeout,
  ),
  DevicePropertyDirtyField.buttonpad => current.copyWith(
    buttonpad: saved.buttonpad,
  ),
  DevicePropertyDirtyField.clickTimeout => current.copyWith(
    clickTimeout: saved.clickTimeout,
  ),
  DevicePropertyDirtyField.handleEvdevEvents => current.copyWith(
    handleEvdevEvents: saved.handleEvdevEvents,
  ),
  DevicePropertyDirtyField.motionThreshold2 => current.copyWith(
    motionThreshold2: saved.motionThreshold2,
  ),
  DevicePropertyDirtyField.motionThreshold3 => current.copyWith(
    motionThreshold3: saved.motionThreshold3,
  ),
  DevicePropertyDirtyField.pressureRangesFinger => current.copyWith(
    pressureRangesFinger: saved.pressureRangesFinger,
  ),
  DevicePropertyDirtyField.pressureRangesThumb => current.copyWith(
    pressureRangesThumb: saved.pressureRangesThumb,
  ),
  DevicePropertyDirtyField.pressureRangesPalm => current.copyWith(
    pressureRangesPalm: saved.pressureRangesPalm,
  ),
};

Object? comparableSpeedSettingFieldValue(
  SpeedSettings? settings,
  SpeedSettingDirtyField field,
) => switch (field) {
  SpeedSettingDirtyField.events => settings?.events,
  SpeedSettingDirtyField.swipeThreshold => settings?.swipeThreshold,
  SpeedSettingDirtyField.pinchInThreshold => settings?.pinchInThreshold,
  SpeedSettingDirtyField.pinchOutThreshold => settings?.pinchOutThreshold,
  SpeedSettingDirtyField.rotateThreshold => settings?.rotateThreshold,
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
