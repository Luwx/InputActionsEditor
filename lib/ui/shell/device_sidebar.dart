import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/config_controller.dart';
import 'package:input_actions_editor/state/navigation/nav_controller.dart';
import 'package:input_actions_editor/ui/features/gestures/gesture_support.dart';

class DeviceSidebar extends ConsumerStatefulWidget {
  const DeviceSidebar({super.key});

  @override
  ConsumerState<DeviceSidebar> createState() => _DeviceSidebarState();
}

class _DeviceSidebarState extends ConsumerState<DeviceSidebar> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Navigates to [device] filter, auto-selecting the first gesture so there
  /// is no intermediate frame with an empty selection.
  void _goToDevice(DeviceType? device) {
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

  @override
  Widget build(BuildContext context) {
    final deviceFilter = ref.watch(deviceFilterProvider);
    final currentView = ref.watch(currentViewProvider);
    final isGestures = currentView == AppView.gestures;
    ref.watch(configControllerProvider);
    final canDiscard =
        ref.read(configControllerProvider.notifier).isDirty &&
        ref.read(configControllerProvider.notifier).savedConfig != null;

    return FSidebar.raw(
      style: const .delta(
        constraints: BoxConstraints(maxWidth: 180),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Editor',
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
                                  title: const Text('Load'),
                                  onPress: () => ref
                                      .read(configControllerProvider.notifier)
                                      .loadFromPicker(),
                                ),
                                .item(
                                  prefix: const Icon(FLucideIcons.save),
                                  title: const Text('Save'),
                                  onPress: () async {
                                    await controller.hide();
                                    await ref
                                        .read(configControllerProvider.notifier)
                                        .save();
                                  },
                                ),
                                .item(
                                  prefix: const Icon(FLucideIcons.undo2),
                                  title: const Text('Discard changes'),
                                  enabled: canDiscard,
                                  onPress: canDiscard
                                      ? () async {
                                          await controller.hide();
                                          ref
                                              .read(
                                                configControllerProvider
                                                    .notifier,
                                              )
                                              .discardChanges();
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
                    label: const Text('Device Gestures'),
                    children: [
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.list),
                        label: const Text('All'),
                        selected: isGestures && deviceFilter == null,
                        onPress: () => _goToDevice(null),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.mouse),
                        label: const Text('Mouse'),
                        selected: isGestures && deviceFilter == .mouse,
                        onPress: () => _goToDevice(DeviceType.mouse),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.mousePointer2),
                        label: const Text('Pointer'),
                        selected: isGestures && deviceFilter == .pointer,
                        onPress: () => _goToDevice(DeviceType.pointer),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.keyboard),
                        label: const Text('Keyboard'),
                        selected: isGestures && deviceFilter == .keyboard,
                        onPress: () => _goToDevice(DeviceType.keyboard),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.touchpad),
                        label: const Text('Touchpad'),
                        selected: isGestures && deviceFilter == .touchpad,
                        onPress: () => _goToDevice(DeviceType.touchpad),
                      ),
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.monitor),
                        label: const Text('Touchscreen'),
                        selected: isGestures && deviceFilter == .touchscreen,
                        onPress: () => _goToDevice(DeviceType.touchscreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FSidebarGroup(
                    children: [
                      FSidebarItem(
                        icon: const Icon(FLucideIcons.history),
                        label: const Text('History'),
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
                label: const Text('Settings'),
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
