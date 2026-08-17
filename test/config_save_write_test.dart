import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/store/config_controller.dart';

import 'helpers/fake_config_repository.dart';

SetLens<List<String>?> _setEmergency(List<String> keys) =>
    SetLens<List<String>?>(globalSettingsEmergencyCombinationLens(), keys);

void main() {
  late FakeConfigRepository repository;
  late ProviderContainer container;

  setUp(() async {
    repository = FakeConfigRepository(
      File('test/fixtures/test_config.yaml').readAsStringSync(),
    );
    container = await configTestContainer(repository);
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);
  });

  ConfigController controller() =>
      container.read(configControllerProvider.notifier);

  EditSession session() => container.read(configControllerProvider).value!;

  test('a failed write reports itself and keeps the draft dirty', () async {
    repository.failWrite = const FileSystemException('read-only file');
    controller().add(_setEmergency(['ctrl', 'alt', 'delete']));

    expect(await controller().save(), isFalse);
    expect(session().isDirty, isTrue);
    expect(
      container.read(configSaveErrorProvider),
      isA<FileSystemException>(),
    );

    repository.failWrite = null;

    expect(await controller().save(), isTrue);
    expect(session().isDirty, isFalse);
    expect(container.read(configSaveErrorProvider), isNull);
  });

  test('saving writes once and does not read the file back', () async {
    final loadsAfterStartup = repository.loads;

    controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
    expect(session().isDirty, isTrue);

    await controller().save();

    expect(session().isDirty, isFalse);
    expect(repository.loads, loadsAfterStartup);
    expect(
      decodeConfig(repository.text).globalSettings.emergencyCombination,
      ['ctrl', 'alt', 'delete'],
    );
  });

  test('the written text becomes the merge base for the next save', () async {
    controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
    await controller().save();
    final afterFirst = repository.text;

    controller().add(_setEmergency(['meta', 'escape']));
    await controller().save();

    expect(repository.mergeBases.last, afterFirst);
    expect(
      decodeConfig(repository.text).globalSettings.emergencyCombination,
      ['meta', 'escape'],
    );
    // Comments and unmodelled keys still ride along on the second write.
    expect(repository.text, contains('my_custom_extension'));
    expect(
      repository.text,
      contains('# Comprehensive InputActions config fixture'),
    );
  });

  test(
    'the saved baseline matches what a reader of the file would see',
    () async {
      controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
      await controller().save();

      final saved = session().saved!;
      final fromDisk = preserveEditIds(
        from: saved,
        to: decodeConfig(repository.text),
      );
      expect(fromDisk, saved);
    },
  );

  test('undo still reaches edits made before the save', () async {
    controller().add(_setEmergency(['ctrl', 'alt', 'delete']));
    await controller().save();

    controller().undo();

    expect(session().draft.globalSettings.emergencyCombination, [
      'backspace',
      'enter',
      'space',
    ]);
    expect(session().isDirty, isTrue);
  });
}
