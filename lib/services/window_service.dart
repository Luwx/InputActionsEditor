import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

final windowServiceProvider = Provider<WindowService>((_) => WindowService());

class WindowService with WindowListener {
  Future<bool> Function()? onCloseRequested;

  Future<void> initialize() async {
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }

  Future<void> setTitle(String title) => windowManager.setTitle(title);

  @override
  Future<void> onWindowClose() async {
    final shouldClose = await onCloseRequested?.call() ?? true;
    if (shouldClose) await windowManager.destroy();
  }
}
