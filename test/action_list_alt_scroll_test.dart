import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

const ValueKey<String> _viewportKey = ValueKey('action-list-viewport');

/// Footers are keyed by action editId, so they are found by position: only an
/// expanded row renders one.
Finder get _rowFooters => find.byWidgetPredicate((widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('action-footer-');
});

/// Rows expand on a tap anywhere in their header band, which sits one card gap
/// plus half a header down from the row's top.
const double _headerBand = 29;

Finder _row(int index) => find.byType(CollapsibleListRow).at(index);

Finder get _lastRow => find.byType(CollapsibleListRow).last;

Future<void> _tapRow(
  WidgetTester tester,
  Finder row, {
  int buttons = kPrimaryButton,
}) async {
  final rect = tester.getRect(row);
  await tester.tapAt(
    Offset(rect.center.dx, rect.top + _headerBand),
    buttons: buttons,
  );
}

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
    this.aboveHeight,
  });

  final ScrollController controller;
  final double bottomSpacerHeight;
  final TriggerCommon? common;

  /// A resizable band inside the anchored sliver, above the list, standing in
  /// for the trigger section.
  final ValueListenable<double>? aboveHeight;

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProviderScope(
        overrides: [
          configControllerProvider.overrideWith(
            () => _SeededController(_common),
          ),
        ],
        child: FTheme(
          data: AppThemes.zinc.dark.desktop,
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
                          child: Column(
                            children: [
                              if (widget.aboveHeight case final above?)
                                ValueListenableBuilder<double>(
                                  valueListenable: above,
                                  builder: (_, height, _) =>
                                      SizedBox(height: height),
                                ),
                              const EditLocationScope(
                                gesture: GestureLocation(
                                  device: DeviceType.mouse,
                                  editId: _seedEditId,
                                ),
                                child: ActionListEditor(),
                              ),
                            ],
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

/// Pre-assigned identity for the single seeded gesture, so the const
/// [EditLocationScope] can address it without reading the draft.
const _seedEditId = 9001;

class _SeededController extends ConfigController {
  _SeededController(TriggerCommon common)
    : _config = Config(
        mouseNodes: [
          GestureNode.leaf(
            PressGesture(common: common.copyWith(editId: _seedEditId)),
          ),
        ],
      );

  final Config _config;

  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(_config);
    return SynchronousFuture(
      EditSession(draft: normalized, saved: normalized),
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

      await tester.ensureVisible(_row(4));
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
      tester.getRect(_row(4));

      await _tapRow(tester, _row(4));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThanOrEqualTo(initialOffset));

      final footerRect = tester.getRect(_rowFooters.last);
      expect(
        footerRect.bottom,
        greaterThanOrEqualTo(viewportRect.bottom - anchorBottomGap - 12),
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

      await _tapRow(tester, _lastRow);
      await tester.pumpAndSettle();
      _expectVisibleInViewport(
        tester,
        find.text('Wait for completion'),
        'The first expansion should reveal the footer.',
      );

      await _tapRow(tester, _lastRow);
      await tester.pumpAndSettle();

      await _scrollUpABit(tester, controller);

      await _tapRow(tester, _lastRow);
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

      await _tapRow(tester, _lastRow);
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
    'duplicating an action scrolls the duplicate into view',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _ActionsEditorHost(
          controller: controller,
          bottomSpacerHeight: 50,
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(_row(4));
      await tester.pumpAndSettle();

      controller.jumpTo(
        (controller.offset - 20).clamp(
          0.0,
          controller.position.maxScrollExtent,
        ),
      );
      await tester.pump();

      await _tapRow(tester, _row(4), buttons: kSecondaryButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pump();
      await tester.pumpAndSettle();

      _expectVisibleInViewport(
        tester,
        _rowFooters.last,
        'The duplicated action footer should scroll into view.',
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

      await _tapRow(tester, _lastRow);
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
    'a fold taller than the viewport never takes its group off the top',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _ActionsEditorHost(
          controller: controller,
          common: TriggerCommon(
            actions: [
              const TriggerAction(action: CommandAction(command: 'before')),
              TriggerAction(
                action: ActionGroup(
                  actions: List.generate(
                    16,
                    (index) => TriggerAction(
                      action: CommandAction(command: 'child $index'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final groupRow = find
          .ancestor(
            of: find.text('First match'),
            matching: find.byType(CollapsibleListRow),
          )
          .first;
      // The group's disclosure is the leading chevron inside its own card.
      final disclosure = find
          .descendant(
            of: find
                .ancestor(
                  of: find.text('First match'),
                  matching: find.byType(AnimatedContainer),
                )
                .first,
            matching: find.byIcon(FLucideIcons.chevronDown),
          )
          .first;

      // Fold it away, then open the card: that unfolds the children again, all
      // of them at once, which is more than the viewport can hold.
      await tester.ensureVisible(groupRow);
      await tester.pumpAndSettle();
      await tester.tap(disclosure);
      await tester.pumpAndSettle();

      await tester.tap(find.text('First match'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));

      final viewportRect = _viewportRect(tester);
      expect(
        tester.getRect(groupRow).top,
        greaterThanOrEqualTo(viewportRect.top - 1),
        reason:
            'The anchor may not spend more than the headroom above the '
            'group; the rest of the fold spills off the bottom.',
      );
      // Which is only meaningful because the fold cannot fit below it.
      expect(
        tester.getRect(find.byType(CollapsibleListRow).last).bottom,
        greaterThan(viewportRect.bottom),
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

      await _tapRow(tester, _lastRow);
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

  testWidgets(
    'a section above the list grows in place once Other Options settles',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      final aboveHeight = ValueNotifier<double>(200);
      addTearDown(aboveHeight.dispose);

      await tester.pumpWidget(
        _ActionsEditorHost(controller: controller, aboveHeight: aboveHeight),
      );
      await tester.pumpAndSettle();

      await _jumpNearBottom(tester, controller);
      await _tapRow(tester, _lastRow);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other Options'));
      await tester.pumpAndSettle();

      controller.jumpTo(0);
      await tester.pumpAndSettle();

      aboveHeight.value = 500;
      await tester.pumpAndSettle();

      expect(controller.offset, 0);
    },
  );
}
