import 'package:equatable/equatable.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';

enum NavAxis { vertical, horizontal }

class TransitionConfig extends Equatable {
  const TransitionConfig(this.axis, this.sign, {this.amount = 0.25});

  final NavAxis axis;

  /// `+1` = toward trailing edge (down / right), `-1` = toward leading edge.
  final double sign;

  /// Slide distance as a fraction of the surface size.
  final double amount;

  @override
  List<Object?> get props => [axis, sign, amount];
}

/// Order of the top-level views in the device sidebar.
int _mainSlot(AppDestination d) => switch (d) {
  GesturesDestination() => 0,
  HistoryDestination() => 1,
  SettingsDestination() => 2,
};

/// Derives the motion for a navigation from [from] to [to] — the single place
/// the app decides axis/direction. MiniRouter never sees this; the app's
/// transition builder calls it and maps the result onto its transition widget.
///
/// Within a shell the slide is vertical and follows sidebar order; crossing
/// into/out of settings slides horizontally.
TransitionConfig navTransition(AppDestination? from, AppDestination? to) {
  return switch ((from, to)) {
    (null, _) || (_, null) => const TransitionConfig(NavAxis.vertical, 1),
    (
      final SettingsDestination fromSettings,
      final SettingsDestination toSettings,
    ) =>
      TransitionConfig(
        NavAxis.vertical,
        toSettings.settingsSidebarOrder >= fromSettings.settingsSidebarOrder
            ? 1.0
            : -1.0,
        amount: 0.15,
      ),
    (SettingsDestination(), _) => const TransitionConfig(
      NavAxis.horizontal,
      -1,
      amount: 0.02,
    ),
    (_, SettingsDestination()) => const TransitionConfig(
      NavAxis.horizontal,
      1,
      amount: 0.02,
    ),
    (final AppDestination fromMain, final AppDestination toMain) =>
      TransitionConfig(
        NavAxis.vertical,
        _mainSlot(toMain) >= _mainSlot(fromMain) ? 1.0 : -1.0,
      ),
  };
}
