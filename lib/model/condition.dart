import 'package:freezed_annotation/freezed_annotation.dart';

part 'condition.freezed.dart';

enum ConditionGroupMode { all, any, none }

enum ConditionOperator {
  equals,
  notEquals,
  greaterThan,
  greaterOrEqual,
  lessThan,
  lessOrEqual,
  between,
  contains,
  matches,
  oneOf,
}

enum ConditionValueType { string, number, bool_, flags, point, enum_, time }

@freezed
sealed class ConditionVariableRef with _$ConditionVariableRef {
  const factory ConditionVariableRef.known(String name) =
      KnownConditionVariable;

  const factory ConditionVariableRef.custom(String name) =
      CustomConditionVariable;
}

extension ConditionVariableRefX on ConditionVariableRef {
  String get name => switch (this) {
    KnownConditionVariable(:final name) => name,
    CustomConditionVariable(:final name) => name,
  };
}

@freezed
sealed class ConditionValue with _$ConditionValue {
  const factory ConditionValue.text(String value) = TextConditionValue;
  const factory ConditionValue.number(double value) = NumberConditionValue;
  const factory ConditionValue.boolean(bool value) = BoolConditionValue;
  const factory ConditionValue.flags(List<String> values) = FlagsConditionValue;
  const factory ConditionValue.point(double x, double y) = PointConditionValue;
  const factory ConditionValue.list(List<String> values) = ListConditionValue;

  const factory ConditionValue.range({
    required ConditionValue from,
    required ConditionValue to,
  }) = RangeConditionValue;

  const factory ConditionValue.raw(String value) = RawConditionValue;
}

/// Lenient readers for the leaf payload of a [ConditionValue].
extension ConditionValuePayload on ConditionValue {
  String get textOrEmpty => switch (this) {
    TextConditionValue(:final value) => value,
    RawConditionValue(:final value) => value,
    _ => '',
  };

  double get numberOrZero => switch (this) {
    NumberConditionValue(:final value) => value,
    _ => 0,
  };

  bool get boolOrFalse => switch (this) {
    BoolConditionValue(:final value) => value,
    _ => false,
  };

  /// Flag/list payloads, with a single non-empty text value promoted to a
  /// one-element list (used when migrating a scalar into a list shape).
  List<String> get stringList => switch (this) {
    ListConditionValue(:final values) => values,
    FlagsConditionValue(:final values) => values,
    TextConditionValue(:final value) when value.trim().isNotEmpty => [
      value.trim(),
    ],
    _ => const [],
  };

  (double, double)? get pointOrNull => switch (this) {
    PointConditionValue(:final x, :final y) => (x, y),
    _ => null,
  };
}

@freezed
sealed class Condition with _$Condition {
  const factory Condition.variable({
    required ConditionVariableRef variable,
    required ConditionOperator operator,
    required ConditionValue value,
    @Default(false) bool negate,
  }) = VariableCondition;

  const factory Condition.group({
    @Default(ConditionGroupMode.all) ConditionGroupMode mode,
    @Default([]) List<Condition> children,
  }) = ConditionGroup;

  /// A JavaScript function evaluated by the daemon; the condition is satisfied
  /// when it returns a truthy value. [expression] is the raw `() => ...`
  /// source.
  const factory Condition.function({required String expression}) =
      FunctionCondition;

  /// Raw YAML string for conditions we cannot parse into the structured model.
  const factory Condition.raw({required String raw}) = RawCondition;
}

Condition? normalizeConditionOrderNullable(Condition? condition) =>
    condition == null ? null : normalizeConditionOrder(condition);

Condition normalizeConditionOrder(Condition condition) => switch (condition) {
  final ConditionGroup group => group.copyWith(
    children: normalizeConditionChildren(group.children),
  ),
  _ => condition,
};

List<Condition> normalizeConditionChildren(List<Condition> children) {
  final nonGroups = <Condition>[];
  final groups = <Condition>[];

  for (final child in children) {
    final normalizedChild = normalizeConditionOrder(child);
    if (normalizedChild is ConditionGroup) {
      groups.add(normalizedChild);
    } else {
      nonGroups.add(normalizedChild);
    }
  }

  return [...nonGroups, ...groups];
}
