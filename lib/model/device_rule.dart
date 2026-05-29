import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/condition.dart';

part 'device_rule.freezed.dart';

@freezed
abstract class DeviceRuleProperties with _$DeviceRuleProperties {
  const factory DeviceRuleProperties({
    bool? grab,
    bool? ignore,
    int? motionTimeout,
    double? motionThreshold,
    int? pressTimeout,
    double? swipeAngleTolerance,
    bool? unblockButtonsOnTimeout,
    bool? buttonpad,
    int? clickTimeout,
    bool? handleEvdevEvents,
    double? motionThreshold2,
    double? motionThreshold3,
    int? pressureRangesFinger,
    int? pressureRangesThumb,
    int? pressureRangesPalm,
  }) = _DeviceRuleProperties;

  const DeviceRuleProperties._();

  bool get isEmpty =>
      grab == null &&
      ignore == null &&
      motionTimeout == null &&
      motionThreshold == null &&
      pressTimeout == null &&
      swipeAngleTolerance == null &&
      unblockButtonsOnTimeout == null &&
      buttonpad == null &&
      clickTimeout == null &&
      handleEvdevEvents == null &&
      motionThreshold2 == null &&
      motionThreshold3 == null &&
      pressureRangesFinger == null &&
      pressureRangesThumb == null &&
      pressureRangesPalm == null;
}

@freezed
abstract class DeviceRule with _$DeviceRule {
  const factory DeviceRule({
    Condition? conditions,
    @Default(DeviceRuleProperties()) DeviceRuleProperties properties,
  }) = _DeviceRule;
}
