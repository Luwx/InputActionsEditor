import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/trigger_common.dart';

extension ActionSourceActions on ActionSource {
  /// The root level of the list, or null when its holder is gone.
  List<TriggerAction>? read(Config? config) =>
      config != null && lens.canGet(config) ? lens.get(config) : null;

  /// Rewrites the list. [transform] sees it as the actions of a
  /// [TriggerCommon], so the generated tree operations apply unchanged.
  Config update(
    Config config,
    TriggerCommon Function(TriggerCommon common) transform,
  ) {
    final actions = read(config);
    if (actions == null) return config;
    return lens.set(config, transform(TriggerCommon(actions: actions)).actions);
  }
}
