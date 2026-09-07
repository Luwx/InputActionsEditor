import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/rotation_direction_select.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class CircleSection extends ConsumerWidget {
  const CircleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lensFor = switch (context.gestureLocation.device) {
      DeviceType.touchpad => touchpadCircleDirectionLens,
      DeviceType.touchscreen => touchscreenCircleDirectionLens,
      _ => circleDirectionLens,
    };
    final directionField = ref.gestureField(
      context,
      lensFor,
      fallbackValue: () => RotationDirection.any,
    );
    return RevealedField(
      field: switch (context.gestureLocation.device) {
        DeviceType.touchpad => ConfigDirtyField.touchpadCircleDirection,
        DeviceType.touchscreen => ConfigDirtyField.touchscreenCircleDirection,
        _ => ConfigDirtyField.circleDirection,
      },
      child: RotationDirectionSelect(
        direction: directionField.value,
        onDirectionChanged: directionField.onChanged,
        label: l10n.sectionCircleDirectionLabel,
        tooltip: l10n.sectionCircleDirectionTooltip,
      ),
    );
  }
}
