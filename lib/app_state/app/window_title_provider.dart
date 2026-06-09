import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/store/config_controller.dart';

const appWindowBaseTitle = 'Input Actions Editor';

String appWindowTitle({required bool isDirty}) =>
    isDirty ? '*$appWindowBaseTitle' : appWindowBaseTitle;

final windowTitleProvider = Provider<String>((ref) {
  final isDirty = ref.watch(
    configControllerProvider.select((s) => s.value?.isDirty ?? false),
  );
  return appWindowTitle(isDirty: isDirty);
});
