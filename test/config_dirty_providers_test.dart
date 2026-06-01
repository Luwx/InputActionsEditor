import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/lenses/action_lenses.dart';
import 'package:input_actions_editor/state/edit/lenses/gesture_lenses.dart';

void main() {
  group('config dirty providers', () {
    test(
      'mouse buttons section becomes clean when restored to saved values',
      () async {
        const savedConfig = Config(
          mouseGestures: [
            PressGesture(
              common: TriggerCommon(
                mouseButtons: [MouseButtonValue.middle],
              ),
            ),
          ],
        );
        final currentConfig = Config(
          mouseGestures: [
            const PressGesture(
              common: TriggerCommon(),
            ).withCommon(
              const TriggerCommon().copyWith(
                mouseButtons: [MouseButtonValue.middle],
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
              const GestureSectionLocation(
                gesture: GestureLocation(device: DeviceType.mouse, index: 0),
                field: GestureSectionDirtyField.mouseButtons,
              ),
            ),
          ),
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
          mouseGestures: [
            PressGesture(
              common: TriggerCommon(actions: [savedAction]),
            ),
          ],
        );
        final currentConfig = Config(
          mouseGestures: [
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
              const GestureSectionLocation(
                gesture: GestureLocation(device: DeviceType.mouse, index: 0),
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
          mouseGestures: [
            PressGesture(
              common: TriggerCommon(actions: [savedAction]),
            ),
          ],
        );
        final currentConfig = Config(
          mouseGestures: [
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
              const ActionLocation(
                gesture: GestureLocation(device: DeviceType.mouse, index: 0),
                actionIndex: 0,
              ),
            ),
          ),
          DirtyMarkState.clean,
        );
      },
    );

    test('lens dirty reports changed scalar fields', () async {
      const location = ActionLocation(
        gesture: GestureLocation(device: DeviceType.mouse, index: 0),
        actionIndex: 0,
      );
      const savedConfig = Config(
        mouseGestures: [
          PressGesture(
            common: TriggerCommon(
              actions: [
                TriggerAction(action: CommandAction(command: 'saved')),
              ],
            ),
          ),
        ],
      );
      const currentConfig = Config(
        mouseGestures: [
          PressGesture(
            common: TriggerCommon(
              actions: [
                TriggerAction(action: CommandAction(command: 'draft')),
              ],
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
        container.read(lensDirtyStateProvider(actionCommandLens(location))),
        DirtyMarkState.changedFromSaved,
      );
    });

    test('lens dirty treats a missing saved path as new unsaved', () async {
      const location = GestureLocation(device: DeviceType.mouse, index: 0);
      const currentConfig = Config(
        mouseGestures: [
          PressGesture(common: TriggerCommon(id: 'new')),
        ],
      );

      final container = _containerWith(
        current: currentConfig,
        saved: const Config(),
      );
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);

      expect(
        container.read(lensDirtyStateProvider(gestureIdLens(location))),
        DirtyMarkState.newUnsaved,
      );
    });

    test(
      'gesture becomes clean when block events is toggled back to default',
      () async {
        const savedConfig = Config(
          mouseGestures: [
            PressGesture(
              common: TriggerCommon(),
            ),
          ],
        );
        final currentConfig = Config(
          mouseGestures: [
            const PressGesture(
              common: TriggerCommon(blockEvents: false),
            ).withCommon(
              const TriggerCommon().copyWith(blockEvents: true),
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
            gestureDirtyStateProvider(
              const GestureLocation(device: DeviceType.mouse, index: 0),
            ),
          ),
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
  Config? get savedConfig => saved;

  @override
  Future<Config> build() async => current;
}
