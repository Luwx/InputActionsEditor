import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart'
    show VarType;

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

extension VarTypeLabels on VarType {
  String badge(AppLocalizations l10n) => switch (this) {
    VarType.string => l10n.varTypeBadgeString,
    VarType.number => l10n.varTypeBadgeNumber,
    VarType.bool_ => l10n.varTypeBadgeBool,
    VarType.flags => l10n.varTypeBadgeFlags,
    VarType.point => l10n.varTypeBadgePoint,
    VarType.enum_ => l10n.varTypeBadgeEnum,
    VarType.time => l10n.varTypeBadgeTime,
  };

  String typeName(AppLocalizations l10n) => switch (this) {
    VarType.string => l10n.varTypeNameString,
    VarType.number => l10n.varTypeNameNumber,
    VarType.bool_ => l10n.varTypeNameBool,
    VarType.flags => l10n.varTypeNameFlags,
    VarType.point => l10n.varTypeNamePoint,
    VarType.enum_ => l10n.varTypeNameEnum,
    VarType.time => l10n.varTypeNameTime,
  };
}
