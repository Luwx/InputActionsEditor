import 'dart:async';
import 'dart:io';

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
      // Don't call windowManager.destroy(): on Linux/GTK3 it re-enters
      // gtk_window_close() while the Flutter GL surface is still live, which
      // intermittently segfaults inside GTK. Saving/discarding has already
      // completed in onCloseRequested, so exit the process directly.
      exit(0);
    }
  }
}
