import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

extension TriggerCommonEffectiveValuesX on TriggerCommon {
  bool get effectiveEnabled => enabled ?? true;
}

extension GlobalSettingsEffectiveValuesX on GlobalSettings {
  bool get effectiveAutoreload => autoreload ?? true;

  bool get effectiveExternalVariableAccess => externalVariableAccess ?? true;

  bool get effectiveNotificationsConfigError =>
      notificationsConfigError ?? true;
}
