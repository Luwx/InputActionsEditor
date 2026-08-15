import 'dart:async' show unawaited;

import 'package:animations/animations.dart';
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
import 'package:input_actions_editor/ui/debug/print_build.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/action_list_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/bulk_edit_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/state/bulk_edit_active_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/keyboard_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/mouse_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/pointer_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchpad_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/devices/touchscreen_gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor_actions.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/gesture_editor_notifier.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/selected_group_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/gesture_commands.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/widgets/renameable_title.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/l10n/labels/gesture_labels.dart';
import 'package:scroll_animator/scroll_animator.dart';

// Flip to enable the magnetic float-and-dock add button. Off = app bar mirror
// only, no floating button.
const bool _dockingAddButton = false;

class GestureDetailSection extends ConsumerWidget {
  const GestureDetailSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    printBuild(1, 'gestureDetailSection build');
    ref.listen(multiSelectControllerProvider, (prev, next) {
      if (next == null) ref.read(bulkEditActiveProvider.notifier).close();
    });

    final multiSelect = ref.watch(multiSelectControllerProvider);
    if (multiSelect != null) {
      final bulkActive = ref.watch(bulkEditActiveProvider);
      final showBulk = bulkActive && multiSelect.isNotEmpty;
      return PageTransitionSwitcher(
        reverse: !showBulk,
        transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
          animation: primary,
          secondaryAnimation: secondary,
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: Colors.transparent,
          child: child,
        ),
        child: showBulk
            ? BulkEditView(
                key: const ValueKey('bulk-edit'),
                selected: multiSelect,
              )
            : _MultiSelectPanel(
                key: const ValueKey('multi-select-panel'),
                selected: multiSelect,
              ),
      );
    }

    final group = ref.watch(selectedGroupProvider);
    if (group != null) {
      return GroupSettingsView(key: ValueKey(group), location: group);
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
    printBuild(2, 'gestureEditorView build');
    final scrollController = useMemoized(
      () => AnimatedScrollController(
        animationFactory: const ChromiumEaseInOut(),
      ),
    );
    useEffect(() => scrollController.dispose, const []);
    final anchorController = useMemoized(ScrollAnchorController.new);
    final addActionHeaderKey = useMemoized(GlobalKey.new);
    final addActionButtonKey = useMemoized(GlobalKey.new);
    final editorKey = useMemoized(GlobalKey.new);
    final addActionCallbackRef = useRef<Future<void> Function()?>(null);
    // Mirror the add button in the app bar once it scrolls behind the header.
    final addActionInAppBar = useState(false);
    // Floating add button placement, or null while docked in the inline slot.
    final addActionFloating = useValueNotifier<AddActionFloatingPlacement?>(
      null,
    );
    final tickerProvider = useSingleTickerProvider();
    final undoFocusNode = useFocusNode(debugLabel: 'gestureEditorUndo');

    useEffect(() {
      final ticker = tickerProvider.createTicker((_) {
        final editorBox =
            editorKey.currentContext?.findRenderObject() as RenderBox?;
        if (editorBox == null || !editorBox.attached || !editorBox.hasSize) {
          return;
        }
        final origin = editorBox.localToGlobal(Offset.zero);

        // App bar mirror: the inline slot scrolled up behind the header.
        final headerBox =
            addActionHeaderKey.currentContext?.findRenderObject() as RenderBox?;
        if (headerBox != null && headerBox.attached && headerBox.hasSize) {
          final headerBottom =
              headerBox.localToGlobal(Offset.zero).dy + headerBox.size.height;
          final above =
              headerBottom < origin.dy + GrowingFrostedHeaderDelegate.minHeight;
          if (addActionInAppBar.value != above) addActionInAppBar.value = above;
        }

        if (!_dockingAddButton) return;

        // Float only while the slot sits below a line near the viewport bottom;
        // past it the inline button takes over and scrolls without lag.
        final buttonBox =
            addActionButtonKey.currentContext?.findRenderObject() as RenderBox?;
        if (buttonBox == null || !buttonBox.attached || !buttonBox.hasSize) {
          addActionFloating.value = null;
          return;
        }
        final btnOrigin = buttonBox.localToGlobal(Offset.zero);
        final dockTop = btnOrigin.dy - origin.dy;
        final floatLine = editorBox.size.height - buttonBox.size.height - 16;
        if (dockTop <= floatLine) {
          addActionFloating.value = null;
          return;
        }
        // Shadow grows with depth and fades to nothing at the dock line.
        final next = (
          left: btnOrigin.dx - origin.dx,
          width: buttonBox.size.width,
          shadow: ((dockTop - floatLine) / 24).clamp(0.0, 1.0),
        );
        if (addActionFloating.value != next) addActionFloating.value = next;
      });
      unawaited(ticker.start());
      return ticker.dispose;
    }, const []);

    ref.listen(selectedGestureProvider, (prev, next) {
      if (prev == next) return;
      addActionInAppBar.value = false;
      addActionFloating.value = null;
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
        key: editorKey,
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
                    visible: addActionInAppBar.value,
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
                      // The copy sits right after the original and only gets
                      // its editId once the edit lands, so its identity
                      // location is resolved from the updated draft.
                      final draft = ref
                          .read(configControllerProvider)
                          .value
                          ?.draft;
                      final index = gestureIndexOf(draft, location);
                      final copy = index == null
                          ? null
                          : gestureLocationAt(
                              draft,
                              location.device,
                              index + 1,
                            );
                      if (copy != null) context.selectGesture(copy);
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
                  buttonKey: addActionButtonKey,
                  floating: _dockingAddButton ? addActionFloating : null,
                  callbackRef: addActionCallbackRef,
                  child: _GestureEditorBody(location: location),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Without docking there's no floating button, so skip the overlay Stack.
    final editorBody = !_dockingAddButton
        ? editor
        : Stack(
            children: [
              editor,
              ValueListenableBuilder<AddActionFloatingPlacement?>(
                valueListenable: addActionFloating,
                builder: (context, placement, _) {
                  if (placement == null) return const SizedBox.shrink();
                  return Positioned(
                    bottom: 16,
                    left: placement.left,
                    width: placement.width,
                    child: _FloatingAddAction(
                      shadowOpacity: placement.shadow,
                      onPress: () => addActionCallbackRef.value?.call(),
                    ),
                  );
                },
              ),
            ],
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
            child: editorBody,
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
    printBuild(3, 'gestureEditorBody build');
    final key = ValueKey('${location.device.name}:${location.editId}');
    return switch (location.device) {
      DeviceType.mouse => MouseGestureEditor(key: key, location: location),
      DeviceType.keyboard => KeyboardGestureEditor(
        key: key,
        location: location,
      ),
      DeviceType.pointer => PointerGestureEditor(
        key: key,
        location: location,
      ),
      DeviceType.touchpad => TouchpadGestureEditor(
        key: key,
        location: location,
      ),
      DeviceType.touchscreen => TouchscreenGestureEditor(
        key: key,
        location: location,
      ),
    };
  }
}

/// Floating copy of the inline add button, shown while it's below the fold.
class _FloatingAddAction extends StatelessWidget {
  const _FloatingAddAction({
    required this.shadowOpacity,
    required this.onPress,
  });

  final double shadowOpacity;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: shadowOpacity <= 0
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22 * shadowOpacity),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: FButton(
        onPress: onPress,
        prefix: const Icon(FLucideIcons.plus, size: 14),
        child: Text(context.l10n.addAction),
      ),
    );
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
        style: typography.body.sm.copyWith(color: colors.mutedForeground),
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
  const _MultiSelectPanel({required this.selected, super.key});

  final Set<GestureLocation> selected;

  void _enable(WidgetRef ref) {
    ref.read(gestureCommandsProvider).enableGestures(selected);
  }

  void _disable(WidgetRef ref) {
    ref.read(gestureCommandsProvider).disableGestures(selected);
  }

  void _delete(BuildContext context, WidgetRef ref) {
    final listNotifier = ref.read(gestureCommandsProvider);
    selected.forEach(listNotifier.removeGesture);
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
          final gesture = gestureAt(config, sel);
          if (gesture == null) continue;
          final isEnabled = gesture.common.enabled != false;
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
    final l10n = context.l10n;

    // One unified toggle: while any selected gesture is enabled, the button
    // disables the whole selection; only when they're all disabled does it
    // switch to enabling.
    final canToggle = canEnable || canDisable;
    final enableAll = !canDisable;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.multiSelectCount(selected.length),
            style: typography.body.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FButton(
                variant: .outline,
                onPress: ref.read(bulkEditActiveProvider.notifier).open,
                prefix: const Icon(FLucideIcons.sliders),
                child: Text(l10n.bulkEdit),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .outline,
                onPress: canToggle
                    ? () => enableAll ? _enable(ref) : _disable(ref)
                    : null,
                prefix: Icon(
                  enableAll ? FLucideIcons.eye : FLucideIcons.eyeOff,
                ),
                child: Text(
                  enableAll ? l10n.actionEnable : l10n.actionDisable,
                ),
              ),
              const SizedBox(width: 12),
              FButton(
                variant: .destructive,
                onPress: () => _delete(context, ref),
                prefix: const Icon(FLucideIcons.trash),
                child: Text(l10n.actionDelete),
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
