import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';

part 'dirty_locations.freezed.dart';

@freezed
abstract class GestureLocation with _$GestureLocation {
  const factory GestureLocation({
    required DeviceType device,
    required int index,
  }) = _GestureLocation;
}

enum GestureSectionDirtyField { mouseButtons, triggerConditions, actions }

@freezed
abstract class GestureSectionLocation with _$GestureSectionLocation {
  const factory GestureSectionLocation({
    required GestureLocation gesture,
    required GestureSectionDirtyField field,
  }) = _GestureSectionLocation;
}

@freezed
abstract class ActionLocation with _$ActionLocation {
  const factory ActionLocation({
    required GestureLocation gesture,
    required int actionIndex,
  }) = _ActionLocation;
}
