// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action.dart';

// **************************************************************************
// MetaGenerator
// **************************************************************************

abstract final class TriggerActionMeta {
  static const String self = 'TriggerAction';

  static const String action = 'action';
  static const String enabled = 'enabled';
  static const String on = 'on';
  static const String conditions = 'conditions';
  static const String interval = 'interval';
  static const String threshold = 'threshold';
  static const String conflicting = 'conflicting';
  static const String id = 'id';
  static const String limit = 'limit';
  static const String editId = 'editId';

  static const List<String> props = [
    action,
    enabled,
    on,
    conditions,
    interval,
    threshold,
    conflicting,
    id,
    limit,
    editId,
  ];
}

abstract final class CommandActionMeta {
  static const String self = 'CommandAction';

  static const String command = 'command';
  static const String wait = 'wait';

  static const List<String> props = [command, wait];
}

abstract final class InputActionMeta {
  static const String self = 'InputAction';

  static const String entries = 'entries';
  static const String delay = 'delay';

  static const List<String> props = [entries, delay];
}

abstract final class PlasmaShortcutActionMeta {
  static const String self = 'PlasmaShortcutAction';

  static const String component = 'component';
  static const String shortcut = 'shortcut';

  static const List<String> props = [component, shortcut];
}

abstract final class ActivateWindowActionMeta {
  static const String self = 'ActivateWindowAction';

  static const String windowId = 'windowId';

  static const List<String> props = [windowId];
}

abstract final class ReplaceTextActionMeta {
  static const String self = 'ReplaceTextAction';

  static const String rules = 'rules';

  static const List<String> props = [rules];
}

abstract final class SleepActionMeta {
  static const String self = 'SleepAction';

  static const String milliseconds = 'milliseconds';

  static const List<String> props = [milliseconds];
}

abstract final class FunctionActionMeta {
  static const String self = 'FunctionAction';

  static const String expression = 'expression';

  static const List<String> props = [expression];
}

abstract final class ActionGroupMeta {
  static const String self = 'ActionGroup';

  static const String actions = 'actions';

  static const List<String> props = [actions];
}

abstract final class ContextMenuActionMeta {
  static const String self = 'ContextMenuAction';

  static const String items = 'items';

  static const List<String> props = [items];
}

abstract final class RawActionMeta {
  static const String self = 'RawAction';

  static const String raw = 'raw';

  static const List<String> props = [raw];
}

abstract final class ActionMenuItemMeta {
  static const String self = 'ActionMenuItem';

  static const String text = 'text';
  static const String icon = 'icon';
  static const String actions = 'actions';
  static const String editId = 'editId';

  static const List<String> props = [text, icon, actions, editId];
}

abstract final class SubMenuItemMeta {
  static const String self = 'SubMenuItem';

  static const String text = 'text';
  static const String icon = 'icon';
  static const String items = 'items';
  static const String editId = 'editId';

  static const List<String> props = [text, icon, items, editId];
}

abstract final class SectionMenuItemMeta {
  static const String self = 'SectionMenuItem';

  static const String text = 'text';
  static const String editId = 'editId';

  static const List<String> props = [text, editId];
}

abstract final class SeparatorMenuItemMeta {
  static const String self = 'SeparatorMenuItem';

  static const String editId = 'editId';

  static const List<String> props = [editId];
}

abstract final class TextSubstitutionRuleMeta {
  static const String self = 'TextSubstitutionRule';

  static const String regex = 'regex';
  static const String replace = 'replace';

  static const List<String> props = [regex, replace];
}

abstract final class LiteralTextMeta {
  static const String self = 'LiteralText';

  static const String text = 'text';

  static const List<String> props = [text];
}

abstract final class CommandTextMeta {
  static const String self = 'CommandText';

  static const String command = 'command';

  static const List<String> props = [command];
}

abstract final class InputEntryMeta {
  static const String self = 'InputEntry';

  static const String device = 'device';
  static const String tokens = 'tokens';

  static const List<String> props = [device, tokens];
}

abstract final class PressInputTokenMeta {
  static const String self = 'PressInputToken';

  static const String key = 'key';

  static const List<String> props = [key];
}

abstract final class ReleaseInputTokenMeta {
  static const String self = 'ReleaseInputToken';

  static const String key = 'key';

  static const List<String> props = [key];
}

abstract final class ComboInputTokenMeta {
  static const String self = 'ComboInputToken';

  static const String keys = 'keys';

  static const List<String> props = [keys];
}

abstract final class TextInputTokenMeta {
  static const String self = 'TextInputToken';

  static const String value = 'value';

  static const List<String> props = [value];
}

abstract final class MoveByInputTokenMeta {
  static const String self = 'MoveByInputToken';

  static const String x = 'x';
  static const String y = 'y';

  static const List<String> props = [x, y];
}

abstract final class MoveByDeltaInputTokenMeta {
  static const String self = 'MoveByDeltaInputToken';

  static const String multiplier = 'multiplier';

  static const List<String> props = [multiplier];
}

abstract final class MoveToInputTokenMeta {
  static const String self = 'MoveToInputToken';

  static const String x = 'x';
  static const String y = 'y';

  static const List<String> props = [x, y];
}

abstract final class WheelInputTokenMeta {
  static const String self = 'WheelInputToken';

  static const String x = 'x';
  static const String y = 'y';

  static const List<String> props = [x, y];
}

abstract final class RawInputTokenMeta {
  static const String self = 'RawInputToken';

  static const String token = 'token';

  static const List<String> props = [token];
}
