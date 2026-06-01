import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/state/config_controller.dart';

const appWindowBaseTitle = 'Input Actions Editor';

String appWindowTitle({required bool isDirty}) =>
    isDirty ? '*$appWindowBaseTitle' : appWindowBaseTitle;

final windowTitleProvider = Provider<String>((ref) {
  ref.watch(configControllerProvider);
  final isDirty = ref.read(configControllerProvider.notifier).isDirty;
  return appWindowTitle(isDirty: isDirty);
});
