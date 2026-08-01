import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/diff/dirty_locations.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart'
    show
        ActionLocation,
        GestureLocation,
        actionCommandLens,
        gestureIdLens,
        gestureLocationAt;
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';

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
              ActionLocation(gesture: _mouse0(container), actionIndex: 0),
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

      final location = ActionLocation(
        gesture: _mouse0(container),
        actionIndex: 0,
      );
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
}

ProviderContainer _containerWith({
  required Config current,
  required Config? saved,
}) {
  return ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(
        () => _FakeConfigController(current: current, saved: saved),
      ),
    ],
  );
}

class _FakeConfigController extends ConfigController {
  _FakeConfigController({required this.current, required this.saved});

  final Config current;
  final Config? saved;

  @override
  Future<EditSession> build() async {
    // Mirror the production session: the draft gets editIds and the saved
    // baseline shares them by position, so identity locations address the
    // same gesture in both snapshots.
    final draft = assignEditIds(current);
    return EditSession(
      draft: draft,
      saved: saved == null ? null : preserveEditIds(from: draft, to: saved!),
    );
  }
}

/// Identity location of the first mouse gesture in the live draft.
GestureLocation _mouse0(ProviderContainer container) => gestureLocationAt(
  container.read(configControllerProvider).requireValue.draft,
  DeviceType.mouse,
  0,
)!;
