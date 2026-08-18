import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';

Widget _host(List<ReorderableGroupableListEntry<int, String>> entries) {
  final scrollController = ScrollController();
  return MaterialApp(
    builder: (context, child) => FTheme(
      data: AppThemes.zinc.dark.desktop,
      child: child!,
    ),
    home: Scaffold(
      body: ReorderableGroupableList<int, String>(
        entries: entries,
        scrollController: scrollController,
        borderColor: const Color(0xFF888888),
        groupHeaderExtent: 38,
        reorderEnabled: false,
        onItemsReordered: (_) {},
        onGroupMoved: (_) {},
        itemBuilder: (context, item, handle, isDragging) =>
            SizedBox(height: 40, child: Text('item:${item.id}')),
        groupBuilder: (context, group, handle, isPinned, scrollBuilder) =>
            SizedBox(height: 38, child: Text('group:${group.id}')),
      ),
    ),
  );
}

const _outer = ReorderableGroupableGroup<int, String>(
  key: ValueKey('g:outer'),
  id: 'outer',
);
const _inner = ReorderableGroupableGroup<int, String>(
  key: ValueKey('g:inner'),
  id: 'inner',
  parentId: 'outer',
  depth: 1,
);

ReorderableGroupableItem<int, String> _item(
  int id,
  String? group,
  int depth, {
  bool isVisible = true,
}) => ReorderableGroupableItem(
  key: ValueKey('i:$id'),
  id: id,
  groupId: group,
  depth: depth,
  isVisible: isVisible,
);

void main() {
  testWidgets('renders a nested group header as a row inside its parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        _outer,
        _item(0, 'outer', 1),
        _inner,
        _item(1, 'inner', 2),
        _item(2, null, 0),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('group:outer'), findsOneWidget);
    expect(find.text('group:inner'), findsOneWidget);
    expect(find.text('item:0'), findsOneWidget);
    expect(find.text('item:1'), findsOneWidget);
    expect(find.text('item:2'), findsOneWidget);

    // The nested row is indented one level deeper than its sibling.
    final item0 = tester.getTopLeft(find.text('item:0'));
    final item1 = tester.getTopLeft(find.text('item:1'));
    final item2 = tester.getTopLeft(find.text('item:2'));
    expect(item1.dx, greaterThan(item0.dx));
    expect(item0.dx, greaterThan(item2.dx));

    // The sub-header sits between its parent's header and its own rows.
    final outerY = tester.getTopLeft(find.text('group:outer')).dy;
    final innerY = tester.getTopLeft(find.text('group:inner')).dy;
    expect(innerY, greaterThan(outerY));
    expect(tester.getTopLeft(find.text('item:1')).dy, greaterThan(innerY));
  });

  testWidgets('nested headers pin stacked below their ancestors', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        _outer,
        for (var i = 0; i < 3; i++) _item(i, 'outer', 1),
        _inner,
        for (var i = 3; i < 40; i++) _item(i, 'inner', 2),
      ]),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
    await tester.pumpAndSettle();

    // Deep inside the inner group: both headers pinned, stacked.
    expect(tester.getTopLeft(find.text('group:outer')).dy, 0);
    expect(tester.getTopLeft(find.text('group:inner')).dy, 38);
  });

  testWidgets('a pinned nested header scrolls away with its own subtree', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        _outer,
        _inner,
        for (var i = 0; i < 20; i++) _item(i, 'inner', 2),
        // Direct rows of the outer group after the inner subtree.
        for (var i = 20; i < 40; i++) _item(i, 'outer', 1),
      ]),
    );
    await tester.pumpAndSettle();

    // Scroll until the inner subtree has fully passed.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1400));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('group:outer')).dy, 0);
    final inner = find.text('group:inner');
    if (inner.evaluate().isNotEmpty) {
      // Still mounted: it must have been pushed off above the outer header's
      // bottom edge rather than lingering pinned over foreign rows.
      expect(tester.getBottomLeft(inner).dy, lessThanOrEqualTo(38));
    }
  });

  testWidgets('collapsing an ancestor hides the nested subtree', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        _outer,
        _item(0, 'outer', 1, isVisible: false),
        const ReorderableGroupableGroup<int, String>(
          key: ValueKey('g:inner'),
          id: 'inner',
          parentId: 'outer',
          depth: 1,
          isVisible: false,
        ),
        _item(1, 'inner', 2, isVisible: false),
        _item(2, null, 0),
      ]),
    );
    await tester.pumpAndSettle();

    // Rows and the nested header are collapsed to zero height, but the
    // top-level pinned header and the ungrouped row stay.
    expect(find.text('group:outer'), findsOneWidget);
    expect(tester.getSize(find.text('item:2')).height, greaterThan(0));
    final innerFinder = find.text('group:inner');
    if (innerFinder.evaluate().isNotEmpty) {
      expect(tester.getSize(innerFinder).height, 0);
    }
    final item1Finder = find.text('item:1');
    if (item1Finder.evaluate().isNotEmpty) {
      expect(tester.getSize(item1Finder).height, 0);
    }
  });

  testWidgets('every group but the last is followed by a separator', (
    tester,
  ) async {
    const groups = ['a', 'b', 'c', 'd'];
    await tester.pumpWidget(
      _host([
        for (final id in groups)
          ReorderableGroupableGroup<int, String>(
            key: ValueKey('g:$id'),
            id: id,
          ),
      ]),
    );
    await tester.pumpAndSettle();

    Rect headerOf(String id) => tester.getRect(find.text('group:$id'));
    final lines = tester
        .widgetList<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.constraints?.maxHeight == 1,
          ),
        )
        .length;
    expect(lines, groups.length - 1);

    // And each line lands between two headers.
    for (var i = 1; i < groups.length; i++) {
      expect(headerOf(groups[i]).top, greaterThan(headerOf(groups[i - 1]).top));
    }
  });
}
