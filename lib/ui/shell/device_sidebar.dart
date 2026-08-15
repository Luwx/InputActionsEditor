import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app_router.dart';
import 'package:input_actions_editor/app_state/navigation/app_destination.dart';
import 'package:input_actions_editor/app_state/navigation/nav_controller.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/menu_shortcut_hint.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/shell/document_actions.dart';

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
    final canSave = ref.watch(isDirtyProvider);

    void goToDevice(DeviceType? device) {
      final currentView = ref.read(currentViewProvider);
      final currentFilter = ref.read(deviceFilterProvider);
      final changingFilter =
          currentView != AppView.gestures || currentFilter != device;

      if (changingFilter) {
        final config = ref.read(configControllerProvider).value?.draft;
        final first = config == null
            ? null
            : firstGestureForFilter(config, device);
        if (first != null) {
          context.goToGesturesSelectFirst(filter: device, location: first);
          return;
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
                              'Input Actions',
                              style: context.theme.typography.body.lg.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Editor',
                              style: context.theme.typography.body.xs.copyWith(
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
                          menuBuilder: (context, controller, _) =>
                              _fileMenuItems(
                                l10n: l10n,
                                controller: controller,
                                rootContext: rootContext,
                                ref: ref,
                                configController: configController,
                                canSave: canSave,
                                canDiscard: canDiscard,
                              ),
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

List<FItemGroupMixin> _fileMenuItems({
  required AppLocalizations l10n,
  required FPopoverController controller,
  required BuildContext rootContext,
  required WidgetRef ref,
  required ConfigController configController,
  required bool canSave,
  required bool canDiscard,
}) {
  return [
    FItemGroup(
      children: [
        FItem(
          title: Text(l10n.actionNew),
          prefix: const Icon(FLucideIcons.filePlus2),
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyN,
              control: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            if (!rootContext.mounted) return;
            await newConfigDocument(rootContext, ref);
          },
        ),
        FItem(
          title: Text(l10n.actionLoad),
          prefix: const Icon(FLucideIcons.folderOpen),
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyO,
              control: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            if (!rootContext.mounted) return;
            await loadConfigDocument(rootContext, ref);
          },
        ),
        FItem(
          title: Text(l10n.actionLoadFromClipboard),
          prefix: const Icon(FLucideIcons.clipboard),
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyV,
              control: true,
              shift: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            if (!rootContext.mounted) return;
            await loadConfigFromClipboard(rootContext, ref);
          },
        ),
      ],
    ),
    FItemGroup(
      children: [
        FItem(
          title: Text(l10n.actionSave),
          prefix: const Icon(FLucideIcons.save),
          enabled: canSave,
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyS,
              control: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            await configController.save();
            if (!rootContext.mounted) return;
            showFToast(
              context: rootContext,
              title: Text(l10n.configSaveSuccess),
              suffixBuilder: (context, entry) => FButton.icon(
                onPress: entry.dismiss,
                child: const Icon(FLucideIcons.x),
              ),
              duration: const Duration(seconds: 3),
            );
          },
        ),
        FItem(
          title: Text(l10n.actionSaveAs),
          prefix: const Icon(FLucideIcons.save),
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyS,
              control: true,
              shift: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            await configController.saveAs();
          },
        ),
        FItem(
          title: Text(l10n.actionCopyToClipboard),
          prefix: const Icon(FLucideIcons.clipboardCopy),
          details: const MenuShortcutHint(
            SingleActivator(
              LogicalKeyboardKey.keyC,
              control: true,
              alt: true,
            ),
          ),
          onPress: () async {
            await controller.hide();
            if (!rootContext.mounted) return;
            await copyConfigToClipboard(rootContext, configController);
          },
        ),
        FItem(
          title: Text(l10n.actionDiscardChanges),
          prefix: const Icon(FLucideIcons.undo2),
          enabled: canDiscard,
          onPress: () async {
            await controller.hide();
            configController.discardChanges();
          },
        ),
      ],
    ),
  ];
}
