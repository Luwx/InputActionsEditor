import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';

class StrokeSection extends ConsumerWidget {
  const StrokeSection({
    required this.gesture,
    required this.onUpdate,
    super.key,
  });

  final StrokeGesture gesture;
  final void Function(MouseGesture Function(MouseGesture)) onUpdate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StrokesField(
      strokes: gesture.strokes,
      onStrokesChanged: (strokes) =>
          onUpdate((g) => (g as StrokeGesture).copyWith(strokes: strokes)),
    );
  }
}
