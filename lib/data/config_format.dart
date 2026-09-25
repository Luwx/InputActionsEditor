import 'package:input_actions_editor/data/yaml/yaml_helpers.dart';
import 'package:input_actions_editor/model/action.dart';

/// The YAML key holding an [ActionGroup]'s nested actions.
const actionGroupYamlKey = 'one';

/// Top-level key of a copied action snippet, so pasted text is recognisably
/// ours and a stray YAML document is rejected.
const actionsClipboardKey = 'actions';

/// Block keys whose list items carry an `enabled:` flag and are disabled by
/// commenting them out.
bool isDisableableItemList(String key) =>
    key == 'gestures' || key == 'actions' || key == actionGroupYamlKey;

const deviceSectionKeys = {
  'mouse',
  'keyboard',
  'pointer',
  'touchpad',
  'touchscreen',
};

const editorExtraKey = '_extra';

String? itemEnabledLine(List<String> block, int itemIndent) {
  final keyIndent = itemIndent + 2;
  var inExtra = false;
  for (final line in block) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    final indent = indentOf(line);
    if (isListItemAt(line, itemIndent) || indent == keyIndent) {
      inExtra = _opensExtra(line, keyIndent);
    } else if (inExtra && indent == keyIndent + 2 && keyAt(line, 'enabled')) {
      return line;
    }
  }
  return null;
}

List<String> withEnabledFalse(List<String> block, int itemIndent) {
  final keyIndent = itemIndent + 2;
  final flag = '${' ' * (keyIndent + 2)}enabled: false';
  final extraAt = block.indexWhere((line) => _opensExtra(line, keyIndent));
  if (extraAt == -1) {
    return [...block, '${' ' * keyIndent}$editorExtraKey:', flag];
  }
  return [...block]..insert(extraAt + 1, flag);
}

bool _opensExtra(String line, int keyIndent) {
  final context = blockContext(line);
  return context?.key == editorExtraKey && context!.indent == keyIndent;
}

String materializeDisabledYamlComments(String yamlText) => uncommentListItems(
  yamlText,
  isItemList: isDisableableItemList,
  onItem: (item, itemIndent) => itemEnabledLine(item, itemIndent) == null
      ? withEnabledFalse(item, itemIndent)
      : item,
);

/// Disabled items are commented out so the daemon skips them.
String commentDisabledYamlItems(String yamlText) => commentOutListItems(
  yamlText,
  isItemList: isDisableableItemList,
  shouldComment: (item, itemIndent) =>
      itemEnabledLine(item, itemIndent)?.trimRight().endsWith('false') ?? false,
);
