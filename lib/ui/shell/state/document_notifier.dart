import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:meta/meta.dart';

final documentProvider = NotifierProvider<DocumentNotifier, DocumentVm>(
  DocumentNotifier.new,
);

@immutable
class DocumentVm {
  const DocumentVm({
    required this.config,
    required this.canDiscard,
  });

  final Config? config;
  final bool canDiscard;

  @override
  bool operator ==(Object other) =>
      other is DocumentVm &&
      other.config == config &&
      other.canDiscard == canDiscard;

  @override
  int get hashCode => Object.hash(config, canDiscard);
}

class DocumentNotifier extends Notifier<DocumentVm> {
  @override
  DocumentVm build() {
    final config = ref.watch(
      configControllerProvider.select((state) => state.value),
    );
    final controller = ref.read(configControllerProvider.notifier);
    return DocumentVm(
      config: config,
      canDiscard: controller.isDirty && controller.savedConfig != null,
    );
  }

  Future<void> loadFromPicker() {
    return ref.read(configControllerProvider.notifier).loadFromPicker();
  }

  Future<void> save() {
    return ref.read(configControllerProvider.notifier).save();
  }

  void discardChanges() {
    ref.read(configControllerProvider.notifier).discardChanges();
  }
}
