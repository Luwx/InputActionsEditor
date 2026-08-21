import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/collapsible_section.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _seedEditId = 9001;

class _SeededController extends ConfigController {
  static const common = TriggerCommon(
    actions: [TriggerAction(action: CommandAction(command: 'first'))],
  );

  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: common.copyWith(editId: _seedEditId)),
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

void main() {
  testWidgets('an undo of a hidden action option opens Other options', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 1600)
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
                        gesture: GestureLocation(
                          device: DeviceType.mouse,
                          editId: _seedEditId,
                        ),
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

    const gesture = GestureLocation(
      device: DeviceType.mouse,
      editId: _seedEditId,
    );
    final draft = container.read(configControllerProvider).requireValue.draft;
    final action = actionsOf(gestureAt(draft, gesture)!.common).single;
    final location = ActionLocation(
      gesture: gesture,
      editId: action.editId!,
    );

    // Interval is not set, so it lives in the card's "Other options".
    final notifier = container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(actionIntervalLens(location), '40'),
        scope: const GesturesScope(),
      );
    await tester.pumpAndSettle();
    expect(find.byType(CollapsibleSection), findsNothing);

    notifier.undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // The reveal opened the card, and the accordion holding interval with it.
    final accordion = find.byType(CollapsibleSection);
    expect(accordion, findsOneWidget);
    final opened = tester.getSize(accordion).height;

    await tester.tap(find.text('Other Options'));
    await tester.pumpAndSettle();

    expect(tester.getSize(accordion).height, lessThan(opened));
  });
}
