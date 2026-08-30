import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/keyboard_timeline_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/editors/editor_input_action/widgets/mouse_timeline_field.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_delta_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_vector_editor.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class InputEntryInlineEditor extends HookWidget {
  const InputEntryInlineEditor({
    required this.mode,
    required this.tokens,
    required this.onChanged,
    super.key,
  });

  final InputEntryMode mode;
  final List<InputToken> tokens;
  final ValueChanged<List<InputToken>> onChanged;

  @override
  Widget build(BuildContext context) {
    final textValue = _keyboardTextValue(tokens);
    final keyboardText = useSyncedTextController(
      switch (textValue) {
        LiteralText(:final text) => text,
        CommandText(:final command) => command,
      },
      (value) => onChanged([
        InputToken.text(
          switch (textValue) {
            LiteralText() => DynamicText.literal(value.text),
            CommandText() => DynamicText.command(value.text),
          },
        ),
      ]),
    );

    final (x, y) = _vectorOf(tokens);

    return switch (mode) {
      InputEntryMode.keyboardTimeline => KeyboardTimelineField(
        tokens: tokens,
        onChanged: onChanged,
      ),
      InputEntryMode.mouseTimeline => MouseTimelineField(
        tokens: tokens,
        onChanged: onChanged,
      ),
      InputEntryMode.keyboardText => FTextField(
        control: FTextFieldControl.managed(controller: keyboardText),
        label: Text(context.l10n.inputTextToTypeLabel),
        maxLines: null,
        hint: 'Hello world',
      ),
      InputEntryMode.mouseMoveBy => MouseVectorEditor(
        x: x,
        y: y,
        onChanged: (x, y) => onChanged([InputToken.moveBy(x, y)]),
      ),
      InputEntryMode.mouseMoveByDelta => MouseDeltaEditor(
        multiplier: _multiplierOf(tokens),
        onChanged: (value) => onChanged([InputToken.moveByDelta(value)]),
      ),
      InputEntryMode.mouseMoveTo => MouseVectorEditor(
        x: x,
        y: y,
        onChanged: (x, y) => onChanged([InputToken.moveTo(x, y)]),
      ),
      InputEntryMode.mouseWheel => MouseVectorEditor(
        x: x,
        y: y,
        onChanged: (x, y) => onChanged([InputToken.wheel(x, y)]),
      ),
    };
  }
}

/// The x/y a vector editor should show, whatever the entry currently holds.
(double, double) _vectorOf(List<InputToken> tokens) =>
    switch (tokens.firstOrNull) {
      MoveByInputToken(:final x, :final y) => (x, y),
      MoveToInputToken(:final x, :final y) => (x, y),
      WheelInputToken(:final x, :final y) => (x, y),
      _ => (0, 0),
    };

double? _multiplierOf(List<InputToken> tokens) => switch (tokens.firstOrNull) {
  MoveByDeltaInputToken(:final multiplier) => multiplier,
  _ => null,
};

DynamicText _keyboardTextValue(List<InputToken> tokens) =>
    switch (tokens.firstOrNull) {
      TextInputToken(:final value) => value,
      _ => const DynamicText.literal(''),
    };
