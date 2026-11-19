import 'package:flutter/material.dart' hide Action;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/icon_picker/icon_picker_dialog.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_grid.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_add_row.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_item_detail.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_item_icon.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_row_drag.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_context_menu/widgets/menu_tree_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_list_header.dart';

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

Finder get _iconSearch => find.descendant(
  of: find.byType(IconPickerDialog),
  matching: find.byType(EditableText),
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

const _iconPath = 'linux/icons/128x128/apps/dev.luwx.input_actions_editor.png';
const _icons = [
  DesktopIcon(name: 'konsole', path: _iconPath),
  DesktopIcon(name: 'utilities-terminal', path: _iconPath),
];

List<MenuItem> _entries(WidgetTester tester) {
  final draft = _container(
    tester,
  ).read(configControllerProvider).requireValue.draft;
  final action = actionsOf(gestureAt(draft, _gesture)!.common).first.action;
  return (action as ContextMenuAction).items.map(_withoutIds).toList();
}

List<MenuItem> _kinds(WidgetTester tester) => _entries(tester);

Future<AppLocalizations> _pump(
  WidgetTester tester, {
  TriggerCommon common = _menu,
  Size size = const Size(900, 1600),
}) async {
  await loadAppFonts();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    actionListHost(
      common,
      overrides: [desktopIconsProvider.overrideWith((ref) async => _icons)],
    ),
  );
  await tester.pumpAndSettle();
  if (common.actions.isNotEmpty) {
    await tester.tap(find.text('Context menu').first);
    await tester.pumpAndSettle();
  }
  return AppLocalizations.of(tester.element(find.byType(ActionListEditor)));
}

final Finder _actionsTile = find.descendant(
  of: find.byType(MenuItemDetail),
  matching: find.byType(FTile),
);

Finder _add(IconData icon) => find.descendant(
  of: find.byType(MenuAddRow),
  matching: find.byIcon(icon),
);

void main() {
  group('context menu editor', () {
    testWidgets(
      'long icon names fit the detail button and still open the picker',
      (tester) async {
        const name = 'application-vnd.sun.xml.impress.template-symbolic';
        await _pump(
          tester,
          size: const Size(720, 1200),
          common: const TriggerCommon(
            actions: [
              TriggerAction(
                action: ContextMenuAction(
                  items: [
                    MenuItem.action(text: 'Copy', icon: name),
                  ],
                ),
              ),
            ],
          ),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
        expect(find.byType(IconPickerDialog), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect((_entries(tester).single as ActionMenuItem).icon, name);
      },
    );

    testWidgets('new menus contain copy, cut and delete shortcuts', (
      tester,
    ) async {
      final l10n = await _pump(tester, common: const TriggerCommon());
      await tester.tap(find.text(l10n.addAction));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.actionMetaContextMenuLabel));
      await tester.pumpAndSettle();

      final items = _entries(tester).cast<ActionMenuItem>();
      expect(items.map((item) => item.text), [
        '&${l10n.actionCopy}',
        l10n.actionCut,
        l10n.actionDelete,
      ]);
      expect(items.map((item) => item.icon), [
        'edit-copy',
        'edit-cut',
        'edit-delete',
      ]);
      final inputs = items.map(
        (item) => item.actions.single.action as InputAction,
      );
      expect(
        inputs.map((input) => input.entries.single.device),
        everyElement(InputDevice.keyboard),
      );
      expect(inputs.map((input) => input.entries.single.tokens), const [
        [
          InputToken.combo(['leftctrl', 'c']),
        ],
        [
          InputToken.combo(['leftctrl', 'x']),
        ],
        [
          InputToken.combo(['delete']),
        ],
      ]);
      await tester.pump();
      await tester.pumpAndSettle();
    });

    testWidgets('sections have a separator after their text', (tester) async {
      await _pump(tester);
      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();
      final row = find
          .descendant(
            of: find.byType(MenuTreeView),
            matching: find.byType(MenuRowDropTarget),
          )
          .last;
      final divider = find.descendant(of: row, matching: find.byType(Divider));
      final label = find.descendant(of: row, matching: find.text('Section'));
      expect(divider, findsOneWidget);
      expect(
        tester.getRect(divider).left,
        greaterThan(tester.getRect(label).right),
      );
      expect(tester.getSize(divider).width, greaterThan(20));
    });

    testWidgets(
      'separator rows keep the item height and brighten when selected',
      (tester) async {
        await _pump(tester);
        await tester.tap(_add(FLucideIcons.minus));
        await tester.pumpAndSettle();
        final rows = find.descendant(
          of: find.byType(MenuTreeView),
          matching: find.byType(MenuRowDropTarget),
        );
        expect(
          tester.getSize(rows.last).height,
          tester.getSize(rows.first).height,
        );
        final divider = find.descendant(
          of: rows.last,
          matching: find.byType(Divider),
        );
        final selectedColor = tester.widget<Divider>(divider).color;
        await tester.tap(find.text('Terminal'));
        await tester.pumpAndSettle();
        expect(tester.widget<Divider>(divider).color, isNot(selectedColor));
      },
    );

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

      expect(find.textContaining('konsole'), findsOneWidget);
      expect(
        find.descendant(
          of: _actionsTile,
          matching: find.textContaining('konsole'),
        ),
        findsOneWidget,
      );
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

    testWidgets('the tree holds two rows and grows smoothly past them', (
      tester,
    ) async {
      await _pump(tester);
      double height() => tester.getSize(find.byType(MenuTreeView)).height;
      final one = height();

      await tester.tap(_add(FLucideIcons.heading));
      await tester.pumpAndSettle();
      final two = height();
      expect(two, one);

      await tester.tap(_add(FLucideIcons.minus));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final growing = height();
      await tester.pumpAndSettle();

      expect(growing, inExclusiveRange(two, height()));
    });

    testWidgets('adding items keeps the add row pinned', (tester) async {
      await loadAppFonts();
      const height = 300.0;
      await pumpAnchoredActionList(
        tester,
        _menu,
        size: const Size(900, height),
      );
      await tester.tap(find.text('Context menu').first);
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
      await tester.pumpAndSettle();

      double addRowBottom() => tester.getBottomLeft(find.byType(MenuAddRow)).dy;
      for (var i = 0; i < 5; i++) {
        final before = addRowBottom();
        await tester.tap(_add(FLucideIcons.plus));
        for (var frame = 0; frame < 30; frame++) {
          await tester.pump(const Duration(milliseconds: 16));
          expect(
            addRowBottom(),
            moreOrLessEquals(before, epsilon: 0.1),
            reason: 'add $i, frame $frame',
          );
        }
        await tester.pumpAndSettle();
      }
    });

    testWidgets('the actions tile lists every action of the item', (
      tester,
    ) async {
      await _pump(
        tester,
        common: const TriggerCommon(
          actions: [
            TriggerAction(
              action: ContextMenuAction(
                items: [
                  MenuItem.action(
                    text: 'Terminal',
                    actions: [
                      TriggerAction(action: CommandAction(command: 'konsole')),
                      TriggerAction(action: SleepAction(milliseconds: 500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      expect(
        find.descendant(
          of: _actionsTile,
          matching: find.textContaining(RegExp('konsole, .sleep 500ms')),
        ),
        findsOneWidget,
      );
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

    testWidgets('searches and selects an installed icon from the tree row', (
      tester,
    ) async {
      await _pump(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(MenuTreeView),
          matching: find.byType(MenuItemIcon),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(IconPickerDialog), findsOneWidget);
      await tester.enterText(_iconSearch, 'missing-icon');
      await tester.pumpAndSettle();
      expect(find.text('No icons found'), findsOneWidget);
      await tester.enterText(_iconSearch, ' KonSole ');
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(IconGrid),
          matching: find.text('utilities-terminal'),
        ),
        findsNothing,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(IconGrid),
          matching: find.text('konsole'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(IconPickerDialog), findsNothing);
      expect((_entries(tester).single as ActionMenuItem).icon, 'konsole');
      _container(tester).read(configControllerProvider.notifier).undo();
      await tester.pumpAndSettle();
      expect(_entries(tester), const [_terminal]);
    });

    testWidgets('clears an icon from the detail picker and can undo it', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('utilities-terminal'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(IconPickerDialog),
          matching: find.text('No icon'),
        ),
      );
      await tester.pumpAndSettle();

      expect((_entries(tester).single as ActionMenuItem).icon, isNull);
      _container(tester).read(configControllerProvider.notifier).undo();
      await tester.pumpAndSettle();
      expect(_entries(tester), const [_terminal]);
    });

    testWidgets('cancelling the icon picker preserves the current icon', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.text('utilities-terminal'));
      await tester.pumpAndSettle();
      await tester.enterText(_iconSearch, 'konsole');
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(find.byType(IconPickerDialog), findsNothing);
      expect(_entries(tester), const [_terminal]);
    });

    testWidgets('selects a submenu icon from the detail picker', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(_add(FLucideIcons.folderPlus));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No icon'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('konsole'));
      await tester.pumpAndSettle();

      expect(find.byType(IconPickerDialog), findsNothing);
      expect((_entries(tester).last as SubMenuItem).icon, 'konsole');
    });

    testWidgets('show actions opens the item actions in a side sheet', (
      tester,
    ) async {
      final l10n = await _pump(tester);

      await tester.tap(_actionsTile);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ActionListHeader),
          matching: find.text(l10n.actionGroupSummary(1)),
        ),
        findsOneWidget,
      );
      expect(_field('konsole'), findsOneWidget);
    });

    testWidgets('editing an action field in the sheet changes the item', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(_actionsTile);
      await tester.pumpAndSettle();

      await tester.enterText(_field('konsole'), 'dolphin');
      await tester.pumpAndSettle();

      expect((_entries(tester).single as ActionMenuItem).actions, const [
        TriggerAction(action: CommandAction(command: 'dolphin')),
      ]);
    });

    testWidgets('undo takes back an edit made in the sheet', (tester) async {
      await _pump(tester);
      await tester.tap(_actionsTile);
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
      await tester.tap(_actionsTile);
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
