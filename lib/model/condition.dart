import 'package:freezed_annotation/freezed_annotation.dart';

part 'condition.freezed.dart';

enum ConditionGroupMode { all, any, none }

@freezed
sealed class Condition with _$Condition {
  const factory Condition.variable({
    required String variable,
    required String operator,
    required String value,
    @Default(false) bool negate,
  }) = VariableCondition;

  const factory Condition.group({
    @Default(ConditionGroupMode.all) ConditionGroupMode mode,
    @Default([]) List<Condition> children,
  }) = ConditionGroup;

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
