import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _channel = OptionalMethodChannel(
  'input_actions_editor/keyboard_recording',
);

Future<void> setKeyboardRecordingGrab(bool enabled) async {
  if (defaultTargetPlatform != TargetPlatform.linux) return;
  await _channel.invokeMethod<void>(enabled ? 'grab' : 'ungrab');
}
