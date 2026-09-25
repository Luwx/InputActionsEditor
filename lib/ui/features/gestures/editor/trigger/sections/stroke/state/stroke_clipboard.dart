import 'package:flutter/services.dart';
import 'package:input_actions_editor/data/yaml/stroke_yaml.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/stroke_codec.dart';

abstract final class StrokeClipboard {
  static Future<void> write(List<Stroke> strokes) =>
      Clipboard.setData(ClipboardData(text: encodeStrokesYaml(strokes)));

  static Future<List<Stroke>> read() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return [
      for (final stroke in decodeStrokesYaml(data?.text ?? ''))
        if (decodeStrokeDetailed(stroke.data) != null) stroke,
    ];
  }
}
