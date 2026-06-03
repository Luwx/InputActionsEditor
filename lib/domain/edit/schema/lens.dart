import 'package:input_actions_editor/model/config.dart';
import 'package:meta/meta.dart';

/// A typed getter/setter for one slot of type [T] inside a [Config].
@immutable
class Lens<T> {
  const Lens({required this.get, required this.set, required this.name});

  final T Function(Config config) get;
  final Config Function(Config config, T value) set;
  final String name;

  Lens<U> then<U>(LensPart<T, U> part) => Lens<U>(
    get: (config) => part.get(get(config)),
    set: (config, value) => set(config, part.set(get(config), value)),
    name: '$name.${part.name}',
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
  const LensPart({required this.get, required this.set, required this.name});

  final T Function(S source) get;
  final S Function(S source, T value) set;
  final String name;
}
