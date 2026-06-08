import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/stroke/strokes_field.dart';

class StrokeSection extends ConsumerWidget {
  const StrokeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = ref.gestureField(
      context,
      mouseGestureStrokeStrokesLens,
      fallbackValue: () => const <String>[],
    );
    return StrokesField(
      strokes: field.value,
      onStrokesChanged: field.onChanged,
      deviceType: DeviceType.mouse,
    );
  }
}
