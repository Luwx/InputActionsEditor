// Single source of truth for the config edit/dirty schema: every
// @GenerateEditSchema definition plus the hand-written lenses and helpers
// that compose them. Generated into config_schema.g.dart.

import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
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
import 'package:input_actions_editor/state/dirty/dirty_model_access.dart';
import 'package:input_actions_editor/state/edit/lens.dart';
import 'package:lens_geneartor/lens_geneartor.dart';

part 'config_schema.g.dart';

// ============================================================================
// Config root (dirty projection only)
// ============================================================================

/// Root-level dirty fields for the whole [Config]. These are comparison-only
/// (`readOnly`): editing happens through the per-property lenses in
/// `settings_lenses.dart`; this schema only describes how each section is
/// projected for dirty comparison and when it has a saved backing.
@GenerateEditSchema()
final EditSchema<Config, void> rootConfigSchema = editSchema<Config, void>(
  id: 'rootConfig',
  fields: [
    prop(
      'deviceRules',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.deviceRules ?? const <DeviceRule>[],
      ),
      backing: backedWhen<Config>((value) => value.deviceRules.isNotEmpty),
    ),
    prop(
      'effectGeneral',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => [
          value?.globalSettings.effectiveAutoreload,
          value?.globalSettings.effectiveExternalVariableAccess,
        ],
      ),
    ),
    prop(
      'effectNotifications',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.globalSettings.effectiveNotificationsConfigError,
      ),
    ),
    prop(
      'effectEmergencyCombination',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => value?.globalSettings.emergencyCombination,
      ),
    ),
    prop(
      'mouseDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.mouse)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.mouse) != null,
      ),
    ),
    prop(
      'keyboardDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.keyboard)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.keyboard) != null,
      ),
    ),
    prop(
      'touchpadDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.touchpad)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.touchpad) != null,
      ),
    ),
    prop(
      'touchscreenDeviceProperties',
      readOnly: true,
      compare: projected<Config, Object?>(
        (value) => defaultDeviceRule(value, DeviceType.touchscreen)?.properties,
      ),
      backing: backedWhen<Config>(
        (value) => defaultDeviceRule(value, DeviceType.touchscreen) != null,
      ),
    ),
    prop(
      'mouseSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.mouseSpeed),
      backing: backedWhen<Config>((value) => value.mouseSpeed != null),
    ),
    prop(
      'touchpadSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.touchpadSpeed),
      backing: backedWhen<Config>((value) => value.touchpadSpeed != null),
    ),
    prop(
      'touchscreenSpeed',
      readOnly: true,
      compare: projected<Config, Object?>((value) => value?.touchscreenSpeed),
      backing: backedWhen<Config>((value) => value.touchscreenSpeed != null),
    ),
  ],
);

// ============================================================================
// Actions and per-gesture TriggerCommon
// ============================================================================

@GenerateEditSchema()
final EditSchema<TriggerAction, ActionLocation> actionSchema =
    editSchema<TriggerAction, ActionLocation>(
      id: 'action',
      rootLens: 'triggerActionLens',
      fields: [
        union<CommandAction>(
          'action',
          fields: [
            prop('command'),
            prop(
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
            prop('component'),
            prop('shortcut'),
          ],
        ),
        union<SleepAction>(
          'action',
          fields: [
            prop('duration', property: 'milliseconds'),
          ],
        ),
        union<RawAction>('action', fields: [prop('raw')]),
        union<InputAction>(
          'action',
          fields: [
            prop(
              'inputEntries',
              property: 'entries',
            ),
          ],
        ),
        prop('triggerOn', property: 'on'),
        prop('interval', adapter: nullableText()),
        prop('threshold', adapter: nullableText()),
        prop('limit', adapter: nullableInt()),
        prop('conflicting'),
        prop('conditions'),
        prop('id', adapter: nullableText()),
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
        prop('id', adapter: nullableText()),
        prop('threshold', adapter: nullableText()),
        prop('resumeTimeout', adapter: nullableInt()),
        prop(
          'accelerated',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveAccelerated,
          ),
        ),
        prop(
          'blockEvents',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveBlockEvents,
          ),
        ),
        prop(
          'clearModifiers',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveClearModifiers,
          ),
        ),
        prop(
          'setLastTrigger',
          compare: projected<TriggerCommon, bool?>(
            (value) => value?.effectiveSetLastTrigger,
          ),
        ),
        prop('conditions'),
        prop('endConditions'),
        prop('mouseButtons'),
        prop('mouseButtonsExactOrder'),
        prop('actions'),
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

// Guarded copy-on-write list helpers for each per-device gesture list on
// [Config]: replace/update/add/insert/remove/duplicate/move{Device}GestureAt.
@GenerateEditSchema()
final ListSchema<Config, MouseGesture> mouseGestureList =
    listSchema<Config, MouseGesture>(
      property: 'mouseGestures',
      id: 'mouseGesture',
    );

@GenerateEditSchema()
final ListSchema<Config, KeyboardGesture> keyboardGestureList =
    listSchema<Config, KeyboardGesture>(
      property: 'keyboardGestures',
      id: 'keyboardGesture',
    );

@GenerateEditSchema()
final ListSchema<Config, PointerGesture> pointerGestureList =
    listSchema<Config, PointerGesture>(
      property: 'pointerGestures',
      id: 'pointerGesture',
    );

@GenerateEditSchema()
final ListSchema<Config, TouchpadGesture> touchpadGestureList =
    listSchema<Config, TouchpadGesture>(
      property: 'touchpadGestures',
      id: 'touchpadGesture',
    );

@GenerateEditSchema()
final ListSchema<Config, TouchscreenGesture> touchscreenGestureList =
    listSchema<Config, TouchscreenGesture>(
      property: 'touchscreenGestures',
      id: 'touchscreenGesture',
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
  DeviceType.mouse => updateMouseGestureAt(
    config,
    location.index,
    (gesture) => gesture.withCommon(common),
  ),
  DeviceType.keyboard => updateKeyboardGestureAt(
    config,
    location.index,
    (gesture) => gesture.withCommon(common),
  ),
  DeviceType.pointer => updatePointerGestureAt(
    config,
    location.index,
    (gesture) => gesture.withCommon(common),
  ),
  DeviceType.touchpad => updateTouchpadGestureAt(
    config,
    location.index,
    (gesture) => gesture.withCommon(common),
  ),
  DeviceType.touchscreen => updateTouchscreenGestureAt(
    config,
    location.index,
    (gesture) => gesture.withCommon(common),
  ),
};

// ============================================================================
// Per-device gesture schemas + gesture root lenses
// ============================================================================

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> pressSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'press',
      rootLens: 'mouseGestureLens',
      fields: [
        union<PressGesture>('self', fields: [prop('instant')]),
      ],
    );

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> wheelSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'wheel',
      rootLens: 'mouseGestureLens',
      fields: [
        union<WheelGesture>('self', fields: [prop('direction')]),
      ],
    );

@GenerateEditSchema()
final EditSchema<MouseGesture, GestureLocation> circleSchema =
    editSchema<MouseGesture, GestureLocation>(
      id: 'circle',
      rootLens: 'mouseGestureLens',
      fields: [
        union<CircleGesture>('self', fields: [prop('direction')]),
      ],
    );

@GenerateEditSchema()
final EditSchema<KeyboardGesture, GestureLocation> shortcutSchema =
    editSchema<KeyboardGesture, GestureLocation>(
      id: 'shortcut',
      rootLens: 'keyboardGestureLens',
      fields: [
        union<ShortcutGesture>('self', fields: [prop('keys')]),
      ],
    );

@GenerateEditSchema()
final EditSchema<TouchpadGesture, GestureLocation> touchpadSchema =
    editSchema<TouchpadGesture, GestureLocation>(
      id: 'touchpad',
      rootLens: 'touchpadGestureLens',
      fields: [
        prop(
          'fingers',
          select: lens(
            get: _getTouchpadFingers,
            set: (value, next) => value.withFingers(next),
          ),
        ),
        prop(
          'motion',
          select: lens(get: _getTouchpadMotion, set: _setTouchpadMotion),
        ),
        union<TouchpadSwipeGesture>(
          'self',
          fields: [prop('swipeMode', property: 'mode')],
        ),
        union<TouchpadPinchGesture>(
          'self',
          fields: [prop('pinchDirection', property: 'direction')],
        ),
        union<TouchpadRotateGesture>(
          'self',
          fields: [prop('rotateDirection', property: 'direction')],
        ),
        union<TouchpadCircleGesture>(
          'self',
          fields: [prop('circleDirection', property: 'direction')],
        ),
        union<TouchpadStrokeGesture>(
          'self',
          fields: [prop('strokeStrokes', property: 'strokes')],
        ),
      ],
    );

@GenerateEditSchema()
final EditSchema<TouchscreenGesture, GestureLocation> touchscreenSchema =
    editSchema<TouchscreenGesture, GestureLocation>(
      id: 'touchscreen',
      rootLens: 'touchscreenGestureLens',
      fields: [
        prop(
          'fingers',
          select: lens(
            get: _getTouchscreenFingers,
            set: (value, next) => value.withFingers(next),
          ),
        ),
        prop(
          'motion',
          select: lens(get: _getTouchscreenMotion, set: _setTouchscreenMotion),
        ),
        union<TouchscreenSwipeGesture>(
          'self',
          fields: [prop('swipeMode', property: 'mode')],
        ),
        union<TouchscreenPinchGesture>(
          'self',
          fields: [prop('pinchDirection', property: 'direction')],
        ),
        union<TouchscreenRotateGesture>(
          'self',
          fields: [prop('rotateDirection', property: 'direction')],
        ),
        union<TouchscreenCircleGesture>(
          'self',
          fields: [prop('circleDirection', property: 'direction')],
        ),
        union<TouchscreenStrokeGesture>(
          'self',
          fields: [prop('strokeStrokes', property: 'strokes')],
        ),
      ],
    );

Lens<MouseGesture> mouseGestureLens(GestureLocation location) =>
    Lens<MouseGesture>(
      get: (config) => config.mouseGestures[location.index],
      set: (config, gesture) =>
          replaceMouseGestureAt(config, location.index, gesture),
      name: 'mouseGesture[${location.index}]',
    );

Lens<KeyboardGesture> keyboardGestureLens(GestureLocation location) =>
    Lens<KeyboardGesture>(
      get: (config) => config.keyboardGestures[location.index],
      set: (config, gesture) =>
          replaceKeyboardGestureAt(config, location.index, gesture),
      name: 'keyboardGesture[${location.index}]',
    );

Lens<TouchpadGesture> touchpadGestureLens(GestureLocation location) =>
    Lens<TouchpadGesture>(
      get: (config) => config.touchpadGestures[location.index],
      set: (config, gesture) =>
          replaceTouchpadGestureAt(config, location.index, gesture),
      name: 'touchpadGesture[${location.index}]',
    );

Lens<TouchscreenGesture> touchscreenGestureLens(GestureLocation location) =>
    Lens<TouchscreenGesture>(
      get: (config) => config.touchscreenGestures[location.index],
      set: (config, gesture) =>
          replaceTouchscreenGestureAt(config, location.index, gesture),
      name: 'touchscreenGesture[${location.index}]',
    );

Config replaceTriggerCommonAt(
  Config config,
  GestureLocation location,
  TriggerCommon common,
) => replaceGestureCommonAt(config, location, common);

// ============================================================================
// Speed / device-rule / global settings
// ============================================================================

@GenerateEditSchema()
final EditSchema<SpeedSettings, DeviceType> speedSchema =
    editSchema<SpeedSettings, DeviceType>(
      id: 'speed',
      rootLens: 'speedSettingsLens',
      fields: [
        prop('events', adapter: nullableInt()),
        prop('swipeThreshold', adapter: nullableDouble()),
        prop('pinchInThreshold', adapter: nullableDouble()),
        prop('pinchOutThreshold', adapter: nullableDouble()),
        prop('rotateThreshold', adapter: nullableDouble()),
      ],
    );

@GenerateEditSchema()
final EditSchema<DeviceRuleProperties, DeviceType> defaultDeviceSchema =
    editSchema<DeviceRuleProperties, DeviceType>(
      id: 'defaultDevice',
      rootLens: 'defaultDevicePropertiesLens',
      fields: [
        prop('ignore'),
        prop('grab'),
        prop('motionTimeout', adapter: nullableInt()),
        prop('motionThreshold', adapter: nullableDouble()),
        prop('pressTimeout', adapter: nullableInt()),
        prop('swipeAngleTolerance', adapter: nullableDouble()),
        prop('unblockButtonsOnTimeout'),
        prop('buttonpad'),
        prop('clickTimeout', adapter: nullableInt()),
        prop('handleEvdevEvents'),
        prop('motionThreshold2', adapter: nullableDouble()),
        prop('motionThreshold3', adapter: nullableDouble()),
        prop('pressureRangesFinger', adapter: nullableInt()),
        prop('pressureRangesThumb', adapter: nullableInt()),
        prop('pressureRangesPalm', adapter: nullableInt()),
      ],
    );

/// The same [DeviceRuleProperties] fields as [defaultDeviceSchema], but
/// addressed by device-rule list index instead of [DeviceType]. Generates the
/// `deviceRule{Field}Lens(int)` family (composing [deviceRulePropertiesLens]),
/// replacing the previous hand-written property lenses.
@GenerateEditSchema()
final EditSchema<DeviceRuleProperties, int> deviceRulePropertySchema =
    editSchema<DeviceRuleProperties, int>(
      id: 'deviceRule',
      rootLens: 'deviceRulePropertiesLens',
      fields: [
        prop('ignore'),
        prop('grab'),
        prop('motionTimeout', adapter: nullableInt()),
        prop('motionThreshold', adapter: nullableDouble()),
        prop('pressTimeout', adapter: nullableInt()),
        prop('swipeAngleTolerance', adapter: nullableDouble()),
        prop('unblockButtonsOnTimeout'),
        prop('buttonpad'),
        prop('clickTimeout', adapter: nullableInt()),
        prop('handleEvdevEvents'),
        prop('motionThreshold2', adapter: nullableDouble()),
        prop('motionThreshold3', adapter: nullableDouble()),
        prop('pressureRangesFinger', adapter: nullableInt()),
        prop('pressureRangesThumb', adapter: nullableInt()),
        prop('pressureRangesPalm', adapter: nullableInt()),
      ],
    );

@GenerateEditSchema()
final ListSchema<Config, DeviceRule> deviceRuleList =
    listSchema<Config, DeviceRule>(property: 'deviceRules', id: 'deviceRule');

/// Comparison-only projection of a [MotionCommon].
/// Generates `comparableMotionCommonValue`.
@GenerateEditSchema()
final ValueSchema<MotionCommon> motionValueSchema = valueSchema<MotionCommon>(
  fields: [
    prop('speed'),
    prop('lockPointer', property: 'effectiveLockPointer'),
  ],
);

/// Comparison-only projection of a [TriggerCommon] — the whole-common tuple
/// (`comparableTriggerCommonValue`). The action list is mapped through
/// [comparableTriggerActionValue]; effective getters normalize unset values.
@GenerateEditSchema()
final ValueSchema<TriggerCommon> triggerCommonValueSchema =
    valueSchema<TriggerCommon>(
      fields: [
        prop('name'),
        prop('enabled', property: 'effectiveEnabled'),
        prop('id'),
        prop('groupId'),
        prop('mouseButtons', orElse: const <Object?>[]),
        prop('mouseButtonsExactOrder', orElse: false),
        prop('conditions'),
        prop('endConditions'),
        prop('blockEvents', property: 'effectiveBlockEvents'),
        prop('clearModifiers', property: 'effectiveClearModifiers'),
        prop('resumeTimeout'),
        prop('setLastTrigger', property: 'effectiveSetLastTrigger'),
        prop('threshold'),
        prop('accelerated', property: 'effectiveAccelerated'),
        prop('actions', compare: composed()),
      ],
    );

/// Comparison-only projection of a [SwipeMode]: `comparableSwipeModeValue`.
@GenerateEditSchema()
final ValueSchema<SwipeMode> swipeModeValueSchema = valueSchema<SwipeMode>(
  cases: [
    valueCase<SwipeDirectionMode>(
      'direction',
      fields: [prop('direction')],
    ),
    valueCase<SwipeAngleMode>(
      'angle',
      fields: [
        prop('minAngle'),
        prop('maxAngle'),
        prop('bidirectional'),
      ],
    ),
  ],
);

// ============================================================================
// Whole-gesture comparison projections
// ============================================================================

// Whole-gesture comparison projections per device family. Each case is tagged
// and composes the shared `common`, plus per-case `motion`/`mode`. These mirror
// the previous hand-written `comparableGesture` switch; field order matters
// for dirty comparison. The composed `comparable*Value` helpers come from
// value_projections.dart.

@GenerateEditSchema()
final ValueSchema<MouseGesture> mouseGestureValueSchema =
    valueSchema<MouseGesture>(
      shared: [
        prop('common', compare: composed()),
      ],
      cases: [
        valueCase<StrokeGesture>(
          'stroke',
          fields: [
            prop('motion', compare: composed()),
            prop('strokes'),
          ],
        ),
        valueCase<SwipeGesture>(
          'swipe',
          fields: [
            prop('motion', compare: composed()),
            prop('mode', compare: composed()),
          ],
        ),
        valueCase<CircleGesture>(
          'circle',
          fields: [
            prop('motion', compare: composed()),
            prop('direction'),
          ],
        ),
        valueCase<PressGesture>(
          'press',
          fields: [
            prop('motion', compare: composed()),
            prop('instant', orElse: false),
          ],
        ),
        valueCase<WheelGesture>(
          'wheel',
          fields: [
            prop('motion', compare: composed()),
            prop('direction'),
          ],
        ),
      ],
    );

@GenerateEditSchema()
final ValueSchema<KeyboardGesture> keyboardGestureValueSchema =
    valueSchema<KeyboardGesture>(
      shared: [
        prop('common', compare: composed()),
      ],
      cases: [
        valueCase<ShortcutGesture>(
          'shortcut',
          fields: [prop('keys')],
        ),
      ],
    );

@GenerateEditSchema()
final ValueSchema<PointerGesture> pointerGestureValueSchema =
    valueSchema<PointerGesture>(
      shared: [
        prop('common', compare: composed()),
      ],
      cases: [valueCase<HoverGesture>('hover')],
    );

@GenerateEditSchema()
final ValueSchema<TouchpadGesture> touchpadGestureValueSchema =
    valueSchema<TouchpadGesture>(
      shared: [
        prop('common', compare: composed()),
      ],
      cases: [
        valueCase<TouchpadSwipeGesture>(
          'touchpadSwipe',
          fields: [
            prop('fingers'),
            prop('mode', compare: composed()),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchpadPinchGesture>(
          'touchpadPinch',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchpadRotateGesture>(
          'touchpadRotate',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchpadCircleGesture>(
          'touchpadCircle',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchpadTapGesture>(
          'touchpadTap',
          fields: [prop('fingers')],
        ),
        valueCase<TouchpadClickGesture>(
          'touchpadClick',
          fields: [prop('fingers')],
        ),
        valueCase<TouchpadHoldGesture>(
          'touchpadHold',
          fields: [prop('fingers')],
        ),
        valueCase<TouchpadStrokeGesture>(
          'touchpadStroke',
          fields: [
            prop('fingers'),
            prop('strokes'),
            prop('motion', compare: composed()),
          ],
        ),
      ],
    );

@GenerateEditSchema()
final ValueSchema<TouchscreenGesture> touchscreenGestureValueSchema =
    valueSchema<TouchscreenGesture>(
      shared: [
        prop('common', compare: composed()),
      ],
      cases: [
        valueCase<TouchscreenSwipeGesture>(
          'touchscreenSwipe',
          fields: [
            prop('fingers'),
            prop('mode', compare: composed()),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchscreenPinchGesture>(
          'touchscreenPinch',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchscreenRotateGesture>(
          'touchscreenRotate',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchscreenCircleGesture>(
          'touchscreenCircle',
          fields: [
            prop('fingers'),
            prop('direction'),
            prop('motion', compare: composed()),
          ],
        ),
        valueCase<TouchscreenTapGesture>(
          'touchscreenTap',
          fields: [prop('fingers')],
        ),
        valueCase<TouchscreenHoldGesture>(
          'touchscreenHold',
          fields: [prop('fingers')],
        ),
        valueCase<TouchscreenStrokeGesture>(
          'touchscreenStroke',
          fields: [
            prop('fingers'),
            prop('strokes'),
            prop('motion', compare: composed()),
          ],
        ),
      ],
    );

///
/// Manual helpers
///

const globalAutoreloadPart = LensPart<GlobalSettings, bool?>(
  get: _getAutoreload,
  set: _setAutoreload,
  name: 'autoreload',
);

const globalExternalVariableAccessPart = LensPart<GlobalSettings, bool?>(
  get: _getExternalVariableAccess,
  set: _setExternalVariableAccess,
  name: 'externalVariableAccess',
);

const globalNotificationsConfigErrorPart = LensPart<GlobalSettings, bool?>(
  get: _getNotificationsConfigError,
  set: _setNotificationsConfigError,
  name: 'notificationsConfigError',
);

const globalEmergencyCombinationPart = LensPart<GlobalSettings, List<String>?>(
  get: _getEmergencyCombination,
  set: _setEmergencyCombination,
  name: 'emergencyCombination',
);

Lens<SpeedSettings> speedSettingsLens(DeviceType device) => Lens<SpeedSettings>(
  get: (config) => config.speedForDevice(device) ?? const SpeedSettings(),
  set: (config, settings) => _setSpeedSettings(config, device, settings),
  name: 'speed[${device.name}]',
);

final Lens<GlobalSettings> globalSettingsLens = Lens<GlobalSettings>(
  get: (config) => config.globalSettings,
  set: (config, settings) => config.copyWith(globalSettings: settings),
  name: 'globalSettings',
);

final Lens<bool?> globalAutoreloadLens = globalSettingsLens.then(
  globalAutoreloadPart,
);

final Lens<bool?> globalExternalVariableAccessLens = globalSettingsLens.then(
  globalExternalVariableAccessPart,
);

final Lens<bool?> globalNotificationsConfigErrorLens = globalSettingsLens.then(
  globalNotificationsConfigErrorPart,
);

final Lens<List<String>?> globalEmergencyCombinationLens = globalSettingsLens
    .then(
      globalEmergencyCombinationPart,
    );

Lens<DeviceRule> deviceRuleLens(int index) => Lens<DeviceRule>(
  get: (config) => config.deviceRules[index],
  set: (config, rule) => replaceDeviceRuleAt(config, index, rule),
  name: 'deviceRule[$index]',
);

Lens<Condition?> deviceRuleConditionsLens(int index) =>
    _deviceRuleFieldLens<Condition?>(
      index,
      'conditions',
      (rule) => rule.conditions,
      (rule, value) => rule.copyWith(conditions: value),
    );

Lens<DeviceRuleProperties> deviceRulePropertiesLens(int index) =>
    _deviceRuleFieldLens<DeviceRuleProperties>(
      index,
      'properties',
      (rule) => rule.properties,
      (rule, value) => rule.copyWith(properties: value),
    );

Lens<DeviceRuleProperties> defaultDevicePropertiesLens(DeviceType device) =>
    Lens<DeviceRuleProperties>(
      get: (config) =>
          _defaultDeviceRule(config, device)?.properties ??
          const DeviceRuleProperties(),
      set: (config, properties) =>
          _setDefaultDeviceProperties(config, device, properties),
      name: 'defaultDevice[${device.name}].properties',
    );

Config _setSpeedSettings(
  Config config,
  DeviceType device,
  SpeedSettings settings,
) {
  final value = settings.isEmpty ? null : settings;
  return switch (device) {
    DeviceType.mouse => config.copyWith(mouseSpeed: value),
    DeviceType.touchpad => config.copyWith(touchpadSpeed: value),
    DeviceType.touchscreen => config.copyWith(touchscreenSpeed: value),
    DeviceType.keyboard || DeviceType.pointer => config,
  };
}

bool? _getAutoreload(GlobalSettings settings) => settings.autoreload;

GlobalSettings _setAutoreload(GlobalSettings settings, bool? value) =>
    settings.copyWith(autoreload: value);

bool? _getExternalVariableAccess(GlobalSettings settings) =>
    settings.externalVariableAccess;

GlobalSettings _setExternalVariableAccess(
  GlobalSettings settings,
  bool? value,
) => settings.copyWith(externalVariableAccess: value);

bool? _getNotificationsConfigError(GlobalSettings settings) =>
    settings.notificationsConfigError;

GlobalSettings _setNotificationsConfigError(
  GlobalSettings settings,
  bool? value,
) => settings.copyWith(notificationsConfigError: value);

List<String>? _getEmergencyCombination(GlobalSettings settings) =>
    settings.emergencyCombination;

GlobalSettings _setEmergencyCombination(
  GlobalSettings settings,
  List<String>? value,
) => settings.copyWith(emergencyCombination: value);

Lens<T> _deviceRuleFieldLens<T>(
  int index,
  String name,
  T Function(DeviceRule rule) get,
  DeviceRule Function(DeviceRule rule, T value) set,
) {
  return Lens<T>(
    get: (config) => get(config.deviceRules[index]),
    set: (config, value) {
      if (index < 0 || index >= config.deviceRules.length) return config;
      return replaceDeviceRuleAt(
        config,
        index,
        set(config.deviceRules[index], value),
      );
    },
    name: 'deviceRule[$index].$name',
  );
}

Config _setDefaultDeviceProperties(
  Config config,
  DeviceType device,
  DeviceRuleProperties properties,
) {
  final index = _defaultDeviceRuleIndex(config, device);
  if (index != null) {
    final rules = List<DeviceRule>.of(config.deviceRules);
    if (properties.isEmpty) {
      rules.removeAt(index);
    } else {
      rules[index] = rules[index].copyWith(properties: properties);
    }
    return config.copyWith(deviceRules: rules);
  }
  if (properties.isEmpty) return config;
  final conditionVar = _defaultDeviceConditionVariable(device);
  if (conditionVar == null) return config;
  return config.copyWith(
    deviceRules: [
      ...config.deviceRules,
      DeviceRule(
        conditions: VariableCondition(
          variable: conditionVar,
          operator: '==',
          value: 'true',
        ),
        properties: properties,
      ),
    ],
  );
}

DeviceRule? _defaultDeviceRule(Config config, DeviceType device) {
  final index = _defaultDeviceRuleIndex(config, device);
  return index == null ? null : config.deviceRules[index];
}

int? _defaultDeviceRuleIndex(Config config, DeviceType device) {
  final conditionVar = _defaultDeviceConditionVariable(device);
  if (conditionVar == null) return null;
  for (var i = 0; i < config.deviceRules.length; i++) {
    final conditions = config.deviceRules[i].conditions;
    if (conditions is VariableCondition &&
        conditions.variable == conditionVar &&
        conditions.operator == '==' &&
        conditions.value == 'true' &&
        !conditions.negate) {
      return i;
    }
  }
  return null;
}

String? _defaultDeviceConditionVariable(DeviceType device) => switch (device) {
  DeviceType.mouse => 'mouse',
  DeviceType.keyboard => 'keyboard',
  DeviceType.touchpad => 'touchpad',
  DeviceType.touchscreen => 'touchscreen',
  DeviceType.pointer => null,
};

/// Comparison-only projection of a [TriggerAction] — the whole-action tuple
/// used when comparing a gesture's action list. Equals the generated `all`
/// group.
Object? comparableTriggerActionValue(TriggerAction? action) =>
    comparableActionGroupValue(action, ActionDirtyGroup.all);

int? _getTouchpadFingers(TouchpadGesture gesture) => gesture.fingers;
int? _getTouchscreenFingers(TouchscreenGesture gesture) => gesture.fingers;

MotionCommon _getTouchpadMotion(TouchpadGesture gesture) => switch (gesture) {
  TouchpadSwipeGesture(:final motion) => motion,
  TouchpadPinchGesture(:final motion) => motion,
  TouchpadRotateGesture(:final motion) => motion,
  TouchpadCircleGesture(:final motion) => motion,
  TouchpadStrokeGesture(:final motion) => motion,
  TouchpadTapGesture() ||
  TouchpadClickGesture() ||
  TouchpadHoldGesture() => const MotionCommon(),
};

TouchpadGesture _setTouchpadMotion(
  TouchpadGesture gesture,
  MotionCommon value,
) => switch (gesture) {
  TouchpadSwipeGesture() => gesture.copyWith(motion: value),
  TouchpadPinchGesture() => gesture.copyWith(motion: value),
  TouchpadRotateGesture() => gesture.copyWith(motion: value),
  TouchpadCircleGesture() => gesture.copyWith(motion: value),
  TouchpadStrokeGesture() => gesture.copyWith(motion: value),
  TouchpadTapGesture() ||
  TouchpadClickGesture() ||
  TouchpadHoldGesture() => gesture,
};

MotionCommon _getTouchscreenMotion(TouchscreenGesture gesture) =>
    switch (gesture) {
      TouchscreenSwipeGesture(:final motion) => motion,
      TouchscreenPinchGesture(:final motion) => motion,
      TouchscreenRotateGesture(:final motion) => motion,
      TouchscreenCircleGesture(:final motion) => motion,
      TouchscreenStrokeGesture(:final motion) => motion,
      TouchscreenTapGesture() ||
      TouchscreenHoldGesture() => const MotionCommon(),
    };

TouchscreenGesture _setTouchscreenMotion(
  TouchscreenGesture gesture,
  MotionCommon value,
) => switch (gesture) {
  TouchscreenSwipeGesture() => gesture.copyWith(motion: value),
  TouchscreenPinchGesture() => gesture.copyWith(motion: value),
  TouchscreenRotateGesture() => gesture.copyWith(motion: value),
  TouchscreenCircleGesture() => gesture.copyWith(motion: value),
  TouchscreenStrokeGesture() => gesture.copyWith(motion: value),
  TouchscreenTapGesture() || TouchscreenHoldGesture() => gesture,
};
