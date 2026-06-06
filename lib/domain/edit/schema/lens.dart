import 'package:input_actions_editor/model/config.dart';
import 'package:meta/meta.dart';

/// A typed getter/setter for one slot of type [T] inside a [Config].
@immutable
class Lens<T> {
  const Lens({
    required this.get,
    required this.set,
    required this.name,
    bool Function(Config config)? canGet,
  }) : _canGet = canGet;

  final T Function(Config config) get;
  final Config Function(Config config, T value) set;
  final String name;

  /// Narrowing guard composed from any subtype hops in the chain. Null means
  /// every hop is total (the lens is always readable).
  final bool Function(Config config)? _canGet;

  /// Whether [get] is safe to call for [config]. False when a subtype hop
  /// narrows to a different union member (e.g. the action at this location is
  /// not the cast target), so the value reads as absent instead of throwing.
  bool canGet(Config config) => _canGet?.call(config) ?? true;

  Lens<U> then<U>(LensPart<T, U> part) => Lens<U>(
    get: (config) => part.get(get(config)),
    set: (config, value) => set(config, part.set(get(config), value)),
    name: '$name.${part.name}',
    canGet: (config) {
      if (!canGet(config)) return false;
      final partCanGet = part.canGet;
      return partCanGet == null || partCanGet(get(config));
    },
  );

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Lens && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}

/// A typed getter/setter for a sub-part, independent of [Config].
class LensPart<S, T> {
  const LensPart({
    required this.get,
    required this.set,
    required this.name,
    this.canGet,
  });

  final T Function(S source) get;
  final S Function(S source, T value) set;
  final String name;
  final bool Function(S source)? canGet;
}
