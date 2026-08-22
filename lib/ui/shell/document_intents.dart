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
