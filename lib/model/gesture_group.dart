import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:input_actions_editor/model/enums.dart';

part 'gesture_group.freezed.dart';

@freezed
abstract class GestureGroup with _$GestureGroup {
  const factory GestureGroup({
    required String id,
    required String name,
    required DeviceType device,
    @Default(true) bool enabled,
  }) = _GestureGroup;
}
