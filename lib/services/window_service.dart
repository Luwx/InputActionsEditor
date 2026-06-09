import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

final windowServiceProvider = Provider<WindowService>((_) => WindowService());

class WindowService with WindowListener {
  Future<bool> Function()? onCloseRequested;
  bool _destroying = false;

  Future<void> initialize() async {
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }

  Future<void> setTitle(String title) {
    if (_destroying) return Future.value();
    return windowManager.setTitle(title);
  }

  @override
  Future<void> onWindowClose() async {
    final shouldClose = await onCloseRequested?.call() ?? true;
    if (shouldClose) {
      _destroying = true;
      await windowManager.destroy();
    }
  }
}
