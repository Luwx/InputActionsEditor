import 'package:flutter/services.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/action.dart';

/// The clipboard boundary for actions: they travel as the same YAML a gesture's
/// `actions:` block holds, so a snippet can be pasted into a text editor and
/// hand-written text can be pasted back in.
abstract final class ActionClipboard {
  static Future<void> write(List<TriggerAction> actions) =>
      Clipboard.setData(ClipboardData(text: encodeActionsYaml(actions)));

  /// The actions on the clipboard, or an empty list when it holds anything
  /// else. Callers treat empty as "nothing to paste".
  static Future<List<TriggerAction>> read() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return decodeActionsYaml(data?.text ?? '');
  }
}
