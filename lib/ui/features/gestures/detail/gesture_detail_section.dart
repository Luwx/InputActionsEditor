import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/keyboard_gesture.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/pointer_gesture.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/touchscreen_gesture.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/features/gestures/detail/gesture_detail_actions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/keyboard_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/pointer_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchpad_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchscreen_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/widgets/sliver_smart_anchor.dart';

class GestureDetailSection extends ConsumerStatefulWidget {
  const GestureDetailSection({super.key});

  @override
  ConsumerState<GestureDetailSection> createState() =>
      _GestureDetailSectionState();
}

class _GestureDetailSectionState extends ConsumerState<GestureDetailSection> {
  late final ScrollController _scrollController;

  /// Lets the actions editor keep an expanding row's bottom visible by driving
  /// the [SliverSmartAnchor] that wraps the editor body.
  final ScrollAnchorController _anchorController = ScrollAnchorController();

  /// Holds focus for the editor pane so the undo/redo [Shortcuts] receive key
  /// events. Key events bubble up the focus tree, so something inside the
  /// Shortcuts subtree must be focused for Ctrl+Z to fire.
  final FocusNode _undoFocusNode = FocusNode(debugLabel: 'gestureEditorUndo');

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _undoFocusNode.dispose();
    super.dispose();
  }

  void _enableSelected(Set<GestureSelection> selected) {
    final notifier = ref.read(configControllerProvider.notifier);
    for (final s in selected) {
      notifier.updateGestureCommonForDevice(
        s.device,
        s.index,
        (c) => c.copyWith(enabled: null),
      );
    }
  }

  void _disableSelected(Set<GestureSelection> selected) {
    final notifier = ref.read(configControllerProvider.notifier);
    for (final s in selected) {
      notifier.updateGestureCommonForDevice(
        s.device,
        s.index,
        (c) => c.copyWith(enabled: false),
      );
    }
  }

  void _deleteSelected(Set<GestureSelection> selected) {
    final byDevice = <DeviceType, List<int>>{};
    for (final s in selected) {
      byDevice.putIfAbsent(s.device, () => []).add(s.index);
    }
    final notifier = ref.read(configControllerProvider.notifier);
    for (final entry in byDevice.entries) {
      final indices = entry.value..sort();
      for (final i in indices.reversed) {
        notifier.removeGestureForDevice(entry.key, i);
      }
    }
    context.clearGestureSelection();
    ref.read(multiSelectControllerProvider.notifier).exit();
  }

  void _updateSelectedGesture(
    DeviceType device,
    int index,
    Object Function(Object) transform,
  ) {
    final notifier = ref.read(configControllerProvider.notifier);
    switch (device) {
      case DeviceType.mouse:
        notifier.updateMouseGesture(index, (g) => transform(g) as MouseGesture);
      case DeviceType.keyboard:
        notifier.updateKeyboardGesture(
          index,
          (g) => transform(g) as KeyboardGesture,
        );
      case DeviceType.pointer:
        notifier.updatePointerGesture(
          index,
          (g) => transform(g) as PointerGesture,
        );
      case DeviceType.touchpad:
        notifier.updateTouchpadGesture(
          index,
          (g) => transform(g) as TouchpadGesture,
        );
      case DeviceType.touchscreen:
        notifier.updateTouchscreenGesture(
          index,
          (g) => transform(g) as TouchscreenGesture,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev == next) return;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted || !_scrollController.hasClients) return;
        await _scrollController.animateTo(
          0,
          duration: Durations.medium1,
          curve: Easing.standard,
        );
      });
    });

    final multiSelect = ref.watch(multiSelectControllerProvider);
    final config = ref.watch(configControllerProvider).value;

    if (multiSelect != null) {
      final selectedEnabledStates = [
        if (config != null)
          for (final selection in multiSelect)
            if (selection.index <
                config.gesturesForDevice(selection.device).length)
              gestureCommon(
                    config.gesturesForDevice(selection.device)[selection.index]
                        as Object,
                  ).enabled !=
                  false,
      ];
      final canDisable = selectedEnabledStates.any((isEnabled) => isEnabled);
      final canEnable = selectedEnabledStates.any((isEnabled) => !isEnabled);

      return _MultiSelectPanel(
        count: multiSelect.length,
        canDisable: canDisable,
        canEnable: canEnable,
        onEnable: () => _enableSelected(multiSelect),
        onDisable: () => _disableSelected(multiSelect),
        onDelete: () => _deleteSelected(multiSelect),
      );
    }

    final selection = ref.watch(selectedGestureProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (selection == null || config == null) {
      return Center(
        child: Text(
          'Select a gesture to edit',
          style: typography.sm.copyWith(color: colors.mutedForeground),
        ),
      );
    }

    final gestures = config.gesturesForDevice(selection.device);
    if (selection.index >= gestures.length) {
      return Center(
        child: Text(
          'Select a gesture to edit',
          style: typography.sm.copyWith(color: colors.mutedForeground),
        ),
      );
    }

    final gesture = gestures[selection.index] as Object;
    final common = gestureCommon(gesture);
    final name = (common.name?.isNotEmpty ?? false)
        ? common.name!
        : gestureTypeLabel(gesture);
    final subtitle =
        '${gestureTypeLabel(gesture)} '
        '· ${gestureDeviceLabel(selection.device)}';
    final isEnabled = common.effectiveEnabled;

    final editor = ScrollbarMediaPadding(
      topInset: GrowingFrostedHeaderDelegate.maxHeight,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GrowingFrostedHeaderDelegate(
              titleBuilder: (style) =>
                  _RenameableTitle(name: name, titleStyle: style),
              subtitle: subtitle,
              trailing: _GestureHeaderMenu(
                isEnabled: isEnabled,
                onToggleEnabled: () => ref
                    .read(configControllerProvider.notifier)
                    .updateGestureCommonForDevice(
                      selection.device,
                      selection.index,
                      (c) => c.copyWith(enabled: isEnabled ? false : null),
                    ),
                onResetDefaults: () => _updateSelectedGesture(
                  selection.device,
                  selection.index,
                  resetGestureToDefaults,
                ),
                onDuplicate: () {
                  ref
                      .read(configControllerProvider.notifier)
                      .duplicateGestureForDevice(
                        selection.device,
                        selection.index,
                      );
                  context.selectGesture(
                    selection.device,
                    selection.index + 1,
                  );
                },
                onCopyYaml: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: gestureYamlSnippet(
                        device: selection.device,
                        gesture: gesture,
                      ),
                    ),
                  );
                  if (!context.mounted) return;
                  showFToast(
                    context: context,
                    title: const Text('Gesture YAML copied.'),
                    suffixBuilder: (context, entry) => FButton.icon(
                      onPress: entry.dismiss,
                      child: const Icon(FLucideIcons.x),
                    ),
                    duration: const Duration(seconds: 3),
                  );
                },
                onDelete: () {
                  context.clearGestureSelection();
                  ref
                      .read(configControllerProvider.notifier)
                      .removeGestureForDevice(
                        selection.device,
                        selection.index,
                      );
                },
              ),
              horizontalPadding: 16,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverSmartAnchor(
              controller: _anchorController,
              scrollPosition: () => _scrollController.hasClients
                  ? _scrollController.position
                  : null,
              child: ScrollAnchorScope(
                controller: _anchorController,
                child: _buildEditor(
                  key: ValueKey('${selection.device.name}:${selection.index}'),
                  device: selection.device,
                  index: selection.index,
                  gesture: gesture,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Per-gesture undo/redo, scoped to the editor's focus subtree. Ctrl+Z while
    // focus is inside a text field is handled natively by that field; elsewhere
    // in the editor it walks this gesture's history.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): _UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): _RedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              ref
                  .read(configControllerProvider.notifier)
                  .undoActiveGesture(selection.device, selection.index);
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              ref
                  .read(configControllerProvider.notifier)
                  .redoActiveGesture(selection.device, selection.index);
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: _undoFocusNode,
          autofocus: true,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _undoFocusNode.requestFocus,
            child: editor,
          ),
        ),
      ),
    );
  }
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildEditor({
  required Key key,
  required DeviceType device,
  required int index,
  required Object gesture,
}) => switch (device) {
  DeviceType.mouse => MouseGestureEditor(
    key: key,
    index: index,
    gesture: gesture as MouseGesture,
  ),
  DeviceType.keyboard => KeyboardGestureEditor(
    key: key,
    index: index,
    gesture: gesture as KeyboardGesture,
  ),
  DeviceType.pointer => PointerGestureEditor(
    key: key,
    index: index,
    gesture: gesture as PointerGesture,
  ),
  DeviceType.touchpad => TouchpadGestureEditor(
    key: key,
    index: index,
    gesture: gesture as TouchpadGesture,
  ),
  DeviceType.touchscreen => TouchscreenGestureEditor(
    key: key,
    index: index,
    gesture: gesture as TouchscreenGesture,
  ),
};

class _MultiSelectPanel extends StatelessWidget {
  const _MultiSelectPanel({
    required this.count,
    required this.canDisable,
    required this.canEnable,
    required this.onEnable,
    required this.onDisable,
    required this.onDelete,
  });

  final int count;
  final bool canDisable;
  final bool canEnable;
  final VoidCallback onEnable;
  final VoidCallback onDisable;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count gesture${count == 1 ? '' : 's'} selected',
            style: typography.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FButton(
                variant: .outline,
                onPress: canEnable ? onEnable : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FLucideIcons.eye),
                    SizedBox(width: 6),
                    Text('Enable'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .outline,
                onPress: canDisable ? onDisable : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FLucideIcons.eyeOff),
                    SizedBox(width: 6),
                    Text('Disable'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .destructive,
                onPress: onDelete,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FLucideIcons.trash),
                    SizedBox(width: 6),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _RenameableTitle extends ConsumerStatefulWidget {
  const _RenameableTitle({required this.name, required this.titleStyle});

  final String name;
  final TextStyle? titleStyle;

  @override
  ConsumerState<_RenameableTitle> createState() => _RenameableTitleState();
}

class _RenameableTitleState extends ConsumerState<_RenameableTitle> {
  bool _isRenaming = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isRenaming) {
      setState(() => _isRenaming = false);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startRename() {
    _controller.text = widget.name;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.name.length,
    );
    setState(() => _isRenaming = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _doConfirm() {
    final text = _controller.text.trim();
    setState(() => _isRenaming = false);
    final selection = ref.read(selectedGestureProvider);
    if (selection == null) return;
    ref
        .read(configControllerProvider.notifier)
        .updateGestureCommonForDevice(
          selection.device,
          selection.index,
          (c) => c.copyWith(name: text.isEmpty ? null : text),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev != next && _isRenaming) setState(() => _isRenaming = false);
    });

    if (_isRenaming) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FTextField(
                control: FTextFieldControl.managed(controller: _controller),
                focusNode: _focusNode,
                hint: 'Name',
                onSubmit: (_) => _doConfirm(),
              ),
            ),
            const SizedBox(width: 8),
            FButton.icon(
              onPress: _doConfirm,
              size: .sm,
              child: const Icon(FLucideIcons.check),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: _startRename,
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Text(
                widget.name,
                style: widget.titleStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FButton.icon(
          variant: .ghost,
          size: .xs,
          onPress: _startRename,
          child: const Icon(FLucideIcons.pencil),
        ),
      ],
    );
  }
}

class _GestureHeaderMenu extends StatelessWidget {
  const _GestureHeaderMenu({
    required this.isEnabled,
    required this.onToggleEnabled,
    required this.onResetDefaults,
    required this.onDuplicate,
    required this.onCopyYaml,
    required this.onDelete,
  });

  final bool isEnabled;
  final VoidCallback onToggleEnabled;
  final VoidCallback onResetDefaults;
  final VoidCallback onDuplicate;
  final Future<void> Function() onCopyYaml;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return FPopover(
      builder: (context, controller, child) => FButton(
        variant: .outline,
        size: .sm,
        onPress: controller.toggle,
        child: child,
      ),
      popoverBuilder: (context, controller) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
        child: FItemGroup(
          children: [
            FItem(
              prefix: Icon(isEnabled ? Icons.visibility_off : Icons.visibility),
              title: Text(isEnabled ? 'Disable' : 'Enable'),
              onPress: () async {
                await controller.hide();
                onToggleEnabled();
              },
            ),
            FItem(
              prefix: const Icon(Icons.restart_alt),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Reset To Defaults'),
                  const SizedBox(width: 6),
                  AppTooltip(
                    tipBuilder: (context, _) => const Text(
                      resetGestureDefaultsTooltip,
                    ),
                    child: const Icon(Icons.info_outline, size: 14),
                  ),
                ],
              ),
              onPress: () async {
                await controller.hide();
                onResetDefaults();
              },
            ),
            FItem(
              prefix: const Icon(Icons.copy_all),
              title: const Text('Duplicate'),
              onPress: () async {
                await controller.hide();
                onDuplicate();
              },
            ),
            FItem(
              prefix: const Icon(Icons.content_copy),
              title: const Text('Copy YAML'),
              onPress: () async {
                await controller.hide();
                await onCopyYaml();
              },
            ),
            FItem(
              variant: FItemVariant.destructive,
              prefix: const Icon(Icons.delete_outline),
              title: const Text('Delete'),
              onPress: () async {
                await controller.hide();
                onDelete();
              },
            ),
          ],
        ),
      ),
      child: const Icon(Icons.menu),
    );
  }
}
