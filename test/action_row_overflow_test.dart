import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _seedEditId = 9001;

class _SeededController extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(
              common: TriggerCommon(
                editId: _seedEditId,
                actions: [
                  TriggerAction(
                    action: InputAction(
                      entries: [
                        InputEntry(
                          device: InputDevice.keyboard,
                          tokens: ['leftctrl+c'],
                        ),
                      ],
                    ),
                    on: TriggerOn.update,
                    interval: '33333333',
                    threshold: '9999999',
                    limit: 7628,
                    conflicting: false,
                    editId: 9101,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

void main() {
  const gesture = GestureLocation(
    device: DeviceType.mouse,
    editId: _seedEditId,
  );

  testWidgets('a row crowded with chips does not overflow', (tester) async {
    tester.view
      ..physicalSize = const Size(620, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(_SeededController.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final anchorController = ScrollAnchorController();
    final scrollController = ScrollController();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: FScaffold(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverSmartAnchor(
                    controller: anchorController,
                    scrollPosition: () => scrollController.hasClients
                        ? scrollController.position
                        : null,
                    child: ScrollAnchorScope(
                      controller: anchorController,
                      child: const EditLocationScope(
                        gesture: gesture,
                        child: ActionListEditor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the chips sit at the right of the row', (tester) async {
    tester.view
      ..physicalSize = const Size(1400, 700)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(_SeededController.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final anchorController = ScrollAnchorController();
    final scrollController = ScrollController();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: FScaffold(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverSmartAnchor(
                    controller: anchorController,
                    scrollPosition: () => scrollController.hasClients
                        ? scrollController.position
                        : null,
                    child: ScrollAnchorScope(
                      controller: anchorController,
                      child: const EditLocationScope(
                        gesture: gesture,
                        child: ActionListEditor(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chips = tester.getRect(find.textContaining('Conflicting').first);
    final trailing = tester.getRect(find.byIcon(FLucideIcons.chevronDown));
    // The last chip ends where the row's buttons begin.
    expect(trailing.left - chips.right, lessThan(40));
  });
}
