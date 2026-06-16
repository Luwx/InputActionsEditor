import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/between_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/bool_toggle.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/flags_input.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/widgets/number_value_input.dart';
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
  final void Function(ConditionValue) onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched at the top so the subscription is always registered regardless
    // of which branch is taken below.
    final kwinSupported = ref.watch(kwinSupportedProvider).value ?? false;

    final type = info?.type;
    final value = condition.value;
    final variable = condition.variable.name;

    if (condition.operator == ConditionOperator.between) {
      if (type == ConditionValueType.point) {
        return PointBetweenInput(
          value: _pointRangeValue(value),
          onChanged: (from, to) => onChanged(
            ConditionValue.range(
              from: ConditionValue.point(from.$1, from.$2),
              to: ConditionValue.point(to.$1, to.$2),
            ),
          ),
        );
      }
      if (type == ConditionValueType.number ||
          type == ConditionValueType.time) {
        final (:from, :to) = _numberRangeValue(value);
        return NumberBetweenInput(
          from: from,
          to: to,
          onChanged: (from, to) => onChanged(
            ConditionValue.range(
              from: ConditionValue.number(from),
              to: ConditionValue.number(to),
            ),
          ),
          hint: type == ConditionValueType.time ? 'ms' : 'n',
        );
      }
      final (:from, :to) = _rangeTextValue(value);
      return BetweenInput(
        from: from,
        to: to,
        onChanged: (from, to) => onChanged(
          ConditionValue.range(
            from: ConditionValue.text(from),
            to: ConditionValue.text(to),
          ),
        ),
        hint: 'n',
      );
    }

    if (condition.operator == ConditionOperator.oneOf) {
      return OneOfInput(
        value: value.stringList,
        onChanged: (value) => onChanged(ConditionValue.list(value)),
        enumValues: type == ConditionValueType.enum_ ? info?.enumValues : null,
      );
    }

    if (type == ConditionValueType.bool_) {
      return BoolToggle(
        value: value.boolOrFalse,
        onChanged: (value) => onChanged(ConditionValue.boolean(value)),
      );
    }

    if (type == ConditionValueType.flags && info?.flagValues != null) {
      if (condition.operator == ConditionOperator.contains ||
          condition.operator == ConditionOperator.equals ||
          condition.operator == ConditionOperator.notEquals) {
        return FlagsInput(
          flagValues: info!.flagValues!,
          value: value.stringList.toSet(),
          onChanged: (value) => onChanged(ConditionValue.flags(value.toList())),
        );
      }
    }

    if (type == ConditionValueType.enum_ && info?.enumValues != null) {
      final enumValues = info!.enumValues!;
      final enumIcons = info!.enumIcons;
      final textValue = value.textOrEmpty;
      final current = enumValues.contains(textValue)
          ? textValue
          : enumValues.first;
      if (enumIcons != null) {
        return FSelect<String>.rich(
          key: ValueKey(variable),
          canRequestFocus: false,
          format: (v) => v,
          prefixBuilder: (_, style, variants) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(enumIcons[current] ?? FLucideIcons.tag, size: 14),
          ),
          control: FSelectControl<String>.lifted(
            value: current,
            onChange: (value) {
              if (value != null) onChanged(ConditionValue.text(value));
            },
          ),
          contentConstraints: const FPortalConstraints(
            maxWidth: 260,
            maxHeight: 280,
          ),
          children: [
            for (final v in enumValues)
              FSelectItem<String>.item(
                value: v,
                title: Text(v, overflow: TextOverflow.ellipsis),
                prefix: Icon(enumIcons[v] ?? FLucideIcons.tag, size: 14),
              ),
          ],
        );
      }
      return FSelect<String>(
        key: ValueKey(variable),
        canRequestFocus: false,
        items: {for (final value in enumValues) value: value},
        control: FSelectControl<String>.lifted(
          value: current,
          onChange: (value) {
            if (value != null) onChanged(ConditionValue.text(value));
          },
        ),
        contentConstraints: const FPortalConstraints(
          maxWidth: 260,
          maxHeight: 280,
        ),
      );
    }

    if (type == ConditionValueType.point) {
      return PointInput(
        value: value.pointOrNull,
        onChanged: (x, y) => onChanged(ConditionValue.point(x, y)),
      );
    }

    if (type == ConditionValueType.number || type == ConditionValueType.time) {
      return NumberValueInput(
        value: value.numberOrZero,
        onChanged: (value) => onChanged(ConditionValue.number(value)),
        hint: type == ConditionValueType.time ? 'ms' : 'value',
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
        if (props != null) {
          onChanged(ConditionValue.text(e(props)));
        }
      };
    }

    return TextValueInput(
      value: value.textOrEmpty,
      onChanged: (value) => onChanged(ConditionValue.text(value)),
      hint: 'value',
      onDetect: onDetect,
    );
  }
}

({String from, String to}) _rangeTextValue(ConditionValue value) =>
    switch (value) {
      RangeConditionValue(:final from, :final to) => (
        from: from.textOrEmpty,
        to: to.textOrEmpty,
      ),
      _ => (from: '', to: ''),
    };

({double? from, double? to}) _numberRangeValue(ConditionValue value) =>
    switch (value) {
      RangeConditionValue(
        from: NumberConditionValue(value: final from),
        to: NumberConditionValue(value: final to),
      ) =>
        (from: from, to: to),
      _ => (from: null, to: null),
    };

({(double, double)? from, (double, double)? to}) _pointRangeValue(
  ConditionValue value,
) => switch (value) {
  RangeConditionValue(:final from, :final to) => (
    from: from.pointOrNull,
    to: to.pointOrNull,
  ),
  _ => (from: null, to: null),
};
