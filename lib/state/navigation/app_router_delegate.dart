import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/app_routes.dart';
import 'package:input_actions_editor/state/navigation/nav_history_adapter.dart';

/// The app's router delegate — a thin assembly of the MiniRouter wrapper over
/// the Riverpod-backed history. All routing decisions live in [buildAppRouter].
final appRouterDelegateProvider = Provider<MiniRouterDelegate<AppDestination>>((
  ref,
) {
  final history = NavHistoryAdapter(ref);
  final delegate = MiniRouterDelegate<AppDestination>(
    buildAppRouter(history),
  );
  ref.onDispose(() {
    delegate.dispose();
    history.dispose();
  });
  return delegate;
});
