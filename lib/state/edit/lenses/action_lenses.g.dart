// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_lenses.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: prefer_null_aware_operators

enum ActionDirtyField {
  command,
  wait,
  component,
  shortcut,
  duration,
  raw,
  triggerOn,
  interval,
  threshold,
  limit,
  conflicting,
  conditions,
  inputEntries,
}

final _actionAsCommandActionPart = LensPart<TriggerAction, CommandAction>(
  get: (value) => value.action as CommandAction,
  set: (value, next) => value.copyWith(action: next),
  name: 'CommandAction',
);

final _actionCommandPart = LensPart<CommandAction, String>(
  get: (value) => value.command,
  set: (value, next) => value.copyWith(command: next),
  name: 'command',
);

Lens<String> actionCommandLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsCommandActionPart).then(_actionCommandPart);

final _actionWaitPart = LensPart<CommandAction, bool?>(
  get: (value) => value.wait,
  set: (value, next) => value.copyWith(wait: next),
  name: 'wait',
);

Lens<bool?> actionWaitLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsCommandActionPart).then(_actionWaitPart);

final _actionAsPlasmaShortcutActionPart =
    LensPart<TriggerAction, PlasmaShortcutAction>(
      get: (value) => value.action as PlasmaShortcutAction,
      set: (value, next) => value.copyWith(action: next),
      name: 'PlasmaShortcutAction',
    );

final _actionComponentPart = LensPart<PlasmaShortcutAction, String>(
  get: (value) => value.component,
  set: (value, next) => value.copyWith(component: next),
  name: 'component',
);

Lens<String> actionComponentLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsPlasmaShortcutActionPart).then(_actionComponentPart);

final _actionShortcutPart = LensPart<PlasmaShortcutAction, String>(
  get: (value) => value.shortcut,
  set: (value, next) => value.copyWith(shortcut: next),
  name: 'shortcut',
);

Lens<String> actionShortcutLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsPlasmaShortcutActionPart).then(_actionShortcutPart);

final _actionAsSleepActionPart = LensPart<TriggerAction, SleepAction>(
  get: (value) => value.action as SleepAction,
  set: (value, next) => value.copyWith(action: next),
  name: 'SleepAction',
);

final _actionDurationPart = LensPart<SleepAction, int>(
  get: (value) => value.milliseconds,
  set: (value, next) => value.copyWith(milliseconds: next),
  name: 'duration',
);

Lens<int> actionDurationLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsSleepActionPart).then(_actionDurationPart);

final _actionAsRawActionPart = LensPart<TriggerAction, RawAction>(
  get: (value) => value.action as RawAction,
  set: (value, next) => value.copyWith(action: next),
  name: 'RawAction',
);

final _actionRawPart = LensPart<RawAction, String>(
  get: (value) => value.raw,
  set: (value, next) => value.copyWith(raw: next),
  name: 'raw',
);

Lens<String> actionRawLens(ActionLocation location) => triggerActionLens(
  location,
).then(_actionAsRawActionPart).then(_actionRawPart);

final _actionTriggerOnPart = LensPart<TriggerAction, TriggerOn?>(
  get: (value) => value.on,
  set: (value, next) => value.copyWith(on: next),
  name: 'triggerOn',
);

Lens<TriggerOn?> actionTriggerOnLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionTriggerOnPart);

final _actionIntervalPart = LensPart<TriggerAction, String?>(
  get: (value) => value.interval,
  set: (value, next) => value.copyWith(interval: next),
  name: 'interval',
);

Lens<String?> actionIntervalLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionIntervalPart);

final _actionThresholdPart = LensPart<TriggerAction, String?>(
  get: (value) => value.threshold,
  set: (value, next) => value.copyWith(threshold: next),
  name: 'threshold',
);

Lens<String?> actionThresholdLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionThresholdPart);

final _actionLimitPart = LensPart<TriggerAction, int?>(
  get: (value) => value.limit,
  set: (value, next) => value.copyWith(limit: next),
  name: 'limit',
);

Lens<int?> actionLimitLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionLimitPart);

final _actionConflictingPart = LensPart<TriggerAction, bool>(
  get: (value) => value.conflicting,
  set: (value, next) => value.copyWith(conflicting: next),
  name: 'conflicting',
);

Lens<bool> actionConflictingLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionConflictingPart);

final _actionConditionsPart = LensPart<TriggerAction, Condition?>(
  get: (value) => value.conditions,
  set: (value, next) => value.copyWith(conditions: next),
  name: 'conditions',
);

Lens<Condition?> actionConditionsLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionConditionsPart);

final _actionAsInputActionPart = LensPart<TriggerAction, InputAction>(
  get: (value) => value.action as InputAction,
  set: (value, next) => value.copyWith(action: next),
  name: 'InputAction',
);

final _actionInputEntriesPart = LensPart<InputAction, List<InputEntry>>(
  get: (value) => value.entries,
  set: (value, next) => value.copyWith(entries: next),
  name: 'inputEntries',
);

Lens<List<InputEntry>> actionInputEntriesLens(ActionLocation location) =>
    triggerActionLens(
      location,
    ).then(_actionAsInputActionPart).then(_actionInputEntriesPart);

Object? comparableActionFieldValue(
  TriggerAction? value,
  ActionDirtyField field,
) => switch (field) {
  ActionDirtyField.command => switch (value) {
    null => null,
    _ => switch (value.action) {
      CommandAction() && final caseValue => caseValue.command,
      _ => null,
    },
  },
  ActionDirtyField.wait => switch (value) {
    null => null,
    _ => switch (value.action) {
      CommandAction() && final caseValue => caseValue.wait,
      _ => null,
    },
  },
  ActionDirtyField.component => switch (value) {
    null => null,
    _ => switch (value.action) {
      PlasmaShortcutAction() && final caseValue => caseValue.component,
      _ => null,
    },
  },
  ActionDirtyField.shortcut => switch (value) {
    null => null,
    _ => switch (value.action) {
      PlasmaShortcutAction() && final caseValue => caseValue.shortcut,
      _ => null,
    },
  },
  ActionDirtyField.duration => switch (value) {
    null => null,
    _ => switch (value.action) {
      SleepAction() && final caseValue => caseValue.milliseconds,
      _ => null,
    },
  },
  ActionDirtyField.raw => switch (value) {
    null => null,
    _ => switch (value.action) {
      RawAction() && final caseValue => caseValue.raw,
      _ => null,
    },
  },
  ActionDirtyField.triggerOn => value == null ? null : value.on,
  ActionDirtyField.interval => value == null ? null : value.interval,
  ActionDirtyField.threshold => value == null ? null : value.threshold,
  ActionDirtyField.limit => value == null ? null : value.limit,
  ActionDirtyField.conflicting => value == null ? null : value.conflicting,
  ActionDirtyField.conditions => value == null ? null : value.conditions,
  ActionDirtyField.inputEntries => switch (value) {
    null => null,
    _ => switch (value.action) {
      InputAction() && final caseValue => caseValue.entries,
      _ => null,
    },
  },
};

TriggerAction restoreActionField({
  required TriggerAction current,
  required TriggerAction saved,
  required ActionDirtyField field,
}) => switch (field) {
  ActionDirtyField.command => switch ((current.action, saved.action)) {
    (
      CommandAction() && final currentValue,
      CommandAction() && final savedValue,
    ) =>
      current.copyWith(
        action: currentValue.copyWith(command: savedValue.command),
      ),
    _ => current,
  },
  ActionDirtyField.wait => switch ((current.action, saved.action)) {
    (
      CommandAction() && final currentValue,
      CommandAction() && final savedValue,
    ) =>
      current.copyWith(action: currentValue.copyWith(wait: savedValue.wait)),
    _ => current,
  },
  ActionDirtyField.component => switch ((current.action, saved.action)) {
    (
      PlasmaShortcutAction() && final currentValue,
      PlasmaShortcutAction() && final savedValue,
    ) =>
      current.copyWith(
        action: currentValue.copyWith(component: savedValue.component),
      ),
    _ => current,
  },
  ActionDirtyField.shortcut => switch ((current.action, saved.action)) {
    (
      PlasmaShortcutAction() && final currentValue,
      PlasmaShortcutAction() && final savedValue,
    ) =>
      current.copyWith(
        action: currentValue.copyWith(shortcut: savedValue.shortcut),
      ),
    _ => current,
  },
  ActionDirtyField.duration => switch ((current.action, saved.action)) {
    (SleepAction() && final currentValue, SleepAction() && final savedValue) =>
      current.copyWith(
        action: currentValue.copyWith(milliseconds: savedValue.milliseconds),
      ),
    _ => current,
  },
  ActionDirtyField.raw => switch ((current.action, saved.action)) {
    (RawAction() && final currentValue, RawAction() && final savedValue) =>
      current.copyWith(action: currentValue.copyWith(raw: savedValue.raw)),
    _ => current,
  },
  ActionDirtyField.triggerOn => current.copyWith(on: saved.on),
  ActionDirtyField.interval => current.copyWith(interval: saved.interval),
  ActionDirtyField.threshold => current.copyWith(threshold: saved.threshold),
  ActionDirtyField.limit => current.copyWith(limit: saved.limit),
  ActionDirtyField.conflicting => current.copyWith(
    conflicting: saved.conflicting,
  ),
  ActionDirtyField.conditions => current.copyWith(conditions: saved.conditions),
  ActionDirtyField.inputEntries => switch ((current.action, saved.action)) {
    (InputAction() && final currentValue, InputAction() && final savedValue) =>
      current.copyWith(
        action: currentValue.copyWith(entries: savedValue.entries),
      ),
    _ => current,
  },
};

bool actionHasSavedBacking(TriggerAction? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: prefer_null_aware_operators

enum GestureDirtyField {
  id,
  threshold,
  resumeTimeout,
  accelerated,
  blockEvents,
  clearModifiers,
  setLastTrigger,
  conditions,
  endConditions,
  mouseButtons,
  mouseButtonsExactOrder,
  actions,
}

final _gestureIdPart = LensPart<TriggerCommon, String?>(
  get: (value) => value.id,
  set: (value, next) => value.copyWith(id: next),
  name: 'id',
);

Lens<String?> gestureIdLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureIdPart);

final _gestureThresholdPart = LensPart<TriggerCommon, String?>(
  get: (value) => value.threshold,
  set: (value, next) => value.copyWith(threshold: next),
  name: 'threshold',
);

Lens<String?> gestureThresholdLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureThresholdPart);

final _gestureResumeTimeoutPart = LensPart<TriggerCommon, int?>(
  get: (value) => value.resumeTimeout,
  set: (value, next) => value.copyWith(resumeTimeout: next),
  name: 'resumeTimeout',
);

Lens<int?> gestureResumeTimeoutLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureResumeTimeoutPart);

final _gestureAcceleratedPart = LensPart<TriggerCommon, bool?>(
  get: (value) => value.accelerated,
  set: (value, next) => value.copyWith(accelerated: next),
  name: 'accelerated',
);

Lens<bool?> gestureAcceleratedLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureAcceleratedPart);

final _gestureBlockEventsPart = LensPart<TriggerCommon, bool?>(
  get: (value) => value.blockEvents,
  set: (value, next) => value.copyWith(blockEvents: next),
  name: 'blockEvents',
);

Lens<bool?> gestureBlockEventsLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureBlockEventsPart);

final _gestureClearModifiersPart = LensPart<TriggerCommon, bool?>(
  get: (value) => value.clearModifiers,
  set: (value, next) => value.copyWith(clearModifiers: next),
  name: 'clearModifiers',
);

Lens<bool?> gestureClearModifiersLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureClearModifiersPart);

final _gestureSetLastTriggerPart = LensPart<TriggerCommon, bool?>(
  get: (value) => value.setLastTrigger,
  set: (value, next) => value.copyWith(setLastTrigger: next),
  name: 'setLastTrigger',
);

Lens<bool?> gestureSetLastTriggerLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureSetLastTriggerPart);

final _gestureConditionsPart = LensPart<TriggerCommon, Condition?>(
  get: (value) => value.conditions,
  set: (value, next) => value.copyWith(conditions: next),
  name: 'conditions',
);

Lens<Condition?> gestureConditionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureConditionsPart);

final _gestureEndConditionsPart = LensPart<TriggerCommon, Condition?>(
  get: (value) => value.endConditions,
  set: (value, next) => value.copyWith(endConditions: next),
  name: 'endConditions',
);

Lens<Condition?> gestureEndConditionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureEndConditionsPart);

final _gestureMouseButtonsPart =
    LensPart<TriggerCommon, List<MouseButtonValue>>(
      get: (value) => value.mouseButtons,
      set: (value, next) => value.copyWith(mouseButtons: next),
      name: 'mouseButtons',
    );

Lens<List<MouseButtonValue>> gestureMouseButtonsLens(
  GestureLocation location,
) => triggerCommonLens(location).then(_gestureMouseButtonsPart);

final _gestureMouseButtonsExactOrderPart = LensPart<TriggerCommon, bool>(
  get: (value) => value.mouseButtonsExactOrder,
  set: (value, next) => value.copyWith(mouseButtonsExactOrder: next),
  name: 'mouseButtonsExactOrder',
);

Lens<bool> gestureMouseButtonsExactOrderLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureMouseButtonsExactOrderPart);

final _gestureActionsPart = LensPart<TriggerCommon, List<TriggerAction>>(
  get: (value) => value.actions,
  set: (value, next) => value.copyWith(actions: next),
  name: 'actions',
);

Lens<List<TriggerAction>> gestureActionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(_gestureActionsPart);

Object? comparableGestureFieldValue(
  TriggerCommon? value,
  GestureDirtyField field,
) => switch (field) {
  GestureDirtyField.id => value == null ? null : value.id,
  GestureDirtyField.threshold => value == null ? null : value.threshold,
  GestureDirtyField.resumeTimeout => value == null ? null : value.resumeTimeout,
  GestureDirtyField.accelerated => value == null ? null : value.accelerated,
  GestureDirtyField.blockEvents => value == null ? null : value.blockEvents,
  GestureDirtyField.clearModifiers =>
    value == null ? null : value.clearModifiers,
  GestureDirtyField.setLastTrigger =>
    value == null ? null : value.setLastTrigger,
  GestureDirtyField.conditions => value == null ? null : value.conditions,
  GestureDirtyField.endConditions => value == null ? null : value.endConditions,
  GestureDirtyField.mouseButtons => value == null ? null : value.mouseButtons,
  GestureDirtyField.mouseButtonsExactOrder =>
    value == null ? null : value.mouseButtonsExactOrder,
  GestureDirtyField.actions => value == null ? null : value.actions,
};

TriggerCommon restoreGestureField({
  required TriggerCommon current,
  required TriggerCommon saved,
  required GestureDirtyField field,
}) => switch (field) {
  GestureDirtyField.id => current.copyWith(id: saved.id),
  GestureDirtyField.threshold => current.copyWith(threshold: saved.threshold),
  GestureDirtyField.resumeTimeout => current.copyWith(
    resumeTimeout: saved.resumeTimeout,
  ),
  GestureDirtyField.accelerated => current.copyWith(
    accelerated: saved.accelerated,
  ),
  GestureDirtyField.blockEvents => current.copyWith(
    blockEvents: saved.blockEvents,
  ),
  GestureDirtyField.clearModifiers => current.copyWith(
    clearModifiers: saved.clearModifiers,
  ),
  GestureDirtyField.setLastTrigger => current.copyWith(
    setLastTrigger: saved.setLastTrigger,
  ),
  GestureDirtyField.conditions => current.copyWith(
    conditions: saved.conditions,
  ),
  GestureDirtyField.endConditions => current.copyWith(
    endConditions: saved.endConditions,
  ),
  GestureDirtyField.mouseButtons => current.copyWith(
    mouseButtons: saved.mouseButtons,
  ),
  GestureDirtyField.mouseButtonsExactOrder => current.copyWith(
    mouseButtonsExactOrder: saved.mouseButtonsExactOrder,
  ),
  GestureDirtyField.actions => current.copyWith(actions: saved.actions),
};

bool gestureHasSavedBacking(TriggerCommon? saved) => saved != null;
