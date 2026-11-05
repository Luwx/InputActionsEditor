import 'package:collection/collection.dart';
import 'package:input_actions_editor/domain/conditions/condition_value_codec.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';

/// The variable holding the app class of the window under the pointer.
const exceptionVariable = 'window_under_pointer_class';

/// The apps listed in the NONE block of [conditions], in order.
List<String> exceptionApps(Condition? conditions) => [
  for (final child in _noneBlockOf(conditions)?.children ?? const <Condition>[])
    if (_exceptionApp(child) case final String app) app,
];

/// [conditions] with [app] added to the NONE block, which is created if needed.
/// Other conditions stay as they are.
Condition withExceptionApp(Condition? conditions, String app) {
  final existing = _noneBlockOf(conditions);
  if (existing != null) {
    if (exceptionApps(conditions).contains(app)) return conditions!;
    return _replaceChild(
      conditions!,
      existing,
      existing.copyWith(children: [...existing.children, _appCondition(app)]),
    );
  }
  final block = ConditionGroup(
    mode: ConditionGroupMode.none,
    children: [_appCondition(app)],
  );
  return switch (conditions) {
    null => ConditionGroup(children: [block]),
    final ConditionGroup root when root.mode == ConditionGroupMode.all =>
      root.copyWith(children: [...root.children, block]),
    final other => ConditionGroup(children: [other, block]),
  };
}

/// [conditions] without [app]. A NONE block left empty is dropped, and so is a
/// root group left empty.
Condition? withoutExceptionApp(Condition? conditions, String app) {
  final existing = _noneBlockOf(conditions);
  if (existing == null) return conditions;
  final remaining = existing.children
      .where((child) => _exceptionApp(child) != app)
      .toList();
  if (remaining.isNotEmpty) {
    return _replaceChild(
      conditions!,
      existing,
      existing.copyWith(children: remaining),
    );
  }
  if (identical(conditions, existing)) return null;
  final root = conditions! as ConditionGroup;
  final children = root.children
      .where((child) => !identical(child, existing))
      .toList();
  return children.isEmpty ? null : root.copyWith(children: children);
}

/// Where exceptions for mouse gestures are kept.
class GestureExceptionsTarget {
  const GestureExceptionsTarget({
    required this.location,
    required this.group,
    required this.outsideCount,
  });

  final GestureGroupLocation location;
  final GestureGroupNode group;

  /// Mouse gestures outside [group], which exceptions don't apply to.
  final int outsideCount;

  List<String> get apps => exceptionApps(group.conditions);
}

/// The top-level mouse group that has exceptions, or else the first one with
/// gestures. Null when no mouse gesture is in a group.
GestureExceptionsTarget? gestureExceptionsTarget(Config config) {
  final nodes = gestureNodesForDevice(config, DeviceType.mouse);
  final groups = nodes.whereType<GestureGroupNode>().where(
    (group) => group.editId != null,
  );
  final group =
      groups.firstWhereOrNull(
        (group) => exceptionApps(group.conditions).isNotEmpty,
      ) ??
      groups.firstWhereOrNull((group) => group.gestures.isNotEmpty);
  if (group == null) return null;
  final total = nodes.fold(0, (sum, node) => sum + node.gestures.length);
  return GestureExceptionsTarget(
    location: GestureGroupLocation(
      device: DeviceType.mouse,
      editId: group.editId!,
    ),
    group: group,
    outsideCount: total - group.gestures.length,
  );
}

/// The NONE block that holds exceptions: [conditions] itself or a direct child
/// of an ALL group. NONE blocks without any exception are not used.
ConditionGroup? _noneBlockOf(Condition? conditions) {
  bool isBlock(Condition condition) =>
      condition is ConditionGroup &&
      condition.mode == ConditionGroupMode.none &&
      condition.children.any((child) => _exceptionApp(child) != null);
  if (conditions == null) return null;
  if (isBlock(conditions)) return conditions as ConditionGroup;
  if (conditions is ConditionGroup &&
      conditions.mode == ConditionGroupMode.all) {
    return conditions.children.firstWhereOrNull(isBlock) as ConditionGroup?;
  }
  return null;
}

String? _exceptionApp(Condition condition) => switch (condition) {
  VariableCondition(
    :final variable,
    operator: ConditionOperator.equals,
    :final value,
    negate: false,
  )
      when variable.name == exceptionVariable =>
    value.textOrEmpty,
  _ => null,
};

Condition _appCondition(String app) => Condition.variable(
  variable: parseConditionVariableRef(exceptionVariable),
  operator: ConditionOperator.equals,
  value: ConditionValue.text(app),
);

Condition _replaceChild(
  Condition root,
  ConditionGroup old,
  ConditionGroup replacement,
) {
  if (identical(root, old)) return replacement;
  final group = root as ConditionGroup;
  return group.copyWith(
    children: [
      for (final child in group.children)
        if (identical(child, old)) replacement else child,
    ],
  );
}
