import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';

void main() {
  group('gesture reorder saved identity', () {
    test(
      'editor saved gesture follows moved gesture, not destination index',
      () async {
        const seed = Config(
          mouseGestures: [
            WheelGesture(
              common: TriggerCommon(name: 'Wheel #1', groupId: 'wheel'),
              direction: WheelDirection.left,
            ),
            WheelGesture(
              common: TriggerCommon(name: 'Wheel #2', groupId: 'wheel'),
              direction: WheelDirection.right,
            ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            configControllerProvider.overrideWith(
              () => _SeededController(seed),
            ),
          ],
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        container
            .read(configControllerProvider.notifier)
            .add(
              ReorderAndUpdateGroups(
                DeviceType.mouse,
                const [1, 0],
                const {},
              ),
            );

        const movedWheel1 = GestureLocation(
          device: DeviceType.mouse,
          index: 1,
        );
        final editorState = container.read(gestureEditorProvider(movedWheel1));

        expect(editorState.gesture?.common.name, 'Wheel #1');
        expect(editorState.savedGesture?.common.name, 'Wheel #1');
        expect(
          (editorState.savedGesture as WheelGesture?)?.direction,
          WheelDirection.left,
        );
        expect(
          container.read(
            lensDirtyStateProvider(wheelDirectionLens(movedWheel1)),
          ),
          DirtyMarkState.clean,
        );

        container
            .read(configControllerProvider.notifier)
            .add(
              UpdateGesture(
                DeviceType.mouse,
                movedWheel1.index,
                (gesture) => (gesture as WheelGesture).copyWith(
                  direction: WheelDirection.up,
                ),
              ),
              scope: movedWheel1,
            );
        expect(
          container.read(
            lensDirtyStateProvider(wheelDirectionLens(movedWheel1)),
          ),
          DirtyMarkState.changedFromSaved,
        );

        container
            .read(configControllerProvider.notifier)
            .revert(wheelDirectionLens(movedWheel1), scope: movedWheel1);
        expect(
          (container
                      .read(configControllerProvider)
                      .requireValue
                      .draft
                      .mouseGestures[movedWheel1.index]
                  as WheelGesture)
              .direction,
          WheelDirection.left,
        );

        container
            .read(configControllerProvider.notifier)
            .add(
              UpdateGesture(
                DeviceType.mouse,
                movedWheel1.index,
                (gesture) => (gesture as WheelGesture).copyWith(
                  direction: WheelDirection.up,
                ),
              ),
              scope: movedWheel1,
            );

        final savedForRevert = container
            .read(gestureEditorProvider(movedWheel1))
            .savedGesture!;
        container
            .read(gestureEditorProvider(movedWheel1).notifier)
            .revertTriggerConfig(savedForRevert);

        final reverted =
            container
                    .read(configControllerProvider)
                    .requireValue
                    .draft
                    .mouseGestures[movedWheel1.index]
                as WheelGesture;
        expect(reverted.common.name, 'Wheel #1');
        expect(reverted.direction, WheelDirection.left);
      },
    );
  });
}

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Future<EditSession> build() async =>
      EditSession(draft: _normalized, saved: _normalized);
}
