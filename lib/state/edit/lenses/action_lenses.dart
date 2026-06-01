import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/dirty/dirty_locations.dart';
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

const commandActionCommandPart = LensPart<CommandAction, String>(
  get: _getCommand,
  set: _setCommand,
  name: 'command',
);

const commandActionWaitPart = LensPart<CommandAction, bool?>(
  get: _getWait,
  set: _setWait,
  name: 'wait',
);

const plasmaShortcutComponentPart = LensPart<PlasmaShortcutAction, String>(
  get: _getComponent,
  set: _setComponent,
  name: 'component',
);

const plasmaShortcutShortcutPart = LensPart<PlasmaShortcutAction, String>(
  get: _getShortcut,
  set: _setShortcut,
  name: 'shortcut',
);

const sleepMillisecondsPart = LensPart<SleepAction, int>(
  get: _getMilliseconds,
  set: _setMilliseconds,
  name: 'milliseconds',
);

const rawActionRawPart = LensPart<RawAction, String>(
  get: _getRaw,
  set: _setRaw,
  name: 'raw',
);

const triggerOnPart = LensPart<TriggerAction, TriggerOn?>(
  get: _getTriggerOn,
  set: _setTriggerOn,
  name: 'triggerOn',
);

const intervalPart = LensPart<TriggerAction, String?>(
  get: _getInterval,
  set: _setInterval,
  name: 'interval',
);

const thresholdPart = LensPart<TriggerAction, String?>(
  get: _getThreshold,
  set: _setThreshold,
  name: 'threshold',
);

const limitPart = LensPart<TriggerAction, int?>(
  get: _getLimit,
  set: _setLimit,
  name: 'limit',
);

const conflictingPart = LensPart<TriggerAction, bool>(
  get: _getConflicting,
  set: _setConflicting,
  name: 'conflicting',
);

const conditionsPart = LensPart<TriggerAction, Condition?>(
  get: _getConditions,
  set: _setConditions,
  name: 'conditions',
);

const actionsPart = LensPart<TriggerCommon, List<TriggerAction>>(
  get: _getActions,
  set: _setActions,
  name: 'actions',
);

const _asCommandActionPart = LensPart<TriggerAction, CommandAction>(
  get: _asCommandAction,
  set: _setCommandAction,
  name: 'asCommand',
);

const _asPlasmaShortcutActionPart =
    LensPart<TriggerAction, PlasmaShortcutAction>(
      get: _asPlasmaShortcutAction,
      set: _setPlasmaShortcutAction,
      name: 'asPlasmaShortcut',
    );

const _asSleepActionPart = LensPart<TriggerAction, SleepAction>(
  get: _asSleepAction,
  set: _setSleepAction,
  name: 'asSleep',
);

const _asRawActionPart = LensPart<TriggerAction, RawAction>(
  get: _asRawAction,
  set: _setRawAction,
  name: 'asRaw',
);

const _asInputActionPart = LensPart<TriggerAction, InputAction>(
  get: _asInputAction,
  set: _setInputAction,
  name: 'asInput',
);

const inputEntriesPart = LensPart<InputAction, List<InputEntry>>(
  get: _getInputEntries,
  set: _setInputEntries,
  name: 'entries',
);

Lens<TriggerCommon> triggerCommonLens(GestureLocation location) =>
    Lens<TriggerCommon>(
      get: (config) => gestureCommonOf(gestureAt(config, location))!,
      set: (config, common) => replaceGestureCommonAt(config, location, common),
      name: 'gesture[${location.device.name}/${location.index}].common',
    );

Lens<TriggerAction> triggerActionLens(ActionLocation location) =>
    Lens<TriggerAction>(
      get: (config) => actionAt(config, location)!,
      set: (config, action) => replaceActionAt(config, location, action),
      name:
          'gesture[${location.gesture.device.name}/${location.gesture.index}]'
          '.action[${location.actionIndex}]',
    );

Lens<String> actionCommandLens(ActionLocation location) => triggerActionLens(
  location,
).then(_asCommandActionPart).then(commandActionCommandPart);

Lens<bool?> actionWaitLens(ActionLocation location) => triggerActionLens(
  location,
).then(_asCommandActionPart).then(commandActionWaitPart);

Lens<String> actionComponentLens(ActionLocation location) => triggerActionLens(
  location,
).then(_asPlasmaShortcutActionPart).then(plasmaShortcutComponentPart);

Lens<String> actionShortcutLens(ActionLocation location) => triggerActionLens(
  location,
).then(_asPlasmaShortcutActionPart).then(plasmaShortcutShortcutPart);

Lens<int> actionDurationLens(ActionLocation location) =>
    triggerActionLens(location)
        .then(_asSleepActionPart)
        .then(
          sleepMillisecondsPart,
        );

Lens<String> actionRawLens(ActionLocation location) =>
    triggerActionLens(location).then(_asRawActionPart).then(rawActionRawPart);

Lens<TriggerOn?> actionTriggerOnLens(ActionLocation location) =>
    triggerActionLens(location).then(triggerOnPart);

Lens<String?> actionIntervalLens(ActionLocation location) =>
    triggerActionLens(location).then(intervalPart);

Lens<String?> actionThresholdLens(ActionLocation location) =>
    triggerActionLens(location).then(thresholdPart);

Lens<int?> actionLimitLens(ActionLocation location) =>
    triggerActionLens(location).then(limitPart);

Lens<bool> actionConflictingLens(ActionLocation location) =>
    triggerActionLens(location).then(conflictingPart);

Lens<Condition?> actionConditionsLens(ActionLocation location) =>
    triggerActionLens(location).then(conditionsPart);

Lens<List<TriggerAction>> gestureActionsLens(GestureLocation location) =>
    triggerCommonLens(location).then(actionsPart);

Lens<List<InputEntry>> actionInputEntriesLens(ActionLocation location) =>
    triggerActionLens(location).then(_asInputActionPart).then(inputEntriesPart);

Config replaceActionAt(
  Config config,
  ActionLocation location,
  TriggerAction action,
) {
  final gesture = gestureAt(config, location.gesture);
  final common = gestureCommonOf(gesture);
  if (gesture == null || common == null) return config;
  if (location.actionIndex < 0 ||
      location.actionIndex >= common.actions.length) {
    return config;
  }
  final actions = List<TriggerAction>.of(common.actions);
  actions[location.actionIndex] = action;
  return _replaceGestureCommonAt(
    config,
    location.gesture,
    common.copyWith(actions: actions),
  );
}

Config replaceGestureCommonAt(
  Config config,
  GestureLocation location,
  TriggerCommon common,
) => _replaceGestureCommonAt(config, location, common);

String _getCommand(CommandAction action) => action.command;

CommandAction _setCommand(CommandAction action, String value) =>
    action.copyWith(command: value);

bool? _getWait(CommandAction action) => action.wait;

CommandAction _setWait(CommandAction action, bool? value) =>
    action.copyWith(wait: value);

CommandAction _asCommandAction(TriggerAction action) =>
    action.action as CommandAction;

TriggerAction _setCommandAction(TriggerAction trigger, CommandAction action) =>
    trigger.copyWith(action: action);

String _getComponent(PlasmaShortcutAction action) => action.component;

PlasmaShortcutAction _setComponent(
  PlasmaShortcutAction action,
  String value,
) => action.copyWith(component: value);

String _getShortcut(PlasmaShortcutAction action) => action.shortcut;

PlasmaShortcutAction _setShortcut(
  PlasmaShortcutAction action,
  String value,
) => action.copyWith(shortcut: value);

int _getMilliseconds(SleepAction action) => action.milliseconds;

SleepAction _setMilliseconds(SleepAction action, int value) =>
    action.copyWith(milliseconds: value);

String _getRaw(RawAction action) => action.raw;

RawAction _setRaw(RawAction action, String value) =>
    action.copyWith(raw: value);

TriggerOn? _getTriggerOn(TriggerAction action) => action.on;

TriggerAction _setTriggerOn(TriggerAction action, TriggerOn? value) =>
    action.copyWith(on: value);

String? _getInterval(TriggerAction action) => action.interval;

TriggerAction _setInterval(TriggerAction action, String? value) =>
    action.copyWith(interval: value);

String? _getThreshold(TriggerAction action) => action.threshold;

TriggerAction _setThreshold(TriggerAction action, String? value) =>
    action.copyWith(threshold: value);

int? _getLimit(TriggerAction action) => action.limit;

TriggerAction _setLimit(TriggerAction action, int? value) =>
    action.copyWith(limit: value);

bool _getConflicting(TriggerAction action) => action.conflicting;

TriggerAction _setConflicting(TriggerAction action, bool value) =>
    action.copyWith(conflicting: value);

Condition? _getConditions(TriggerAction action) => action.conditions;

TriggerAction _setConditions(TriggerAction action, Condition? value) =>
    action.copyWith(conditions: value);

List<TriggerAction> _getActions(TriggerCommon common) => common.actions;

TriggerCommon _setActions(TriggerCommon common, List<TriggerAction> value) =>
    common.copyWith(actions: value);

PlasmaShortcutAction _asPlasmaShortcutAction(TriggerAction action) =>
    action.action as PlasmaShortcutAction;

TriggerAction _setPlasmaShortcutAction(
  TriggerAction trigger,
  PlasmaShortcutAction action,
) => trigger.copyWith(action: action);

SleepAction _asSleepAction(TriggerAction action) =>
    action.action as SleepAction;

TriggerAction _setSleepAction(TriggerAction trigger, SleepAction action) =>
    trigger.copyWith(action: action);

RawAction _asRawAction(TriggerAction action) => action.action as RawAction;

TriggerAction _setRawAction(TriggerAction trigger, RawAction action) =>
    trigger.copyWith(action: action);

InputAction _asInputAction(TriggerAction action) =>
    action.action as InputAction;

TriggerAction _setInputAction(TriggerAction trigger, InputAction action) =>
    trigger.copyWith(action: action);

List<InputEntry> _getInputEntries(InputAction action) => action.entries;

InputAction _setInputEntries(InputAction action, List<InputEntry> value) =>
    action.copyWith(entries: value);

Config _replaceGestureCommonAt(
  Config config,
  GestureLocation location,
  TriggerCommon common,
) => switch (location.device) {
  DeviceType.mouse => _replaceAt<MouseGesture>(
    config,
    location.index,
    config.mouseGestures,
    (gesture) => gesture.withCommon(common),
    (gestures) => config.copyWith(mouseGestures: gestures),
  ),
  DeviceType.keyboard => _replaceAt<KeyboardGesture>(
    config,
    location.index,
    config.keyboardGestures,
    (gesture) => gesture.withCommon(common),
    (gestures) => config.copyWith(keyboardGestures: gestures),
  ),
  DeviceType.pointer => _replaceAt<PointerGesture>(
    config,
    location.index,
    config.pointerGestures,
    (gesture) => gesture.withCommon(common),
    (gestures) => config.copyWith(pointerGestures: gestures),
  ),
  DeviceType.touchpad => _replaceAt<TouchpadGesture>(
    config,
    location.index,
    config.touchpadGestures,
    (gesture) => gesture.withCommon(common),
    (gestures) => config.copyWith(touchpadGestures: gestures),
  ),
  DeviceType.touchscreen => _replaceAt<TouchscreenGesture>(
    config,
    location.index,
    config.touchscreenGestures,
    (gesture) => gesture.withCommon(common),
    (gestures) => config.copyWith(touchscreenGestures: gestures),
  ),
};

Config _replaceAt<T>(
  Config config,
  int index,
  List<T> source,
  T Function(T gesture) update,
  Config Function(List<T> gestures) setList,
) {
  if (index < 0 || index >= source.length) return config;
  final gestures = List<T>.of(source);
  gestures[index] = update(gestures[index]);
  return setList(gestures);
}
