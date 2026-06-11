import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edits/gesture_edits.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show gestureLocationAt;
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/projections/conflict_provider.dart';
import 'package:input_actions_editor/store/config_controller.dart';

class _FakeConfigController extends ConfigController {
  _FakeConfigController(Config seed) : _seed = assignEditIds(seed);

  final Config _seed;

  @override
  Future<EditSession> build() async => EditSession(draft: _seed, saved: _seed);
}

ProviderContainer _containerWith(Config seed) {
  return ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(() => _FakeConfigController(seed)),
    ],
  );
}

// A minimal instant multi-button press gesture (stand-in for any gesture that
// holds exclusive rights to a specific button combo).
PressGesture _instantPress(
  List<MouseButtonValue> buttons, {
  String name = 'instant press',
}) => PressGesture(
  common: TriggerCommon(name: name, mouseButtons: buttons),
  instant: true,
);

void main() {
  group('conflictReportProvider reactive wiring', () {
    // Helper that builds a container, primes the provider, and collapses the
    // debounce so every edit triggers an immediate synchronous recompute.
    Future<ProviderContainer> makeContainer(Config seed) async {
      final container = _containerWith(seed);
      addTearDown(container.dispose);
      await container.read(configControllerProvider.future);
      container.read(conflictReportProvider.notifier).interval = Duration.zero;
      return container;
    }

    test('baseline config with no conflicts starts clean', () async {
      final seed = Config(
        mouseGestures: [
          _instantPress([MouseButtonValue.right]),
          const StrokeGesture(
            common: TriggerCommon(mouseButtons: [MouseButtonValue.middle]),
          ),
        ],
      );
      final container = await makeContainer(seed);
      expect(container.read(conflictReportProvider).hasAny, isFalse);
    });

    test('adding a conflicting gesture is reflected immediately', () async {
      final seed = Config(
        mouseGestures: [
          _instantPress([MouseButtonValue.right, MouseButtonValue.left]),
        ],
      );
      final container = await makeContainer(seed);
      container
          .read(configControllerProvider.notifier)
          // A wildcard stroke (no buttons) conflicts because it can activate on
          // any combo including right+left.
          .add(
            AddGesture(
              DeviceType.mouse,
              const StrokeGesture(common: TriggerCommon()),
            ),
          );

      final draft = container.read(draftConfigProvider);
      final stroke = gestureLocationAt(
        draft,
        DeviceType.mouse,
        draft.mouseGestures.length - 1,
      )!;
      final report = container.read(conflictReportProvider);

      expect(report.hasAny, isTrue);
      expect(report.forGesture(stroke), hasLength(1));
      expect(report.forGesture(stroke).single.kind, ConflictKind.instantPress);
    });

    test('edit that removes the conflict clears the report', () async {
      final seed = Config(
        mouseGestures: [
          _instantPress([MouseButtonValue.right, MouseButtonValue.left]),
        ],
      );
      final container = await makeContainer(seed);
      final controller = container.read(configControllerProvider.notifier)
        ..add(
          AddGesture(
            DeviceType.mouse,
            const StrokeGesture(common: TriggerCommon()),
          ),
        );
      final draft = container.read(draftConfigProvider);
      final stroke = gestureLocationAt(
        draft,
        DeviceType.mouse,
        draft.mouseGestures.length - 1,
      )!;

      expect(container.read(conflictReportProvider).hasAny, isTrue);

      // Assigning [left] (size 1) makes the stroke mutually exclusive with the
      // size-2 instant, press plugin requires pressed-count == button list size
      controller.add(
        SetLens(gestureMouseButtonsLens(stroke), [MouseButtonValue.left]),
      );

      expect(
        container.read(conflictReportProvider).forGesture(stroke),
        isEmpty,
      );
    });

    test(
      'sequential button edits produce correct conflict state each time',
      () async {
        // Exercises the full add → [left] → [right] → [left,right] flow so the
        // provider stays correct across multiple consecutive edits.
        final seed = Config(
          mouseGestures: [
            _instantPress([MouseButtonValue.right, MouseButtonValue.left]),
          ],
        );
        final container = await makeContainer(seed);
        final controller = container.read(configControllerProvider.notifier)
          // Step 1 - wildcard stroke: conflict.
          ..add(
            AddGesture(
              DeviceType.mouse,
              const StrokeGesture(common: TriggerCommon()),
            ),
          );
        final draft = container.read(draftConfigProvider);
        final strokeLocation = gestureLocationAt(
          draft,
          DeviceType.mouse,
          draft.mouseGestures.length - 1,
        )!;
        final instantPressLocation = gestureLocationAt(
          draft,
          DeviceType.mouse,
          0,
        )!;

        var report = container.read(conflictReportProvider);
        expect(report.forGesture(strokeLocation), hasLength(1));
        expect(
          report.forGesture(strokeLocation).single.kind,
          ConflictKind.instantPress,
        );
        expect(
          report.forGesture(strokeLocation).single.other(strokeLocation),
          instantPressLocation,
        );

        // Step 2 assign [left] only: no conflict (size 1 ≠ size 2).
        controller.add(
          SetLens(gestureMouseButtonsLens(strokeLocation), [
            MouseButtonValue.left,
          ]),
        );
        expect(
          container.read(conflictReportProvider).forGesture(strokeLocation),
          isEmpty,
        );

        // Step 3 - change to [right] only: still no conflict (size 1 ≠ size 2).
        controller.add(
          SetLens(gestureMouseButtonsLens(strokeLocation), [
            MouseButtonValue.right,
          ]),
        );
        expect(
          container.read(conflictReportProvider).forGesture(strokeLocation),
          isEmpty,
        );

        // Step 4 - assign [right, left]: conflict again
        controller.add(
          SetLens(
            gestureMouseButtonsLens(strokeLocation),
            [MouseButtonValue.right, MouseButtonValue.left],
          ),
        );
        report = container.read(conflictReportProvider);
        expect(report.forGesture(strokeLocation), hasLength(1));
        expect(
          report.forGesture(strokeLocation).single.kind,
          ConflictKind.instantPress,
        );
      },
    );
  });
}
