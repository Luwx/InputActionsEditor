import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_editor.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';

const ValueKey<String> _viewportKey = ValueKey('action-list-viewport');
const ValueKey<String> _targetRowFooterKey = ValueKey('action-footer-4');

Finder get _lastRowChevron => find.byIcon(FLucideIcons.chevronDown).last;
Finder _rowChevron(int index) =>
    find.byIcon(FLucideIcons.chevronDown).at(index);

Future<void> _jumpNearBottom(
  WidgetTester tester,
  ScrollController controller,
) async {
  final offset = (controller.position.maxScrollExtent - 80).clamp(
    0.0,
    controller.position.maxScrollExtent,
  );
  controller.jumpTo(offset);
  await tester.pump();
}

Future<void> _scrollUpABit(
  WidgetTester tester,
  ScrollController controller, {
  double delta = 120,
}) async {
  controller.jumpTo((controller.offset - delta).clamp(0.0, double.infinity));
  await tester.pump();
}

Rect _viewportRect(WidgetTester tester) =>
    tester.getRect(find.byKey(_viewportKey));

void _expectVisibleInViewport(
  WidgetTester tester,
  Finder finder,
  String reason,
) {
  final viewportRect = _viewportRect(tester);
  final targetRect = tester.getRect(finder);

  expect(
    targetRect.bottom,
    lessThanOrEqualTo(viewportRect.bottom),
    reason: reason,
  );
}

class _ActionsEditorHost extends StatefulWidget {
  const _ActionsEditorHost({
    required this.controller,
    this.bottomSpacerHeight = 120,
    this.common,
  });

  final ScrollController controller;
  final double bottomSpacerHeight;
  final TriggerCommon? common;

  @override
  State<_ActionsEditorHost> createState() => _ActionsEditorHostState();
}

class _ActionsEditorHostState extends State<_ActionsEditorHost> {
  late TriggerCommon _common;
  final ScrollAnchorController _anchor = ScrollAnchorController();

  @override
  void initState() {
    super.initState();
    _common =
        widget.common ??
        TriggerCommon(
          actions: List.generate(
            6,
            (index) => TriggerAction(
              action: CommandAction(command: 'echo action $index'),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProviderScope(
        child: FTheme(
          data: FThemes.zinc.dark.desktop,
          child: FScaffold(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                key: _viewportKey,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                ),
                // height: 320,
                child: CustomScrollView(
                  controller: widget.controller,
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 360)),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverSmartAnchor(
                        controller: _anchor,
                        scrollPosition: () => widget.controller.hasClients
                            ? widget.controller.position
                            : null,
                        child: ScrollAnchorScope(
                          controller: _anchor,
                          child: ActionListEditor(
                            gestureLocation: const GestureLocation(
                              device: DeviceType.mouse,
                              index: 0,
                            ),
                            common: _common,
                            onCommonChanged: (common) =>
                                setState(() => _common = common),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: widget.bottomSpacerHeight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets(
    'expanding a fully visible row away from the bottom scrolls'
    ' its footer into view',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _ActionsEditorHost(
          controller: controller,
          bottomSpacerHeight: 50,
          common: TriggerCommon(
            actions: List.generate(
              6,
              (index) => TriggerAction(
                action: index == 4
                    ? const InputAction(
                        entries: [
                          InputEntry(device: InputDevice.keyboard),
                          InputEntry(device: InputDevice.mouse),
                        ],
                      )
                    : CommandAction(command: 'echo action $index'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(_rowChevron(4));
      await tester.pumpAndSettle();

      controller.jumpTo(
        (controller.offset - 20).clamp(
          0.0,
          controller.position.maxScrollExtent,
        ),
      );
      await tester.pump();
      final initialOffset = controller.offset;
      final viewportRect = _viewportRect(tester);
      tester.getRect(_rowChevron(4));

      await tester.tap(_rowChevron(4));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThanOrEqualTo(initialOffset));

      final footerRect = tester.getRect(find.byKey(_targetRowFooterKey));
      expect(
        footerRect.bottom,
        greaterThanOrEqualTo(viewportRect.bottom - 12),
        reason: 'The expanded row footer should scroll near the viewport end.',
      );
      expect(
        footerRect.bottom,
        lessThanOrEqualTo(viewportRect.bottom),
        reason: 'The expanded row footer should remain visible.',
      );
    },
  );

  testWidgets(
    'expanding the same action row again scrolls its footer into view',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_ActionsEditorHost(controller: controller));
      await tester.pumpAndSettle();

      await _jumpNearBottom(tester, controller);

      await tester.tap(_lastRowChevron);
      await tester.pumpAndSettle();
      _expectVisibleInViewport(
        tester,
        find.text('Wait for completion'),
        'The first expansion should reveal the footer.',
      );

      await tester.tap(find.byIcon(FLucideIcons.chevronUp).last);
      await tester.pumpAndSettle();

      await _scrollUpABit(tester, controller);

      await tester.tap(_lastRowChevron);
      await tester.pump();
      await tester.pumpAndSettle();

      _expectVisibleInViewport(
        tester,
        find.text('Wait for completion'),
        'Re-expanding the same row should reveal the footer again.',
      );
    },
  );

  testWidgets(
    'opening Other Options keeps the last action fields visible',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_ActionsEditorHost(controller: controller));
      await tester.pumpAndSettle();

      await _jumpNearBottom(tester, controller);

      await tester.tap(_lastRowChevron);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other Options'));
      await tester.pump();
      await tester.pumpAndSettle();

      _expectVisibleInViewport(
        tester,
        find.text('Action Conditions'),
        'The accordion footer should remain visible after opening.',
      );
    },
  );

  testWidgets(
    'opening Other Options again keeps the last action fields visible',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_ActionsEditorHost(controller: controller));
      await tester.pumpAndSettle();

      await _jumpNearBottom(tester, controller);

      await tester.tap(_lastRowChevron);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other Options'));
      await tester.pumpAndSettle();
      _expectVisibleInViewport(
        tester,
        find.text('Action Conditions'),
        'The first accordion expansion should reveal the footer.',
      );

      await tester.tap(find.text('Other Options'));
      await tester.pumpAndSettle();

      await _scrollUpABit(tester, controller);

      await tester.tap(find.text('Other Options'));
      await tester.pump();
      await tester.pumpAndSettle();

      _expectVisibleInViewport(
        tester,
        find.text('Action Conditions'),
        'Re-opening the accordion should reveal the footer again.',
      );
    },
  );

  testWidgets(
    'opening Other Options does not reverse-scroll upward first',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(_ActionsEditorHost(controller: controller));
      await tester.pumpAndSettle();

      await _jumpNearBottom(tester, controller);

      await tester.tap(_lastRowChevron);
      await tester.pumpAndSettle();

      await _scrollUpABit(tester, controller, delta: 10);
      final beforeOpenOffset = controller.offset;

      await tester.tap(find.text('Other Options'));
      await tester.pump();

      expect(
        controller.offset,
        greaterThanOrEqualTo(beforeOpenOffset),
        reason: 'Opening the accordion should not first scroll upward.',
      );

      await tester.pumpAndSettle();

      _expectVisibleInViewport(
        tester,
        find.text('Action Conditions'),
        'The accordion footer should remain visible after opening.',
      );
    },
  );
}
