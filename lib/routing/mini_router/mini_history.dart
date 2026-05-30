import 'package:flutter/foundation.dart';

/// A flat, app-owned browser-style navigation history of typed destinations.
///
/// MiniRouter reads from this and never mutates the stack itself beyond
/// [back] (for system back / pop). The shape — a list plus a cursor — is the
/// whole model: the visible destination is [current], and entries ahead of the
/// cursor are the forward stack.
///
/// Implementations are [Listenable]; MiniRouter rebuilds when they notify.
abstract interface class MiniHistory<D> implements Listenable {
  /// The destination currently shown.
  D get current;

  /// Index of [current] within the underlying history list. Used only to tell
  /// whether a change moved backward (a pop) — handed to the app via
  /// `MiniTransition.isBack` so it can choose temporal vs. spatial motion.
  int get cursor;

  bool get canBack;
  bool get canForward;

  void back();
  void forward();
}
