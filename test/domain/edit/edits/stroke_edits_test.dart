import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edits/stroke_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';

const _up = 'MGQA0DMnPMwwAGQA';
const _down = 'MAAAMTNkZAA=';

List<Stroke> _mouseStrokes(Config config) =>
    (config.mouseGestures.single as StrokeGesture).strokes;

List<Stroke> _touchpadStrokes(Config config) =>
    (config.touchpadGestures.single as TouchpadStrokeGesture).strokes;

void main() {
  group('stroke edits', () {
    Config twoDevices() => assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            StrokeGesture(
              common: TriggerCommon(),
              strokes: [Stroke(_up), Stroke(_down)],
            ),
          ),
        ],
        touchpadNodes: [
          GestureNode.leaf(
            TouchpadStrokeGesture(
              common: TriggerCommon(),
              strokes: [Stroke(_up, name: 'old')],
            ),
          ),
        ],
      ),
    );

    test('renaming names every identical stroke', () {
      final renamed = RenameStroke(_up, 'L').apply(twoDevices());

      expect(_mouseStrokes(renamed), const [
        Stroke(_up, name: 'L'),
        Stroke(_down),
      ]);
      expect(_touchpadStrokes(renamed), const [Stroke(_up, name: 'L')]);
    });

    test('a pasted stroke takes the name its twin has', () {
      final config = twoDevices();
      final location = gestureLocationAt(config, DeviceType.mouse, 0)!;
      final pasted = InsertStrokes(location, const [
        Stroke(_up, name: 'other'),
      ]).apply(config);

      expect(_mouseStrokes(pasted).last, const Stroke(_up, name: 'old'));
    });

    test('a pasted name another stroke holds takes a suffix', () {
      final config = twoDevices();
      final location = gestureLocationAt(config, DeviceType.mouse, 0)!;
      final pasted = InsertStrokes(location, const [
        Stroke('AAAAAAAAAAA=', name: 'old'),
      ], at: 1).apply(config);

      expect(
        _mouseStrokes(pasted)[1],
        const Stroke('AAAAAAAAAAA=', name: 'old_2'),
      );
    });

    test('a name is refused when another stroke holds it', () {
      final strokes = twoDevices().strokes;

      expect(Stroke.nameIssue(strokes, _down, 'old'), StrokeNameIssue.taken);
      expect(Stroke.nameIssue(strokes, _up, 'old'), isNull);
      expect(
        Stroke.nameIssue(strokes, _down, 'swipe up'),
        StrokeNameIssue.invalid,
      );
    });
  });
}
