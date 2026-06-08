import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/between_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/bool_toggle.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/flags_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/one_of_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/point_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/text_value_input.dart';

// Maps a window variable name to the WindowProperties field it should detect.
// Returns null for variables that don't map to a window property.
String Function(WindowProperties)? _windowExtractor(String? varName) {
  if (varName == null) return null;
  if (varName.endsWith('_title')) return (p) => p.title;
  if (varName.endsWith('_class')) return (p) => p.resourceClass;
  if (varName.endsWith('_name')) return (p) => p.resourceName;
  return null;
}

class ValueInput extends ConsumerWidget {
  const ValueInput({
    required this.condition,
    required this.info,
    required this.onChanged,
    super.key,
  });

  final VariableCondition condition;
  final VariableInfo? info;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched at the top so the subscription is always registered regardless
    // of which branch is taken below.
    final kwinSupported = ref.watch(kwinSupportedProvider).value ?? false;

    final type = info?.type;
    final operator = condition.operator;

    if (operator == 'between') {
      if (type == VarType.point) {
        return PointBetweenInput(
          value: condition.value,
          onChanged: onChanged,
        );
      }
      return BetweenInput(
        value: condition.value,
        onChanged: onChanged,
        hint: type == VarType.time ? 'ms' : 'n',
      );
    }

    if (operator == 'one_of') {
      return OneOfInput(
        value: condition.value,
        onChanged: onChanged,
        enumValues: type == VarType.enum_ ? info?.enumValues : null,
      );
    }

    if (type == VarType.bool_) {
      return BoolToggle(
        value: condition.value == 'true',
        onChanged: (value) => onChanged(value ? 'true' : 'false'),
      );
    }

    if (type == VarType.flags && info?.flagValues != null) {
      if (operator == 'contains' || operator == '==' || operator == '!=') {
        return FlagsInput(
          flagValues: info!.flagValues!,
          value: condition.value,
          onChanged: onChanged,
        );
      }
    }

    if (type == VarType.enum_ && info?.enumValues != null) {
      final enumValues = info!.enumValues!;
      final current = enumValues.contains(condition.value)
          ? condition.value
          : enumValues.first;
      return FSelect<String>(
        key: ValueKey(condition.variable),
        canRequestFocus: false,
        items: {for (final value in enumValues) value: value},
        control: FSelectControl<String>.lifted(
          value: current,
          onChange: (value) {
            if (value != null) onChanged(value);
          },
        ),
        contentConstraints: const FPortalConstraints(
          maxWidth: 260,
          maxHeight: 280,
        ),
      );
    }

    if (type == VarType.point) {
      return PointInput(
        value: condition.value,
        onChanged: onChanged,
      );
    }

    final extractor = kwinSupported ? _windowExtractor(info?.name) : null;
    Future<void> Function()? onDetect;
    if (extractor != null) {
      final e = extractor;
      onDetect = () async {
        final props = await ref
            .read(kwinWindowServiceProvider)
            .queryWindowInfo();
        if (props != null) onChanged(e(props));
      };
    }

    return TextValueInput(
      value: condition.value,
      onChanged: onChanged,
      hint: type == VarType.time ? 'ms' : 'value',
      onDetect: onDetect,
    );
  }
}
