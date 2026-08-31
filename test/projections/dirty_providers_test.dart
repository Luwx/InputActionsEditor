import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/edits/group_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';

import '../helpers/seeded_config_controller.dart';

ProviderContainer _containerWith({
  required Config current,
  required Config? saved,
}) {
  return ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(
        () => DivergingController(current: current, saved: saved),
      ),
    ],
  );
}

/// Identity location of the first mouse gesture in the live draft.
/// The first action of the first mouse gesture, by identity.
ActionLocation _mouseAction0(ProviderContainer container) {
  final gesture = _mouse0(container);
  final draft = container.read(configControllerProvider).requireValue.draft;
  return ActionLocation(
    gesture: gesture,
    editId: gestureAt(draft, gesture)!.common.actions.first.editId!,
  );
}

GestureLocation _mouse0(ProviderContainer container) => gestureLocationAt(
  container.read(configControllerProvider).requireValue.draft,
  DeviceType.mouse,
  0,
)!;

void main() {
  group('config dirty providers', () {
    test(
      'mouse buttons section becomes clean when restored to saved values',
      () async {
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  mouseButtons: [MouseButtonValue.middle],
                ),
              ),
            ),
          ],
        );
        final currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              const PressGesture(
                common: TriggerCommon(),
              ).withCommon(
                const TriggerCommon().copyWith(
                  mouseButtons: [MouseButtonValue.middle],
                ),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureSectionDirtyStateProvider(
              GestureSectionLocation(
                gesture: _mouse0(container),
                field: GestureSectionDirtyField.mouseButtons,
              ),
            ),
          ),
          DirtyMarkState.clean,
        );
      },
    );

    test(
      'point condition section is clean when only decimal spelling differs',
      () async {
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  conditions: VariableCondition(
                    variable: ConditionVariableRef.custom(
                      'pointer_position_screen_percentage',
                    ),
                    operator: ConditionOperator.equals,
                    value: ConditionValue.point(0.2, 0.2),
                  ),
                ),
              ),
            ),
          ],
        );
        const currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(
                  conditions: VariableCondition(
                    variable: ConditionVariableRef.custom(
                      'pointer_position_screen_percentage',
                    ),
                    operator: ConditionOperator.equals,
                    value: ConditionValue.point(0.2, 0.2),
                  ),
                ),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureSectionDirtyStateProvider(
              GestureSectionLocation(
                gesture: _mouse0(container),
                field: GestureSectionDirtyField.triggerConditions,
              ),
            ),
          ),
          DirtyMarkState.clean,
        );
        expect(
          container.read(gestureDirtyStateProvider(_mouse0(container))),
          DirtyMarkState.clean,
        );
      },
    );

    test(
      'actions section becomes clean when action is manually restored',
      () async {
        const savedAction = TriggerAction(
          action: CommandAction(command: 'echo saved'),
        );
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(actions: [savedAction]),
              ),
            ),
          ],
        );
        final currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              const PressGesture(
                common: TriggerCommon(),
              ).withCommon(
                const TriggerCommon().copyWith(
                  actions: [
                    const TriggerAction(
                      action: CommandAction(command: 'echo draft'),
                    ).copyWith(
                      action: const CommandAction(command: 'echo saved'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureSectionDirtyStateProvider(
              GestureSectionLocation(
                gesture: _mouse0(container),
                field: GestureSectionDirtyField.actions,
              ),
            ),
          ),
          DirtyMarkState.clean,
        );
      },
    );

    test(
      'command action becomes clean when wait is toggled back to unchecked',
      () async {
        const savedAction = TriggerAction(
          action: CommandAction(command: 'echo saved'),
        );
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(actions: [savedAction]),
              ),
            ),
          ],
        );
        final currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              const PressGesture(
                common: TriggerCommon(),
              ).withCommon(
                const TriggerCommon().copyWith(
                  actions: [
                    const TriggerAction(
                      action: CommandAction(command: 'echo saved', wait: true),
                    ).copyWith(
                      action: const CommandAction(
                        command: 'echo saved',
                        wait: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            actionDirtyStateProvider(
              _mouseAction0(container),
            ),
          ),
          DirtyMarkState.clean,
        );
      },
    );

    test('lens dirty reports changed scalar fields', () async {
      const savedConfig = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(action: CommandAction(command: 'saved')),
                ],
              ),
            ),
          ),
        ],
      );
      const currentConfig = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                actions: [
                  TriggerAction(action: CommandAction(command: 'draft')),
                ],
              ),
            ),
          ),
        ],
      );

      final container = _containerWith(
        current: currentConfig,
        saved: savedConfig,
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      final location = _mouseAction0(container);
      expect(
        container.read(lensDirtyStateProvider(actionCommandLens(location))),
        DirtyMarkState.changedFromSaved,
      );
    });

    test('lens dirty treats a missing saved path as new unsaved', () async {
      const currentConfig = Config(
        mouseNodes: [
          GestureNode.leaf(PressGesture(common: TriggerCommon(id: 'new'))),
        ],
      );

      final container = _containerWith(
        current: currentConfig,
        saved: const Config(),
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      expect(
        container.read(
          lensDirtyStateProvider(gestureIdLens(_mouse0(container))),
        ),
        DirtyMarkState.newUnsaved,
      );
    });

    group('gestureTriggerConfigDirtyState', () {
      test(
        'is changedFromSaved when swipe mode changes direction→angle',
        () async {
          const savedConfig = Config(
            mouseNodes: [
              GestureNode.leaf(
                SwipeGesture(
                  common: TriggerCommon(),
                  mode: SwipeMode.direction(direction: SwipeDirection.right),
                ),
              ),
            ],
          );
          const currentConfig = Config(
            mouseNodes: [
              GestureNode.leaf(
                SwipeGesture(
                  common: TriggerCommon(),
                  mode: SwipeMode.angle(minAngle: 0, maxAngle: 90),
                ),
              ),
            ],
          );

          final container = _containerWith(
            current: currentConfig,
            saved: savedConfig,
          );
          addTearDown(container.dispose);
          await container.read(configControllerProvider.future);

          expect(
            container.read(
              gestureTriggerConfigDirtyStateProvider(_mouse0(container)),
            ),
            DirtyMarkState.changedFromSaved,
          );
        },
      );

      test('is changedFromSaved when swipe direction changes', () async {
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              SwipeGesture(
                common: TriggerCommon(),
                mode: SwipeMode.direction(direction: SwipeDirection.right),
              ),
            ),
          ],
        );
        const currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              SwipeGesture(
                common: TriggerCommon(),
                mode: SwipeMode.direction(direction: SwipeDirection.left),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureTriggerConfigDirtyStateProvider(_mouse0(container)),
          ),
          DirtyMarkState.changedFromSaved,
        );
      });

      test('is clean when swipe mode is identical to saved', () async {
        const config = Config(
          mouseNodes: [
            GestureNode.leaf(
              SwipeGesture(
                common: TriggerCommon(),
                mode: SwipeMode.direction(direction: SwipeDirection.right),
              ),
            ),
          ],
        );

        final container = _containerWith(current: config, saved: config);
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureTriggerConfigDirtyStateProvider(_mouse0(container)),
          ),
          DirtyMarkState.clean,
        );
      });

      test('is changedFromSaved when a TriggerCommon field changes', () async {
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              SwipeGesture(
                common: TriggerCommon(threshold: '5'),
                mode: SwipeMode.direction(direction: SwipeDirection.right),
              ),
            ),
          ],
        );
        const currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              SwipeGesture(
                common: TriggerCommon(threshold: '10'),
                mode: SwipeMode.direction(direction: SwipeDirection.right),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(
            gestureTriggerConfigDirtyStateProvider(_mouse0(container)),
          ),
          DirtyMarkState.changedFromSaved,
        );
      });

      test(
        'is clean when only action changes (actions are excluded)',
        () async {
          const savedConfig = Config(
            mouseNodes: [
              GestureNode.leaf(
                SwipeGesture(
                  common: TriggerCommon(
                    actions: [
                      TriggerAction(action: CommandAction(command: 'a')),
                    ],
                  ),
                  mode: SwipeMode.direction(direction: SwipeDirection.right),
                ),
              ),
            ],
          );
          const currentConfig = Config(
            mouseNodes: [
              GestureNode.leaf(
                SwipeGesture(
                  common: TriggerCommon(
                    actions: [
                      TriggerAction(action: CommandAction(command: 'b')),
                    ],
                  ),
                  mode: SwipeMode.direction(direction: SwipeDirection.right),
                ),
              ),
            ],
          );

          final container = _containerWith(
            current: currentConfig,
            saved: savedConfig,
          );
          addTearDown(container.dispose);
          await container.read(configControllerProvider.future);

          expect(
            container.read(
              gestureTriggerConfigDirtyStateProvider(_mouse0(container)),
            ),
            DirtyMarkState.clean,
          );
        },
      );
    });

    test(
      'gesture becomes clean when block events is toggled back to default',
      () async {
        const savedConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              PressGesture(
                common: TriggerCommon(),
              ),
            ),
          ],
        );
        final currentConfig = Config(
          mouseNodes: [
            GestureNode.leaf(
              const PressGesture(
                common: TriggerCommon(blockEvents: false),
              ).withCommon(
                const TriggerCommon().copyWith(blockEvents: true),
              ),
            ),
          ],
        );

        final container = _containerWith(
          current: currentConfig,
          saved: savedConfig,
        );
        addTearDown(container.dispose);
        await container.read(configControllerProvider.future);

        expect(
          container.read(gestureDirtyStateProvider(_mouse0(container))),
          DirtyMarkState.clean,
        );
      },
    );
  });

  // Regression for the reorder-vs-saved identity bug: moving a gesture within
  // its list must keep the editor, dirty markers, and revert addressing *that*
  // gesture's saved baseline, not whatever gesture now occupies its old index.
  // Locations are identity-keyed (editId), so the same location reads the same
  // logical gesture from the draft and the saved snapshot by construction.
  group('saved identity', () {
    group('gesture reorder saved identity', () {
      test(
        'editor saved gesture follows moved gesture, not destination index',
        () async {
          const seed = Config(
            mouseNodes: [
              GestureNode.leaf(
                WheelGesture(
                  common: TriggerCommon(name: 'Wheel #1'),
                  direction: WheelDirection.left,
                ),
              ),
              GestureNode.leaf(
                WheelGesture(
                  common: TriggerCommon(name: 'Wheel #2'),
                  direction: WheelDirection.right,
                ),
              ),
            ],
          );
          final container = ProviderContainer(
            overrides: [
              configControllerProvider.overrideWith(
                () => SeededController(seed),
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
                scope: const GesturesScope(),
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
              .revert(wheelDirectionLens(wheel1), scope: const GesturesScope());
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
                scope: const GesturesScope(),
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
          mouseNodes: [
            GestureNode.leaf(
              WheelGesture(
                common: TriggerCommon(name: 'Wheel #1'),
                direction: WheelDirection.left,
              ),
            ),
          ],
        );
        final container = ProviderContainer(
          overrides: [
            configControllerProvider.overrideWith(() => SeededController(seed)),
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
        final draft = container
            .read(configControllerProvider)
            .requireValue
            .draft;
        final added = gestureLocationAt(draft, DeviceType.mouse, 1)!;

        expect(
          container.read(gestureEditorProvider(added)).savedGesture,
          isNull,
        );
        expect(
          container.read(lensDirtyStateProvider(wheelDirectionLens(added))),
          DirtyMarkState.newUnsaved,
        );
      });
    });
  });
}
