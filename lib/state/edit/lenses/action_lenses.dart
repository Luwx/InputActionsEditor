import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
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
final EditSchema<TriggerAction, ActionLocation> actionSchema =
    editSchema<TriggerAction, ActionLocation>(
      id: 'action',
      rootLens: 'triggerActionLens',
      fields: [
        union<CommandAction>(
          'action',
          fields: [
            prop<dynamic, String>('command'),
            prop<TriggerAction, bool?>(
              'wait',
              compare: projected<TriggerAction, bool?>(
                (value) => value?.action is CommandAction
                    ? (value!.action as CommandAction).effectiveWait
                    : null,
              ),
            ),
          ],
        ),
        union<PlasmaShortcutAction>(
          'action',
          fields: [
            prop<dynamic, String>('component'),
            prop<dynamic, String>('shortcut'),
          ],
        ),
        union<SleepAction>(
          'action',
          fields: [
            prop<dynamic, int>('duration', property: 'milliseconds'),
          ],
        ),
        union<RawAction>('action', fields: [prop<dynamic, String>('raw')]),
        union<InputAction>(
          'action',
          fields: [
            prop<dynamic, List<InputEntry>>(
              'inputEntries',
              property: 'entries',
            ),
          ],
        ),
        prop<TriggerAction, TriggerOn?>('triggerOn', property: 'on'),
        prop<TriggerAction, String?>('interval', adapter: nullableText()),
        prop<TriggerAction, String?>('threshold', adapter: nullableText()),
        prop<TriggerAction, int?>('limit', adapter: nullableInt()),
        prop<TriggerAction, bool>('conflicting'),
        prop<TriggerAction, Condition?>('conditions'),
        prop<TriggerAction, String?>('id', adapter: nullableText()),
      ],
      groups: [
        editGroup(
          id: 'all',
          members: [
            'triggerOn',
            'command',
            'wait',
            'component',
            'shortcut',
            'duration',
            'raw',
            'inputEntries',
            'conditions',
            'interval',
            'threshold',
            'conflicting',
            'id',
            'limit',
          ],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<TriggerCommon, GestureLocation> gestureSchema =
    editSchema<TriggerCommon, GestureLocation>(
      id: 'gesture',
      rootLens: 'triggerCommonLens',
      fields: [
        prop<TriggerCommon, String?>('id', adapter: nullableText()),
        prop<TriggerCommon, String?>('threshold', adapter: nullableText()),
        prop<TriggerCommon, int?>('resumeTimeout', adapter: nullableInt()),
        prop<TriggerCommon, bool?>(
          'accelerated',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveAccelerated,
          ),
        ),
        prop<TriggerCommon, bool?>(
          'blockEvents',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveBlockEvents,
          ),
        ),
        prop<TriggerCommon, bool?>(
          'clearModifiers',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveClearModifiers,
          ),
        ),
        prop<TriggerCommon, bool?>(
          'setLastTrigger',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveSetLastTrigger,
          ),
        ),
        prop<TriggerCommon, Condition?>('conditions'),
        prop<TriggerCommon, Condition?>('endConditions'),
        prop<TriggerCommon, List<MouseButtonValue>>('mouseButtons'),
        prop<TriggerCommon, bool>('mouseButtonsExactOrder'),
        prop<TriggerCommon, List<TriggerAction>>('actions'),
      ],
      groups: [
        editGroup(
          id: 'mouseButtonsSection',
          members: ['mouseButtons', 'mouseButtonsExactOrder'],
        ),
        editGroup(id: 'triggerConditions', members: ['conditions']),
        editGroup(id: 'actionsSection', members: ['actions']),
        editGroup(
          id: 'triggerConfig',
          members: [
            'mouseButtons',
            'mouseButtonsExactOrder',
            'conditions',
            'id',
            'threshold',
            'resumeTimeout',
            'accelerated',
            'blockEvents',
            'clearModifiers',
            'setLastTrigger',
            'endConditions',
          ],
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
