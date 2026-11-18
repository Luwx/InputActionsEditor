import 'package:flutter/material.dart' hide Action;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_add_row.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_tree_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';

import '../../../../../../helpers/action_list_harness.dart';
import '../../../../../../helpers/load_fonts.dart';

const _terminal = MenuItem.action(
  text: 'Terminal',
  icon: 'utilities-terminal',
  actions: [TriggerAction(action: CommandAction(command: 'konsole'))],
);

const _menu = TriggerCommon(
  actions: [
    TriggerAction(
      action: ContextMenuAction(items: [_terminal]),
    ),
  ],
);

Finder _field(String text) => find.byWidgetPredicate(
  (widget) => widget is EditableText && widget.controller.text == text,
);

MenuItem _withoutIds(MenuItem item) => switch (item) {
  final SubMenuItem item => item.copyWith(
    editId: null,
    items: item.items.map(_withoutIds).toList(),
  ),
  final ActionMenuItem item => item.copyWith(
    editId: null,
    actions: item.actions.map(_actionWithoutIds).toList(),
  ),
  _ => item.copyWith(editId: null),
};

TriggerAction _actionWithoutIds(TriggerAction action) => action.copyWith(
  editId: null,
  action: switch (action.action) {
    final ActionGroup group => group.copyWith(
      actions: group.actions.map(_actionWithoutIds).toList(),
    ),
    final ContextMenuAction menu => menu.copyWith(
      items: menu.items.map(_withoutIds).toList(),
    ),
    final other => other,
  },
);

ProviderContainer _container(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(ActionListEditor).first),
  listen: false,
);

const _gesture = GestureLocation(device: DeviceType.mouse, editId: seedEditId);

List<MenuItem> _entries(WidgetTester tester) {
  final draft = _container(
    tester,
  ).read(configControllerProvider).requireValue.draft;
  final action = actionsOf(gestureAt(draft, _gesture)!.common).first.action;
  return (action as ContextMenuAction).items.map(_withoutIds).toList();
}

List<MenuItem> _kinds(WidgetTester tester) => _entries(tester);

Future<AppLocalizations> _pump(WidgetTester tester) async {
  await loadAppFonts();
  tester.view.physicalSize = const Size(900, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(actionListHost(_menu));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Context menu').first);
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byType(ActionListEditor)));
}

Finder _add(IconData icon) => find.descendant(
  of: find.byType(MenuAddRow),
  matching: find.byIcon(icon),
);

void main() {
  group('context menu editor', () {
    testWidgets('selects the first item and edits its text', (tester) async {
      await _pump(tester);

      await tester.enterText(_field('Terminal'), 'Console');
      await tester.pumpAndSettle();

      expect(
        _entries(tester).single,
        const MenuItem.action(
          text: 'Console',
          icon: 'utilities-terminal',
          actions: [TriggerAction(action: CommandAction(command: 'konsole'))],
        ),
      );
    });

    testWidgets('the main list shows the menu but not its items', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('konsole'), findsNothing);
    });

    testWidgets('adds after a selected item and inside a selected submenu', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(_add(FLucideIcons.folderPlus));
      await tester.pumpAndSettle();
      await tester.tap(_add(FLucideIcons.minus));
      await tester.pumpAndSettle();

      expect(_entries(tester).skip(1), const [
        MenuItem.subMenu(items: [MenuItem.separator()]),
      ]);

      await tester.tap(find.text('Terminal'));
      await tester.pumpAndSettle();
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();

      expect(_kinds(tester).map((a) => a.runtimeType.toString()), [
        'ActionMenuItem',
        'SectionMenuItem',
        'SubMenuItem',
      ]);
    });

    testWidgets('focuses the text field of a newly added item', (tester) async {
      await _pump(tester);

      await tester.tap(_add(FLucideIcons.plus));
      await tester.pumpAndSettle();

      final focused = find.byWidgetPredicate(
        (widget) =>
            widget is EditableText &&
            widget.focusNode.hasFocus &&
            widget.controller.text.isEmpty,
      );
      expect(focused, findsOneWidget);
    });

    testWidgets('deletes an item from its trash button', (tester) async {
      await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .descendant(
              of: find.byType(MenuTreeView),
              matching: find.byIcon(FLucideIcons.trash2),
            )
            .last,
      );
      await tester.pumpAndSettle();

      expect(_kinds(tester).single, isA<ActionMenuItem>());
    });

    testWidgets('the trash button of an idle row does not delete it', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .descendant(
              of: find.byType(MenuTreeView),
              matching: find.byIcon(FLucideIcons.trash2),
            )
            .first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(_kinds(tester), hasLength(2));
    });

    testWidgets('deleting after a folded submenu selects the submenu', (
      tester,
    ) async {
      final l10n = await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Terminal'));
      await tester.pumpAndSettle();
      await tester.tap(_add(FLucideIcons.folderPlus));
      await tester.pumpAndSettle();
      await tester.tap(_add(FLucideIcons.minus));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(MenuTreeView),
          matching: find.byIcon(FLucideIcons.chevronDown),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.actionContextMenuSectionLabel));
      await tester.pumpAndSettle();

      await tester.tap(
        find
            .descendant(
              of: find.byType(MenuTreeView),
              matching: find.byIcon(FLucideIcons.trash2),
            )
            .last,
      );
      await tester.pumpAndSettle();

      expect(_kinds(tester).last, isA<SubMenuItem>());
      expect(find.text(l10n.actionContextMenuSeparatorLabel), findsNothing);
    });

    testWidgets('undo takes back an added item', (tester) async {
      await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();

      _container(tester).read(configControllerProvider.notifier).undo();
      await tester.pumpAndSettle();

      expect(_entries(tester), const [_terminal]);
    });

    testWidgets('dragging a grip reorders and nests items', (tester) async {
      final l10n = await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();
      await tester.tap(_add(FLucideIcons.folderPlus));
      await tester.pumpAndSettle();

      Future<void> drag(int grip, Finder target, double dy) async {
        final from = tester.getCenter(
          find
              .descendant(
                of: find.byType(MenuTreeView),
                matching: find.byIcon(FLucideIcons.gripVertical),
              )
              .at(grip),
        );
        final to = tester.getCenter(target) + Offset(0, dy);
        final gesture = await tester.startGesture(from);
        await gesture.moveBy(const Offset(0, -30));
        await tester.pump();
        await gesture.moveTo(to);
        await tester.pump();
        await gesture.moveBy(const Offset(1, 0));
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();
      }

      await drag(1, find.text('Terminal'), -10);
      expect(_kinds(tester).map((a) => a.runtimeType.toString()), [
        'SectionMenuItem',
        'ActionMenuItem',
        'SubMenuItem',
      ]);

      await drag(1, find.text(l10n.actionContextMenuNoText).last, 0);
      final submenu = _kinds(tester).last as SubMenuItem;
      expect(submenu.items.single, isA<ActionMenuItem>());
    });

    testWidgets('edits the icon from the tree row', (tester) async {
      await _pump(tester);

      await tester.tap(find.byIcon(FLucideIcons.image));
      await tester.pumpAndSettle();
      await tester.enterText(_field('utilities-terminal').last, 'konsole');
      await tester.pumpAndSettle();

      expect((_entries(tester).single as ActionMenuItem).icon, 'konsole');
    });

    testWidgets('show actions opens the item actions in a side sheet', (
      tester,
    ) async {
      final l10n = await _pump(tester);

      await tester.tap(find.text(l10n.actionContextMenuShowActions));
      await tester.pumpAndSettle();

      expect(find.text('konsole'), findsOneWidget);
    });

    testWidgets('editing an action field in the sheet changes the item', (
      tester,
    ) async {
      final l10n = await _pump(tester);
      await tester.tap(find.text(l10n.actionContextMenuShowActions));
      await tester.pumpAndSettle();

      await tester.tap(find.text('konsole'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('konsole'), 'dolphin');
      await tester.pumpAndSettle();

      expect((_entries(tester).single as ActionMenuItem).actions, const [
        TriggerAction(action: CommandAction(command: 'dolphin')),
      ]);
    });

    testWidgets('undo takes back an edit made in the sheet', (tester) async {
      final l10n = await _pump(tester);
      await tester.tap(find.text(l10n.actionContextMenuShowActions));
      await tester.pumpAndSettle();
      await tester.tap(find.text('konsole'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('konsole'), 'dolphin');
      await tester.pumpAndSettle();

      _container(tester).read(configControllerProvider.notifier).undo();
      await tester.pumpAndSettle();

      expect(_entries(tester), const [_terminal]);
    });

    testWidgets('an action added in the sheet lands in the item', (
      tester,
    ) async {
      final l10n = await _pump(tester);
      await tester.tap(find.text(l10n.actionContextMenuShowActions));
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.addAction).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.actionMetaSleepLabel).last);
      await tester.pumpAndSettle();

      final item = _entries(tester).single as ActionMenuItem;
      expect(item.actions.map((a) => a.action.runtimeType.toString()), [
        'CommandAction',
        'SleepAction',
      ]);
    });
  });
}
