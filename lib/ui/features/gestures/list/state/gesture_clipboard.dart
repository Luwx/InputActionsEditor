import 'package:flutter/services.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';

/// The clipboard boundary for gestures: they travel as the same YAML a config
/// file's device blocks hold, so a snippet can be pasted into a text editor and
/// hand-written text can be pasted back in.
abstract final class GestureClipboard {
  static Future<void> write(Map<DeviceType, List<Gesture>> byDevice) {
    var config = const Config();
    for (final MapEntry(key: device, value: gestures) in byDevice.entries) {
      config = withGestureNodesForDevice(config, device, [
        for (final gesture in gestures) GestureNode.leaf(gesture),
      ]);
    }
    return Clipboard.setData(
      ClipboardData(text: encodeConfig(config, '').trim()),
    );
  }

  /// The clipboard's gestures for [device], or an empty list when it holds
  /// anything else. A gesture type belongs to exactly one device, so a snippet
  /// copied from another one has nothing to offer here.
  static Future<List<Gesture>> read(DeviceType device) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.trim().isEmpty) return const [];
    try {
      return gesturesForDevice(decodeConfig(text), device);
    } on Object catch (_) {
      return const [];
    }
  }
}
