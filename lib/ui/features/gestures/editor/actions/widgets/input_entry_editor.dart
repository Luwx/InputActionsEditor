import 'package:flutter/gestures.dart'
    show
        PointerDeviceKind,
        PointerDownEvent,
        PointerUpEvent,
        kBackMouseButton,
        kForwardMouseButton,
        kMiddleMouseButton,
        kPrimaryMouseButton,
        kSecondaryMouseButton;
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyEvent, KeyUpEvent;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/keyboard_physical_key_map.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_delta_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_vector_editor.dart';

const Map<int, String> _mouseButtonNames = {
  kPrimaryMouseButton: 'left',
  kSecondaryMouseButton: 'right',
  kMiddleMouseButton: 'middle',
  kBackMouseButton: 'back',
  kForwardMouseButton: 'forward',
};

class InputEntryEditor extends HookWidget {
  const InputEntryEditor({
    required this.index,
    required this.entry,
    required this.deviceOptions,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  final int index;
  final InputEntry entry;
  final Map<String, InputDevice> deviceOptions;
  final void Function(InputEntry) onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timelinePopoverGroup = useMemoized(Object.new);
    final isKeyboardRecording = useState(false);
    final liveKeyTokens = useState<List<String>>([]);
    final keySeqController = useTextEditingController(
      text: entry.tokens.join(', '),
    );
    final liveMouseTokens = useState<List<String>>([]);
    final buttonsDown = useRef(0);
    final mouseSeqController = useTextEditingController(
      text: entry.tokens.join(', '),
    );

    final mode = inferInputEntryMode(entry);

    // Keyboard recording handler,
    // stored in a ref so cleanup always unregisters.
    final keyHandlerRef = useRef<bool Function(KeyEvent)?>(null);

    useEffect(() {
      return () {
        final handler = keyHandlerRef.value;
        if (handler != null) {
          HardwareKeyboard.instance.removeHandler(handler);
        }
      };
    }, const []);

    void replaceTokens(List<String> tokens) {
      onChanged(entry.copyWith(tokens: tokens));
    }

    void replaceSingleToken(String token) => replaceTokens([token]);

    void changeMode(InputEntryMode? m) {
      if (m == null || m == mode) return;
      replaceTokens(defaultTokensForMode(m));
    }

    bool onKeyEvent(KeyEvent event) {
      if (event is! KeyDownEvent && event is! KeyUpEvent) return true;
      final scancode = physicalKeyToScancode[event.physicalKey];
      if (scancode != null) {
        final token = '${event is KeyDownEvent ? '+' : '-'}$scancode';
        liveKeyTokens.value = [...liveKeyTokens.value, token];
      }
      return true;
    }

    void startRecording() {
      isKeyboardRecording.value = true;
      liveKeyTokens.value = [];
      keyHandlerRef.value = onKeyEvent;
      HardwareKeyboard.instance.addHandler(onKeyEvent);
    }

    void stopRecording({required bool append}) {
      final handler = keyHandlerRef.value;
      if (handler != null) {
        HardwareKeyboard.instance.removeHandler(handler);
        keyHandlerRef.value = null;
      }
      if (append && liveKeyTokens.value.isNotEmpty) {
        final existing = keySeqController.text.trim();
        final appended = liveKeyTokens.value.join(', ');
        keySeqController.text = existing.isEmpty
            ? appended
            : '$existing, $appended';
      }
      isKeyboardRecording.value = false;
      liveKeyTokens.value = [];
    }

    void onRecordAreaPointerDown(PointerDownEvent event) {
      if (event.kind != PointerDeviceKind.mouse) return;
      final pressed = event.buttons & ~buttonsDown.value;
      buttonsDown.value = event.buttons;
      var changed = false;
      for (final e in _mouseButtonNames.entries) {
        if (pressed & e.key != 0) {
          liveMouseTokens.value = [...liveMouseTokens.value, '+${e.value}'];
          changed = true;
        }
      }
      if (changed) {}
    }

    void onRecordAreaPointerUp(PointerUpEvent event) {
      final released = buttonsDown.value & ~event.buttons;
      buttonsDown.value = event.buttons;
      for (final e in _mouseButtonNames.entries) {
        if (released & e.key != 0) {
          liveMouseTokens.value = [...liveMouseTokens.value, '-${e.value}'];
        }
      }
    }

    Widget buildKeyboardTimelineEditor() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: KeySequenceTextField(
              controller: keySeqController,
              onChanged: replaceTokens,
            ),
          ),
          const SizedBox(width: 8),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              'Record a sequence of keystrokes.',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            child: FPopover(
              groupId: isKeyboardRecording.value ? null : timelinePopoverGroup,
              hideRegion: isKeyboardRecording.value ? .none : .excludeChild,
              constraints: const FPortalConstraints(maxWidth: 300),
              builder: (context, controller, child) => FButton.icon(
                size: .sm,
                onPress: controller.toggle,
                child: child,
              ),
              popoverBuilder: (context, controller) => Padding(
                padding: const EdgeInsets.all(12),
                child: isKeyboardRecording.value
                    ? _buildKeyboardRecordingView(
                        context,
                        controller,
                        liveKeyTokens.value,
                        stopRecording: stopRecording,
                      )
                    : _buildKeyboardRecordStart(
                        context,
                        startRecording: startRecording,
                      ),
              ),
              child: const Icon(Icons.radio_button_checked, size: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    Widget buildMouseTimelineEditor() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: KeySequenceTextField(
              controller: mouseSeqController,
              onChanged: replaceTokens,
              label: 'Button Sequence',
              hintText:
                  'e.g.  +left, -left   or   +right, +left, -left, -right',
            ),
          ),
          const SizedBox(width: 8),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              'Record mouse button clicks.',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            child: FPopover(
              groupId: timelinePopoverGroup,
              constraints: const FPortalConstraints(maxWidth: 300),
              builder: (context, controller, child) => FButton.icon(
                size: .sm,
                onPress: controller.toggle,
                child: child,
              ),
              popoverBuilder: (context, controller) => Padding(
                padding: const EdgeInsets.all(12),
                child: _buildMouseRecordPopover(
                  context,
                  controller,
                  liveMouseTokens: liveMouseTokens.value,
                  mouseSeqController: mouseSeqController,
                  onPointerDown: onRecordAreaPointerDown,
                  onPointerUp: onRecordAreaPointerUp,
                  onClearTokens: () => liveMouseTokens.value = [],
                ),
              ),
              child: const Icon(Icons.radio_button_checked, size: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      );
    }

    final inlineEditor = switch (mode) {
      InputEntryMode.keyboardTimeline => buildKeyboardTimelineEditor(),
      InputEntryMode.mouseTimeline => buildMouseTimelineEditor(),
      InputEntryMode.keyboardText => FTextField(
        key: ValueKey(entry.tokens.join('|')),
        control: FTextFieldControl.managed(
          initial: TextEditingValue(text: keyboardTextValue(entry.tokens)),
          onChange: (value) => replaceSingleToken('text: ${value.text}'),
        ),
        label: const Text('Text to type'),
        maxLines: null,
        hint: 'Hello world',
      ),
      InputEntryMode.mouseMoveBy => MouseVectorEditor(
        token: singleTokenOrDefault(entry.tokens, mode),
        mode: mode,
        onChanged: replaceSingleToken,
      ),
      InputEntryMode.mouseMoveByDelta => MouseDeltaEditor(
        token: singleTokenOrDefault(entry.tokens, mode),
        onChanged: replaceSingleToken,
      ),
      InputEntryMode.mouseMoveTo => MouseVectorEditor(
        token: singleTokenOrDefault(entry.tokens, mode),
        mode: mode,
        onChanged: replaceSingleToken,
      ),
      InputEntryMode.mouseWheel => MouseVectorEditor(
        token: singleTokenOrDefault(entry.tokens, mode),
        mode: mode,
        onChanged: replaceSingleToken,
      ),
    };

    final options = modeOptions(entry.device);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final deviceField = FSelect<InputDevice>(
                label: const LabelWithTooltip(
                  label: 'Device',
                  tooltip: 'Whether to simulate keyboard or mouse input.',
                ),
                key: ValueKey(entry.device),
                items: deviceOptions,
                control: FSelectManagedControl<InputDevice>(
                  initial: entry.device,
                  onChange: (value) {
                    if (value != null) {
                      onChanged(entry.copyWith(device: value, tokens: []));
                    }
                  },
                ),
              );
              final actionTypeField = FSelect<InputEntryMode>(
                label: const LabelWithTooltip(
                  label: 'Action type',
                  tooltip:
                      'The kind of simulated input: key combination, '
                      'typed text, mouse movement, scroll wheel, etc.',
                ),
                key: ValueKey(mode),
                items: options,
                control: FSelectManagedControl<InputEntryMode>(
                  initial: mode,
                  onChange: changeMode,
                ),
              );

              final compact = constraints.maxWidth < 620;

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: deviceField),
                        const SizedBox(width: 12),
                        Expanded(child: actionTypeField),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: FButton(
                            variant: .ghost,
                            size: .sm,
                            onPress: onDelete,
                            child: const Icon(FLucideIcons.trash),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    inlineEditor,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(child: deviceField),
                  Expanded(flex: 2, child: actionTypeField),
                  Expanded(flex: 3, child: inlineEditor),
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: FButton(
                      variant: .ghost,
                      size: .sm,
                      onPress: onDelete,
                      child: const Icon(FLucideIcons.trash),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildKeyboardRecordStart(
  BuildContext context, {
  required VoidCallback startRecording,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Record keystrokes',
        style: context.theme.typography.sm.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      FButton(
        variant: .outline,
        onPress: startRecording,
        prefix: const Icon(Icons.radio_button_checked),
        child: const Text('Record'),
      ),
    ],
  );
}

Widget _buildKeyboardRecordingView(
  BuildContext context,
  FPopoverController controller,
  List<String> liveKeyTokens, {
  required void Function({required bool append}) stopRecording,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.radio_button_checked,
            color: Colors.redAccent,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'Recording keystrokes...',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (liveKeyTokens.isEmpty)
        Text(
          'Press any key to record.',
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        )
      else
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final token in liveKeyTokens)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.theme.colors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(token, style: context.theme.typography.xs),
                ),
              ),
          ],
        ),
      const SizedBox(height: 12),
      Row(
        children: [
          FButton(
            size: .sm,
            onPress: () async {
              stopRecording(append: true);
              await controller.hide();
            },
            child: const Text('Stop & Add'),
          ),
          const SizedBox(width: 8),
          FButton(
            variant: .ghost,
            size: .sm,
            onPress: () async {
              stopRecording(append: false);
              await controller.hide();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ],
  );
}

Widget _buildMouseRecordPopover(
  BuildContext context,
  FPopoverController controller, {
  required List<String> liveMouseTokens,
  required TextEditingController mouseSeqController,
  required void Function(PointerDownEvent) onPointerDown,
  required void Function(PointerUpEvent) onPointerUp,
  required VoidCallback onClearTokens,
}) {
  final colors = context.theme.colors;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Record mouse buttons',
        style: context.theme.typography.sm.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: onPointerDown,
        onPointerUp: onPointerUp,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.secondary.withValues(alpha: 0.6),
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: liveMouseTokens.isEmpty
              ? Center(
                  child: Text(
                    'Click any mouse button here',
                    style: context.theme.typography.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final token in liveMouseTokens)
                      Builder(
                        builder: (context) {
                          final vis = tokenVisual(
                            token,
                            InputDevice.mouse,
                            colors,
                          );
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: vis.background,
                              border: Border.all(color: vis.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                vis.label,
                                style: context.theme.typography.xs.copyWith(
                                  color: vis.foreground,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          FButton(
            size: .sm,
            onPress: liveMouseTokens.isEmpty
                ? null
                : () async {
                    final existing = mouseSeqController.text.trim();
                    final appended = liveMouseTokens.join(', ');
                    mouseSeqController.text = existing.isEmpty
                        ? appended
                        : '$existing, $appended';
                    onClearTokens();
                    await controller.hide();
                  },
            child: const Text('Add to sequence'),
          ),
          const SizedBox(width: 8),
          FButton(
            variant: .ghost,
            size: .sm,
            onPress: () async {
              onClearTokens();
              await controller.hide();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    ],
  );
}
