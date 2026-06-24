import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/tree_table/indent_guides.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table_column.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table_node.dart';
import 'package:input_actions_editor/ui/common/tree_table/tree_table_style.dart';

export 'package:input_actions_editor/ui/common/tree_table/tree_table_column.dart';
export 'package:input_actions_editor/ui/common/tree_table/tree_table_node.dart';
export 'package:input_actions_editor/ui/common/tree_table/tree_table_style.dart';

/// Builds the expand/collapse affordance for a group header. Receives the
/// current [expanded] state and a [toggle] callback.
typedef TreeTableChevronBuilder =
    Widget Function(BuildContext context, bool expanded, VoidCallback toggle);

/// A generic table whose rows form a tree. Leaf rows lay their cells out across
/// resizable columns; group rows render a header and indented children.
///
/// The engine owns column widths, expand/collapse state, horizontal scrolling,
/// and all indent-guide geometry. Consumers supply an immutable node tree and
/// the cell/header widgets; structural concerns (depth, sibling order, guide
/// visibility) are derived internally.
class TreeTable extends StatefulWidget {
  const TreeTable({
    required this.columns,
    required this.roots,
    this.trailingWidth = 0,
    this.style = const TreeTableStyle(),
    this.showHeader = true,
    this.groupBackground,
    this.chevronBuilder,
    super.key,
  });

  final List<TreeTableColumn> columns;
  final List<TreeTableNode> roots;

  /// Width of the fixed action slot at the end of every row.
  final double trailingWidth;

  final TreeTableStyle style;
  final bool showHeader;

  /// Optional background tint for a group's body, by depth.
  final Color? Function(int depth)? groupBackground;

  /// Optional override for the expand/collapse chevron.
  final TreeTableChevronBuilder? chevronBuilder;

  @override
  State<TreeTable> createState() => _TreeTableState();
}

class _TreeTableState extends State<TreeTable> {
  final Map<String, double> _columnWidths = {};
  final Map<Key, bool> _expanded = {};

  TreeTableStyle get _style => widget.style;

  double _widthOf(TreeTableColumn column) {
    final stored = _columnWidths[column.id] ?? column.initialWidth ?? 0;
    return stored.clamp(column.minWidth, double.infinity);
  }

  bool _expandedOf(TreeTableGroup group) =>
      _expanded[group.key] ?? group.initiallyExpanded;

  void _toggle(TreeTableGroup group) {
    setState(() => _expanded[group.key] = !_expandedOf(group));
  }

  void _resize(TreeTableColumn column, double delta) {
    setState(() {
      _columnWidths[column.id] = (_widthOf(column) + delta).clamp(
        column.minWidth,
        double.infinity,
      );
    });
  }

  _ResolvedLayout _resolveLayout(double viewportWidth) {
    final widths = <String, double>{};
    var sizedSum = 0.0;
    var flexMin = 0.0;
    TreeTableColumn? flexColumn;

    for (final column in widget.columns) {
      if (column.flex) {
        flexColumn = column;
        flexMin = column.minWidth;
      } else {
        final width = _widthOf(column);
        widths[column.id] = width;
        sizedSum += width;
      }
    }

    final dividerCount = widget.columns.isEmpty ? 0 : widget.columns.length - 1;
    final dividers = dividerCount * _style.columnDividerWidth;
    final reserved =
        _style.rowLeftPadding +
        _style.rowRightPadding +
        dividers +
        widget.trailingWidth;
    final contentMinWidth = reserved + sizedSum + flexMin;
    final tableWidth = math.max(viewportWidth, contentMinWidth);

    if (flexColumn != null) {
      widths[flexColumn.id] = tableWidth - reserved - sizedSum;
    }

    return _ResolvedLayout(tableWidth: tableWidth, columnWidths: widths);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : _style.fallbackWidth;
        final layout = _resolveLayout(viewportWidth);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: layout.tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showHeader) ...[
                  _buildHeader(layout, colors),
                  const FDivider(
                    style: .delta(padding: .value(EdgeInsetsGeometry.zero)),
                  ),
                ],
                for (var i = 0; i < widget.roots.length; i++)
                  _buildNode(
                    widget.roots[i],
                    layout: layout,
                    colors: colors,
                    depth: 0,
                    isFirst: i == 0,
                    isLast: i == widget.roots.length - 1,
                    parentHasMore: const [],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode(
    TreeTableNode node, {
    required _ResolvedLayout layout,
    required FColors colors,
    required int depth,
    required bool isFirst,
    required bool isLast,
    required List<bool> parentHasMore,
  }) {
    return switch (node) {
      final TreeTableLeaf leaf => _buildLeaf(
        leaf,
        layout: layout,
        colors: colors,
        depth: depth,
        isLast: isLast,
        guideLevelVisibility: depth == 0
            ? null
            : [...parentHasMore.take(depth - 1), true],
      ),
      final TreeTableGroup group => _buildGroup(
        group,
        layout: layout,
        colors: colors,
        depth: depth,
        isFirst: isFirst,
        isLast: isLast,
        parentHasMore: parentHasMore,
      ),
    };
  }

  Widget _buildLeaf(
    TreeTableLeaf leaf, {
    required _ResolvedLayout layout,
    required FColors colors,
    required int depth,
    required bool isLast,
    required List<bool>? guideLevelVisibility,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: leaf.minHeight),
      child: IndentGuides(
        depth: depth,
        color: colors.border,
        style: _style,
        guideLevelVisibility: guideLevelVisibility,
        leadingInset: _style.rowLeftPadding,
        paintHorizontalConnector: true,
        truncateDeepestGuideBelowConnector: isLast,
        child: Padding(
          padding: _rowPadding,
          child: Row(
            children: leaf.content != null
                ? _fullWidthLeaf(leaf, depth)
                : _leafCells(leaf, layout, depth),
          ),
        ),
      ),
    );
  }

  /// Lays a [TreeTableLeaf.content] row across the full data area (after the
  /// indent), keeping the fixed trailing action slot aligned with other rows.
  List<Widget> _fullWidthLeaf(TreeTableLeaf leaf, int depth) {
    return [
      SizedBox(width: _style.indentWidth(depth)),
      Expanded(child: leaf.content!),
      if (widget.trailingWidth > 0)
        SizedBox(
          width: widget.trailingWidth,
          child: leaf.trailing ?? const SizedBox.shrink(),
        ),
    ];
  }

  List<Widget> _leafCells(
    TreeTableLeaf leaf,
    _ResolvedLayout layout,
    int depth,
  ) {
    final cells = <Widget>[];
    for (var c = 0; c < widget.columns.length; c++) {
      if (c > 0) {
        cells.add(SizedBox(width: _style.columnDividerWidth));
      }
      final column = widget.columns[c];
      final content = c < leaf.cells.length
          ? leaf.cells[c]
          : const SizedBox.shrink();
      final cell = c == 0
          ? Row(
              children: [
                SizedBox(width: _style.indentWidth(depth)),
                Expanded(child: content),
              ],
            )
          : content;
      cells.add(
        column.flex
            ? Expanded(child: cell)
            : SizedBox(width: layout.columnWidths[column.id], child: cell),
      );
    }
    if (widget.trailingWidth > 0) {
      cells.add(
        SizedBox(
          width: widget.trailingWidth,
          child: leaf.trailing ?? const SizedBox.shrink(),
        ),
      );
    }
    return cells;
  }

  Widget _buildGroup(
    TreeTableGroup group, {
    required _ResolvedLayout layout,
    required FColors colors,
    required int depth,
    required bool isFirst,
    required bool isLast,
    required List<bool> parentHasMore,
  }) {
    final children = group.children;
    final childWidgets = <Widget>[
      for (var i = 0; i < children.length; i++)
        _buildNode(
          children[i],
          layout: layout,
          colors: colors,
          depth: depth + 1,
          isFirst: i == 0,
          isLast: i == children.length - 1,
          parentHasMore: [...parentHasMore, i < children.length - 1],
        ),
    ];

    final expanded = _expandedOf(group);
    final headerGuideVisibility = depth == 0
        ? const <bool>[]
        : [...parentHasMore.take(depth - 1), true];
    final paintBottomLine = !isLast && (!expanded || depth == 0);
    final paintLeadingStemBelow = expanded && children.isNotEmpty;
    final background = widget.groupBackground?.call(depth);

    final header = IndentGuides(
      depth: depth,
      color: colors.border,
      style: _style,
      guideLevelVisibility: headerGuideVisibility,
      leadingInset: _style.rowLeftPadding,
      paintBottomLine: paintBottomLine,
      paintHorizontalConnector: true,
      paintLeadingStemBelow: paintLeadingStemBelow,
      truncateDeepestGuideBelowConnector: isLast,
      child: Padding(
        padding: _rowPadding,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(width: _style.indentWidth(depth)),
                  _chevron(expanded, () => _toggle(group)),
                  const SizedBox(width: 2),
                  Expanded(child: group.header),
                ],
              ),
            ),
            if (group.trailing != null)
              SizedBox(width: widget.trailingWidth, child: group.trailing),
          ],
        ),
      ),
    );

    final body = children.isEmpty
        ? const SizedBox.shrink()
        : Container(
            decoration: background == null
                ? null
                : BoxDecoration(color: background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: childWidgets,
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: expanded && children.isNotEmpty ? 1 : 0,
              child: expanded ? body : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chevron(bool expanded, VoidCallback toggle) {
    final builder = widget.chevronBuilder;
    if (builder != null) return builder(context, expanded, toggle);
    return FButton(
      variant: .ghost,
      size: .sm,
      onPress: toggle,
      child: Icon(
        expanded ? FLucideIcons.chevronDown : FLucideIcons.chevronRight,
        size: 14,
      ),
    );
  }

  Widget _buildHeader(_ResolvedLayout layout, FColors colors) {
    final style = context.theme.typography.body.xs.copyWith(
      color: colors.mutedForeground,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );

    final cells = <Widget>[];
    for (var c = 0; c < widget.columns.length; c++) {
      if (c > 0) {
        cells.add(
          Container(
            width: _style.columnDividerWidth,
            height: _style.headerHeight,
            color: colors.border,
          ),
        );
      }
      final column = widget.columns[c];
      final label = Padding(
        padding: column.labelPadding,
        child: Text(column.label ?? '', style: style),
      );
      cells.add(
        column.flex
            ? Expanded(child: label)
            : SizedBox(width: layout.columnWidths[column.id], child: label),
      );
    }
    if (widget.trailingWidth > 0) {
      cells.add(SizedBox(width: widget.trailingWidth));
    }

    return Padding(
      padding: EdgeInsets.only(
        left: _style.rowLeftPadding,
        right: _style.rowRightPadding,
      ),
      child: SizedBox(
        height: _style.headerHeight,
        child: Stack(
          children: [
            Row(children: cells),
            ..._resizeHandles(layout),
          ],
        ),
      ),
    );
  }

  List<Widget> _resizeHandles(_ResolvedLayout layout) {
    final handles = <Widget>[];
    var x = 0.0;
    for (var c = 0; c < widget.columns.length; c++) {
      final column = widget.columns[c];
      x += column.flex
          ? (layout.columnWidths[column.id] ?? 0)
          : _widthOf(column);
      if (column.resizable) {
        handles.add(
          Positioned(
            left: x - (_style.resizeHandleWidth / 2),
            top: 0,
            bottom: 0,
            child: _ResizeHandle(
              width: _style.resizeHandleWidth,
              onDrag: (delta) => _resize(column, delta),
            ),
          ),
        );
      }
      if (c < widget.columns.length - 1) x += _style.columnDividerWidth;
    }
    return handles;
  }

  EdgeInsets get _rowPadding => EdgeInsets.only(
    left: _style.rowLeftPadding,
    top: _style.rowVerticalPadding,
    right: _style.rowRightPadding,
    bottom: _style.rowVerticalPadding,
  );
}

class _ResolvedLayout {
  const _ResolvedLayout({required this.tableWidth, required this.columnWidths});

  final double tableWidth;
  final Map<String, double> columnWidths;
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({required this.width, required this.onDrag});

  final double width;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: SizedBox(width: width),
      ),
    );
  }
}
