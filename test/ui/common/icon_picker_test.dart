import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/services/kicon_service.dart';
import 'package:input_actions_editor/ui/common/file_icon.dart';
import 'package:input_actions_editor/ui/common/icon_picker/icon_picker_dialog.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_category_selector.dart';
import 'package:input_actions_editor/ui/common/icon_picker/widgets/icon_grid.dart';

import '../../helpers/load_fonts.dart';
import '../../helpers/themed_app.dart';

const _path = 'linux/icons/128x128/apps/dev.luwx.input_actions_editor.png';

Future<void> _open(
  WidgetTester tester,
  Future<List<DesktopIcon>> Function() load, {
  String? selected = 'icon-0',
}) async {
  await loadAppFonts();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [desktopIconsProvider.overrideWith((ref) => load())],
      child: themedApp(
        Builder(
          builder: (context) => Center(
            child: FButton(
              onPress: () => showIconPickerDialog(
                context,
                selected: selected,
                onSelected: (_) {},
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  testWidgets('category button spacing and footer alignment', (tester) async {
    await _open(
      tester,
      () async => const [
        DesktopIcon(name: 'edit-copy', path: _path, contexts: [1]),
      ],
    );
    await tester.pumpAndSettle();
    final list = tester.getRect(find.byType(IconCategorySelector));
    final button = tester.getRect(
      find.ancestor(
        of: find.text('All'),
        matching: find.byType(FButton),
      ),
    );
    expect(button.left - list.left, 8);
    expect(list.right - button.right, 8);
    final icon = find.descendant(
      of: find.byType(IconCategorySelector),
      matching: find.byIcon(FLucideIcons.layoutGrid),
    );
    expect(
      tester.getRect(find.text('All')).left - tester.getRect(icon).right,
      12,
    );
    expect(
      find.descendant(
        of: find.byType(IconCategorySelector),
        matching: find.byIcon(FLucideIcons.layoutGrid),
      ),
      findsOneWidget,
    );
    final search = tester.getRect(find.byType(FTextField));
    final noIcon = tester.getRect(
      find.ancestor(
        of: find.text('No icon'),
        matching: find.byType(FButton),
      ),
    );
    final cancel = tester.getRect(
      find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(FButton),
      ),
    );
    expect(noIcon.left, search.left);
    expect(cancel.right, search.right);
  });

  testWidgets('combines desktop categories with icon search', (tester) async {
    await _open(
      tester,
      () async => const [
        DesktopIcon(name: 'edit-copy', path: _path, contexts: [1]),
        DesktopIcon(name: 'utilities-terminal', path: _path, contexts: [2]),
        DesktopIcon(name: 'custom-icon', path: _path),
      ],
    );
    await tester.pumpAndSettle();
    Finder category(String label) => find.descendant(
      of: find.byType(IconCategorySelector),
      matching: find.text(label),
    );
    Finder icon(String name) => find.descendant(
      of: find.byType(IconGrid),
      matching: find.text(name),
    );
    await tester.tap(category('Applications'));
    await tester.pumpAndSettle();
    expect(icon('utilities-terminal'), findsOneWidget);
    expect(icon('edit-copy'), findsNothing);
    await tester.enterText(find.byType(EditableText), 'terminal');
    await tester.pumpAndSettle();
    await tester.tap(category('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('No icons found'), findsOneWidget);
    await tester.enterText(find.byType(EditableText), '');
    await tester.pumpAndSettle();
    expect(icon('edit-copy'), findsOneWidget);
    await tester.tap(category('Other'));
    await tester.pumpAndSettle();
    expect(icon('custom-icon'), findsOneWidget);
    expect(icon('edit-copy'), findsNothing);
    await tester.tap(category('All'));
    await tester.pumpAndSettle();
    expect(icon('edit-copy'), findsOneWidget);
    expect(icon('utilities-terminal'), findsOneWidget);
  });

  testWidgets('shows loading and an empty catalogue', (tester) async {
    final load = Completer<List<DesktopIcon>>();
    await _open(tester, () => load.future);
    expect(find.byType(FCircularProgress), findsOneWidget);

    load.complete([]);
    await tester.pumpAndSettle();
    expect(find.text('No installed icons available.'), findsOneWidget);
    expect(find.text('icon-0'), findsNothing);
  });

  testWidgets('retries a failed catalogue load', (tester) async {
    var attempts = 0;
    await _open(tester, () async {
      if (++attempts == 1) throw StateError('helper unavailable');
      return [const DesktopIcon(name: 'utilities-terminal', path: _path)];
    });
    await tester.pumpAndSettle();
    expect(find.text('Could not load installed icons.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('utilities-terminal'), findsOneWidget);
    expect(find.text('Could not load installed icons.'), findsNothing);
  });

  testWidgets('keeps long icon names inside their grid cells', (tester) async {
    await _open(
      tester,
      () async => [
        const DesktopIcon(
          name: 'org.kde.plasma.volume-symbolic',
          path: _path,
        ),
      ],
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('reveals the selected icon when the dialog opens', (
    tester,
  ) async {
    await _open(
      tester,
      () async => [
        for (var i = 0; i < 300; i++) DesktopIcon(name: 'icon-$i', path: _path),
      ],
      selected: 'icon-230',
    );
    await tester.pumpAndSettle();
    final selected = find.descendant(
      of: find.byType(IconGrid),
      matching: find.text('icon-230'),
    );
    expect(selected, findsOneWidget);
    final viewport = tester.getRect(find.byType(GridView));
    final item = tester.getRect(selected);
    expect(viewport.contains(item.topLeft), isTrue);
    expect(viewport.contains(item.bottomRight), isTrue);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets(
    'list viewports reach the dialog separators with padding inside',
    (tester) async {
      await _open(
        tester,
        () async => const [
          DesktopIcon(name: 'edit-copy', path: _path, contexts: [1]),
          DesktopIcon(name: 'utilities-terminal', path: _path, contexts: [2]),
        ],
      );
      await tester.pumpAndSettle();
      final dividers = find.descendant(
        of: find.byType(IconPickerDialog),
        matching: find.byType(Divider),
      );
      expect(dividers, findsNWidgets(2));
      final top = tester.getRect(dividers.first);
      final bottom = tester.getRect(dividers.last);
      final grid = tester.getRect(find.byType(GridView));
      final categories = tester.getRect(find.byType(IconCategorySelector));
      final vertical = tester.getRect(find.byType(VerticalDivider));
      expect(categories.left, top.left);
      expect(grid.right, top.right);
      expect(grid.right, bottom.right);
      expect(grid.top, top.bottom);
      expect(grid.bottom, bottom.top);
      expect(vertical.left, categories.right);
      expect(vertical.right, grid.left);
      expect(
        tester.widget<GridView>(find.byType(GridView)).padding,
        isNot(EdgeInsets.zero),
      );
    },
  );

  testWidgets(
    'builds a lazy grid in a small window and dismisses with Escape',
    (tester) async {
      tester.view.physicalSize = const Size(360, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _open(
        tester,
        () async => [
          for (var i = 0; i < 300; i++)
            DesktopIcon(name: 'icon-$i', path: _path),
        ],
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FileIcon).evaluate().length, lessThan(300));
      await tester.scrollUntilVisible(
        find.text('icon-299'),
        400,
        scrollable: find.descendant(
          of: find.byType(GridView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('icon-299'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(IconPickerDialog), findsNothing);
    },
  );
}
