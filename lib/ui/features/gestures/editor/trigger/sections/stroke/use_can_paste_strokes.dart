import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/ui/common/dismissible_context_menu.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/state/stroke_clipboard.dart';

bool useCanPasteStrokes(FPopoverController menu) {
  final canPaste = useState(false);
  final shown = menu.isShown;
  useEffect(() {
    if (!shown) return null;
    var live = true;
    unawaited(
      StrokeClipboard.read().then((strokes) {
        if (live) canPaste.value = strokes.isNotEmpty;
      }),
    );
    return () => live = false;
  }, [shown]);
  return canPaste.value;
}
