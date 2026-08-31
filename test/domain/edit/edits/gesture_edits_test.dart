import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import '../../../helpers/config_fixtures.dart';

void main() {
  group('Gesture edits', () {
    test('AddGesture appends to the right device list', () {
      var c = const Config();
      c = AddGesture(DeviceType.mouse, mouse1).apply(c);
      c = AddGesture(DeviceType.keyboard, kbd1).apply(c);
      c = AddGesture(DeviceType.pointer, ptr1).apply(c);
      c = AddGesture(DeviceType.touchpad, tp1).apply(c);
      c = AddGesture(DeviceType.touchscreen, ts1).apply(c);
      expect(c.mouseGestures.single.common.name, 'm1');
      expect(c.keyboardGestures.single.common.name, 'k1');
      expect(c.pointerGestures.single.common.name, 'p1');
      expect(c.touchpadGestures.single.common.name, 'tp1');
      expect(c.touchscreenGestures.single.common.name, 'ts1');
    });

    test('RemoveGesture deletes by identity, ignores a missing gesture', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(mouse1), GestureNode.leaf(mouse2)],
        ),
      );
      expect(
        names(
          RemoveGestures([at(c, DeviceType.mouse, 0)]).apply(c).mouseGestures,
        ),
        ['m2'],
      );
      expect(RemoveGestures([missing]).apply(c), c);
    });

    test('RemoveGesture follows the gesture across a reorder', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(mouse1), GestureNode.leaf(mouse2)],
        ),
      );
      final m1 = at(c, DeviceType.mouse, 0);
      final reordered = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(
        names(RemoveGestures([m1]).apply(reordered).mouseGestures),
        ['m2'],
      );
    });

    test('DuplicateGesture inserts a copy after the original', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [GestureNode.leaf(mouse1), GestureNode.leaf(mouse2)],
        ),
      );
      final out = DuplicateGestures([at(c, DeviceType.mouse, 0)]).apply(c);
      expect(names(out.mouseGestures), ['m1', 'm1-copy', 'm2']);
    });

    test('UpdateGesture transforms in place, ignores a missing gesture', () {
      final c = assignEditIds(
        const Config(
          keyboardNodes: [GestureNode.leaf(kbd1), GestureNode.leaf(kbd2)],
        ),
      );
      final out = UpdateGesture(
        at(c, DeviceType.keyboard, 0),
        (g) => g.withCommon(rename('updated')(g.common)),
      ).apply(c);
      expect(names(out.keyboardGestures), ['updated', 'k2']);
      expect(UpdateGesture(missing, (g) => g).apply(c), c);
    });

    test('UpdateGestureCommon patches the shared common', () {
      final c = assignEditIds(
        const Config(touchpadNodes: [GestureNode.leaf(tp1)]),
      );
      final out = UpdateGestureCommon(
        at(c, DeviceType.touchpad, 0),
        (common) => common.copyWith(threshold: '5'),
      ).apply(c);
      expect(out.touchpadGestures.single.common.threshold, '5');
    });

    test('ReorderGesture moves forward (newIndex > oldIndex)', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureNode.leaf(mouse1),
            GestureNode.leaf(mouse2),
            GestureNode.leaf(mouse3),
          ],
        ),
      );
      // Move index 0 to after index 1: Flutter passes newIndex = 2.
      final out = ReorderGesture(DeviceType.mouse, 0, 2).apply(c);
      expect(names(out.mouseGestures), ['m2', 'm1', 'm3']);
    });

    test('ReorderGesture moves backward (newIndex < oldIndex)', () {
      final c = assignEditIds(
        const Config(
          mouseNodes: [
            GestureNode.leaf(mouse1),
            GestureNode.leaf(mouse2),
            GestureNode.leaf(mouse3),
          ],
        ),
      );
      final out = ReorderGesture(DeviceType.mouse, 2, 0).apply(c);
      expect(names(out.mouseGestures), ['m3', 'm1', 'm2']);
    });

    test('only in-place updates are CoalescingEdits', () {
      expect(UpdateGesture(missing, (g) => g), isA<CoalescingEdit>());
      expect(UpdateGestureCommon(missing, (c) => c), isA<CoalescingEdit>());
      expect(
        AddGesture(DeviceType.mouse, mouse1),
        isNot(isA<CoalescingEdit>()),
      );
    });
  });
}
