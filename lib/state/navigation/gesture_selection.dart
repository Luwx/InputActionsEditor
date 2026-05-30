import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:input_actions_editor/model/enums.dart';

part 'gesture_selection.freezed.dart';

/// Open gesture selection: which device + index is visible in the detail panel.
typedef OpenGesture = ({DeviceType device, int index});

/// Snapshot of filter + open gesture. Used as a view-model where both are
/// needed together (e.g. gesture list section listeners).
@freezed
abstract class GestureSelection with _$GestureSelection {
  const factory GestureSelection({
    DeviceType? filter,
    OpenGesture? open,
  }) = _GestureSelection;
}
