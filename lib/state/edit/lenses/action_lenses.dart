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
import 'package:lens_geneartor/lens_geneartor.dart';

part 'action_lenses.g.dart';

@GenerateEditSchema()
final EditRoot<TriggerAction, ActionLocation> actionSchema =
    editRoot<TriggerAction, ActionLocation>(
      id: 'action',
      rootLens: 'triggerActionLens',
      savedBacking: SavedBackingSpec<TriggerAction>.rootExists(),
      fields: [
        field<TriggerAction, String>(
          id: 'command',
          select: unionField<TriggerAction, CommandAction, String>(
            getCase: (value) => value.action,
          ),
        ),
        field<TriggerAction, bool?>(
          id: 'wait',
          select: unionField<TriggerAction, CommandAction, bool?>(
            getCase: (value) => value.action,
          ),
        ),
        field<TriggerAction, String>(
          id: 'component',
          select: unionField<TriggerAction, PlasmaShortcutAction, String>(
            getCase: (value) => value.action,
          ),
        ),
        field<TriggerAction, String>(
          id: 'shortcut',
          select: unionField<TriggerAction, PlasmaShortcutAction, String>(
            getCase: (value) => value.action,
          ),
        ),
        field<TriggerAction, int>(
          id: 'duration',
          select: unionField<TriggerAction, SleepAction, int>(
            getCase: (value) => value.action,
            fieldName: 'milliseconds',
          ),
        ),
        field<TriggerAction, String>(
          id: 'raw',
          select: unionField<TriggerAction, RawAction, String>(
            getCase: (value) => value.action,
          ),
        ),
        field<TriggerAction, TriggerOn?>(
          id: 'triggerOn',
          select: leaf<TriggerAction, TriggerOn?>(fieldName: 'on'),
        ),
        field<TriggerAction, String?>(
          id: 'interval',
          select: leaf<TriggerAction, String?>(),
        ),
        field<TriggerAction, String?>(
          id: 'threshold',
          select: leaf<TriggerAction, String?>(),
        ),
        field<TriggerAction, int?>(
          id: 'limit',
          select: leaf<TriggerAction, int?>(),
        ),
        field<TriggerAction, bool>(
          id: 'conflicting',
          select: leaf<TriggerAction, bool>(),
        ),
        field<TriggerAction, Condition?>(
          id: 'conditions',
          select: leaf<TriggerAction, Condition?>(),
        ),
        field<TriggerAction, List<InputEntry>>(
          id: 'inputEntries',
          select: unionField<TriggerAction, InputAction, List<InputEntry>>(
            getCase: (value) => value.action,
            fieldName: 'entries',
          ),
        ),
      ],
    );

@GenerateEditSchema()
final EditRoot<TriggerCommon, GestureLocation> gestureSchema =
    editRoot<TriggerCommon, GestureLocation>(
      id: 'gesture',
      rootLens: 'triggerCommonLens',
      savedBacking: SavedBackingSpec<TriggerCommon>.rootExists(),
      fields: [
        field<TriggerCommon, String?>(
          id: 'id',
          select: leaf<TriggerCommon, String?>(),
        ),
        field<TriggerCommon, String?>(
          id: 'threshold',
          select: leaf<TriggerCommon, String?>(),
        ),
        field<TriggerCommon, int?>(
          id: 'resumeTimeout',
          select: leaf<TriggerCommon, int?>(),
        ),
        field<TriggerCommon, bool?>(
          id: 'accelerated',
          select: leaf<TriggerCommon, bool?>(),
        ),
        field<TriggerCommon, bool?>(
          id: 'blockEvents',
          select: leaf<TriggerCommon, bool?>(),
        ),
        field<TriggerCommon, bool?>(
          id: 'clearModifiers',
          select: leaf<TriggerCommon, bool?>(),
        ),
        field<TriggerCommon, bool?>(
          id: 'setLastTrigger',
          select: leaf<TriggerCommon, bool?>(),
        ),
        field<TriggerCommon, Condition?>(
          id: 'conditions',
          select: leaf<TriggerCommon, Condition?>(),
        ),
        field<TriggerCommon, Condition?>(
          id: 'endConditions',
          select: leaf<TriggerCommon, Condition?>(),
        ),
        field<TriggerCommon, List<MouseButtonValue>>(
          id: 'mouseButtons',
          select: leaf<TriggerCommon, List<MouseButtonValue>>(),
        ),
        field<TriggerCommon, bool>(
          id: 'mouseButtonsExactOrder',
          select: leaf<TriggerCommon, bool>(),
        ),
        field<TriggerCommon, List<TriggerAction>>(
          id: 'actions',
          select: leaf<TriggerCommon, List<TriggerAction>>(),
        ),
      ],
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
