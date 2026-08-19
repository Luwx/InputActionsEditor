import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/domain/misc/keyboard_key_search_index.dart';
import 'package:input_actions_editor/domain/misc/keyboard_physical_key_map.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/key_sequence_text_field.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/input_recording_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';

import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_delta_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/mouse_vector_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/revealed_field.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/action_labels.dart';

const Map<int, String> _mouseButtonNames = {
  kPrimaryMouseButton: 'left',
  kSecondaryMouseButton: 'right',
  kMiddleMouseButton: 'middle',
  kBackMouseButton: 'back',
  kForwardMouseButton: 'forward',
};

class EditorInputAction extends HookConsumerWidget {
  const EditorInputAction({super.key});

  static const Map<String, InputDevice> deviceOptions = {
    'Keyboard': InputDevice.keyboard,
    'Mouse': InputDevice.mouse,
  };

  void _addEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
  ) {
    onChanged([...current, const InputEntry(device: InputDevice.keyboard)]);
  }

  void _removeEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
    int index,
  ) {
    onChanged(List<InputEntry>.of(current)..removeAt(index));
  }

  void _updateEntry(
    List<InputEntry> current,
    void Function(List<InputEntry>) onChanged,
    int index,
    InputEntry updated,
  ) {
    final list = List<InputEntry>.of(current);
    list[index] = updated;
    onChanged(list);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesField = ref.actionField(
      context,
      actionInputEntriesLens,
      fallbackValue: () => const <InputEntry>[],
    );
    final currentEntries = entriesField.value;
    // final colors = context.theme.colors;
    return RevealedField(
      field: ConfigDirtyField.actionInputEntries,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              UnsavedLabel(
                state: entriesField.dirty,
                onRevert: entriesField.onRevert,
                child: Text(
                  context.l10n.inputDevicesLabel,
                  style: context.theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              FButton(
                variant: .outline,
                size: .sm,
                onPress: () =>
                    _addEntry(currentEntries, entriesField.onChanged),
                prefix: const Icon(FLucideIcons.plus, size: 14),
                child: Text(context.l10n.inputAddDevice),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              // border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              // padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, entry) in currentEntries.indexed)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _InputEntryEditor(
                          index: index,
                          entry: entry,
                          deviceOptions: deviceOptions,
                          onChanged: (updated) => _updateEntry(
                            currentEntries,
                            entriesField.onChanged,
                            index,
                            updated,
                          ),
                          onDelete: () => _removeEntry(
                            currentEntries,
                            entriesField.onChanged,
                            index,
                          ),
                        ),
                        if (index != currentEntries.length - 1)
                          const FDivider(
                            style: .delta(
                              padding: .value(
                                EdgeInsets.only(bottom: 12, top: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputEntryEditor extends HookWidget {
  const _InputEntryEditor({
    required this.index,
    required this.entry,
    required this.deviceOptions,
    required this.onChanged,
    required this.onDelete,
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

    final syncing = useRef(false);

    void replaceTokens(List<String> tokens) {
      if (syncing.value) return;
      onChanged(entry.copyWith(tokens: tokens));
    }

    void replaceSingleToken(String token) => replaceTokens([token]);

    final keyboardText = useSyncedTextController(
      keyboardTextValue(entry.tokens),
      (value) => replaceSingleToken('text: ${value.text}'),
    );

    final tokenKey = entry.tokens.join(', ');
    useEffect(() {
      void resync(TextEditingController controller) {
        if (controller.text == tokenKey) return;
        final typed = KeySequenceParser.toTokens(
          KeySequenceParser.parse(controller.text),
        ).join(', ');
        // Text the parser cannot read canonicalizes to nothing, which must not
        // pass for an empty sequence.
        if (typed.isNotEmpty && typed == tokenKey) return;
        unawaited(
          Future.microtask(() {
            syncing.value = true;
            controller.text = tokenKey;
            syncing.value = false;
          }),
        );
      }

      resync(keySeqController);
      resync(mouseSeqController);
      return null;
    }, [tokenKey]);

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

    void stopRecording({
      required bool append,
      bool convertToShortcut = false,
    }) {
      final handler = keyHandlerRef.value;
      if (handler != null) {
        HardwareKeyboard.instance.removeHandler(handler);
        keyHandlerRef.value = null;
      }
      if (append && liveKeyTokens.value.isNotEmpty) {
        final tokens = liveKeyTokens.value;
        final appended = convertToShortcut
            ? KeySequenceParser.tokensToShortcutString(tokens)
            : tokens.join(', ');
        final existing = keySeqController.text.trim();
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
              labelWidget: LabelWithTooltip(
                label: context.l10n.inputKeySequenceLabel,
                tooltipContent: const KeySequenceTooltip(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              context.l10n.inputKeySequenceRecordTip,
              style: context.theme.typography.body.xs.copyWith(
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
              popoverBuilder: (context, controller) => Focus(
                autofocus: isKeyboardRecording.value,
                onKeyEvent: isKeyboardRecording.value
                    ? (_, _) => KeyEventResult.handled
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: isKeyboardRecording.value
                      ? _KeyboardRecordingView(
                          controller: controller,
                          liveKeyTokens: liveKeyTokens.value,
                          stopRecording: stopRecording,
                          onClear: () => liveKeyTokens.value = [],
                        )
                      : _buildKeyboardRecordStart(
                          context,
                          startRecording: startRecording,
                        ),
                ),
              ),
              child: const Icon(Icons.radio_button_checked, size: 16),
            ),
          ),
          const SizedBox(width: 4),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              context.l10n.inputKeySequenceBrowseTip,
              style: context.theme.typography.body.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            child: FPopover(
              groupId: timelinePopoverGroup,
              constraints: const FPortalConstraints(maxWidth: 260),
              builder: (context, controller, child) => FButton.icon(
                size: .sm,
                onPress: controller.toggle,
                child: child,
              ),
              popoverBuilder: (context, controller) => _KeyBrowserPopover(
                onSelect: (scancode) {
                  final existing = keySeqController.text.trim();
                  keySeqController.text = existing.isEmpty
                      ? scancode
                      : '$existing, $scancode';
                },
              ),
              child: const Icon(FLucideIcons.search, size: 15),
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
              labelWidget: LabelWithTooltip(
                label: context.l10n.inputButtonSequenceLabel,
                tooltipContent: const ButtonSequenceTooltip(),
              ),
              hintText:
                  'e.g.  +left, -left   or   +right, +left, -left, -right',
            ),
          ),
          const SizedBox(width: 8),
          AppTooltip(
            tipBuilder: (context, _) => Text(
              context.l10n.inputButtonSequenceRecordTip,
              style: context.theme.typography.body.xs.copyWith(
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
              popoverBuilder: (context, controller) => _RecordingScope(
                child: Padding(
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
        control: FTextFieldControl.managed(controller: keyboardText),
        label: Text(context.l10n.inputTextToTypeLabel),
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

    final optionsList = inputModeOptions(entry.device, context.l10n);
    final options = {
      for (final o in optionsList) o.label: o.mode,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final deviceField = FSelect<InputDevice>(
              label: LabelWithTooltip(
                label: context.l10n.inputDeviceFieldLabel,
                tooltip: context.l10n.inputDeviceFieldTooltip,
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
              label: LabelWithTooltip(
                label: context.l10n.inputActionTypeLabel,
                tooltip: context.l10n.inputActionTypeTooltip,
              ),
              key: ValueKey(mode),
              items: options,
              control: FSelectManagedControl<InputEntryMode>(
                initial: mode,
                onChange: changeMode,
              ),
            );

            final compact = constraints.maxWidth < 580;

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
    );
  }
}

/// Marks an in-app recorder as active for as long as it is mounted, so the
/// app's global input handlers (mouse back / forward navigation, undo / redo
/// shortcuts) stand down and let the captured events be recorded instead.
///
/// Also absorbs key events so stray keypresses during recording don't trigger
/// focused-widget behavior.
class _RecordingScope extends HookConsumerWidget {
  const _RecordingScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      // Deferred: hooks run effects during build, and Riverpod forbids
      // modifying a provider mid-build.
      final notifier = ref.read(inputRecordingProvider.notifier);
      scheduleMicrotask(notifier.begin);
      return () => scheduleMicrotask(notifier.end);
    }, const []);

    return Focus(
      autofocus: true,
      onKeyEvent: (_, _) => KeyEventResult.handled,
      child: child,
    );
  }
}

Widget _buildKeyboardRecordStart(
  BuildContext context, {
  required VoidCallback startRecording,
}) {
  final l10n = context.l10n;
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        l10n.inputKeySequenceRecordTitle,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 8),
      FButton(
        variant: .outline,
        onPress: startRecording,
        prefix: const Icon(Icons.radio_button_checked),
        child: Text(l10n.actionRecord),
      ),
    ],
  );
}

class _KeyboardRecordingView extends HookWidget {
  const _KeyboardRecordingView({
    required this.controller,
    required this.liveKeyTokens,
    required this.stopRecording,
    required this.onClear,
  });

  final FPopoverController controller;
  final List<String> liveKeyTokens;
  final void Function({required bool append, bool convertToShortcut})
  stopRecording;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final convertChecked = useState(true);
    final canConvert = KeySequenceParser.canExpressAsShortcut(liveKeyTokens);

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
              context.l10n.inputKeySequenceRecordingTitle,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (liveKeyTokens.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              context.l10n.inputKeySequenceRecordPrompt,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Wrap(
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
                      child: Text(
                        token,
                        style: context.theme.typography.body.xs,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        FCheckbox(
          value: canConvert && convertChecked.value,
          enabled: canConvert,
          onChange: (v) => convertChecked.value = v,
          // label: Text(
          //   context.l10n.inputKeySequenceRecordingConvertShortcut,
          // ),
          label: LabelWithTooltip(
            label: context.l10n.inputKeySequenceRecordingConvertShortcut,
            tooltipContent: const ConvertToShortcutTooltip(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FButton(
              size: .sm,
              onPress: () async {
                stopRecording(
                  append: true,
                  convertToShortcut: canConvert && convertChecked.value,
                );
                await controller.hide();
              },
              child: Text(context.l10n.inputKeySequenceStopAdd),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: onClear,
              child: Text(context.l10n.inputKeySequenceRecordingClear),
            ),
            const SizedBox(width: 8),
            FButton(
              variant: .ghost,
              size: .sm,
              onPress: () async {
                stopRecording(append: false);
                await controller.hide();
              },
              child: Text(context.l10n.actionCancel),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyBrowserPopover extends HookWidget {
  const _KeyBrowserPopover({required this.onSelect});

  final void Function(String scancode) onSelect;

  @override
  Widget build(BuildContext context) {
    final query = useState('');
    final searchController = useTextEditingController();
    final results = useMemoized(
      () => query.value.trim().isEmpty
          ? keySearchIndex
          : keySearchIndex.where((e) => e.matches(query.value)).toList(),
      [query.value],
    );

    final colors = context.theme.colors;
    final t = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              controller: searchController,
              onChange: (v) => query.value = v.text,
            ),
            hint: context.l10n.inputKeyBrowseHint,
            autofocus: true,
          ),
          SizedBox(
            height: 220,
            child: results.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.inputKeyBrowseEmpty,
                      style: t.body.xs.copyWith(color: colors.mutedForeground),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemExtent: 32,
                    itemBuilder: (context, i) => _KeyResultTile(
                      entry: results[i],
                      onSelect: onSelect,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _KeyResultTile extends HookWidget {
  const _KeyResultTile({required this.entry, required this.onSelect});

  final KeyEntry entry;
  final void Function(String scancode) onSelect;

  @override
  Widget build(BuildContext context) {
    final hovered = useState(false);
    final colors = context.theme.colors;
    final t = context.theme.typography;

    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSelect(entry.scancode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hovered.value
                ? colors.secondary.withValues(alpha: 0.8)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Text(
                entry.label,
                style: t.body.sm.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.scancode,
                  style: t.body.xs.copyWith(
                    color: colors.mutedForeground,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        context.l10n.inputButtonSequenceRecordTitle,
        style: context.theme.typography.body.sm.copyWith(
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
                    context.l10n.inputButtonSequenceRecordPrompt,
                    style: context.theme.typography.body.sm.copyWith(
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
                            context.l10n,
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
                                style: context.theme.typography.body.xs
                                    .copyWith(
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
            child: Text(context.l10n.inputButtonSequenceAddToSeq),
          ),
          const SizedBox(width: 8),
          FButton(
            variant: .ghost,
            size: .sm,
            onPress: () async {
              onClearTokens();
              await controller.hide();
            },
            child: Text(context.l10n.actionCancel),
          ),
        ],
      ),
    ],
  );
}
