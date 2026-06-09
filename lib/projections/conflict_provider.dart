import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/conflict/conflict_detector.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_conflict.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:meta/meta.dart';

/// All detected conflicts plus fast per-gesture lookups.
class ConflictReport extends Equatable {
  ConflictReport(this.all) : _byGesture = _index(all), hasAny = all.isNotEmpty;

  const ConflictReport._empty()
    : all = const [],
      _byGesture = const {},
      hasAny = false;

  static const empty = ConflictReport._empty();

  final List<GestureConflict> all;
  final bool hasAny;
  final Map<GestureRef, List<GestureConflict>> _byGesture;

  @override
  List<Object?> get props => [all];

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
  Duration interval = const Duration(milliseconds: 300);

  Timer? _timer;
  final _sinceLastRun = Stopwatch();

  @override
  ConflictReport build() {
    // Drive recomputation ourselves rather than rebuilding the provider, so we
    // control the cadence instead of tracking the config one-for-one.
    ref
      ..onDispose(() => _timer?.cancel())
      ..listen(draftConfigProvider, (_, _) => _onConfigChanged());
    return _compute();
  }

  ConflictReport _compute() {
    final config = ref.read(draftConfigProvider);
    return ConflictReport(detectConflicts(config));
  }

  void _onConfigChanged() {
    if (_timer != null) return; // a trailing run is already pending
    final elapsed = _sinceLastRun.isRunning ? _sinceLastRun.elapsed : interval;
    if (elapsed >= interval) {
      _run();
    } else {
      _timer = Timer(interval - elapsed, _run);
    }
  }

  void _run() {
    _timer = null;
    _sinceLastRun
      ..reset()
      ..start();
    state = _compute();
  }
}

final conflictReportProvider =
    NotifierProvider<ConflictReportNotifier, ConflictReport>(
      ConflictReportNotifier.new,
    );
