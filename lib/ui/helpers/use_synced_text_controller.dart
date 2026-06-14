import 'package:flutter/widgets.dart'
    show TextEditingController, TextEditingValue, ValueChanged;
import 'package:flutter_hooks/flutter_hooks.dart';

/// Creates a [TextEditingController] whose text is kept in sync with [text]
/// and whose user-typed changes are forwarded to [onChange].
///
/// The hook owns the [onChange] path: it adds a listener to the controller
/// that calls [onChange] for real user edits and suppresses it during the
/// programmatic sync (e.g. revert-to-saved) so the update cannot
/// round-trip back into the store.
TextEditingController useSyncedTextController(
  String text,
  ValueChanged<TextEditingValue> onChange,
) {
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
      controller.text = text;
      syncing.value = false;
    }
    return null;
  }, [text]);

  return controller;
}
