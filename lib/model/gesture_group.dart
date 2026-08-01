import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';

part 'gesture_group.freezed.dart';

@freezed
abstract class GestureGroup with _$GestureGroup {
  const factory GestureGroup({
    required String id,
    required String name,
    required DeviceType device,
    @Default(true) bool enabled,

    /// Parent group id for nested groups; null at the top level. The group
    /// [id] is in-memory only — groups serialize as YAML nesting, which
    /// carries no id (the daemon would merge one into every member).
    String? parentId,


    /// Conditions the daemon applies to every gesture in this group.
    Condition? conditions,

    /// Unmodelled properties of a native group node, preserved for round-trip.
    @Default(<String, dynamic>{}) Map<String, dynamic> extra,
  }) = _GestureGroup;
}
