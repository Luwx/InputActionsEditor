// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_lenses.dart';

// **************************************************************************
// EditSchemaSourceGenerator
// **************************************************************************

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

enum ActionDirtyField {
  command,
  wait,
  component,
  shortcut,
  duration,
  raw,
  inputEntries,
  triggerOn,
  interval,
  threshold,
  limit,
  conflicting,
  conditions,
  id,
}

enum ActionDirtyGroup { all }

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

final _actionIdPart = LensPart<TriggerAction, String?>(
  get: (value) => value.id,
  set: (value, next) => value.copyWith(id: next),
  name: 'id',
);

Lens<String?> actionIdLens(ActionLocation location) =>
    triggerActionLens(location).then(_actionIdPart);

final actionCommandField =
    GeneratedEditField<TriggerAction, ActionLocation, String, Lens<String>>(
      id: 'command',
      dirtyField: ActionDirtyField.command,
      lens: actionCommandLens,
      fallback: (value) => switch (value.action) {
        CommandAction() && final caseValue => caseValue.command,
        _ => throw StateError('Fallback unavailable for field command'),
      },
      adapter: FieldAdapterSpec<String>.identity(),
    );

final actionWaitField =
    GeneratedEditField<TriggerAction, ActionLocation, bool?, Lens<bool?>>(
      id: 'wait',
      dirtyField: ActionDirtyField.wait,
      lens: actionWaitLens,
      fallback: (value) => switch (value.action) {
        CommandAction() && final caseValue => caseValue.wait,
        _ => throw StateError('Fallback unavailable for field wait'),
      },
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final actionComponentField =
    GeneratedEditField<TriggerAction, ActionLocation, String, Lens<String>>(
      id: 'component',
      dirtyField: ActionDirtyField.component,
      lens: actionComponentLens,
      fallback: (value) => switch (value.action) {
        PlasmaShortcutAction() && final caseValue => caseValue.component,
        _ => throw StateError('Fallback unavailable for field component'),
      },
      adapter: FieldAdapterSpec<String>.identity(),
    );

final actionShortcutField =
    GeneratedEditField<TriggerAction, ActionLocation, String, Lens<String>>(
      id: 'shortcut',
      dirtyField: ActionDirtyField.shortcut,
      lens: actionShortcutLens,
      fallback: (value) => switch (value.action) {
        PlasmaShortcutAction() && final caseValue => caseValue.shortcut,
        _ => throw StateError('Fallback unavailable for field shortcut'),
      },
      adapter: FieldAdapterSpec<String>.identity(),
    );

final actionDurationField =
    GeneratedEditField<TriggerAction, ActionLocation, int, Lens<int>>(
      id: 'duration',
      dirtyField: ActionDirtyField.duration,
      lens: actionDurationLens,
      fallback: (value) => switch (value.action) {
        SleepAction() && final caseValue => caseValue.milliseconds,
        _ => throw StateError('Fallback unavailable for field duration'),
      },
      adapter: FieldAdapterSpec<int>.identity(),
    );

final actionRawField =
    GeneratedEditField<TriggerAction, ActionLocation, String, Lens<String>>(
      id: 'raw',
      dirtyField: ActionDirtyField.raw,
      lens: actionRawLens,
      fallback: (value) => switch (value.action) {
        RawAction() && final caseValue => caseValue.raw,
        _ => throw StateError('Fallback unavailable for field raw'),
      },
      adapter: FieldAdapterSpec<String>.identity(),
    );

final actionInputEntriesField =
    GeneratedEditField<
      TriggerAction,
      ActionLocation,
      List<InputEntry>,
      Lens<List<InputEntry>>
    >(
      id: 'inputEntries',
      dirtyField: ActionDirtyField.inputEntries,
      lens: actionInputEntriesLens,
      fallback: (value) => switch (value.action) {
        InputAction() && final caseValue => caseValue.entries,
        _ => throw StateError('Fallback unavailable for field inputEntries'),
      },
      adapter: FieldAdapterSpec<List<InputEntry>>.identity(),
    );

final actionTriggerOnField =
    GeneratedEditField<
      TriggerAction,
      ActionLocation,
      TriggerOn?,
      Lens<TriggerOn?>
    >(
      id: 'triggerOn',
      dirtyField: ActionDirtyField.triggerOn,
      lens: actionTriggerOnLens,
      fallback: (value) => value.on,
      adapter: FieldAdapterSpec<TriggerOn?>.identity(),
    );

final actionIntervalField =
    GeneratedEditField<TriggerAction, ActionLocation, String?, Lens<String?>>(
      id: 'interval',
      dirtyField: ActionDirtyField.interval,
      lens: actionIntervalLens,
      fallback: (value) => value.interval,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

final actionThresholdField =
    GeneratedEditField<TriggerAction, ActionLocation, String?, Lens<String?>>(
      id: 'threshold',
      dirtyField: ActionDirtyField.threshold,
      lens: actionThresholdLens,
      fallback: (value) => value.threshold,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

final actionLimitField =
    GeneratedEditField<TriggerAction, ActionLocation, int?, Lens<int?>>(
      id: 'limit',
      dirtyField: ActionDirtyField.limit,
      lens: actionLimitLens,
      fallback: (value) => value.limit,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final actionConflictingField =
    GeneratedEditField<TriggerAction, ActionLocation, bool, Lens<bool>>(
      id: 'conflicting',
      dirtyField: ActionDirtyField.conflicting,
      lens: actionConflictingLens,
      fallback: (value) => value.conflicting,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

final actionConditionsField =
    GeneratedEditField<
      TriggerAction,
      ActionLocation,
      Condition?,
      Lens<Condition?>
    >(
      id: 'conditions',
      dirtyField: ActionDirtyField.conditions,
      lens: actionConditionsLens,
      fallback: (value) => value.conditions,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

final actionIdField =
    GeneratedEditField<TriggerAction, ActionLocation, String?, Lens<String?>>(
      id: 'id',
      dirtyField: ActionDirtyField.id,
      lens: actionIdLens,
      fallback: (value) => value.id,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

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
  ActionDirtyField.wait =>
    value?.action is CommandAction
        ? (value!.action as CommandAction).effectiveWait
        : null,
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
  ActionDirtyField.inputEntries => switch (value) {
    null => null,
    _ => switch (value.action) {
      InputAction() && final caseValue => caseValue.entries,
      _ => null,
    },
  },
  ActionDirtyField.triggerOn => value == null ? null : value.on,
  ActionDirtyField.interval => value == null ? null : value.interval,
  ActionDirtyField.threshold => value == null ? null : value.threshold,
  ActionDirtyField.limit => value == null ? null : value.limit,
  ActionDirtyField.conflicting => value == null ? null : value.conflicting,
  ActionDirtyField.conditions => value == null ? null : value.conditions,
  ActionDirtyField.id => value == null ? null : value.id,
};

Object? comparableActionGroupValue(
  TriggerAction? value,
  ActionDirtyGroup group,
) => switch (group) {
  ActionDirtyGroup.all => [
    comparableActionFieldValue(value, ActionDirtyField.triggerOn),
    comparableActionFieldValue(value, ActionDirtyField.command),
    comparableActionFieldValue(value, ActionDirtyField.wait),
    comparableActionFieldValue(value, ActionDirtyField.component),
    comparableActionFieldValue(value, ActionDirtyField.shortcut),
    comparableActionFieldValue(value, ActionDirtyField.duration),
    comparableActionFieldValue(value, ActionDirtyField.raw),
    comparableActionFieldValue(value, ActionDirtyField.inputEntries),
    comparableActionFieldValue(value, ActionDirtyField.conditions),
    comparableActionFieldValue(value, ActionDirtyField.interval),
    comparableActionFieldValue(value, ActionDirtyField.threshold),
    comparableActionFieldValue(value, ActionDirtyField.conflicting),
    comparableActionFieldValue(value, ActionDirtyField.id),
    comparableActionFieldValue(value, ActionDirtyField.limit),
  ],
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
  ActionDirtyField.inputEntries => switch ((current.action, saved.action)) {
    (InputAction() && final currentValue, InputAction() && final savedValue) =>
      current.copyWith(
        action: currentValue.copyWith(entries: savedValue.entries),
      ),
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
  ActionDirtyField.id => current.copyWith(id: saved.id),
};

bool actionHasSavedBacking(TriggerAction? saved) => saved != null;

// Generated code. Do not modify by hand.
// ignore_for_file: dead_code, prefer_null_aware_operators, lines_longer_than_80_chars, unnecessary_cast, unnecessary_lambdas, unnecessary_parenthesis, unreachable_switch_case

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

enum GestureDirtyGroup {
  mouseButtonsSection,
  triggerConditions,
  actionsSection,
  triggerConfig,
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

final gestureIdField =
    GeneratedEditField<TriggerCommon, GestureLocation, String?, Lens<String?>>(
      id: 'id',
      dirtyField: GestureDirtyField.id,
      lens: gestureIdLens,
      fallback: (value) => value.id,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

final gestureThresholdField =
    GeneratedEditField<TriggerCommon, GestureLocation, String?, Lens<String?>>(
      id: 'threshold',
      dirtyField: GestureDirtyField.threshold,
      lens: gestureThresholdLens,
      fallback: (value) => value.threshold,
      adapter: FieldAdapterSpec<String?>.nullableText(),
    );

final gestureResumeTimeoutField =
    GeneratedEditField<TriggerCommon, GestureLocation, int?, Lens<int?>>(
      id: 'resumeTimeout',
      dirtyField: GestureDirtyField.resumeTimeout,
      lens: gestureResumeTimeoutLens,
      fallback: (value) => value.resumeTimeout,
      adapter: FieldAdapterSpec<int?>.nullableInt(),
    );

final gestureAcceleratedField =
    GeneratedEditField<TriggerCommon, GestureLocation, bool?, Lens<bool?>>(
      id: 'accelerated',
      dirtyField: GestureDirtyField.accelerated,
      lens: gestureAcceleratedLens,
      fallback: (value) => value.accelerated,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final gestureBlockEventsField =
    GeneratedEditField<TriggerCommon, GestureLocation, bool?, Lens<bool?>>(
      id: 'blockEvents',
      dirtyField: GestureDirtyField.blockEvents,
      lens: gestureBlockEventsLens,
      fallback: (value) => value.blockEvents,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final gestureClearModifiersField =
    GeneratedEditField<TriggerCommon, GestureLocation, bool?, Lens<bool?>>(
      id: 'clearModifiers',
      dirtyField: GestureDirtyField.clearModifiers,
      lens: gestureClearModifiersLens,
      fallback: (value) => value.clearModifiers,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final gestureSetLastTriggerField =
    GeneratedEditField<TriggerCommon, GestureLocation, bool?, Lens<bool?>>(
      id: 'setLastTrigger',
      dirtyField: GestureDirtyField.setLastTrigger,
      lens: gestureSetLastTriggerLens,
      fallback: (value) => value.setLastTrigger,
      adapter: FieldAdapterSpec<bool?>.identity(),
    );

final gestureConditionsField =
    GeneratedEditField<
      TriggerCommon,
      GestureLocation,
      Condition?,
      Lens<Condition?>
    >(
      id: 'conditions',
      dirtyField: GestureDirtyField.conditions,
      lens: gestureConditionsLens,
      fallback: (value) => value.conditions,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

final gestureEndConditionsField =
    GeneratedEditField<
      TriggerCommon,
      GestureLocation,
      Condition?,
      Lens<Condition?>
    >(
      id: 'endConditions',
      dirtyField: GestureDirtyField.endConditions,
      lens: gestureEndConditionsLens,
      fallback: (value) => value.endConditions,
      adapter: FieldAdapterSpec<Condition?>.identity(),
    );

final gestureMouseButtonsField =
    GeneratedEditField<
      TriggerCommon,
      GestureLocation,
      List<MouseButtonValue>,
      Lens<List<MouseButtonValue>>
    >(
      id: 'mouseButtons',
      dirtyField: GestureDirtyField.mouseButtons,
      lens: gestureMouseButtonsLens,
      fallback: (value) => value.mouseButtons,
      adapter: FieldAdapterSpec<List<MouseButtonValue>>.identity(),
    );

final gestureMouseButtonsExactOrderField =
    GeneratedEditField<TriggerCommon, GestureLocation, bool, Lens<bool>>(
      id: 'mouseButtonsExactOrder',
      dirtyField: GestureDirtyField.mouseButtonsExactOrder,
      lens: gestureMouseButtonsExactOrderLens,
      fallback: (value) => value.mouseButtonsExactOrder,
      adapter: FieldAdapterSpec<bool>.identity(),
    );

final gestureActionsField =
    GeneratedEditField<
      TriggerCommon,
      GestureLocation,
      List<TriggerAction>,
      Lens<List<TriggerAction>>
    >(
      id: 'actions',
      dirtyField: GestureDirtyField.actions,
      lens: gestureActionsLens,
      fallback: (value) => value.actions,
      adapter: FieldAdapterSpec<List<TriggerAction>>.identity(),
    );

Object? comparableGestureFieldValue(
  TriggerCommon? value,
  GestureDirtyField field,
) => switch (field) {
  GestureDirtyField.id => value == null ? null : value.id,
  GestureDirtyField.threshold => value == null ? null : value.threshold,
  GestureDirtyField.resumeTimeout => value == null ? null : value.resumeTimeout,
  GestureDirtyField.accelerated => value?.effectiveAccelerated,
  GestureDirtyField.blockEvents => value?.effectiveBlockEvents,
  GestureDirtyField.clearModifiers => value?.effectiveClearModifiers,
  GestureDirtyField.setLastTrigger => value?.effectiveSetLastTrigger,
  GestureDirtyField.conditions => value == null ? null : value.conditions,
  GestureDirtyField.endConditions => value == null ? null : value.endConditions,
  GestureDirtyField.mouseButtons => value == null ? null : value.mouseButtons,
  GestureDirtyField.mouseButtonsExactOrder =>
    value == null ? null : value.mouseButtonsExactOrder,
  GestureDirtyField.actions => value == null ? null : value.actions,
};

Object? comparableGestureGroupValue(
  TriggerCommon? value,
  GestureDirtyGroup group,
) => switch (group) {
  GestureDirtyGroup.mouseButtonsSection => [
    comparableGestureFieldValue(value, GestureDirtyField.mouseButtons),
    comparableGestureFieldValue(
      value,
      GestureDirtyField.mouseButtonsExactOrder,
    ),
  ],
  GestureDirtyGroup.triggerConditions => [
    comparableGestureFieldValue(value, GestureDirtyField.conditions),
  ],
  GestureDirtyGroup.actionsSection => [
    comparableGestureFieldValue(value, GestureDirtyField.actions),
  ],
  GestureDirtyGroup.triggerConfig => [
    comparableGestureFieldValue(value, GestureDirtyField.mouseButtons),
    comparableGestureFieldValue(
      value,
      GestureDirtyField.mouseButtonsExactOrder,
    ),
    comparableGestureFieldValue(value, GestureDirtyField.conditions),
    comparableGestureFieldValue(value, GestureDirtyField.id),
    comparableGestureFieldValue(value, GestureDirtyField.threshold),
    comparableGestureFieldValue(value, GestureDirtyField.resumeTimeout),
    comparableGestureFieldValue(value, GestureDirtyField.accelerated),
    comparableGestureFieldValue(value, GestureDirtyField.blockEvents),
    comparableGestureFieldValue(value, GestureDirtyField.clearModifiers),
    comparableGestureFieldValue(value, GestureDirtyField.setLastTrigger),
    comparableGestureFieldValue(value, GestureDirtyField.endConditions),
  ],
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
