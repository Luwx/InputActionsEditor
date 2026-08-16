import 'package:flutter/widgets.dart'
    show TextEditingController, TextEditingValue, TextSelection, ValueChanged;
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates a [TextEditingController] whose text is kept in sync with [text]
/// and whose user-typed changes are forwarded to [onChange].
///
/// The hook owns the [onChange] path: it adds a listener to the controller
/// that calls [onChange] for real user edits and suppresses it during the
/// programmatic sync (e.g. revert-to-saved) so the update cannot
/// round-trip back into the store.
///
/// Set [preserveSelection] to carry the caret across the sync, clamped into
/// the new text, instead of dropping it.
TextEditingController useSyncedTextController(
  String text,
  ValueChanged<TextEditingValue> onChange, {
  bool preserveSelection = false,
}) {
  final controller = useTextEditingController(text: text);
  final syncing = useRef(false);

  // Always hold the latest onChange without re-registering the listener.
  final onChangeRef = useRef(onChange)..value = onChange;

  useEffect(() {
    void listener() {
      if (!syncing.value) onChangeRef.value(controller.value);
    }

    controller.addListener(listener);
    return () => controller.removeListener(listener);
  }, [controller]);

  useEffect(() {
    if (controller.text != text) {
      syncing.value = true;
      if (preserveSelection) {
        controller.value = TextEditingValue(
          text: text,
          selection: _clampSelection(controller.selection, text.length),
        );
      } else {
        controller.text = text;
      }
      syncing.value = false;
    }
    return null;
  }, [text]);

  return controller;
}

TextSelection _clampSelection(TextSelection selection, int textLength) {
  if (!selection.isValid) {
    return TextSelection.collapsed(offset: textLength);
  }
  return TextSelection(
    baseOffset: selection.baseOffset.clamp(0, textLength),
    extentOffset: selection.extentOffset.clamp(0, textLength),
    affinity: selection.affinity,
    isDirectional: selection.isDirectional,
  );
}
