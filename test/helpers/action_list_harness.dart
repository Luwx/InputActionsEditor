import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
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
import 'package:input_actions_editor/ui/common/tree_list/list_transitions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

const seedEditId = 9001;

TriggerAction cmd(String command) =>
    TriggerAction(action: CommandAction(command: command));

Finder rowFor(String command) => find.ancestor(
  of: find.text(command),
  matching: find.byType(AnimatedContainer),
);

double leftOf(WidgetTester tester, String command) =>
    tester.getTopLeft(rowFor(command).first).dx;

class SeededActionsController extends ConfigController {
  SeededActionsController(this.common);

  final TriggerCommon common;

  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: common.copyWith(editId: seedEditId)),
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

Widget actionListHost(TriggerCommon common) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: ProviderScope(
    overrides: [
      configControllerProvider.overrideWith(
        () => SeededActionsController(common),
      ),
    ],
    child: FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: FToaster(
        child: FScaffold(
          child: SingleChildScrollView(
            child: ScrollAnchorScope(
              controller: ScrollAnchorController(),
              child: const EditLocationScope(
                gesture: GestureLocation(
                  device: DeviceType.mouse,
                  editId: seedEditId,
                ),
                child: ActionListEditor(),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);

/// The command summaries in the order they are laid out, ghosts included.
List<String> orderOf(WidgetTester tester) {
  const names = {'alpha', 'beta', 'gamma'};
  return [
    for (final text in tester.widgetList<Text>(find.byType(Text)))
      if (names.contains(text.data)) text.data!,
  ];
}

/// Rendered height of the row carrying [text]; a folded row measures 0.
double rowHeightOf(WidgetTester tester, Finder text) => tester
    .getSize(
      find.ancestor(of: text, matching: find.byType(CollapsibleListRow)).first,
    )
    .height;

double rowHeight(WidgetTester tester, String command) =>
    rowHeightOf(tester, find.text(command).first);

/// Routes the platform clipboard through a local string for the test.
void mockClipboard(WidgetTester tester) {
  String? clipboard;
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String;
      }
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboard};
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
}

/// The outer group's disclosure: the first chevron inside its own card.
Finder disclosureOf(WidgetTester tester, IconData icon) => find
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

/// Only an expanded row renders a footer, so this counts open cards.
Finder get rowFooters => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('action-footer-');
});

/// Deletes a row through its context menu, the path outside select mode.
Future<void> deleteViaMenu(WidgetTester tester, Finder row) async {
  await tester.tap(row, buttons: kSecondaryButton);
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(FLucideIcons.trash2));
}

Future<void> marqueeOver(
  WidgetTester tester,
  Finder from,
  Finder to,
) async {
  // Press near the left edge of the list, clear of any control, then travel
  // past the marquee threshold before sweeping to the target.
  final start = Offset(
    tester.getRect(find.byType(ActionListEditor)).left + 4,
    tester.getCenter(from).dy,
  );
  final gesture = await tester.startGesture(
    start,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(start + const Offset(0, 60));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.moveTo(tester.getCenter(to));
  await tester.pump(const Duration(milliseconds: 50));
  await gesture.up();
  await tester.pumpAndSettle();
}

/// A root list holding a group two levels deep, the shape most of these tests
/// lay out against.
final nested = TriggerCommon(
  actions: [
    cmd('root one'),
    TriggerAction(
      action: ActionGroup(
        actions: [
          cmd('child one'),
          TriggerAction(
            action: ActionGroup(actions: [cmd('grandchild')]),
          ),
        ],
      ),
    ),
    cmd('root two'),
  ],
);

const gestureLocation = GestureLocation(
  device: DeviceType.mouse,
  editId: seedEditId,
);

/// Pumps the action list inside the sliver anchor the app scrolls it in, and
/// hands back the container driving it. The plain [actionListHost] has no
/// anchor, so reveal and scroll-landing behaviour needs this one.
Future<ProviderContainer> pumpAnchoredActionList(
  WidgetTester tester,
  TriggerCommon common, {
  Size size = const Size(1000, 1800),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(
        () => SeededActionsController(common),
      ),
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
                      gesture: gestureLocation,
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
  return container;
}
