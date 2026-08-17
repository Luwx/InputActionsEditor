import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import 'helpers/fake_config_repository.dart';

void main() {
  const source = '''
autoreload: false
mouse:
  gestures:
    - type: press
      name: first
      threshold: 1
''';

  late FakeConfigRepository repository;
  late ProviderContainer container;

  setUp(() async {
    repository = FakeConfigRepository(source);
    container = await configTestContainer(repository);
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);
  });

  ConfigController controller() =>
      container.read(configControllerProvider.notifier);

  EditSession session() => container.read(configControllerProvider).value!;

  GestureLocation gestureLocation() =>
      gestureLocationAt(session().draft, DeviceType.mouse, 0)!;

  SetLens<String?> editGesture(String threshold) => SetLens<String?>(
    gestureThresholdLens(gestureLocation()),
    threshold,
  );

  SetLens<List<String>?> editSettings(List<String> keys) =>
      SetLens<List<String>?>(globalSettingsEmergencyCombinationLens(), keys);

  test('committing settings leaves gesture edits unsaved', () async {
    controller()
      ..add(editGesture('42'), scope: const GesturesScope())
      ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope());

    await controller().saveSettings();

    final onDisk = decodeConfig(repository.text);
    expect(onDisk.globalSettings.emergencyCombination, ['ctrl', 'alt']);
    expect(onDisk.mouseGestures[0].common.threshold, '1');

    expect(session().draft.mouseGestures[0].common.threshold, '42');
    expect(session().gesturesDirty.isDirty, isTrue);
    expect(session().settingsDirty.isDirty, isFalse);
  });

  test('discarding settings leaves gesture edits alone', () async {
    controller()
      ..add(editGesture('42'), scope: const GesturesScope())
      ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope())
      ..discardSettings();

    expect(session().draft.globalSettings.emergencyCombination, isNull);
    expect(session().draft.mouseGestures[0].common.threshold, '42');
  });

  test('undo in the settings scope never reaches a gesture edit', () async {
    controller()
      ..add(editSettings(['ctrl', 'alt']), scope: const SettingsScope())
      ..add(editGesture('42'), scope: const GesturesScope())
      ..undo(scope: const SettingsScope());

    expect(session().draft.mouseGestures[0].common.threshold, '42');
    expect(session().draft.globalSettings.emergencyCombination, isNull);
    expect(controller().canUndo(scope: const SettingsScope()), isFalse);
  });
}
