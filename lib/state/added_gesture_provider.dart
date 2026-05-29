import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddedGestureMarker {
  const AddedGestureMarker({required this.id, required this.index});

  final int id;
  final int index;
}

class AddedGestureController extends Notifier<AddedGestureMarker?> {
  int _nextId = 0;
  Timer? _clearTimer;

  @override
  AddedGestureMarker? build() {
    ref.onDispose(() => _clearTimer?.cancel());
    return null;
  }

  AddedGestureMarker markAdded(int index) {
    _clearTimer?.cancel();
    final marker = AddedGestureMarker(id: _nextId++, index: index);
    state = marker;
    _clearTimer = Timer(const Duration(seconds: 2), () {
      if (state?.id == marker.id) {
        state = null;
      }
    });
    return marker;
  }
}

final addedGestureProvider =
    NotifierProvider<AddedGestureController, AddedGestureMarker?>(
      AddedGestureController.new,
    );
