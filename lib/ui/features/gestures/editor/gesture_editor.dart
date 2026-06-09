import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/app_tooltip.dart';
import 'package:input_actions_editor/ui/common/extensions.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/sliver_smart_anchor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/keyboard_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/pointer_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchpad_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchscreen_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_actions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/widgets/renameable_title.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';
import 'package:scroll_animator/scroll_animator.dart';

class GestureDetailSection extends ConsumerWidget {
  const GestureDetailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multiSelect = ref.watch(multiSelectControllerProvider);
    if (multiSelect != null) {
      return _MultiSelectPanel(selected: multiSelect);
    }

    final location = ref.watch(selectedGestureProvider);
    if (location == null) {
      return const _GestureSelectPrompt();
    }

    return _GestureEditorView(location: location);
  }
}

class _GestureEditorView extends HookConsumerWidget {
  const _GestureEditorView({required this.location});

  final GestureLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useMemoized(
      () => AnimatedScrollController(
        animationFactory: const ChromiumEaseInOut(),
      ),
    );
    useEffect(() => scrollController.dispose, const []);
    final anchorController = useMemoized(ScrollAnchorController.new);
    final addActionHeaderKey = useMemoized(GlobalKey.new);
    final addActionCallbackRef = useRef<Future<void> Function()?>(null);
    final addActionVisible = useState(false);
    final tickerProvider = useSingleTickerProvider();
    final undoFocusNode = useFocusNode(debugLabel: 'gestureEditorUndo');

    useEffect(() {
      final ticker = tickerProvider.createTicker((_) {
        final ctx = addActionHeaderKey.currentContext;
        if (ctx == null) return;
        final renderBox = ctx.findRenderObject() as RenderBox?;
        if (renderBox == null || !renderBox.attached || !renderBox.hasSize) {
          return;
        }
        final bottom =
            renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height;
        final hidden = bottom < GrowingFrostedHeaderDelegate.minHeight;
        if (addActionVisible.value != hidden) addActionVisible.value = hidden;
      });
      unawaited(ticker.start());
      return ticker.dispose;
    }, const []);

    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev == next) return;
      addActionVisible.value = false;
      // WidgetsBinding.instance.addPostFrameCallback((_) async {
      //   if (!scrollController.hasClients) return;
      //   await scrollController.animateTo(
      //     0,
      //     duration: Durations.medium1,
      //     curve: Easing.standard,
      //   );
      // });
    });

    final l10n = context.l10n;
    final header = ref.watch(
      gestureEditorProvider(location).select((state) {
        final gesture = state.gesture;
        if (gesture == null) return null;
        final common = gesture.common;
        final typeLabel = gestureTypeLabel(gesture, l10n);
        return (
          name: (common.name?.isNotEmpty ?? false) ? common.name! : typeLabel,
          subtitle: '$typeLabel · ${gestureDeviceLabel(location.device, l10n)}',
          isEnabled: common.effectiveEnabled,
        );
      }),
    );

    // The selected gesture was removed (e.g. deleted or undone) while this view
    // was still mounted.
    if (header == null) {
      return const _GestureSelectPrompt();
    }

    final gestureEditor = ref.read(gestureEditorProvider(location).notifier);

    final editor = ScrollbarMediaPadding(
      topInset: GrowingFrostedHeaderDelegate.maxHeight,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: GrowingFrostedHeaderDelegate(
              titleBuilder: (style) => RenameableTitle(
                name: header.name,
                titleStyle: style,
                onRename: gestureEditor.rename,
              ),
              subtitle: header.subtitle,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FButton(
                    key: const ValueKey('add-action'),
                    variant: .ghost,
                    size: .sm,
                    onPress: () => addActionCallbackRef.value?.call(),
                    prefix: const Icon(FLucideIcons.plus),
                    child: Text(context.l10n.addAction),
                  ).appearToggle(
                    visible: addActionVisible.value,
                    axis: Axis.horizontal,
                    slideFactor: 0.8,
                    duration: Durations.short4,
                  ),
                  _GestureHeaderMenu(
                    isEnabled: header.isEnabled,
                    onToggleEnabled: () =>
                        gestureEditor.setEnabled(!header.isEnabled),
                    onResetDefaults: () {
                      final gesture = ref
                          .read(gestureEditorProvider(location))
                          .gesture;
                      if (gesture != null) {
                        gestureEditor.resetDefaults(gesture);
                      }
                    },
                    onDuplicate: () {
                      gestureEditor.duplicate();
                      context.selectGesture(
                        location.device,
                        location.index + 1,
                      );
                    },
                    onCopyYaml: () async {
                      final gesture = ref
                          .read(gestureEditorProvider(location))
                          .gesture;
                      if (gesture == null) return;
                      await Clipboard.setData(
                        ClipboardData(
                          text: gestureYamlSnippet(
                            device: location.device,
                            gesture: gesture,
                          ),
                        ),
                      );
                      if (!context.mounted) return;
                      showFToast(
                        context: context,
                        title: Text(context.l10n.gestureCopyYamlSuccess),
                        suffixBuilder: (context, entry) => FButton.icon(
                          onPress: entry.dismiss,
                          child: const Icon(FLucideIcons.x),
                        ),
                        duration: const Duration(seconds: 3),
                      );
                    },
                    onDelete: () {
                      context.clearGestureSelection();
                      gestureEditor.delete();
                    },
                  ),
                ],
              ),
              horizontalPadding: 16,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverSmartAnchor(
              controller: anchorController,
              scrollPosition: () => scrollController.hasClients
                  ? scrollController.position
                  : null,
              child: ScrollAnchorScope(
                controller: anchorController,
                child: AddActionScope(
                  headerKey: addActionHeaderKey,
                  callbackRef: addActionCallbackRef,
                  child: _GestureEditorBody(location: location),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): _UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              gestureEditor.undo();
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              gestureEditor.redo();
              return null;
            },
          ),
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) async {
              final isDirty =
                  ref.read(configControllerProvider).value?.isDirty ?? false;
              if (!isDirty) return null;
              await ref.read(configControllerProvider.notifier).save();
              if (!context.mounted) return null;
              showFToast(
                context: context,
                title: Text(context.l10n.configSaveSuccess),
                suffixBuilder: (context, entry) => FButton.icon(
                  onPress: entry.dismiss,
                  child: const Icon(FLucideIcons.x),
                ),
                duration: const Duration(seconds: 3),
              );
              return null;
            },
          ),
        },
        child: Focus(
          focusNode: undoFocusNode,
          autofocus: true,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: undoFocusNode.requestFocus,
            child: editor,
          ),
        ),
      ),
    );
  }
}

class _GestureEditorBody extends StatelessWidget {
  const _GestureEditorBody({required this.location});

  final GestureLocation location;

  @override
  Widget build(BuildContext context) {
    final key = ValueKey('${location.device.name}:${location.index}');
    return switch (location.device) {
      DeviceType.mouse => MouseGestureEditor(key: key, index: location.index),
      DeviceType.keyboard => KeyboardGestureEditor(
        key: key,
        index: location.index,
      ),
      DeviceType.pointer => PointerGestureEditor(
        key: key,
        index: location.index,
      ),
      DeviceType.touchpad => TouchpadGestureEditor(
        key: key,
        index: location.index,
      ),
      DeviceType.touchscreen => TouchscreenGestureEditor(
        key: key,
        index: location.index,
      ),
    };
  }
}

class _GestureSelectPrompt extends StatelessWidget {
  const _GestureSelectPrompt();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    return Center(
      child: Text(
        context.l10n.gestureSelectPrompt,
        style: typography.sm.copyWith(color: colors.mutedForeground),
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

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _MultiSelectPanel extends ConsumerWidget {
  const _MultiSelectPanel({required this.selected});

  final Set<GestureLocation> selected;

  void _enable(WidgetRef ref) {
    ref.read(gestureCommandsProvider).enableGestures(selected);
  }

  void _disable(WidgetRef ref) {
    ref.read(gestureCommandsProvider).disableGestures(selected);
  }

  void _delete(BuildContext context, WidgetRef ref) {
    final byDevice = <DeviceType, List<int>>{};
    for (final s in selected) {
      byDevice.putIfAbsent(s.device, () => []).add(s.index);
    }
    final listNotifier = ref.read(gestureCommandsProvider);
    for (final entry in byDevice.entries) {
      final indices = entry.value..sort();
      for (final i in indices.reversed) {
        listNotifier.removeGesture(entry.key, i);
      }
    }
    context.clearGestureSelection();
    ref.read(multiSelectControllerProvider.notifier).exit();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (:canEnable, :canDisable) = ref.watch(
      configControllerProvider.select((state) {
        final config = state.requireValue.draft;
        var canEnable = false;
        var canDisable = false;
        for (final sel in selected) {
          final gestures = config.gesturesForDevice(sel.device);
          if (sel.index < 0 || sel.index >= gestures.length) continue;
          final isEnabled = gestures[sel.index].common.enabled != false;
          if (isEnabled) {
            canDisable = true;
          } else {
            canEnable = true;
          }
        }
        return (canEnable: canEnable, canDisable: canDisable);
      }),
    );

    final typography = context.theme.typography;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.multiSelectCount(selected.length),
            style: typography.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FButton(
                variant: .outline,
                onPress: canEnable ? () => _enable(ref) : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FLucideIcons.eye),
                    const SizedBox(width: 6),
                    Text(context.l10n.actionEnable),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .outline,
                onPress: canDisable ? () => _disable(ref) : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FLucideIcons.eyeOff),
                    const SizedBox(width: 6),
                    Text(context.l10n.actionDisable),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .destructive,
                onPress: () => _delete(context, ref),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FLucideIcons.trash),
                    const SizedBox(width: 6),
                    Text(context.l10n.actionDelete),
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
    return FPopoverMenu(
      menuAnchor: .topLeft,
      childAnchor: .bottomRight,
      menuBuilder: (context, controller, _) => [
        .group(
          children: [
            .item(
              prefix: Icon(isEnabled ? Icons.visibility_off : Icons.visibility),
              title: Text(
                isEnabled
                    ? context.l10n.gestureMenuDisable
                    : context.l10n.gestureMenuEnable,
              ),
              onPress: () async {
                await controller.hide();
                onToggleEnabled();
              },
            ),
            .item(
              prefix: const Icon(Icons.restart_alt),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.gestureMenuResetToDefaults),
                  const SizedBox(width: 6),
                  AppTooltip(
                    tipBuilder: (context, _) => Text(
                      context.l10n.resetGestureDefaultsTooltip,
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
            .item(
              prefix: const Icon(Icons.copy_all),
              title: Text(context.l10n.gestureMenuDuplicate),
              onPress: () async {
                await controller.hide();
                onDuplicate();
              },
            ),
            .item(
              prefix: const Icon(FLucideIcons.code),
              title: Text(context.l10n.gestureMenuCopyYaml),
              onPress: () async {
                await controller.hide();
                await onCopyYaml();
              },
            ),
            .item(
              variant: FItemVariant.destructive,
              prefix: const Icon(Icons.delete_outline),
              title: Text(context.l10n.gestureMenuDelete),
              onPress: () async {
                await controller.hide();
                onDelete();
              },
            ),
          ],
        ),
      ],
      builder: (context, controller, _) => FButton.icon(
        variant: .ghost,
        size: .sm,
        onPress: controller.toggle,
        child: const Icon(FLucideIcons.menu, size: 13),
      ),
    );
  }
}
