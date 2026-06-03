import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/conflict/conflict_detector.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/store/config_controller.dart';

/// All detected conflicts plus fast per-gesture lookups.
class ConflictReport {
  ConflictReport(this.all) : _byGesture = _index(all), hasAny = all.isNotEmpty;

  const ConflictReport._empty()
    : all = const [],
      _byGesture = const {},
      hasAny = false;

  static const empty = ConflictReport._empty();

  final List<GestureConflict> all;
  final bool hasAny;
  final Map<GestureRef, List<GestureConflict>> _byGesture;

  List<GestureConflict> forGesture(DeviceType device, int index) =>
      _byGesture[(device: device, index: index)] ?? const [];

  bool hasConflict(DeviceType device, int index) =>
      _byGesture.containsKey((device: device, index: index));

  static Map<GestureRef, List<GestureConflict>> _index(
    List<GestureConflict> conflicts,
  ) {
    final map = <GestureRef, List<GestureConflict>>{};
    for (final c in conflicts) {
      map.putIfAbsent(c.a, () => []).add(c);
      map.putIfAbsent(c.b, () => []).add(c);
    }
    return map;
  }
}

/// Recomputed whenever the config changes. While the config is loading or
/// errored, reports no conflicts.
final conflictReportProvider = Provider<ConflictReport>((ref) {
  final config = ref.watch(configControllerProvider).value;
  if (config == null) return ConflictReport.empty;
  return ConflictReport(detectConflicts(config));
});
