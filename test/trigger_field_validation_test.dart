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
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _groupEditId = 901;
const _gestureEditId = 9001;

class _SeededGroup extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.group(
            name: 'G1',
            editId: _groupEditId,
            threshold: '10',
            children: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

class _SeededAction extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.leaf(
            WheelGesture(
              direction: WheelDirection.down,
              common: TriggerCommon(
                editId: _gestureEditId,
                actions: [
                  TriggerAction(
                    action: CommandAction(command: 'first'),
                    on: TriggerOn.update,
                    interval: '4',
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

Future<ProviderContainer> _pump(
  WidgetTester tester,
  ConfigController Function() controller,
  Widget child,
) async {
  tester.view
    ..physicalSize = const Size(1000, 1600)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [configControllerProvider.overrideWith(controller)],
  );
  addTearDown(container.dispose);
  await container.read(configControllerProvider.future);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: FScaffold(child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Finder _fieldWithHint(String hint) => find.descendant(
  of: find.byWidgetPredicate(
    (widget) => widget is FTextField && widget.hint == hint,
  ),
  matching: find.byType(EditableText),
);

String _textOf(WidgetTester tester, Finder field) =>
    tester.widget<EditableText>(field).controller.text;

Future<void> _type(WidgetTester tester, Finder field, String text) async {
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

void main() {
  group('threshold', () {
    const location = GestureGroupLocation(
      device: DeviceType.mouse,
      editId: _groupEditId,
    );

    Future<ProviderContainer> pumpGroup(WidgetTester tester) => _pump(
      tester,
      _SeededGroup.new,
      const GroupSettingsView(location: location),
    );

    Finder field(WidgetTester tester) => _fieldWithHint(
      AppLocalizations.of(
        tester.element(find.byType(GroupSettingsView)),
      ).triggerFieldThresholdHint,
    );

    String? stored(ProviderContainer container) => gestureGroupAt(
      container.read(draftConfigProvider),
      location,
    )?.threshold;

    testWidgets('text that is not a number is rejected', (tester) async {
      final container = await pumpGroup(tester);

      await _type(tester, field(tester), 'abc');

      expect(_textOf(tester, field(tester)), '10');
      expect(stored(container), '10');
    });

    testWidgets('a number and a range are taken', (tester) async {
      final container = await pumpGroup(tester);

      await _type(tester, field(tester), '0.5');
      expect(stored(container), '0.5');

      await _type(tester, field(tester), '50-200');
      expect(stored(container), '50-200');
    });
  });

  group('interval', () {
    const gesture = GestureLocation(
      device: DeviceType.mouse,
      editId: _gestureEditId,
    );

    Future<ProviderContainer> pumpActions(WidgetTester tester) async {
      final anchorController = ScrollAnchorController();
      final scrollController = ScrollController();
      final container = await _pump(
        tester,
        _SeededAction.new,
        CustomScrollView(
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
      );
      await tester.tap(find.byIcon(FLucideIcons.chevronDown));
      await tester.pumpAndSettle();
      return container;
    }

    Finder field(WidgetTester tester) => _fieldWithHint(
      AppLocalizations.of(
        tester.element(find.byType(ActionListEditor)),
      ).actionIntervalHint,
    );

    String? stored(ProviderContainer container) {
      final config = container.read(draftConfigProvider);
      return actionsOf(gestureAt(config, gesture)!.common).single.interval;
    }

    testWidgets('text that is not a number is rejected', (tester) async {
      final container = await pumpActions(tester);

      await _type(tester, field(tester), 'abc');

      expect(_textOf(tester, field(tester)), '4');
      expect(stored(container), '4');
    });

    testWidgets('a signed number and a bare sign are taken', (tester) async {
      final container = await pumpActions(tester);

      await _type(tester, field(tester), '-10');
      expect(stored(container), '-10');

      await _type(tester, field(tester), '+');
      expect(stored(container), '+');
    });
  });
}
