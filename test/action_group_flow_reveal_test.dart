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
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const _seedEditId = 9001;

TriggerAction _cmd(String command) =>
    TriggerAction(action: CommandAction(command: command));

class _SeededController extends ConfigController {
  _SeededController(this.common);

  final TriggerCommon common;

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

/// Mirrors the gesture editor, [SliverSmartAnchor] included.
Widget _host(TriggerCommon common) {
  final anchorController = ScrollAnchorController();
  final scrollController = ScrollController();
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ProviderScope(
      overrides: [
        configControllerProvider.overrideWith(() => _SeededController(common)),
      ],
      child: FTheme(
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
  );
}

/// The conditions of the row being pointed at.
Finder get _liveFlash => find.byWidgetPredicate(
  (widget) => widget is AttentionFlash && widget.trigger != null,
);

/// A reveal takes several frames to reach its row.
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  var elapsed = Duration.zero;
  const step = Duration(milliseconds: 32);
  while (elapsed < timeout && finder.evaluate().isEmpty) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Only an expanded row renders a footer, so this counts open cards.
Finder get _rowFooters => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('action-footer-');
});

double _rowHeight(WidgetTester tester, String command) => tester
    .getSize(
      find
          .ancestor(
            of: find.text(command).first,
            matching: find.byType(CollapsibleListRow),
          )
          .first,
    )
    .height;

/// The outer group's disclosure: the first chevron inside its own card.
Finder _disclosureOf(WidgetTester tester, IconData icon) => find
    .descendant(
      of: find
          .ancestor(
            of: find.text('First match').first,
            matching: find.byType(AnimatedContainer),
          )
          .first,
      matching: find.byIcon(icon),
    )
    .first;

void main() {
  final nested = TriggerCommon(
    actions: [
      TriggerAction(
        action: ActionGroup(actions: [_cmd('child one'), _cmd('child two')]),
      ),
    ],
  );

  testWidgets('a step number opens the card of the row it stands for', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(nested));
    await tester.pumpAndSettle();

    // The preview only shows inside the group's open card.
    await tester.tap(find.text('First match').first);
    await tester.pumpAndSettle();
    expect(_rowFooters, findsOneWidget);

    await tester.tap(find.text('2'));
    await _pumpUntil(tester, _liveFlash);
    expect(_liveFlash, findsOneWidget);

    await tester.pumpAndSettle();

    // The group's card and the second child's card.
    expect(_rowFooters, findsNWidgets(2));
    expect(find.text('child two'), findsNWidgets(2));

    // Let go once settled, so reopening the card by hand does not flash again.
    expect(_liveFlash, findsNothing);
  });

  testWidgets('the reveal lands on the row once its card has grown', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(900, 620)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _host(
        TriggerCommon(
          actions: [
            TriggerAction(
              action: ActionGroup(
                actions: [
                  _cmd('child one'),
                  _cmd('child two'),
                  _cmd('child three'),
                  _cmd('child four'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('First match').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(CustomScrollView));
    final card = tester.getRect(
      find
          .ancestor(
            of: find.text('child four').first,
            matching: find.byType(CollapsibleListRow),
          )
          .first,
    );
    // The whole card, not the collapsed row's height.
    expect(card.top, greaterThanOrEqualTo(viewport.top));
    expect(card.bottom, lessThanOrEqualTo(viewport.bottom));
  });

  testWidgets('a step number unfolds the group holding the row', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1000, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(nested));
    await tester.pumpAndSettle();

    await tester.tap(find.text('First match').first);
    await tester.pumpAndSettle();

    // Fold by hand, then reach for a child through the preview.
    await tester.tap(_disclosureOf(tester, FLucideIcons.chevronDown));
    await tester.pumpAndSettle();
    expect(_rowHeight(tester, 'child one'), 0);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(_rowHeight(tester, 'child one'), greaterThan(0));
    expect(_rowFooters, findsNWidgets(2));
  });
}
