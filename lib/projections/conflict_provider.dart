import 'dart:async';

import 'package:flutter/foundation.dart';
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


class ConflictReportNotifier extends Notifier<ConflictReport> {
  @visibleForTesting
  Duration debounce = const Duration(milliseconds: 300);

  Timer? _timer;

  @override
  ConflictReport build() {
    // Drive recomputation ourselves rather than rebuilding the provider, so we
    // control the cadence instead of tracking the config one-for-one.
    ref
      ..onDispose(() => _timer?.cancel())
      ..listen(configControllerProvider, (_, _) => _schedule());
    return _compute();
  }

  ConflictReport _compute() {
    final config = ref.read(configControllerProvider).value;
    return config == null
        ? ConflictReport.empty
        : ConflictReport(detectConflicts(config));
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, () {
      _timer = null;
      state = _compute();
    });
  }
}


final conflictReportProvider =
    NotifierProvider<ConflictReportNotifier, ConflictReport>(
      ConflictReportNotifier.new,
    );
