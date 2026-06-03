import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:meta_generator/meta_generator.dart';

part 'trigger_common.freezed.dart';
part 'trigger_common.g.dart';

@freezed
@withMeta
abstract class TriggerCommon with _$TriggerCommon {
  const factory TriggerCommon({
    String? name,

    /// KWin does not yet read this field; setting it to false is UI-only until
    /// native support is added to the effect.
    bool? enabled,
    String? id,

    /// UI-only: references a [GestureGroup] by id for organizational grouping.
    String? groupId,
    @Default([]) List<MouseButtonValue> mouseButtons,
    @Default(false) bool mouseButtonsExactOrder,
    Condition? conditions,
    Condition? endConditions,
    bool? blockEvents,
    bool? clearModifiers,
    int? resumeTimeout,
    bool? setLastTrigger,

    /// Either a single number or "min-max" string.
    String? threshold,
    bool? accelerated,
    @Default([]) List<TriggerAction> actions,

    /// In-memory only, never serialized. A stable identity assigned by
    /// [ConfigController] so per-gesture undo history survives reorders/index
    /// shifts. Excluded from dirty-diff comparisons via
    /// [comparableTriggerCommon].
    int? editId,
  }) = _TriggerCommon;
}

@freezed
@withMeta
abstract class MotionCommon with _$MotionCommon {
  const factory MotionCommon({TriggerSpeed? speed, bool? lockPointer}) =
      _MotionCommon;
}
