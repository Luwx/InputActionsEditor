import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

extension CommandActionEffectiveValuesX on CommandAction {
  bool get effectiveWait => wait ?? false;
}

extension TriggerCommonEffectiveValuesX on TriggerCommon {
  bool get effectiveEnabled => enabled ?? true;

  bool get effectiveAccelerated => accelerated ?? false;

  bool get effectiveBlockEvents => blockEvents ?? true;

  bool get effectiveClearModifiers => clearModifiers ?? false;

  bool get effectiveSetLastTrigger => setLastTrigger ?? true;
}

extension GlobalSettingsEffectiveValuesX on GlobalSettings {
  bool get effectiveAutoreload => autoreload ?? true;

  bool get effectiveExternalVariableAccess => externalVariableAccess ?? true;

  bool get effectiveNotificationsConfigError =>
      notificationsConfigError ?? true;
}

extension MotionCommonEffectiveValuesX on MotionCommon {
  bool get effectiveLockPointer => lockPointer ?? false;
}

extension PressGestureEffectiveValuesX on PressGesture {
  bool get effectiveInstant => instant ?? false;
}
