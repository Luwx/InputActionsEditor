import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/condition.dart';

String operatorLabel(String op, AppLocalizations l10n) => switch (op) {
  '==' => l10n.operatorIs,
  '!=' => l10n.operatorIsNot,
  '>' => l10n.operatorGreaterThan,
  '>=' => l10n.operatorGreaterOrEqual,
  '<' => l10n.operatorLessThan,
  '<=' => l10n.operatorLessOrEqual,
  'between' => l10n.operatorBetween,
  'contains' => l10n.operatorContains,
  'matches' => l10n.operatorMatches,
  'one_of' => l10n.operatorIsOneOf,
  _ => op,
};

extension ConditionValueTypeLabels on ConditionValueType {
  String badge(AppLocalizations l10n) => switch (this) {
    ConditionValueType.string => l10n.varTypeBadgeString,
    ConditionValueType.number => l10n.varTypeBadgeNumber,
    ConditionValueType.bool_ => l10n.varTypeBadgeBool,
    ConditionValueType.flags => l10n.varTypeBadgeFlags,
    ConditionValueType.point => l10n.varTypeBadgePoint,
    ConditionValueType.enum_ => l10n.varTypeBadgeEnum,
    ConditionValueType.time => l10n.varTypeBadgeTime,
  };

  String typeName(AppLocalizations l10n) => switch (this) {
    ConditionValueType.string => l10n.varTypeNameString,
    ConditionValueType.number => l10n.varTypeNameNumber,
    ConditionValueType.bool_ => l10n.varTypeNameBool,
    ConditionValueType.flags => l10n.varTypeNameFlags,
    ConditionValueType.point => l10n.varTypeNamePoint,
    ConditionValueType.enum_ => l10n.varTypeNameEnum,
    ConditionValueType.time => l10n.varTypeNameTime,
  };
}
