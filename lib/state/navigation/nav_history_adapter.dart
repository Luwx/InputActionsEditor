import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/routing/mini_router/mini_router.dart';
import 'package:input_actions_editor/state/navigation/app_destination.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';

/// Bridges the Riverpod [navProvider] to MiniRouter's [MiniHistory] contract.
///
/// Keeps the wrapper framework-agnostic: MiniRouter never sees Riverpod, only
/// this listenable view of the flat history.
class NavHistoryAdapter extends ChangeNotifier
    implements MiniHistory<AppDestination> {
  NavHistoryAdapter(this._ref) {
    _sub = _ref.listen<NavState>(
      navProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<NavState> _sub;

  @override
  AppDestination get current => _ref.read(navProvider).current;

  @override
  bool get canBack => _ref.read(navProvider).canBack;

  @override
  void back() => _ref.read(navProvider.notifier).back();

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
