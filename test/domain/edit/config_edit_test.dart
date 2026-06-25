import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/model/speed_settings.dart';

const _globalSettingsLens = Lens<Config, GlobalSettings>(
  get: _getGlobalSettings,
  set: _setGlobalSettings,
  name: 'globalSettings',
);

const _autoreloadPart = LensPart<GlobalSettings, bool?>(
  get: _getAutoreload,
  set: _setAutoreload,
  name: 'autoreload',
);

const _mouseSpeedLens = Lens<Config, SpeedSettings?>(
  get: _getMouseSpeed,
  set: _setMouseSpeed,
  name: 'mouseSpeed',
);

GlobalSettings _getGlobalSettings(Config config) => config.globalSettings;

Config _setGlobalSettings(Config config, GlobalSettings value) =>
    config.copyWith(globalSettings: value);

bool? _getAutoreload(GlobalSettings settings) => settings.autoreload;

GlobalSettings _setAutoreload(GlobalSettings settings, bool? value) =>
    settings.copyWith(autoreload: value);

SpeedSettings? _getMouseSpeed(Config config) => config.mouseSpeed;

Config _setMouseSpeed(Config config, SpeedSettings? value) =>
    config.copyWith(mouseSpeed: value);

void main() {
  group('ConfigEdit', () {
    test('SetLens inverse restores the original config', () {
      final lens = _globalSettingsLens.then(_autoreloadPart);
      const config = Config(
        globalSettings: GlobalSettings(autoreload: false),
      );
      final edit = SetLens<bool?>(lens, true);

      final applied = edit.apply(config);
      final restored = edit.inverse(config).apply(applied);

      expect(applied.globalSettings.autoreload, isTrue);
      expect(restored, config);
    });

    test('BatchEdit inverse restores edits in reverse order', () {
      final autoreloadLens = _globalSettingsLens.then(_autoreloadPart);
      const config = Config(
        globalSettings: GlobalSettings(autoreload: false),
        mouseSpeed: SpeedSettings(events: 2),
      );
      final edit = BatchEdit(
        [
          SetLens<bool?>(autoreloadLens, true),
          SetLens<SpeedSettings?>(
            _mouseSpeedLens,
            const SpeedSettings(events: 8),
          ),
        ],
        label: 'update settings',
      );

      final applied = edit.apply(config);
      final restored = edit.inverse(config).apply(applied);

      expect(applied.globalSettings.autoreload, isTrue);
      expect(applied.mouseSpeed?.events, 8);
      expect(restored, config);
    });
  });
}
