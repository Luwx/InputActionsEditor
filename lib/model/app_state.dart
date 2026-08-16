import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';

part 'app_state.freezed.dart';

/// Restart-stable snapshot of the open gesture. Selections are identity-keyed
/// in memory (GestureLocation carries an editId), but editIds are
/// process-local, so the persisted form stays positional and is resolved back
/// into an identity location against the draft on the first config load.
typedef StoredGestureSelection = ({DeviceType device, int index});

const kDefaultGestureListWidth = 300.0;

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    DeviceType? gestureFilter,
    StoredGestureSelection? selectedGesture,
    @Default(kDefaultGestureListWidth) double gestureListWidth,
  }) = _AppState;

  const AppState._();

  factory AppState.fromJson(Map<String, dynamic> json) {
    final filterName = json['gesture_filter'] as String?;
    final filter = filterName != null
        ? DeviceType.values.where((v) => v.name == filterName).firstOrNull
        : null;

    final deviceName = json['gesture_device'] as String?;
    final device = deviceName != null
        ? DeviceType.values.where((v) => v.name == deviceName).firstOrNull
        : null;
    final index = json['gesture_index'] as int?;
    final selectedGesture = device != null && index != null
        ? (device: device, index: index)
        : null;

    return AppState(
      gestureFilter: filter,
      selectedGesture: selectedGesture,
      gestureListWidth:
          (json['gesture_list_width_px'] as num?)?.toDouble() ??
          kDefaultGestureListWidth,
    );
  }

  Map<String, dynamic> toJson() => {
    if (gestureFilter != null) 'gesture_filter': gestureFilter!.name,
    if (selectedGesture != null) ...{
      'gesture_device': selectedGesture!.device.name,
      'gesture_index': selectedGesture!.index,
    },
    'gesture_list_width_px': gestureListWidth,
  };
}
