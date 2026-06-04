import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class DeviceSidebar extends HookConsumerWidget {
  const DeviceSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    final l10n = context.l10n;
    // Stable context for dialogs opened from the popover menu: the menu
    // builder's own context is torn down when the popover closes.
    final rootContext = context;

    final deviceFilter = ref.watch(deviceFilterProvider);
    final currentView = ref.watch(currentViewProvider);
    final isGestures = currentView == AppView.gestures;
    final configController = ref.read(configControllerProvider.notifier);
    // Only rebuilds when discardability flips, not on every edit.
    final canDiscard = ref.watch(canDiscardChangesProvider);

    void goToDevice(DeviceType? device) {
      final currentView = ref.read(currentViewProvider);
      final currentFilter = ref.read(deviceFilterProvider);
      final changingFilter =
          currentView != AppView.gestures || currentFilter != device;

      if (changingFilter) {
        final config = ref.read(configControllerProvider).value;
        if (config != null) {
          final first = firstGestureForFilter(config, device);
          if (first != null) {
            context.goToGesturesSelectFirst(
              filter: device,
              device: first.device,
              index: first.index,
            );
            return;
          }
        }
      }

      context.goToGestures(device: device);
    }

    return FSidebar.raw(
      style: const .delta(
        constraints: BoxConstraints(maxWidth: 180),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.appName,
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.appSubtitle,
                              style: context.theme.typography.xs.copyWith(
                                color: context.theme.colors.mutedForeground,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.8,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FPopoverMenu(
                          menuAnchor: .topRight,
                          childAnchor: .bottomLeft,
                          menuBuilder: (context, controller, _) => [
                            .group(
                              children: [
                                .item(
                                  prefix: const Icon(FLucideIcons.folderOpen),
                                  title: Text(l10n.actionLoad),
                                  onPress: () async {
                                    await controller.hide();
                                    if (!rootContext.mounted) return;
                                    await _loadConfigDocument(rootContext, ref);
                                  },
                                ),
                                .item(
                                  prefix: const Icon(FLucideIcons.save),
                                  title: Text(l10n.actionSave),
                                  onPress: () async {
                                    await controller.hide();
                                    await configController.save();
                                  },
                                ),
                                .item(
                                  prefix: const Icon(FLucideIcons.undo2),
                                  title: Text(l10n.actionDiscardChanges),
                                  enabled: canDiscard,
                                  onPress: canDiscard
                                      ? () async {
                                          await controller.hide();
                                          configController.discardChanges();
                                        }
                                      : null,
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
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 8),
                  const SizedBox(height: 4),
                  FSidebarGroup(
                    label: Text(l10n.sidebarDeviceGesturesGroup),
                    children: [
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.list),
                        label: Text(l10n.sidebarAllDevices),
                        selected: isGestures && deviceFilter == null,
                        onPress: () => goToDevice(null),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.mouse),
                        label: Text(l10n.deviceTypeMouse),
                        selected: isGestures && deviceFilter == .mouse,
                        onPress: () => goToDevice(DeviceType.mouse),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.mousePointer2),
                        label: Text(l10n.deviceTypePointer),
                        selected: isGestures && deviceFilter == .pointer,
                        onPress: () => goToDevice(DeviceType.pointer),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.keyboard),
                        label: Text(l10n.deviceTypeKeyboard),
                        selected: isGestures && deviceFilter == .keyboard,
                        onPress: () => goToDevice(DeviceType.keyboard),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.touchpad),
                        label: Text(l10n.deviceTypeTouchpad),
                        selected: isGestures && deviceFilter == .touchpad,
                        onPress: () => goToDevice(DeviceType.touchpad),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.monitor),
                        label: Text(l10n.deviceTypeTouchscreen),
                        selected: isGestures && deviceFilter == .touchscreen,
                        onPress: () => goToDevice(DeviceType.touchscreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FSidebarGroup(
                    children: [
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.history),
                        label: Text(l10n.navHistory),
                        selected: currentView == AppView.history,
                        onPress: context.goToHistory,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          FSidebarGroup(
            children: [
              FSidebarItem(
                icon: const Icon(FLucideIcons.cog),
                label: Text(l10n.navSettings),
                selected: currentView == AppView.settings,
                onPress: context.openSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Loads a new config document, replacing the current one.
///
/// If the draft has unsaved changes the user is warned first and may apply,
/// discard, or cancel. On confirmation the navigation stack is reset (closing
/// every open editor before the new document arrives, so none is left bound to
/// a now-stale positional location) and the undo history is dropped inside
/// [ConfigController.loadFromFile].
Future<void> _loadConfigDocument(BuildContext context, WidgetRef ref) async {
  final configController = ref.read(configControllerProvider.notifier);

  if (configController.isDirty) {
    final action = await showUnsavedChangesDialog(context);
    if (action == null) return; // cancelled
    if (action == UnsavedChangesAction.apply) {
      await configController.save();
    }
    // discard: the load below overwrites the unsaved draft.
  }

  await configController.loadFromPicker(
    onBeforeLoad: () => ref.read(navProvider.notifier).reset(),
  );
}
