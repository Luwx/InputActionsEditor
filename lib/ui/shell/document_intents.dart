import 'package:flutter/widgets.dart';

class UndoIntent extends Intent {
  const UndoIntent();
}

class RedoIntent extends Intent {
  const RedoIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class NewDocumentIntent extends Intent {
  const NewDocumentIntent();
}

class OpenDocumentIntent extends Intent {
  const OpenDocumentIntent();
}

class LoadFromClipboardIntent extends Intent {
  const LoadFromClipboardIntent();
}

class SaveAsIntent extends Intent {
  const SaveAsIntent();
}

class CopyToClipboardIntent extends Intent {
  const CopyToClipboardIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class CloseWindowIntent extends Intent {
  const CloseWindowIntent();
}

class RenameGestureIntent extends Intent {
  const RenameGestureIntent();
}

class DuplicateGestureIntent extends Intent {
  const DuplicateGestureIntent();
}

class CopyGestureYamlIntent extends Intent {
  const CopyGestureYamlIntent();
}

/// A move between gestures or devices.
abstract class NavigationIntent extends Intent {
  const NavigationIntent({this.yieldsToTextField = false});

  /// Set on the bindings that collide with text editing (Home/End, Alt+arrow):
  /// the action reports itself disabled while a field has focus, which lets
  /// the key fall through to the field's own binding.
  final bool yieldsToTextField;
}

class StepGestureIntent extends NavigationIntent {
  const StepGestureIntent(this.delta, {super.yieldsToTextField});

  final int delta;
}

class JumpGestureIntent extends NavigationIntent {
  const JumpGestureIntent({required this.last, super.yieldsToTextField});

  final bool last;
}

class StepDeviceIntent extends NavigationIntent {
  const StepDeviceIntent(this.delta, {super.yieldsToTextField});

  final int delta;
}

class JumpDeviceIntent extends NavigationIntent {
  const JumpDeviceIntent({required this.last, super.yieldsToTextField});

  final bool last;
}
