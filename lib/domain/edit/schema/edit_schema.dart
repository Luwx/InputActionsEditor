// Single-tree edit schema for [Config]: one `editTree` that mirrors the config
// data tree and generates every lens, comparable projection, location type,
// saved-backing predicate, field ref, list-mutation helper, and group used by
// the editor and dirty layers.
//
// Cross-cuts:
//  - the 5 gesture lists share one `GestureLocation` coordinate and one
//    `gestureCommon*` family via `vehicleLists` over the `Gesture` supertype;
//  - per-device case fields (motion/mode/fingers/…) yield per-device families;
//  - the default-device-by-condition rule stays a hand-written escape hatch
//    (see config_tree_extra.dart).

import 'package:edit_schema_generator/edit_schema_generator.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/speed_settings.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

part 'edit_schema.g.dart';

final TreeNode<MotionCommon> motionNode = subtree<MotionCommon>(
  fields: [
    prop(MotionCommonMeta.speed),
    prop(
      MotionCommonMeta.lockPointer,
      compare: projected<MotionCommon, bool?>((v) => v?.effectiveLockPointer),
    ),
  ],
);

final TreeNode<SwipeMode> swipeModeNode = subtree<SwipeMode>(
  cases: [
    valueCase<SwipeDirectionMode>(
      'direction',
      fields: [prop(SwipeDirectionModeMeta.direction)],
    ),
    valueCase<SwipeAngleMode>(
      'angle',
      fields: [
        prop(SwipeAngleModeMeta.minAngle),
        prop(SwipeAngleModeMeta.maxAngle),
        prop(SwipeAngleModeMeta.bidirectional),
      ],
    ),
  ],
);

final TreeNode<TriggerAction> actionNode = subtree<TriggerAction>(
  fields: [
    sealed(
      TriggerActionMeta.action,
      cases: [
        valueCase<CommandAction>(
          'command',
          fields: [
            prop(CommandActionMeta.command),
            prop(
              CommandActionMeta.wait,
              compare: projected<CommandAction, bool?>(
                (v) => v?.effectiveWait,
              ),
            ),
          ],
        ),
        valueCase<PlasmaShortcutAction>(
          'plasma',
          fields: [
            prop(PlasmaShortcutActionMeta.component),
            prop(PlasmaShortcutActionMeta.shortcut),
          ],
        ),
        valueCase<SleepAction>(
          'sleep',
          fields: [prop('duration', property: SleepActionMeta.milliseconds)],
        ),
        valueCase<RawAction>('raw', fields: [prop(RawActionMeta.raw)]),
        valueCase<InputAction>(
          'input',
          fields: [prop('inputEntries', property: InputActionMeta.entries)],
        ),
      ],
    ),
    prop('triggerOn', property: TriggerActionMeta.on),
    prop(TriggerActionMeta.interval, adapter: nullableText()),
    prop(TriggerActionMeta.threshold, adapter: nullableText()),
    prop(TriggerActionMeta.limit, adapter: nullableInt()),
    prop(
      TriggerActionMeta.enabled,
      compare: projected<TriggerAction, bool?>((v) => v?.effectiveEnabled),
    ),
    prop(TriggerActionMeta.conflicting),
    prop(TriggerActionMeta.conditions),
    prop(TriggerActionMeta.id, adapter: nullableText()),
  ],
);

final TreeNode<TriggerCommon> commonNode = subtree<TriggerCommon>(
  fields: [
    prop(TriggerCommonMeta.name, readOnly: true),
    prop(
      TriggerCommonMeta.enabled,
      readOnly: true,
      compare: projected<TriggerCommon, bool?>((v) => v?.effectiveEnabled),
    ),
    prop(TriggerCommonMeta.id, adapter: nullableText()),
    prop(TriggerCommonMeta.groupId, readOnly: true),
    prop(TriggerCommonMeta.mouseButtons),
    prop(TriggerCommonMeta.mouseButtonsExactOrder),
    prop(TriggerCommonMeta.conditions),
    prop(TriggerCommonMeta.endConditions),
    prop(
      TriggerCommonMeta.blockEvents,
      compare: projected<TriggerCommon, bool?>((v) => v?.effectiveBlockEvents),
    ),
    prop(
      TriggerCommonMeta.clearModifiers,
      compare: projected<TriggerCommon, bool?>(
        (v) => v?.effectiveClearModifiers,
      ),
    ),
    prop(TriggerCommonMeta.resumeTimeout, adapter: nullableInt()),
    prop(
      TriggerCommonMeta.setLastTrigger,
      compare: projected<TriggerCommon, bool?>(
        (v) => v?.effectiveSetLastTrigger,
      ),
    ),
    prop(TriggerCommonMeta.threshold, adapter: nullableText()),
    prop(
      TriggerCommonMeta.accelerated,
      compare: projected<TriggerCommon, bool?>((v) => v?.effectiveAccelerated),
    ),
    list(
      TriggerCommonMeta.actions,
      of: actionNode,
      scope: 'action',
      location: 'ActionLocation',
      parentField: 'gesture',
      indexField: 'actionIndex',
    ),
  ],
  groups: [
    editGroup(
      id: 'mouseButtonsSection',
      members: [
        TriggerCommonMeta.mouseButtons,
        TriggerCommonMeta.mouseButtonsExactOrder,
      ],
    ),
    editGroup(id: 'triggerConditions', members: [TriggerCommonMeta.conditions]),
    editGroup(id: 'actionsSection', members: [TriggerCommonMeta.actions]),
    editGroup(
      id: 'triggerConfig',
      members: [
        TriggerCommonMeta.mouseButtons,
        TriggerCommonMeta.mouseButtonsExactOrder,
        TriggerCommonMeta.conditions,
        TriggerCommonMeta.id,
        TriggerCommonMeta.threshold,
        TriggerCommonMeta.resumeTimeout,
        TriggerCommonMeta.accelerated,
        TriggerCommonMeta.blockEvents,
        TriggerCommonMeta.clearModifiers,
        TriggerCommonMeta.setLastTrigger,
        TriggerCommonMeta.endConditions,
      ],
    ),
  ],
);

final TreeNode<MouseGesture> mouseNode = subtree<MouseGesture>(
  cases: [
    valueCase<StrokeGesture>(
      'stroke',
      fields: [
        child(StrokeGestureMeta.motion, node: motionNode),
        prop(StrokeGestureMeta.strokes),
      ],
    ),
    valueCase<SwipeGesture>(
      'swipe',
      fields: [
        child(SwipeGestureMeta.motion, node: motionNode),
        child(SwipeGestureMeta.mode, node: swipeModeNode),
      ],
    ),
    valueCase<CircleGesture>(
      'circle',
      scope: 'circle',
      fields: [
        child(CircleGestureMeta.motion, node: motionNode),
        prop(CircleGestureMeta.direction),
      ],
    ),
    valueCase<PressGesture>(
      'press',
      scope: 'press',
      fields: [
        child(PressGestureMeta.motion, node: motionNode),
        prop(PressGestureMeta.instant, orElse: false),
      ],
    ),
    valueCase<WheelGesture>(
      'wheel',
      scope: 'wheel',
      fields: [
        child(WheelGestureMeta.motion, node: motionNode),
        prop(WheelGestureMeta.direction),
      ],
    ),
  ],
);

final TreeNode<KeyboardGesture> keyboardNode = subtree<KeyboardGesture>(
  cases: [
    valueCase<ShortcutGesture>(
      'shortcut',
      scope: 'shortcut',
      fields: [prop(ShortcutGestureMeta.keys)],
    ),
  ],
);

final TreeNode<PointerGesture> pointerNode = subtree<PointerGesture>(
  cases: [valueCase<HoverGesture>('hover')],
);

// Touchpad/touchscreen `fingers` and `motion` are cross-case: a single lens
// (`touchpadFingersLens`/`touchpadMotionLens`) dispatches across every case via
// a `select:`. `motion` keeps the projected comparable (effective lock-pointer
// normalization) via `composed()`; the cases lacking motion read a default
// through the select getter. The `id` scopes every name to `touchpad…`.
final TreeNode<TouchpadGesture> touchpadNode = subtree<TouchpadGesture>(
  id: 'touchpad',
  fields: [
    prop(
      'fingers',
      select: lens(get: _touchpadFingers, set: _setTouchpadFingers),
    ),
    prop(
      'motion',
      compare: composed(),
      select: lens(get: _touchpadMotion, set: _setTouchpadMotion),
    ),
  ],
  cases: [
    valueCase<TouchpadSwipeGesture>(
      'touchpadSwipe',
      fields: [prop('swipeMode', property: TouchpadSwipeGestureMeta.mode)],
    ),
    valueCase<TouchpadPinchGesture>(
      'touchpadPinch',
      fields: [
        prop('pinchDirection', property: TouchpadPinchGestureMeta.direction),
      ],
    ),
    valueCase<TouchpadRotateGesture>(
      'touchpadRotate',
      fields: [
        prop('rotateDirection', property: TouchpadRotateGestureMeta.direction),
      ],
    ),
    valueCase<TouchpadCircleGesture>(
      'touchpadCircle',
      fields: [
        prop('circleDirection', property: TouchpadCircleGestureMeta.direction),
      ],
    ),
    valueCase<TouchpadTapGesture>('touchpadTap'),
    valueCase<TouchpadClickGesture>('touchpadClick'),
    valueCase<TouchpadHoldGesture>('touchpadHold'),
    valueCase<TouchpadStrokeGesture>(
      'touchpadStroke',
      fields: [
        prop('strokeStrokes', property: TouchpadStrokeGestureMeta.strokes),
      ],
    ),
  ],
);

final TreeNode<TouchscreenGesture> touchscreenNode =
    subtree<TouchscreenGesture>(
      id: 'touchscreen',
      fields: [
        prop(
          'fingers',
          select: lens(get: _touchscreenFingers, set: _setTouchscreenFingers),
        ),
        prop(
          'motion',
          compare: composed(),
          select: lens(get: _touchscreenMotion, set: _setTouchscreenMotion),
        ),
      ],
      cases: [
        valueCase<TouchscreenSwipeGesture>(
          'touchscreenSwipe',
          fields: [
            prop('swipeMode', property: TouchscreenSwipeGestureMeta.mode),
          ],
        ),
        valueCase<TouchscreenPinchGesture>(
          'touchscreenPinch',
          fields: [
            prop(
              'pinchDirection',
              property: TouchscreenPinchGestureMeta.direction,
            ),
          ],
        ),
        valueCase<TouchscreenRotateGesture>(
          'touchscreenRotate',
          fields: [
            prop(
              'rotateDirection',
              property: TouchscreenRotateGestureMeta.direction,
            ),
          ],
        ),
        valueCase<TouchscreenCircleGesture>(
          'touchscreenCircle',
          fields: [
            prop(
              'circleDirection',
              property: TouchscreenCircleGestureMeta.direction,
            ),
          ],
        ),
        valueCase<TouchscreenTapGesture>('touchscreenTap'),
        valueCase<TouchscreenHoldGesture>('touchscreenHold'),
        valueCase<TouchscreenStrokeGesture>(
          'touchscreenStroke',
          fields: [
            prop(
              'strokeStrokes',
              property: TouchscreenStrokeGestureMeta.strokes,
            ),
          ],
        ),
      ],
    );

final TreeNode<DeviceRuleProperties> devicePropertiesNode =
    subtree<DeviceRuleProperties>(
      fields: [
        prop(DeviceRulePropertiesMeta.ignore),
        prop(DeviceRulePropertiesMeta.grab),
        prop(DeviceRulePropertiesMeta.motionTimeout, adapter: nullableInt()),
        prop(
          DeviceRulePropertiesMeta.motionThreshold,
          adapter: nullableDouble(),
        ),
        prop(DeviceRulePropertiesMeta.pressTimeout, adapter: nullableInt()),
        prop(
          DeviceRulePropertiesMeta.swipeAngleTolerance,
          adapter: nullableDouble(),
        ),
        prop(DeviceRulePropertiesMeta.unblockButtonsOnTimeout),
        prop(DeviceRulePropertiesMeta.buttonpad),
        prop(DeviceRulePropertiesMeta.clickTimeout, adapter: nullableInt()),
        prop(DeviceRulePropertiesMeta.handleEvdevEvents),
        prop(
          DeviceRulePropertiesMeta.motionThreshold2,
          adapter: nullableDouble(),
        ),
        prop(
          DeviceRulePropertiesMeta.motionThreshold3,
          adapter: nullableDouble(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesFinger,
          adapter: nullableInt(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesThumb,
          adapter: nullableInt(),
        ),
        prop(
          DeviceRulePropertiesMeta.pressureRangesPalm,
          adapter: nullableInt(),
        ),
      ],
    );

final TreeNode<DeviceRule> deviceRuleNode = subtree<DeviceRule>(
  fields: [
    prop(DeviceRuleMeta.conditions),
    child(DeviceRuleMeta.properties, node: devicePropertiesNode),
  ],
);

final TreeNode<SpeedSettings> speedNode = subtree<SpeedSettings>(
  compactWhen: (s) => s.isEmpty,
  fields: [
    prop(SpeedSettingsMeta.events, adapter: nullableInt()),
    prop(SpeedSettingsMeta.swipeThreshold, adapter: nullableDouble()),
    prop(SpeedSettingsMeta.pinchInThreshold, adapter: nullableDouble()),
    prop(SpeedSettingsMeta.pinchOutThreshold, adapter: nullableDouble()),
    prop(SpeedSettingsMeta.rotateThreshold, adapter: nullableDouble()),
  ],
);

@GenerateEditSchema()
final EditTree<Config> configTree = editTree<Config>(
  id: 'config',
  fields: [
    child(
      ConfigMeta.globalSettings,
      fields: [
        prop(
          GlobalSettingsMeta.autoreload,
          compare: projected<GlobalSettings, bool?>(
            (value) => value?.effectiveAutoreload,
          ),
        ),
        prop(
          GlobalSettingsMeta.externalVariableAccess,
          compare: projected<GlobalSettings, bool?>(
            (value) => value?.effectiveExternalVariableAccess,
          ),
        ),
        prop(
          GlobalSettingsMeta.notificationsConfigError,
          compare: projected<GlobalSettings, bool?>(
            (value) => value?.effectiveNotificationsConfigError,
          ),
        ),
        prop(GlobalSettingsMeta.emergencyCombination),
      ],
    ),
    taggedLists<GestureLocation, Gesture, DeviceType>(
      lens: 'gestureLens',
      discriminator: 'device',
      generateLocation: true,
      shared: [
        child(
          'common',
          node: commonNode,
          scope: 'gesture',
          select: lens<Gesture, TriggerCommon>(
            get: (g) => g.common,
            set: (g, c) => g.withCommon(c),
          ),
        ),
      ],
      lists: {
        DeviceType.mouse: (ConfigMeta.mouseGestures, mouseNode),
        DeviceType.keyboard: (ConfigMeta.keyboardGestures, keyboardNode),
        DeviceType.pointer: (ConfigMeta.pointerGestures, pointerNode),
        DeviceType.touchpad: (ConfigMeta.touchpadGestures, touchpadNode),
        DeviceType.touchscreen: (
          ConfigMeta.touchscreenGestures,
          touchscreenNode,
        ),
      },
    ),
    list(ConfigMeta.deviceRules, of: deviceRuleNode),
    dispatch<DeviceType>(
      lens: 'speedSettingsLens',
      node: speedNode,
      name: 'speed',
      param: 'device',
      branches: {
        DeviceType.mouse: ConfigMeta.mouseSpeed,
        DeviceType.touchpad: ConfigMeta.touchpadSpeed,
        DeviceType.touchscreen: ConfigMeta.touchscreenSpeed,
      },
    ),
  ],
);

// cross-case select helpers

int? _touchpadFingers(TouchpadGesture gesture) => gesture.fingers;

TouchpadGesture _setTouchpadFingers(TouchpadGesture gesture, int? fingers) =>
    gesture.withFingers(fingers);

int? _touchscreenFingers(TouchscreenGesture gesture) => gesture.fingers;

TouchscreenGesture _setTouchscreenFingers(
  TouchscreenGesture gesture,
  int? fingers,
) => gesture.withFingers(fingers);

MotionCommon _touchpadMotion(TouchpadGesture gesture) => switch (gesture) {
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

MotionCommon _touchscreenMotion(TouchscreenGesture gesture) =>
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
