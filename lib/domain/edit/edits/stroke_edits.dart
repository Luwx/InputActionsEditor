import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';

final class RenameStroke extends ConfigEdit {
  RenameStroke(this.data, this.name);

  final String data;
  final String? name;

  @override
  String get label => 'rename stroke';

  @override
  Config apply(Config config) => _mapStrokes(
    config,
    (stroke) => stroke.data == data ? Stroke(data, name: name) : stroke,
  );

  @override
  ConfigEdit inverse(Config config) => RestoreGestures(config, label: label);
}

final class InsertStrokes extends ConfigEdit {
  InsertStrokes(this.location, this.strokes, {this.at});

  final GestureLocation location;
  final List<Stroke> strokes;
  final int? at;

  @override
  String get label => strokes.length == 1 ? 'paste stroke' : 'paste strokes';

  @override
  Config apply(Config config) {
    final known = [...config.strokes];
    final inserted = <Stroke>[];
    for (final Stroke(:data, :name) in strokes) {
      final twinName = known
          .where((stroke) => stroke.data == data)
          .map((twin) => twin.name)
          .nonNulls
          .firstOrNull;
      final stroke = Stroke(
        data,
        name: twinName ?? (name == null ? null : _freeName(known, data, name)),
      );
      known.add(stroke);
      inserted.add(stroke);
    }
    return updateGesture(config, location, (gesture) {
      final current = _strokesOf(gesture);
      final index = at ?? current.length;
      return _withStrokes(gesture, [
        ...current.take(index),
        ...inserted,
        ...current.skip(index),
      ]);
    });
  }

  @override
  ConfigEdit inverse(Config config) => RestoreGestures(config, label: label);
}

List<Stroke> _strokesOf(Gesture gesture) => switch (gesture) {
  StrokeGesture(:final strokes) ||
  TouchpadStrokeGesture(:final strokes) ||
  TouchscreenStrokeGesture(:final strokes) => strokes,
  _ => const [],
};

Gesture _withStrokes(Gesture gesture, List<Stroke> strokes) =>
    switch (gesture) {
      StrokeGesture() => gesture.copyWith(strokes: strokes),
      TouchpadStrokeGesture() => gesture.copyWith(strokes: strokes),
      TouchscreenStrokeGesture() => gesture.copyWith(strokes: strokes),
      _ => gesture,
    };

String? _freeName(List<Stroke> strokes, String data, String name) {
  if (!Stroke.isValidName(name)) return null;
  var free = name;
  for (var n = 2; Stroke.nameIssue(strokes, data, free) != null; n++) {
    free = '${name}_$n';
  }
  return free;
}

Config _mapStrokes(Config config, Stroke Function(Stroke stroke) map) {
  List<GestureNode> walk(List<GestureNode> nodes) {
    final out = [
      for (final node in nodes)
        switch (node) {
          GestureLeaf(:final gesture)
              when _strokesOf(gesture).any((s) => map(s) != s) =>
            GestureNode.leaf(
              _withStrokes(gesture, [..._strokesOf(gesture).map(map)]),
            ),
          GestureGroupNode(:final children) => switch (walk(children)) {
            final walked when identical(walked, children) => node,
            final walked => node.copyWith(children: walked),
          },
          GestureLeaf() => node,
        },
    ];
    return out.indexed.every((e) => identical(e.$2, nodes[e.$1])) ? nodes : out;
  }

  var result = config;
  for (final device in DeviceType.values) {
    final nodes = config.nodesForDevice(device);
    final walked = walk(nodes);
    if (!identical(walked, nodes)) {
      result = result.withNodesForDevice(device, walked);
    }
  }
  return result;
}
