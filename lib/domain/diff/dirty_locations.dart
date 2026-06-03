import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';

part 'dirty_locations.freezed.dart';

enum GestureSectionDirtyField { mouseButtons, triggerConditions, actions }

@freezed
abstract class GestureSectionLocation with _$GestureSectionLocation {
  const factory GestureSectionLocation({
    required GestureLocation gesture,
    required GestureSectionDirtyField field,
  }) = _GestureSectionLocation;
}
