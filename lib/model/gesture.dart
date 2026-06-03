import 'package:input_actions_editor/model/trigger_common.dart';

abstract interface class Gesture {
  TriggerCommon get common;
  Gesture withCommon(TriggerCommon common);
}
