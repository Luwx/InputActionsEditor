import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/device_settings_section_provider.dart';
import 'package:input_actions_editor/ui/common/fade_forwards_transition.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_split_layout.dart';
import 'package:input_actions_editor/ui/features/history/history_screen.dart';
import 'package:input_actions_editor/ui/features/settings/appearance_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/device_config_editor.dart';
import 'package:input_actions_editor/ui/features/settings/device_rules_editor.dart';
import 'package:input_actions_editor/ui/features/settings/effect_settings_screen.dart';
import 'package:input_actions_editor/ui/features/settings/settings_split_layout.dart';
import 'package:input_actions_editor/ui/shell/main_page.dart';

/// The selected gesture, identified by device + index. The route is the single
/// source of truth for this (see [selectedGestureProvider]).
typedef GestureSelection = ({DeviceType device, int index});

/// Top-level views, each backed by a route under the app shell.
enum AppView { gestures, history, settings }

/// A parsed representation of the current URL. The router owns the truth; this
/// is the structured view the rest of the app reads.
@immutable
class AppLocation {
  const AppLocation({
    required this.view,
    this.filter,
    this.device,
    this.index,
    this.section,
    this.settingsSection,
  });

  factory AppLocation.parse(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return const AppLocation(view: AppView.gestures);

    switch (segments.first) {
      case 'gestures':
        final device = segments.length > 1
            ? _deviceFromName(segments[1])
            : null;
        final index = segments.length > 2 ? int.tryParse(segments[2]) : null;
        final filter = _deviceFromName(
          uri.queryParameters['filter'] ?? '',
        );
        return AppLocation(
          view: AppView.gestures,
          filter: filter,
          device: device,
          index: device == null ? null : index,
        );
      case 'history':
        return const AppLocation(view: AppView.history);
      case 'settings':
        if (segments.length > 1) {
          switch (segments[1]) {
            case 'device-settings':
              final section = segments.length > 2
                  ? _sectionFromName(segments[2])
                  : DeviceSettingsSection.mouse;
              return AppLocation(
                view: AppView.settings,
                settingsSection: SettingsSection.deviceSettings,
                section: section,
              );
            case 'device-rules':
              return const AppLocation(
                view: AppView.settings,
                settingsSection: SettingsSection.deviceRules,
              );
            case 'effect-settings':
              return const AppLocation(
                view: AppView.settings,
                settingsSection: SettingsSection.effectSettings,
              );
            case 'appearance':
              return const AppLocation(
                view: AppView.settings,
                settingsSection: SettingsSection.appearance,
              );
          }
        }
        return const AppLocation(
          view: AppView.settings,
          settingsSection: SettingsSection.deviceSettings,
        );
      default:
        return const AppLocation(view: AppView.gestures);
    }
  }

  final AppView view;

  /// For [AppView.gestures]: the sidebar device filter (null = All).
  /// Stored as a `?filter=` query parameter, independent of [device].
  final DeviceType? filter;

  /// For [AppView.gestures]: the selected gesture's device.
  final DeviceType? device;

  /// For [AppView.gestures]: the selected gesture index, when one is open.
  final int? index;

  /// For [AppView.settings] + [SettingsSection.deviceSettings]: which device.
  final DeviceSettingsSection? section;

  /// For [AppView.settings]: which settings sub-section is active.
  final SettingsSection? settingsSection;

  static String gestures({DeviceType? filter, DeviceType? device, int? index}) {
    final path = StringBuffer('/gestures');
    if (device != null) {
      path.write('/${device.name}');
      if (index != null) path.write('/$index');
    }
    if (filter != null) path.write('?filter=${filter.name}');
    return path.toString();
  }

  static String deviceSettings(DeviceSettingsSection section) =>
      '/settings/device-settings/${section.name}';

  static const String settings = '/settings';
  static const String history = '/history';
  static const String deviceRules = '/settings/device-rules';
  static const String effectSettings = '/settings/effect-settings';
  static const String appearance = '/settings/appearance';

  static DeviceType? _deviceFromName(String name) {
    for (final d in DeviceType.values) {
      if (d.name == name) return d;
    }
    return null;
  }

  static DeviceSettingsSection _sectionFromName(String name) {
    for (final s in DeviceSettingsSection.values) {
      if (s.name == name) return s;
    }
    return DeviceSettingsSection.mouse;
  }

  AppLocation withGestureStateFrom(AppLocation previous) {
    if (view == AppView.gestures) return this;

    return AppLocation(
      view: view,
      filter: previous.filter,
      device: previous.device,
      index: previous.index,
      section: section,
      settingsSection: settingsSection,
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppLocation.gestures(),
    routes: [
      ShellRoute(
        pageBuilder: (context, state, child) => _mainShellPage(
          context,
          child: MainPage(child: child),
        ),
        routes: [
          GoRoute(
            path: '/gestures',
            pageBuilder: (_, _) =>
                _viewPage(AppView.gestures, const _GesturesRoute()),
          ),
          GoRoute(
            path: '/gestures/:device/:index',
            pageBuilder: (_, _) =>
                _viewPage(AppView.gestures, const _GesturesRoute()),
          ),
          GoRoute(
            path: AppLocation.history,
            pageBuilder: (context, state) => _viewPage(
              AppView.history,
              ColoredBox(
                color: context.theme.colors.background,
                child: const HistoryScreen(),
              ),
            ),
          ),
        ],
      ),
      ShellRoute(
        pageBuilder: (context, state, child) => _settingsShellPage(
          context,
          child: SettingsSplitLayout(child: child),
        ),
        routes: [
          GoRoute(
            path: AppLocation.settings,
            pageBuilder: (context, state) => _settingsContentPage(
              context,
              state,
              child: const DeviceConfigEditor(
                section: DeviceSettingsSection.mouse,
              ),
            ),
          ),
          GoRoute(
            path: '/settings/device-settings/:section',
            pageBuilder: (context, state) => _settingsContentPage(
              context,
              state,
              child: DeviceConfigEditor(
                section:
                    AppLocation.parse(state.uri).section ??
                    DeviceSettingsSection.mouse,
              ),
            ),
          ),
          GoRoute(
            path: AppLocation.deviceRules,
            pageBuilder: (context, state) => _settingsContentPage(
              context,
              state,
              child: const DeviceRulesEditor(),
            ),
          ),
          GoRoute(
            path: AppLocation.effectSettings,
            pageBuilder: (context, state) => _settingsContentPage(
              context,
              state,
              child: const EffectSettingsScreen(),
            ),
          ),
          GoRoute(
            path: AppLocation.appearance,
            pageBuilder: (context, state) => _settingsContentPage(
              context,
              state,
              child: const AppearanceSettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

/// The top-level views in the order they appear, top to bottom, in the
/// sidebar. Used to make the cross-view slide direction-aware: navigating to a
/// lower item slides up, to a higher item slides down.
const List<AppView> _sidebarOrder = [
  AppView.gestures,
  AppView.history,
  AppView.settings,
];

/// The view currently on screen, tracked so [_viewPage] can compare it against
/// the next one and choose a slide direction. Module-level because go_router
/// only rebuilds the *incoming* page on navigation, whereas the transition —
/// which reads [_crossViewSlideSign] — is re-run every frame for both the
/// incoming and outgoing pages (their animations tick), so both observe the
/// same, current direction.
AppView? _shownView;

/// `+1` slides content up (moving to a lower sidebar item), `-1` slides it down
/// (a higher item). Read live by [_FadeForwardsTransition].
double _crossViewSlideSign = 1;

void _recordViewForDirection(AppView next) {
  final from = _shownView;
  _shownView = next;
  if (from == null || from == next) return;
  final fromPos = _sidebarOrder.indexOf(from);
  final toPos = _sidebarOrder.indexOf(next);
  if (fromPos == -1 || toPos == -1) return;
  _crossViewSlideSign = toPos > fromPos ? 1 : -1;
}

/// Wraps a routed view in a page keyed by its [AppView]. Because every route
/// belonging to the same view shares this key, navigating *within* a view (e.g.
/// changing the gesture device filter or the settings section) updates the page
/// in place — the widget is reused and nothing animates. Switching to a
/// different view swaps keys, which cross-fades using the Material 3 "fade
/// forwards" motion, sliding along the sidebar's axis in the direction of
/// travel (see [_recordViewForDirection]).
CustomTransitionPage<void> _viewPage(
  AppView view,
  Widget child, {
  Axis axis = Axis.vertical,
}) {
  _recordViewForDirection(view);
  return CustomTransitionPage<void>(
    key: ValueKey(view),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CustomFadeForwardsTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          axis: axis,
          // Read live (not captured) so the outgoing page, whose transition is
          // rebuilt each frame, observes the current navigation's direction.
          slideSign: _crossViewSlideSign,
          // Match the FTheme background, else it falls back to a grey flash.
          backgroundColor: context.theme.colors.background,
          child: child,
        ),
    child: child,
  );
}

const List<DeviceSettingsSection> _settingsDeviceOrder = [
  DeviceSettingsSection.mouse,
  DeviceSettingsSection.pointer,
  DeviceSettingsSection.keyboard,
  DeviceSettingsSection.touchpad,
  DeviceSettingsSection.touchscreen,
];

AppLocation? _shownSettingsLocation;
double _settingsSlideSign = 1;

void _recordSettingsDirection(AppLocation next) {
  final from = _shownSettingsLocation;
  _shownSettingsLocation = next;
  if (from == null) return;
  final fromPos = _settingsOrderIndex(from);
  final toPos = _settingsOrderIndex(next);
  if (fromPos == toPos) return;
  _settingsSlideSign = toPos > fromPos ? 1 : -1;
}

int _settingsOrderIndex(AppLocation location) {
  return switch (location.settingsSection ?? SettingsSection.deviceSettings) {
    SettingsSection.deviceSettings => _settingsDeviceOrder.indexOf(
      location.section ?? DeviceSettingsSection.mouse,
    ),
    SettingsSection.deviceRules => _settingsDeviceOrder.length,
    SettingsSection.effectSettings => _settingsDeviceOrder.length + 1,
    SettingsSection.appearance => _settingsDeviceOrder.length + 2,
  };
}

CustomTransitionPage<void> _mainShellPage(
  BuildContext context, {
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: const ValueKey('main-shell'),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CustomFadeForwardsTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          axis: Axis.horizontal,
          backgroundColor: context.theme.colors.background,
          child: child,
        ),
    child: ColoredBox(
      color: context.theme.colors.background,
      child: child,
    ),
  );
}

CustomTransitionPage<void> _settingsContentPage(
  BuildContext context,
  GoRouterState state, {
  required Widget child,
}) {
  _recordSettingsDirection(AppLocation.parse(state.uri));

  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CustomFadeForwardsTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          slideSign: _settingsSlideSign,
          backgroundColor: context.theme.colors.background,
          slideAmount: 0.15,
          child: child,
        ),
    child: ColoredBox(
      color: context.theme.colors.background,
      child: child,
    ),
  );
}

CustomTransitionPage<void> _settingsShellPage(
  BuildContext context, {
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: const ValueKey(AppView.settings),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        CustomFadeForwardsTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          axis: Axis.horizontal,
          backgroundColor: context.theme.colors.background,
          child: child,
        ),
    child: ColoredBox(
      color: context.theme.colors.background,
      child: child,
    ),
  );
}

/// Bridges the router's location into Riverpod so providers/widgets can react
/// to navigation. Updated whenever the router delegate notifies.
class AppLocationController extends Notifier<AppLocation> {
  @override
  AppLocation build() {
    final router = ref.watch(routerProvider);
    final delegate = router.routerDelegate;

    void listener() {
      state = AppLocation.parse(
        delegate.currentConfiguration.uri,
      ).withGestureStateFrom(state);
    }

    delegate.addListener(listener);
    ref.onDispose(() => delegate.removeListener(listener));
    return AppLocation.parse(delegate.currentConfiguration.uri);
  }
}

final appLocationProvider =
    NotifierProvider<AppLocationController, AppLocation>(
      AppLocationController.new,
    );

final currentViewProvider = Provider<AppView>(
  (ref) => ref.watch(appLocationProvider).view,
);

/// The last gestures filter chosen by the user.
///
/// This remains set while another top-level view is active so the outgoing
/// gestures page keeps rendering the same list during cross-view transitions.
/// Use [currentViewProvider] when behavior must depend on the visible screen.
final deviceFilterProvider = Provider<DeviceType?>((ref) {
  return ref.watch(appLocationProvider.select((location) => location.filter));
});

/// The last gesture selection opened by the user.
///
/// This remains set while another top-level view is active so the outgoing
/// gestures page keeps rendering the same detail during cross-view transitions.
/// Use [currentViewProvider] when behavior must depend on the visible screen.
final selectedGestureProvider = Provider<GestureSelection?>((ref) {
  final location = ref.watch(appLocationProvider);
  if (location.device != null && location.index != null) {
    return (device: location.device!, index: location.index!);
  }
  return null;
});

final deviceSettingsSectionProvider = Provider<DeviceSettingsSection>(
  (ref) =>
      ref.watch(appLocationProvider).section ?? DeviceSettingsSection.mouse,
);

final currentSettingsSectionProvider = Provider<SettingsSection>(
  (ref) =>
      ref.watch(appLocationProvider).settingsSection ??
      SettingsSection.deviceSettings,
);

/// Persisted across navigation so the split divider position is stable.
class GestureListWidthController extends Notifier<double> {
  @override
  double build() => 0.3;

  double get fraction => state;

  set fraction(double value) => state = value;
}

final gestureListWidthProvider =
    NotifierProvider<GestureListWidthController, double>(
      GestureListWidthController.new,
    );

/// Navigation helpers that derive route state from the live [BuildContext].
extension AppNavigation on BuildContext {
  AppLocation get appLocation => AppLocation.parse(GoRouterState.of(this).uri);

  /// Sidebar navigation: set the device filter and clear any selection.
  void goToGestures({DeviceType? device}) =>
      go(AppLocation.gestures(filter: device));

  /// Sidebar navigation: set the device filter and immediately
  /// select a gesture.
  void goToGesturesSelectFirst({
    required DeviceType device,
    required int index,
    DeviceType? filter,
  }) => go(AppLocation.gestures(filter: filter, device: device, index: index));

  /// Select a specific gesture, preserving the current sidebar filter.
  void selectGesture(DeviceType device, int index) {
    go(
      AppLocation.gestures(
        filter: appLocation.filter,
        device: device,
        index: index,
      ),
    );
  }

  /// Clear gesture selection, preserving the current sidebar filter.
  void clearGestureSelection() =>
      go(AppLocation.gestures(filter: appLocation.filter));

  void goToHistory() => go(AppLocation.history);

  Future<void> pushSettings() => push<void>(AppLocation.settings);
}

class _GesturesRoute extends ConsumerWidget {
  const _GesturesRoute();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(gestureListWidthProvider);
    return ColoredBox(
      color: context.theme.colors.background,
      child: GestureSplitLayout(
        gestureListWidthFraction: fraction,
        onGestureListWidthFractionChanged: (value) =>
            ref.read(gestureListWidthProvider.notifier).fraction = value,
        dividerLayout: ResizeDividerLayout.overlay,
        dividerLinePlacement: ResizeDividerLinePlacement.left,
      ),
    );
  }
}
