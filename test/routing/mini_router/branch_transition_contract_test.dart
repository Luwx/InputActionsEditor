import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';
import 'package:input_actions_editor/ui/common/fade_forwards_transition.dart';

const _duration = Duration(milliseconds: 350);
const _sampleAt = Duration(milliseconds: 120);
const _tolerance = 0.001;

enum _ContainerKind { routeStack, keepAlive }

enum _LeafKind { routeStack, miniSwitcher }

@immutable
class _SettingsFrame {
  const _SettingsFrame({
    required this.settingsDx,
    required this.settingsOpacity,
  });

  final double settingsDx;
  final double settingsOpacity;
}

@immutable
class _LeafFrame {
  const _LeafFrame({
    required this.gesturesDy,
    required this.gesturesOpacity,
    required this.historyDy,
    required this.historyOpacity,
  });

  final double gesturesDy;
  final double gesturesOpacity;
  final double historyDy;
  final double historyOpacity;
}

Widget _host({
  required _ContainerKind kind,
  required int currentIndex,
}) {
  final children = [
    const ColoredBox(
      color: Colors.white,
      child: Center(child: Text('main')),
    ),
    const ColoredBox(
      color: Colors.white,
      child: Center(child: Text('settings')),
    ),
  ];

  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 400,
      height: 300,
      child: switch (kind) {
        _ContainerKind.routeStack => _RouteStackContainer(
          currentIndex: currentIndex,
          transitionDuration: _duration,
          transitionsBuilder: _fadeForwards,
          main: children[0],
          settings: children[1],
        ),
        _ContainerKind.keepAlive => AnimatedBranchContainer(
          currentIndex: currentIndex,
          transitionsBuilder: _fadeForwards,
          children: children,
        ),
      },
    ),
  );
}

Widget _leafHost({
  required _LeafKind kind,
  required int currentIndex,
  required double slideSign,
}) {
  const gestures = ColoredBox(
    color: Colors.white,
    child: Center(child: Text('gestures')),
  );
  const history = ColoredBox(
    color: Colors.white,
    child: Center(child: Text('history')),
  );

  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 400,
      height: 300,
      child: switch (kind) {
        _LeafKind.routeStack => _LeafRouteStackContainer(
          currentIndex: currentIndex,
          transitionDuration: _duration,
          slideSign: slideSign,
          gestures: gestures,
          history: history,
        ),
        _LeafKind.miniSwitcher => CoupledLeafSwitcher(
          axis: Axis.vertical,
          sign: slideSign,
          amount: 0.25,
          transitionsBuilder: _fadeForwardsVertical(slideSign),
          child: switch (currentIndex) {
            0 => const KeyedSubtree(
              key: ValueKey('gestures'),
              child: gestures,
            ),
            _ => const KeyedSubtree(
              key: ValueKey('history'),
              child: history,
            ),
          },
        ),
      },
    ),
  );
}

class _RouteStackContainer extends StatelessWidget {
  const _RouteStackContainer({
    required this.currentIndex,
    required this.transitionDuration,
    required this.transitionsBuilder,
    required this.main,
    required this.settings,
  });

  final int currentIndex;
  final Duration transitionDuration;
  final RouteTransitionsBuilder transitionsBuilder;
  final Widget main;
  final Widget settings;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onDidRemovePage: (page) {},
      pages: [
        CustomTransitionPage<void>(
          key: const ValueKey('main-route'),
          transitionDuration: transitionDuration,
          reverseTransitionDuration: transitionDuration,
          transitionsBuilder: transitionsBuilder,
          child: main,
        ),
        if (currentIndex == 1)
          CustomTransitionPage<void>(
            key: const ValueKey('settings-route'),
            transitionDuration: transitionDuration,
            reverseTransitionDuration: transitionDuration,
            transitionsBuilder: transitionsBuilder,
            child: settings,
          ),
      ],
    );
  }
}

class _LeafRouteStackContainer extends StatelessWidget {
  const _LeafRouteStackContainer({
    required this.currentIndex,
    required this.transitionDuration,
    required this.slideSign,
    required this.gestures,
    required this.history,
  });

  final int currentIndex;
  final Duration transitionDuration;
  final double slideSign;
  final Widget gestures;
  final Widget history;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onDidRemovePage: (page) {},
      pages: [
        CustomTransitionPage<void>(
          key: const ValueKey('gestures-route'),
          transitionDuration: transitionDuration,
          reverseTransitionDuration: transitionDuration,
          transitionsBuilder: _fadeForwardsVertical(slideSign),
          child: gestures,
        ),
        if (currentIndex == 1)
          CustomTransitionPage<void>(
            key: const ValueKey('history-route'),
            transitionDuration: transitionDuration,
            reverseTransitionDuration: transitionDuration,
            transitionsBuilder: _fadeForwardsVertical(slideSign),
            child: history,
          ),
      ],
    );
  }
}

Widget _fadeForwards(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return CustomFadeForwardsTransition(
    animation: animation,
    secondaryAnimation: secondaryAnimation,
    axis: Axis.horizontal,
    backgroundColor: Colors.white,
    child: child,
  );
}

RouteTransitionsBuilder _fadeForwardsVertical(double slideSign) =>
    (
      context,
      animation,
      secondaryAnimation,
      child,
    ) {
      return CustomFadeForwardsTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        slideSign: slideSign,
        backgroundColor: Colors.white,
        child: child,
      );
    };

Future<_SettingsFrame> _sampleTransition(
  WidgetTester tester, {
  required _ContainerKind kind,
  required int from,
  required int to,
}) async {
  await tester.pumpWidget(_host(kind: kind, currentIndex: from));
  await tester.pump();

  await tester.pumpWidget(_host(kind: kind, currentIndex: to));
  await tester.pump();
  await tester.pump(_sampleAt);

  final frame = _SettingsFrame(
    settingsDx: _slideDx(tester, 'settings'),
    settingsOpacity: _opacity(tester, 'settings'),
  );

  await tester.pumpWidget(const SizedBox());
  await tester.pump(_duration);
  return frame;
}

Future<_LeafFrame> _sampleLeafTransition(
  WidgetTester tester, {
  required _LeafKind kind,
  required int from,
  required int to,
}) async {
  final slideSign = to >= from ? 1.0 : -1.0;

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: from, slideSign: slideSign),
  );
  await tester.pump();

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: to, slideSign: slideSign),
  );
  await tester.pump();
  await tester.pump(_sampleAt);

  final frame = _LeafFrame(
    gesturesDy: _slideDy(tester, 'gestures'),
    gesturesOpacity: _opacity(tester, 'gestures'),
    historyDy: _slideDy(tester, 'history'),
    historyOpacity: _opacity(tester, 'history'),
  );

  await tester.pumpWidget(const SizedBox());
  await tester.pump(_duration);
  return frame;
}

Future<_LeafFrame> _sampleLeafPopTransition(
  WidgetTester tester, {
  required _LeafKind kind,
}) async {
  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 0, slideSign: 1),
  );
  await tester.pump();

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 1, slideSign: 1),
  );
  await tester.pump();
  await tester.pump(_duration);
  await tester.pump();

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 0, slideSign: -1),
  );
  await tester.pump();
  await tester.pump(_sampleAt);

  final frame = _LeafFrame(
    gesturesDy: _slideDy(tester, 'gestures'),
    gesturesOpacity: _opacity(tester, 'gestures'),
    historyDy: _slideDy(tester, 'history'),
    historyOpacity: _opacity(tester, 'history'),
  );

  await tester.pumpWidget(const SizedBox());
  await tester.pump(_duration);
  return frame;
}

Future<_LeafFrame> _sampleInterruptedLeafPopTransition(
  WidgetTester tester, {
  required _LeafKind kind,
}) async {
  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 0, slideSign: 1),
  );
  await tester.pump();

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 1, slideSign: 1),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 240));

  await tester.pumpWidget(
    _leafHost(kind: kind, currentIndex: 0, slideSign: -1),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 40));

  final frame = _LeafFrame(
    gesturesDy: _slideDy(tester, 'gestures'),
    gesturesOpacity: _opacity(tester, 'gestures'),
    historyDy: _slideDy(tester, 'history'),
    historyOpacity: _opacity(tester, 'history'),
  );

  await tester.pumpWidget(const SizedBox());
  await tester.pump(_duration);
  return frame;
}

double _slideDx(WidgetTester tester, String label) {
  final slides = find.ancestor(
    of: find.text(label, skipOffstage: false),
    matching: find.byType(SlideTransition, skipOffstage: false),
  );
  expect(slides, findsWidgets);
  final slide = tester.widgetList<SlideTransition>(slides).last;
  return slide.position.value.dx;
}

double _slideDy(WidgetTester tester, String label) {
  final slides = find.ancestor(
    of: find.text(label, skipOffstage: false),
    matching: find.byType(SlideTransition, skipOffstage: false),
  );
  expect(slides, findsWidgets);
  final slide = tester.widgetList<SlideTransition>(slides).last;
  return slide.position.value.dy;
}

double _opacity(WidgetTester tester, String label) {
  final fades = find.ancestor(
    of: find.text(label, skipOffstage: false),
    matching: find.byType(FadeTransition, skipOffstage: false),
  );
  expect(fades, findsWidgets);
  final fade = tester.widgetList<FadeTransition>(fades).last;
  return fade.opacity.value;
}

void _expectSettingsRouteMatches(
  _SettingsFrame actual,
  _SettingsFrame expected,
) {
  expect(
    actual.settingsDx,
    moreOrLessEquals(expected.settingsDx, epsilon: _tolerance),
    reason: 'settings branch slide offset should match the PageRoute oracle',
  );
  expect(
    actual.settingsOpacity,
    moreOrLessEquals(expected.settingsOpacity, epsilon: _tolerance),
    reason: 'settings branch opacity curve should match the PageRoute oracle',
  );
}

void _expectHistoryRouteMatches(_LeafFrame actual, _LeafFrame expected) {
  expect(
    actual.gesturesDy,
    moreOrLessEquals(expected.gesturesDy, epsilon: _tolerance),
    reason: 'gestures leaf slide offset should match the PageRoute oracle',
  );
  expect(
    actual.gesturesOpacity,
    moreOrLessEquals(expected.gesturesOpacity, epsilon: _tolerance),
    reason: 'gestures leaf opacity curve should match the PageRoute oracle',
  );
  expect(
    actual.historyDy,
    moreOrLessEquals(expected.historyDy, epsilon: _tolerance),
    reason: 'history leaf slide offset should match the PageRoute oracle',
  );
  expect(
    actual.historyOpacity,
    moreOrLessEquals(expected.historyOpacity, epsilon: _tolerance),
    reason: 'history leaf opacity curve should match the PageRoute oracle',
  );
}

Widget _fallbackLeafHost(
  String label, {
  Curve curve = Curves.easeInOutCubicEmphasized,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: CoupledLeafSwitcher(
      axis: Axis.vertical,
      sign: 1,
      amount: 0.25,
      duration: const Duration(milliseconds: 300),
      curve: curve,
      child: Text(
        label,
        key: ValueKey(label),
        textDirection: TextDirection.ltr,
      ),
    ),
  );
}

double _fallbackSlideY(WidgetTester tester, String label) {
  final slide = tester.widget<SlideTransition>(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(SlideTransition),
    ),
  );
  return slide.position.value.dy;
}

double _fallbackOpacity(WidgetTester tester, String label) {
  final fade = tester.widget<FadeTransition>(
    find.ancestor(
      of: find.text(label),
      matching: find.byType(FadeTransition),
    ),
  );
  return fade.opacity.value;
}

enum _RestartHostKind {
  routeStack,
  miniKeepAlive,
  leafRouteStack,
  leafSwitcher,
}

final class _AnimationCounters {
  int inits = 0;
  int plays = 0;
}

Widget _restartHost({
  required _RestartHostKind kind,
  required int currentIndex,
  required _AnimationCounters counters,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SizedBox(
      width: 400,
      height: 300,
      child: switch (kind) {
        _RestartHostKind.routeStack => _RestartRouteStackHost(
          currentIndex: currentIndex,
          counters: counters,
          leafMode: false,
        ),
        _RestartHostKind.leafRouteStack => _RestartRouteStackHost(
          currentIndex: currentIndex,
          counters: counters,
          leafMode: true,
        ),
        _RestartHostKind.miniKeepAlive => AnimatedBranchContainer(
          currentIndex: currentIndex,
          transitionsBuilder: _fadeForwards,
          children: [
            _RestartMain(counters: counters),
            const Center(child: Text('settings')),
          ],
        ),
        _RestartHostKind.leafSwitcher => CoupledLeafSwitcher(
          axis: Axis.vertical,
          sign: 1,
          amount: 0.15,
          child: switch (currentIndex) {
            0 => _RestartMain(
              key: const ValueKey('effect-leaf'),
              counters: counters,
            ),
            _ => const Center(
              key: ValueKey('interface-leaf'),
              child: Text('interface'),
            ),
          },
        ),
      },
    ),
  );
}

class _RestartRouteStackHost extends StatelessWidget {
  const _RestartRouteStackHost({
    required this.currentIndex,
    required this.counters,
    required this.leafMode,
  });

  final int currentIndex;
  final _AnimationCounters counters;
  final bool leafMode;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onDidRemovePage: (page) {},
      pages: [
        CustomTransitionPage<void>(
          key: ValueKey(leafMode ? 'effect-route' : 'main-route'),
          transitionDuration: _duration,
          reverseTransitionDuration: _duration,
          transitionsBuilder: _fadeForwards,
          child: _RestartMain(counters: counters),
        ),
        if (currentIndex == 1)
          CustomTransitionPage<void>(
            key: ValueKey(leafMode ? 'interface-route' : 'settings-route'),
            transitionDuration: _duration,
            reverseTransitionDuration: _duration,
            transitionsBuilder: _fadeForwards,
            child: Center(child: Text(leafMode ? 'interface' : 'settings')),
          ),
      ],
    );
  }
}

class _RestartMain extends StatelessWidget {
  const _RestartMain({required this.counters, super.key});

  final _AnimationCounters counters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _RestartProbe(
        key: const ValueKey('animated-title'),
        counters: counters,
        child: const Text('animated title'),
      ),
    );
  }
}

class _RestartProbe extends StatefulWidget {
  const _RestartProbe({
    required this.counters,
    required this.child,
    super.key,
  });

  final _AnimationCounters counters;
  final Widget child;

  @override
  State<_RestartProbe> createState() => _RestartProbeState();
}

class _RestartProbeState extends State<_RestartProbe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    widget.counters.inits++;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    );
    Future<void>.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      widget.counters.plays++;
      unawaited(_controller.forward());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-0.05, 0),
          end: Offset.zero,
        ).animate(_controller),
        child: widget.child,
      ),
    );
  }
}

Future<void> _expectEntranceDoesNotRestart(
  WidgetTester tester,
  _RestartHostKind kind,
) async {
  final counters = _AnimationCounters();

  await tester.pumpWidget(
    _restartHost(kind: kind, currentIndex: 0, counters: counters),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
  expect(counters.inits, 1, reason: '$kind initial init');
  expect(counters.plays, 1, reason: '$kind initial play');

  await tester.pumpWidget(
    _restartHost(kind: kind, currentIndex: 1, counters: counters),
  );
  await tester.pump();
  await tester.pump(_duration);

  await tester.pumpWidget(
    _restartHost(kind: kind, currentIndex: 0, counters: counters),
  );
  await tester.pump();
  await tester.pump(_duration);

  expect(counters.inits, 1, reason: '$kind should reuse state');
  expect(counters.plays, 1, reason: '$kind should not replay entrance');

  await tester.pumpWidget(const SizedBox());
  await tester.pump(_duration);
}

Widget _shellCacheHost({
  required int currentIndex,
  required List<int> builds,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: StatefulNavigationShell(
      currentIndex: currentIndex,
      branchCount: 2,
      buildBranch: (context, index) {
        builds[index]++;
        return Text('branch $index', textDirection: TextDirection.ltr);
      },
      containerBuilder: (context, shell, children) => Stack(
        children: [
          for (var i = 0; i < children.length; i++)
            Offstage(offstage: i != shell.currentIndex, child: children[i]),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('matches PageRoute transition geometry for branches and leaves', (
    tester,
  ) async {
    for (final (from, to) in [(0, 1), (1, 0)]) {
      _expectSettingsRouteMatches(
        await _sampleTransition(
          tester,
          kind: _ContainerKind.keepAlive,
          from: from,
          to: to,
        ),
        await _sampleTransition(
          tester,
          kind: _ContainerKind.routeStack,
          from: from,
          to: to,
        ),
      );
    }

    _expectHistoryRouteMatches(
      await _sampleLeafTransition(
        tester,
        kind: _LeafKind.miniSwitcher,
        from: 0,
        to: 1,
      ),
      await _sampleLeafTransition(
        tester,
        kind: _LeafKind.routeStack,
        from: 0,
        to: 1,
      ),
    );
    _expectHistoryRouteMatches(
      await _sampleLeafPopTransition(tester, kind: _LeafKind.miniSwitcher),
      await _sampleLeafPopTransition(tester, kind: _LeafKind.routeStack),
    );
    _expectHistoryRouteMatches(
      await _sampleInterruptedLeafPopTransition(
        tester,
        kind: _LeafKind.miniSwitcher,
      ),
      await _sampleInterruptedLeafPopTransition(
        tester,
        kind: _LeafKind.routeStack,
      ),
    );
  });

  testWidgets(
    'fallback leaf switcher keeps reversible state',
    (
      tester,
    ) async {
      const fallbackDuration = Duration(milliseconds: 300);

      await tester.pumpWidget(_fallbackLeafHost('A'));
      await tester.pumpWidget(_fallbackLeafHost('B'));
      await tester.pump(fallbackDuration ~/ 2);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      final beforeReverse = _fallbackSlideY(tester, 'B');
      await tester.pumpWidget(_fallbackLeafHost('A'));
      await tester.pump();
      expect(_fallbackSlideY(tester, 'B'), moreOrLessEquals(beforeReverse));

      await tester.pump(
        fallbackDuration ~/ 2 + const Duration(milliseconds: 40),
      );
      expect(find.text('B'), findsNothing);
      expect(find.text('A'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(_fallbackSlideY(tester, 'A'), 0);
      expect(_fallbackOpacity(tester, 'A'), 1);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_fallbackLeafHost('A'));
      await tester.pumpWidget(_fallbackLeafHost('B'));
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(find.text('A'), findsNothing);

      await tester.pumpWidget(_fallbackLeafHost('B'));
      await tester.pump();
      expect(find.text('B'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        _fallbackLeafHost('A', curve: Curves.easeInCubic),
      );
      await tester.pumpWidget(
        _fallbackLeafHost('B', curve: Curves.easeInCubic),
      );
      await tester.pump(const Duration(milliseconds: 240));
      final cubicBeforeReverse = _fallbackSlideY(tester, 'B');
      await tester.pumpWidget(
        _fallbackLeafHost('A', curve: Curves.easeInCubic),
      );
      await tester.pump();
      expect(
        _fallbackSlideY(tester, 'B'),
        moreOrLessEquals(cubicBeforeReverse),
      );
    },
  );

  testWidgets(
    'retained branch and leaf subtrees do not restart entrance animations',
    (
      tester,
    ) async {
      for (final kind in _RestartHostKind.values) {
        await _expectEntranceDoesNotRestart(tester, kind);
      }
    },
  );

  testWidgets(
    'StatefulNavigationShell caches and rebuilds branches',
    (
      tester,
    ) async {
      final builds = [0, 0];

      await tester.pumpWidget(
        _shellCacheHost(currentIndex: 0, builds: builds),
      );
      expect(builds, [1, 0]);

      await tester.pumpWidget(
        _shellCacheHost(currentIndex: 1, builds: builds),
      );
      expect(builds, [1, 1]);

      await tester.pumpWidget(
        _shellCacheHost(currentIndex: 0, builds: builds),
      );
      expect(builds, [1, 1]);

      await tester.pumpWidget(
        _shellCacheHost(currentIndex: 0, builds: builds),
      );
      expect(builds, [2, 1]);
    },
  );
}
