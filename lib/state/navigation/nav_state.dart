import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';

part 'nav_state.freezed.dart';

@freezed
abstract class NavState with _$NavState {
  const factory NavState({
    required List<AppDestination> history,
    required int cursor,
  }) = _NavState;

  const NavState._();

  AppDestination get current => history[cursor];
  bool get canBack => cursor > 0;
  bool get canForward => cursor < history.length - 1;
}
