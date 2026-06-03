import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/device_rule.dart';
import 'package:input_actions_editor/state/edit/config_edit.dart';
import 'package:input_actions_editor/state/edit/lenses/config_schema.dart'
    as gen;

/// Device rules are a single-typed list, so unlike gestures they have no
/// per-device fan-out: these edits delegate straight to the generated
/// `config_schema` helpers.

final class AddDeviceRule extends ConfigEdit {
  AddDeviceRule(this.rule);

  final DeviceRule rule;

  @override
  String get label => 'add device rule';

  @override
  Config apply(Config config) => gen.addDeviceRule(config, rule);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'remove device rule');
}

final class UpdateDeviceRule extends ConfigEdit {
  UpdateDeviceRule(this.index, this.transform);

  final int index;
  final DeviceRule Function(DeviceRule rule) transform;

  @override
  String get label => 'update device rule';

  @override
  Config apply(Config config) =>
      gen.updateDeviceRuleAt(config, index, transform);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'update device rule');
}

final class RemoveDeviceRule extends ConfigEdit {
  RemoveDeviceRule(this.index);

  final int index;

  @override
  String get label => 'remove device rule';

  @override
  Config apply(Config config) => gen.removeDeviceRuleAt(config, index);

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'add device rule');
}

final class ReorderDeviceRule extends ConfigEdit {
  ReorderDeviceRule(this.oldIndex, this.newIndex);

  final int oldIndex;
  final int newIndex;

  @override
  String get label => 'reorder device rules';

  @override
  Config apply(Config config) {
    final list = [...config.deviceRules];
    if (oldIndex < 0 || oldIndex >= list.length) return config;
    final item = list.removeAt(oldIndex);
    final insertAt = newIndex > oldIndex ? newIndex - 1 : newIndex;
    list.insert(insertAt.clamp(0, list.length), item);
    return config.copyWith(deviceRules: list);
  }

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'reorder device rules');
}

final class ReplaceDeviceRules extends ConfigEdit {
  ReplaceDeviceRules(this.rules);

  final List<DeviceRule> rules;

  @override
  String get label => 'replace device rules';

  @override
  Config apply(Config config) =>
      config.copyWith(deviceRules: List<DeviceRule>.of(rules));

  @override
  ConfigEdit inverse(Config config) =>
      RestoreConfig(config, label: 'replace device rules');
}
