import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/app.dart';
import 'package:input_actions_editor/app_state/app/local_settings_provider.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/recognition_event.dart';
import 'package:input_actions_editor/services/local_settings_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/features/history/state/recognition_history_provider.dart';
import 'package:input_actions_editor/ui/shell/device_sidebar.dart';
import 'package:input_actions_editor/ui/shell/sidebar/app_sidebar.dart';
import 'package:input_actions_editor/ui/shell/sidebar/collapsible_sidebar.dart';
import 'package:input_actions_editor/ui/shell/sidebar/sidebar_collapse.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/app_sidebar_group.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/app_sidebar_item.dart';
import 'package:input_actions_editor/ui/shell/sidebar/widgets/sidebar_collapse_divider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/load_fonts.dart';
import '../../../helpers/seeded_config_controller.dart';
import '../../../helpers/test_app.dart';

Widget _shell({
  required bool collapsible,
  required Widget child,
  VoidCallback? onContentPress,
}) {
  final shell = Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      child,
      Expanded(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => onContentPress?.call(),
        ),
      ),
    ],
  );
  return collapsible ? CollapsibleSidebar(child: shell) : shell;
}

class _StubHistoryNotifier extends RecognitionHistoryController {
  @override
  List<RecognitionEvent> build() => [];
}

void main() {
  setUpAll(loadAppFonts);

  Future<void> pumpSidebar(
    WidgetTester tester,
    Widget sidebar, {
    double height = 800,
    bool collapsible = false,
    VoidCallback? onContentPress,
  }) async {
    tester.view.physicalSize = Size(600, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        recognitionHistoryProvider.overrideWith(_StubHistoryNotifier.new),
        configControllerProvider.overrideWith(
          () => SeededController(const Config()),
        ),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    final theme = buildAppFThemeData(const LocalSettings(), Brightness.dark);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(
          FTheme(
            data: theme,
            child: _shell(
              collapsible: collapsible,
              onContentPress: onContentPress,
              child: sidebar,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Drags the divider left by [distance], one pixel-ish step at a time so the
  /// resistance and the snap see every intermediate position.
  Future<TestGesture> dragDivider(
    WidgetTester tester,
    double distance, {
    int steps = 20,
    double? x,
    double? y,
  }) async {
    final divider = find.byType(SidebarCollapseDivider);
    final gesture = await tester.startGesture(
      Offset(
        x ?? tester.getCenter(divider).dx,
        y == null
            ? tester.getCenter(divider).dy
            : tester.getTopLeft(divider).dy + y,
      ),
      kind: PointerDeviceKind.mouse,
    );
    for (var i = 0; i < steps; i++) {
      await gesture.moveBy(Offset(distance / steps, 0));
      await tester.pump();
    }
    return gesture;
  }

  Rect sidebarRect(WidgetTester tester) =>
      tester.getRect(find.byType(AppSidebar));

  double sidebarWidth(WidgetTester tester) => sidebarRect(tester).width;

  testWidgets('a pull short of the threshold only squishes the sidebar', (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    final gesture = await dragDivider(tester, -(kSidebarSnapThreshold - 10));
    final squished = sidebarWidth(tester);
    expect(squished, lessThan(kSidebarExpandedWidth));
    // The sidebar holds its ground: it gives less than the pointer travelled.
    expect(
      kSidebarExpandedWidth - squished,
      lessThan(kSidebarSnapThreshold - 10),
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarExpandedWidth));
  });

  testWidgets('a pull past the threshold snaps the sidebar collapsed', (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    final gesture = await dragDivider(tester, -(kSidebarSnapThreshold + 20));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets('the scrollbar over the divider does not swallow the pull', (
    tester,
  ) async {
    // Short enough that the sidebar scrolls, so its scrollbar has a thumb.
    await pumpSidebar(
      tester,
      const DeviceSidebar(),
      height: 300,
      collapsible: true,
    );

    // The scrollbar's grab zone covers the divider, thumb at the top.
    final gesture = await dragDivider(
      tester,
      -(kSidebarSnapThreshold + 20),
      y: 40,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets('the menu button over the divider does not swallow the pull', (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    // The file menu's button reaches into the divider's strip.
    final gesture = await dragDivider(
      tester,
      -(kSidebarSnapThreshold + 20),
      y: 25,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets('the snap keeps springing under a pointer that is still down', (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    final gesture = await dragDivider(tester, -(kSidebarSnapThreshold + 20));
    final trace = <double>[];
    for (var i = 0; i < 30; i++) {
      await gesture.moveBy(const Offset(-2, 0));
      await tester.pump(const Duration(milliseconds: 16));
      trace.add(sidebarWidth(tester));
    }

    // A held pointer that pins the width to the target would leave a single
    // frame under it.
    expect(
      trace.where((w) => w < kSidebarCollapsedWidth - 1).length,
      greaterThan(2),
      reason: 'the snap stopped springing at the collapsed width',
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets('a press that lands short of the cursor strip still drags', (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    // Where the cursor turns, less the couple of pixels a press falls short by.
    final gesture = await dragDivider(
      tester,
      -(kSidebarSnapThreshold + 20),
      x: sidebarRect(tester).right - kSidebarDividerWidth - 2,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets("a press that lands past the sidebar's edge still drags", (
    tester,
  ) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    // Coming at the edge from the content side overshoots it just as easily.
    final gesture = await dragDivider(
      tester,
      -(kSidebarSnapThreshold + 20),
      x: sidebarRect(tester).right + 1,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarCollapsedWidth));
  });

  testWidgets('a press in the overhang does not reach the content', (
    tester,
  ) async {
    var contentPresses = 0;
    await pumpSidebar(
      tester,
      const DeviceSidebar(),
      collapsible: true,
      onContentPress: () => contentPresses++,
    );

    final edge = sidebarRect(tester).right;
    await tester.tapAt(Offset(edge + 1, 300));
    await tester.pump();
    expect(
      contentPresses,
      0,
      reason: 'the overhang let the press through to the content',
    );

    await tester.tapAt(Offset(edge + kSidebarDividerOverhang + 4, 300));
    await tester.pump();
    expect(contentPresses, 1);
  });

  testWidgets("a click in the divider's reach still hits the row", (
    tester,
  ) async {
    var presses = 0;
    await pumpSidebar(
      tester,
      AppSidebar(
        child: AppSidebarGroup(
          children: [
            AppSidebarItem(
              icon: const Icon(FLucideIcons.mouse),
              label: const Text('Mouse'),
              onPress: () => presses++,
            ),
          ],
        ),
      ),
      collapsible: true,
    );

    await tester.tapAt(
      Offset(
        sidebarRect(tester).right - kSidebarDividerWidth - 2,
        tester.getCenter(find.byType(AppSidebarItem)).dy,
      ),
    );
    await tester.pumpAndSettle();

    expect(presses, 1);
  });

  testWidgets('the same pull the other way brings it back', (tester) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    final collapse = await dragDivider(tester, -(kSidebarSnapThreshold + 20));
    await collapse.up();
    await tester.pumpAndSettle();

    final expand = await dragDivider(tester, kSidebarSnapThreshold + 20);
    await expand.up();
    await tester.pumpAndSettle();

    expect(sidebarWidth(tester), moreOrLessEquals(kSidebarExpandedWidth));
  });

  testWidgets('collapsing leaves every icon where it was', (tester) async {
    await pumpSidebar(tester, const DeviceSidebar(), collapsible: true);

    const icons = [
      FLucideIcons.list,
      FLucideIcons.mouse,
      FLucideIcons.mousePointer2,
      FLucideIcons.keyboard,
      FLucideIcons.touchpad,
      FLucideIcons.monitor,
      FLucideIcons.history,
      FLucideIcons.cog,
    ];
    final before = {
      for (final icon in icons) icon: tester.getCenter(find.byIcon(icon)),
    };

    final gesture = await dragDivider(tester, -(kSidebarSnapThreshold + 20));
    await gesture.up();
    await tester.pumpAndSettle();

    for (final icon in icons) {
      expect(
        tester.getCenter(find.byIcon(icon)),
        within(distance: 0.01, from: before[icon]!),
        reason: '$icon moved',
      );
    }
  });
}
