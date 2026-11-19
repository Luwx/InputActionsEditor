import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/lens.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/raw_option_badge.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class RawTriggerOption extends HookConsumerWidget {
  const RawTriggerOption({required this.option, super.key});

  final String option;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = context.gestureLocation;
    final deleteLabel = context.l10n.actionDelete;
    final field = ref.gestureField(
      context,
      (location) => gestureExtraLens(location).then(
        LensPart<Map<String, Object?>, Object?>(
          name: option,
          get: (extra) => extra[option],
          set: (extra, value) => {...extra, option: value},
          canGet: (extra) => extra.containsKey(option),
        ),
      ),
      fallbackValue: () => null,
    );
    final originalValue = useMemoized(() => field.value);
    final value = field.value;
    final editable =
        value == null || value is String || value is num || value is bool;
    final text = switch (value) {
      null => '',
      String() || num() || bool() => '$value',
      _ => jsonEncode(value),
    };
    final controller = useSyncedTextController(
      text,
      (edit) {
        if (editable && edit.text != text) {
          field.onChanged(_parseValue(edit.text, originalValue));
        }
      },
      preserveSelection: true,
    );

    return FTextField(
      control: FTextFieldControl.managed(controller: controller),
      readOnly: !editable,
      label: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          UnsavedLabel(
            state: field.dirty,
            onRevert: field.onRevert,
            child: Text(option),
          ),
          const RawOptionBadge(),
          AppTooltip(
            tipBuilder: (_, _) => Text(deleteLabel),
            child: FButton.icon(
              variant: .ghost,
              size: .xs,
              onPress: () => ref
                  .read(gestureEditorProvider(location).notifier)
                  .removeRawOption(option),
              child: Icon(FLucideIcons.trash2, semanticLabel: deleteLabel),
            ),
          ),
        ],
      ),
    );
  }
}

Object? _parseValue(String text, Object? originalValue) {
  if (text.isEmpty && originalValue == null) return null;
  final parsed = switch (originalValue) {
    num() => num.tryParse(text),
    bool() => bool.tryParse(text),
    _ => null,
  };
  return parsed != null && parsed.toString() == text ? parsed : text;
}
