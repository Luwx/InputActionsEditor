import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/state/edit/lens.dart';

const _globalSettingsLens = Lens<GlobalSettings>(
  get: _getGlobalSettings,
  set: _setGlobalSettings,
  name: 'globalSettings',
);

const _autoreloadPart = LensPart<GlobalSettings, bool?>(
  get: _getAutoreload,
  set: _setAutoreload,
  name: 'autoreload',
);

GlobalSettings _getGlobalSettings(Config config) => config.globalSettings;

Config _setGlobalSettings(Config config, GlobalSettings value) =>
    config.copyWith(globalSettings: value);

bool? _getAutoreload(GlobalSettings settings) => settings.autoreload;

GlobalSettings _setAutoreload(GlobalSettings settings, bool? value) =>
    settings.copyWith(autoreload: value);

void main() {
  group('Lens', () {
    test('set then get returns the set value', () {
      final lens = _globalSettingsLens.then(_autoreloadPart);
      const config = Config();

      final updated = lens.set(config, true);

      expect(lens.get(updated), isTrue);
    });

    test('setting the current value is a no-op by equality', () {
      final lens = _globalSettingsLens.then(_autoreloadPart);
      const config = Config(
        globalSettings: GlobalSettings(autoreload: true),
      );

      expect(lens.set(config, lens.get(config)), config);
    });

    test('composition preserves a stable dotted name', () {
      final lens = _globalSettingsLens.then(_autoreloadPart);

      expect(lens.name, 'globalSettings.autoreload');
    });
  });
}
