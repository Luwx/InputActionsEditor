// Regression for the reorder-vs-saved identity bug: moving a gesture within
// its list must keep the editor, dirty markers, and revert addressing *that*
// gesture's saved baseline — not whatever gesture now occupies its old index.
// Locations are identity-keyed (editId), so the same location reads the same
// logical gesture from the draft and the saved snapshot by construction.

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

        Config draft() =>
            container.read(configControllerProvider).requireValue.draft;

        final wheel1 = gestureLocationAt(draft(), DeviceType.mouse, 0)!;
        final wheel2 = gestureLocationAt(draft(), DeviceType.mouse, 1)!;

        // Move Wheel #1 below Wheel #2.
        container
            .read(configControllerProvider.notifier)
            .add(
              ReorderAndUpdateGroups(
                DeviceType.mouse,
                [wheel2, wheel1],
                const {},
              ),
            );
        expect(gestureIndexOf(draft(), wheel1), 1);

        // The identity location keeps addressing Wheel #1 — and its saved
        // baseline — after the move.
        final editorState = container.read(gestureEditorProvider(wheel1));
        expect(editorState.gesture?.common.name, 'Wheel #1');
        expect(editorState.savedGesture?.common.name, 'Wheel #1');
        expect(
          (editorState.savedGesture as WheelGesture?)?.direction,
          WheelDirection.left,
        );
        expect(
          container.read(lensDirtyStateProvider(wheelDirectionLens(wheel1))),
          DirtyMarkState.clean,
        );

        // Editing the moved gesture marks only it dirty…
        container
            .read(configControllerProvider.notifier)
            .add(
              UpdateGesture(
                wheel1,
                (gesture) => (gesture as WheelGesture).copyWith(
                  direction: WheelDirection.up,
                ),
              ),
              scope: wheel1,
            );
        expect(
          container.read(lensDirtyStateProvider(wheelDirectionLens(wheel1))),
          DirtyMarkState.changedFromSaved,
        );
        expect(
          container.read(lensDirtyStateProvider(wheelDirectionLens(wheel2))),
          DirtyMarkState.clean,
        );

        // …and revert restores Wheel #1's own saved value, in its new slot.
        container
            .read(configControllerProvider.notifier)
            .revert(wheelDirectionLens(wheel1), scope: wheel1);
        expect(
          (draft().mouseGestures[1] as WheelGesture).direction,
          WheelDirection.left,
        );

        // Trigger-config revert through the editor restores the right gesture
        // too.
        container
            .read(configControllerProvider.notifier)
            .add(
              UpdateGesture(
                wheel1,
                (gesture) => (gesture as WheelGesture).copyWith(
                  direction: WheelDirection.up,
                ),
              ),
              scope: wheel1,
            );

        final savedForRevert = container
            .read(gestureEditorProvider(wheel1))
            .savedGesture!;
        container
            .read(gestureEditorProvider(wheel1).notifier)
            .revertTriggerConfig(savedForRevert);

        final reverted = draft().mouseGestures[1] as WheelGesture;
        expect(reverted.common.name, 'Wheel #1');
        expect(reverted.direction, WheelDirection.left);
      },
    );

    test('a new gesture has no saved backing wherever it sits', () async {
      const seed = Config(
        mouseGestures: [
          WheelGesture(
            common: TriggerCommon(name: 'Wheel #1'),
            direction: WheelDirection.left,
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          configControllerProvider.overrideWith(() => _SeededController(seed)),
        ],
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      container
          .read(configControllerProvider.notifier)
          .add(
            AddGesture(
              DeviceType.mouse,
              const WheelGesture(
                common: TriggerCommon(name: 'Wheel #2'),
                direction: WheelDirection.right,
              ),
            ),
          );
      final draft = container.read(configControllerProvider).requireValue.draft;
      final added = gestureLocationAt(draft, DeviceType.mouse, 1)!;

      expect(container.read(gestureEditorProvider(added)).savedGesture, isNull);
      expect(
        container.read(lensDirtyStateProvider(wheelDirectionLens(added))),
        DirtyMarkState.newUnsaved,
      );
    });
  });
}

class _SeededController extends ConfigController {
  _SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Future<EditSession> build() async =>
      EditSession(draft: _normalized, saved: _normalized);
}
