import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/reorderable_groupable_list.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';

/// Drives a real drag through the list so the translation between the shared
/// move algebra and the item/group callbacks stays covered.
Widget _host(
  List<ReorderableGroupableListEntry<int, String>> entries, {
  required void Function(ReorderableItemsResult<int, String>) onItemsReordered,
  void Function(ReorderableGroupMove<String>)? onGroupMoved,
}) {
  final scrollController = ScrollController();
  return MaterialApp(
    builder: (context, child) =>
        FTheme(data: AppThemes.zinc.dark.desktop, child: child!),
    home: Scaffold(
      body: ReorderableGroupableList<int, String>(
        entries: entries,
        scrollController: scrollController,
        borderColor: const Color(0xFF888888),
        groupHeaderExtent: 38,
        onItemsReordered: onItemsReordered,
        onGroupMoved: onGroupMoved ?? (_) {},
        itemBuilder: (context, item, handle, isDragging) =>
            SizedBox(height: 40, child: Text('item:${item.id}')),
        groupBuilder: (context, group, handle, isPinned, scrollBuilder) =>
            SizedBox(height: 38, child: Text('group:${group.id}')),
      ),
    ),
  );
}

ReorderableGroupableItem<int, String> _item(
  int id, {
  String? group,
  int depth = 0,
}) => ReorderableGroupableItem(
  key: ValueKey('i:$id'),
  id: id,
  groupId: group,
  depth: depth,
);

ReorderableGroupableGroup<int, String> _group(String id) =>
    ReorderableGroupableGroup(key: ValueKey('g:$id'), id: id);

/// Drags the handle of the row at [from] onto the centre of [onto].
Future<void> _dragRow(
  WidgetTester tester, {
  required int from,
  required Finder onto,
}) async {
  final handles = find.byIcon(FLucideIcons.gripVertical);
  final gesture = await tester.startGesture(
    tester.getCenter(handles.at(from)),
  );
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.moveTo(tester.getCenter(onto));
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('dropping a row before another reports the new order', (
    tester,
  ) async {
    ReorderableItemsResult<int, String>? result;
    await tester.pumpWidget(
      _host(
        [_item(0), _item(1), _item(2)],
        onItemsReordered: (r) => result = r,
      ),
    );
    await tester.pumpAndSettle();

    await _dragRow(tester, from: 2, onto: find.text('item:0'));

    expect(result, isNotNull);
    expect(result!.orderedItemIds, [2, 0, 1]);
    expect(result!.movedItemIds, {2});
    expect(result!.groupId, isNull);
  });

  testWidgets('dropping a row on a group header appends it to the group', (
    tester,
  ) async {
    ReorderableItemsResult<int, String>? result;
    await tester.pumpWidget(
      _host(
        [
          _group('a'),
          _item(0, group: 'a', depth: 1),
          _item(1),
          _item(2),
        ],
        onItemsReordered: (r) => result = r,
      ),
    );
    await tester.pumpAndSettle();

    await _dragRow(tester, from: 2, onto: find.text('group:a'));

    expect(result, isNotNull);
    expect(result!.orderedItemIds, [0, 2, 1]);
    expect(result!.groupId, 'a');
  });
}
