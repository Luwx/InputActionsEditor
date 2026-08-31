import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/store/config_controller.dart';

/// Seeds a session whose draft and saved baseline are the same config.
///
// The future resolves synchronously so the first build already sees AsyncData:
// widgets that read `requireValue` are pumped without the root load gate.
class SeededController extends ConfigController {
  SeededController(Config seed) : _normalized = assignEditIds(seed);

  final Config _normalized;

  @override
  Future<EditSession> build() =>
      SynchronousFuture(EditSession(draft: _normalized, saved: _normalized));
}

/// Seeds a session whose saved baseline differs from the draft. The two share
/// edit ids by position, so an identity location addresses the same gesture in
/// both snapshots, as it does after a load followed by edits.
class DivergingController extends ConfigController {
  DivergingController({required this.current, this.saved});

  final Config current;
  final Config? saved;

  @override
  Future<EditSession> build() {
    final draft = assignEditIds(current);
    return SynchronousFuture(
      EditSession(
        draft: draft,
        saved: saved == null ? null : preserveEditIds(from: draft, to: saved!),
      ),
    );
  }
}

ProviderContainer seededContainer(Config seed) {
  final container = ProviderContainer(
    overrides: [
      configControllerProvider.overrideWith(() => SeededController(seed)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

ConfigController notifierOf(ProviderContainer c) =>
    c.read(configControllerProvider.notifier);

EditSession sessionOf(ProviderContainer c) =>
    c.read(configControllerProvider).value!;

Config configOf(ProviderContainer c) => sessionOf(c).draft;
