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
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/keyboard_physical_key_map.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_delta_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_vector_editor.dart';

class InputEntryEditor extends StatefulWidget {
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
  State<InputEntryEditor> createState() => _InputEntryEditorState();
}

class _InputEntryEditorState extends State<InputEntryEditor> {
  static const Map<int, String> _mouseButtonNames = {
    kPrimaryMouseButton: 'left',
    kSecondaryMouseButton: 'right',
    kMiddleMouseButton: 'middle',
    kBackMouseButton: 'back',
    kForwardMouseButton: 'forward',
  };

  final Object _timelinePopoverGroup = Object();

  // ── Keyboard recording ────────────────────────────────────────────────────
  bool _isKeyboardRecording = false;
  final List<String> _liveKeyTokens = [];
  late final TextEditingController _keySeqController;

  // ── Mouse recording area ───────────────────────────────────────────────────
  final List<String> _liveMouseTokens = [];
  int _buttonsDown = 0;
  late final TextEditingController _mouseSeqController;

  InputEntry get _entry => widget.entry;
  InputEntryMode get _mode => inferInputEntryMode(_entry);

  @override
  void initState() {
    super.initState();
    _keySeqController = TextEditingController(
      text: _entry.tokens.join(', '),
    );
    _mouseSeqController = TextEditingController(
      text: _entry.tokens.join(', '),
    );
  }

  void _replaceTokens(List<String> tokens) {
    widget.onChanged(_entry.copyWith(tokens: tokens));
  }

  void _replaceSingleToken(String token) {
    _replaceTokens([token]);
  }

  void _changeMode(InputEntryMode? mode) {
    if (mode == null || mode == _mode) return;
    _replaceTokens(defaultTokensForMode(mode));
  }

  @override
  void dispose() {
    if (_isKeyboardRecording) {
      HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    }
    _keySeqController.dispose();
    _mouseSeqController.dispose();
    super.dispose();
  }

  // ── Keyboard recording ────────────────────────────────────────────────────

  bool _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyUpEvent) return true;
    final scancode = physicalKeyToScancode[event.physicalKey];
    if (scancode != null) {
      final token = '${event is KeyDownEvent ? '+' : '-'}$scancode';
      if (mounted) setState(() => _liveKeyTokens.add(token));
    }
    return true;
  }

  void _startRecording() {
    setState(() {
      _isKeyboardRecording = true;
      _liveKeyTokens.clear();
    });
    HardwareKeyboard.instance.addHandler(_onKeyEvent);
  }

  void _stopRecording({required bool append}) {
    HardwareKeyboard.instance.removeHandler(_onKeyEvent);
    if (!mounted) return;
    if (append && _liveKeyTokens.isNotEmpty) {
      final existing = _keySeqController.text.trim();
      final appended = _liveKeyTokens.join(', ');
      _keySeqController.text = existing.isEmpty
          ? appended
          : '$existing, $appended';
    }
    setState(() {
      _isKeyboardRecording = false;
      _liveKeyTokens.clear();
    });
  }

  // ── Mouse recording area ──────────────────────────────────────────────────

  void _onRecordAreaPointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.mouse) return;
    final pressed = event.buttons & ~_buttonsDown;
    _buttonsDown = event.buttons;
    var changed = false;
    for (final entry in _mouseButtonNames.entries) {
      if (pressed & entry.key != 0) {
        _liveMouseTokens.add('+${entry.value}');
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  void _onRecordAreaPointerUp(PointerUpEvent event) {
    final released = _buttonsDown & ~event.buttons;
    _buttonsDown = event.buttons;
    var changed = false;
    for (final entry in _mouseButtonNames.entries) {
      if (released & entry.key != 0) {
        _liveMouseTokens.add('-${entry.value}');
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  // ── Build helpers ─────────────────────────────────────────────────────────

  Widget _buildKeyboardTimelineEditor(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: KeySequenceTextField(
            controller: _keySeqController,
            onChanged: _replaceTokens,
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
            groupId: _isKeyboardRecording ? null : _timelinePopoverGroup,
            hideRegion: _isKeyboardRecording ? .none : .excludeChild,
            constraints: const FPortalConstraints(maxWidth: 300),
            builder: (context, controller, child) => FButton.icon(
              size: .sm,
              onPress: controller.toggle,
              child: child,
            ),
            popoverBuilder: (context, controller) => Padding(
              padding: const EdgeInsets.all(12),
              child: _isKeyboardRecording
                  ? _buildKeyboardRecordingView(context, controller)
                  : _buildKeyboardRecordStart(context),
            ),
            child: const Icon(Icons.radio_button_checked, size: 16),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildKeyboardRecordStart(BuildContext context) {
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
          onPress: _startRecording,
          prefix: const Icon(Icons.radio_button_checked),
          child: const Text('Record'),
        ),
      ],
    );
  }

  Widget _buildKeyboardRecordingView(
    BuildContext context,
    FPopoverController controller,
  ) {
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
        if (_liveKeyTokens.isEmpty)
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
              for (final token in _liveKeyTokens)
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
                _stopRecording(append: true);
                await controller.hide();
              },
              child: const Text('Stop & Add'),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                _stopRecording(append: false);
                await controller.hide();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMouseTimelineEditor(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: KeySequenceTextField(
            controller: _mouseSeqController,
            onChanged: _replaceTokens,
            label: 'Button Sequence',
            hintText: 'e.g.  +left, -left   or   +right, +left, -left, -right',
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
            groupId: _timelinePopoverGroup,
            constraints: const FPortalConstraints(maxWidth: 300),
            builder: (context, controller, child) => FButton.icon(
              size: .sm,
              onPress: controller.toggle,
              child: child,
            ),
            popoverBuilder: (context, controller) => Padding(
              padding: const EdgeInsets.all(12),
              child: _buildMouseRecordPopover(context, controller),
            ),
            child: const Icon(Icons.radio_button_checked, size: 16),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMouseRecordPopover(
    BuildContext context,
    FPopoverController controller,
  ) {
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
          onPointerDown: _onRecordAreaPointerDown,
          onPointerUp: _onRecordAreaPointerUp,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.6),
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _liveMouseTokens.isEmpty
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
                      for (final token in _liveMouseTokens)
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
              onPress: _liveMouseTokens.isEmpty
                  ? null
                  : () async {
                      final existing = _mouseSeqController.text.trim();
                      final appended = _liveMouseTokens.join(', ');
                      _mouseSeqController.text = existing.isEmpty
                          ? appended
                          : '$existing, $appended';
                      setState(_liveMouseTokens.clear);
                      await controller.hide();
                    },
              child: const Text('Add to sequence'),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                setState(_liveMouseTokens.clear);
                await controller.hide();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = modeOptions(_entry.device);
    final inlineEditor = switch (_mode) {
      InputEntryMode.keyboardTimeline => _buildKeyboardTimelineEditor(context),
      InputEntryMode.mouseTimeline => _buildMouseTimelineEditor(context),
      InputEntryMode.keyboardText => FTextField(
        key: ValueKey(_entry.tokens.join('|')),
        control: FTextFieldControl.managed(
          initial: TextEditingValue(text: keyboardTextValue(_entry.tokens)),
          onChange: (value) => _replaceSingleToken('text: ${value.text}'),
        ),
        label: const Text('Text to type'),
        maxLines: null,
        hint: 'Hello world',
      ),
      InputEntryMode.mouseMoveBy => MouseVectorEditor(
        token: singleTokenOrDefault(_entry.tokens, _mode),
        mode: _mode,
        onChanged: _replaceSingleToken,
      ),
      InputEntryMode.mouseMoveByDelta => MouseDeltaEditor(
        token: singleTokenOrDefault(_entry.tokens, _mode),
        onChanged: _replaceSingleToken,
      ),
      InputEntryMode.mouseMoveTo => MouseVectorEditor(
        token: singleTokenOrDefault(_entry.tokens, _mode),
        mode: _mode,
        onChanged: _replaceSingleToken,
      ),
      InputEntryMode.mouseWheel => MouseVectorEditor(
        token: singleTokenOrDefault(_entry.tokens, _mode),
        mode: _mode,
        onChanged: _replaceSingleToken,
      ),
    };

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
                key: ValueKey(_entry.device),
                items: widget.deviceOptions,
                control: FSelectManagedControl<InputDevice>(
                  initial: _entry.device,
                  onChange: (value) {
                    if (value != null) {
                      widget.onChanged(
                        _entry.copyWith(device: value, tokens: []),
                      );
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
                key: ValueKey(_mode),
                items: options,
                control: FSelectManagedControl<InputEntryMode>(
                  initial: _mode,
                  onChange: _changeMode,
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
                            onPress: widget.onDelete,
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
                      onPress: widget.onDelete,
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
