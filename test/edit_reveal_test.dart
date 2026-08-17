import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/action_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';

class _SeededController extends ConfigController {
  _SeededController(this.seed);

  final Config seed;

  @override
  Future<EditSession> build() async {
    final normalized = assignEditIds(seed);
    return EditSession(draft: normalized, saved: normalized);
  }
}

void main() {
  const seed = Config(
    mouseNodes: [
      GestureNode.leaf(PressGesture(common: TriggerCommon(threshold: '1'))),
      GestureNode.leaf(
        PressGesture(
          common: TriggerCommon(
            threshold: '2',
            actions: [
              TriggerAction(action: CommandAction(command: 'first')),
              TriggerAction(action: CommandAction(command: 'second')),
            ],
          ),
        ),
      ),
    ],
  );

  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(() => _SeededController(seed)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);
  });

  ConfigController controller() =>
      container.read(configControllerProvider.notifier);

  Config draft() => container.read(configControllerProvider).requireValue.draft;

  GestureLocation locationAt(int index) =>
      gestureLocationAt(draft(), DeviceType.mouse, index)!;

  EditReveal? reveal() => container.read(editRevealProvider);

  test('undoing a gesture edit points at that gesture', () {
    final location = locationAt(1);
    controller()
      ..coalesceEnabled = false
      ..add(
        UpdateGestureCommon(
          location,
          (common) => common.copyWith(threshold: '99'),
        ),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());

    expect(reveal()?.gesture, location);
    expect(reveal()?.actionEditId, isNull);
  });

  test('undoing an action edit points at the action inside its gesture', () {
    final location = locationAt(1);
    final action = actionsOf(gestureAt(draft(), location)!.common).last;

    controller()
      ..coalesceEnabled = false
      ..add(
        SetLens<String>(
          actionCommandLens(
            ActionLocation(gesture: location, editId: action.editId!),
          ),
          'changed',
        ),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());

    expect(reveal()?.gesture, location);
    expect(reveal()?.actionEditId, action.editId);
  });

  test('redoing points at the same place, with a fresh ticket', () {
    final location = locationAt(0);
    controller()
      ..coalesceEnabled = false
      ..add(
        UpdateGestureCommon(
          location,
          (common) => common.copyWith(threshold: '77'),
        ),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    final afterUndo = reveal()!;

    controller().redo(scope: const GesturesScope());

    expect(reveal()!.gesture, afterUndo.gesture);
    expect(reveal()!.ticket, greaterThan(afterUndo.ticket));
  });

  test('undoing a removal points at the gesture that comes back', () {
    final location = locationAt(0);
    controller()
      ..coalesceEnabled = false
      ..add(RemoveGesture(location), scope: const GesturesScope())
      ..undo(scope: const GesturesScope());

    expect(reveal()?.gesture, location);
  });

  test('undoing an addition has nothing to point at', () {
    controller()
      ..coalesceEnabled = false
      ..add(
        AddGesture(
          DeviceType.mouse,
          const PressGesture(common: TriggerCommon(threshold: '3')),
        ),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());

    expect(reveal(), isNull);
  });

  test('replaying a step onto a vanished action changes nothing', () {
    final location = locationAt(1);
    final action = actionsOf(gestureAt(draft(), location)!.common).last;
    final target = ActionLocation(gesture: location, editId: action.editId!);
    final edit = SetLens<String>(actionCommandLens(target), 'changed');

    controller()
      ..coalesceEnabled = false
      ..add(RemoveGesture(location), scope: const GesturesScope());

    // The gesture, and with it the action, is gone; the step must not throw.
    expect(edit.apply(draft()), draft());
  });

  test('redoing an add keeps the id later steps address it by', () {
    final location = locationAt(0);
    final notifier = controller()..coalesceEnabled = false;

    final target = ActionLocation(gesture: location, editId: 7001);
    notifier
      ..add(
        AddAction(
          location,
          const TriggerAction(
            action: CommandAction(command: 'new'),
            editId: 7001,
          ),
        ),
        scope: const GesturesScope(),
      )
      ..add(
        SetLens<String>(actionCommandLens(target), 'edited'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope())
      ..undo(scope: const GesturesScope())
      ..redo(scope: const GesturesScope())
      ..redo(scope: const GesturesScope());

    final action = actionAt(draft(), target);
    expect(action, isNotNull);
    expect((action!.action as CommandAction).command, 'edited');
  });

  test('a change inside a group points at the action, not the group', () {
    const groupId = 8001;
    const childId = 8002;
    final location = locationAt(0);
    final notifier = controller()..coalesceEnabled = false;

    final target = ActionLocation(gesture: location, editId: childId);

    notifier
      ..add(
        AddAction(
          location,
          const TriggerAction(
            action: ActionGroup(
              actions: [
                TriggerAction(
                  action: CommandAction(command: 'inner'),
                  editId: childId,
                ),
              ],
            ),
            editId: groupId,
          ),
        ),
        scope: const GesturesScope(),
      )
      ..add(
        SetLens<int?>(actionLimitLens(target), 5),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());

    expect(reveal()?.actionEditId, childId);
  });

  test('undoing a group edit points at that group', () async {
    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(
          () => _SeededController(
            const Config(
              mouseNodes: [
                GestureNode.group(
                  name: 'G1',
                  editId: 901,
                  children: [
                    GestureNode.leaf(PressGesture(common: TriggerCommon())),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    const location = GestureGroupLocation(
      device: DeviceType.mouse,
      editId: 901,
    );
    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureGroupThresholdLens(location), '42'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());

    final reveal = container.read(editRevealProvider);
    expect(reveal?.group, location);
    expect(reveal?.gesture, isNull);
    expect(
      changedGestureGroupFields(reveal!.before, reveal.after, location),
      contains(ConfigDirtyField.gestureGroupThreshold),
    );
  });
}
