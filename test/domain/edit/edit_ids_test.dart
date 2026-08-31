import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/edit_ids.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

void main() {
  test('assignEditIds fills nulls and de-duplicates collisions', () {
    const a = PressGesture(common: TriggerCommon(threshold: '1'));
    // Two gestures sharing the same explicit editId (as after a duplicate).
    final shared = PressGesture(
      common: const TriggerCommon().copyWith(threshold: '2', editId: 7),
    );
    final config = Config(
      mouseNodes: [
        const GestureNode.leaf(a),
        GestureNode.leaf(shared),
        GestureNode.leaf(shared),
      ],
    );

    final out = assignEditIds(config);
    final ids = out.mouseGestures
        .map((g) => g.common.editId)
        .toList(growable: false);

    expect(ids.every((id) => id != null), isTrue);
    expect(ids.toSet().length, 3, reason: 'ids must be unique');
  });

  test('preserveEditIds carries ids across a save round-trip by index', () {
    final saved = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: TriggerCommon(threshold: '1')),
          ),
          GestureNode.leaf(
            PressGesture(common: TriggerCommon(threshold: '2')),
          ),
        ],
      ),
    );
    // Reload reconstructs gestures with null editIds but identical order.
    const reloaded = Config(
      mouseNodes: [
        GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
        GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '2'))),
      ],
    );

    final remapped = preserveEditIds(from: saved, to: reloaded);
    expect(
      remapped.mouseGestures[0].common.editId,
      saved.mouseGestures[0].common.editId,
    );
    expect(
      remapped.mouseGestures[1].common.editId,
      saved.mouseGestures[1].common.editId,
    );
  });

  test('preserveEditIds carries nested action ids too', () {
    const actions = [
      TriggerAction(
        action: ActionGroup(
          actions: [TriggerAction(action: SleepAction(milliseconds: 1))],
        ),
      ),
    ];
    const config = Config(
      mouseNodes: [
        GestureNode.leaf(
          PressGesture(common: TriggerCommon(actions: actions)),
        ),
      ],
    );
    final saved = assignEditIds(config);

    List<int?> keysOf(Config c) {
      final root = c.mouseGestures.single.common.actions.single;
      final child = (root.action as ActionGroup).actions.single;
      return [root.editId, child.editId];
    }

    expect(keysOf(saved).whereType<int>(), hasLength(2));
    expect(keysOf(preserveEditIds(from: saved, to: config)), keysOf(saved));
  });
}
