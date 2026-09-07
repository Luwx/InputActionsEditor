import 'package:flutter/widgets.dart';

/// Holds the grabbing cursor over the whole app while a drag runs.
///
/// Claimed from an overlay entry, which is hit tested ahead of the page: the
/// dragged feedback trails the pointer by a frame, and a row's own cursor
/// outranks any region wrapping the list.
class DragCursorOverlay {
  OverlayEntry? _entry;

  void show(BuildContext context) {
    if (_entry != null) return;
    final entry = OverlayEntry(builder: (_) => const _GrabbingLayer());
    Overlay.of(context, rootOverlay: true).insert(entry);
    _entry = entry;
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _GrabbingLayer extends StatelessWidget {
  const _GrabbingLayer();

  @override
  Widget build(BuildContext context) => const MouseRegion(
    cursor: SystemMouseCursors.grabbing,
    // Annotates the cursor without taking the hit from the drop targets it
    // covers.
    opaque: false,
    hitTestBehavior: HitTestBehavior.translucent,
    child: SizedBox.expand(),
  );
}
