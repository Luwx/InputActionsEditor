import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/state/app_router.dart';
import 'package:input_actions_editor/state/config_controller.dart';
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

  // TODO(me): hacky af, remove
  /// Computes the first visible gesture for [filter] in the same order as the
  /// flat gesture list (groups first, then ungrouped; All view: mouse,
  ///  keyboard, pointer, touchpad, touchscreen).
  ({DeviceType device, int index})? _firstGestureForFilter(
    Config config,
    DeviceType? filter,
  ) {
    if (filter != null) {
      final gestures = config.gesturesForDevice(filter);
      if (gestures.isEmpty) return null;

      final groups = config.groupsForDevice(filter);
      final groupIdSet = {for (final g in groups) g.id};

      final grouped = <String, List<int>>{};
      final ungrouped = <int>[];

      for (final (index, gesture) in gestures.indexed) {
        final groupId = gestureCommon(gesture as Object).groupId;
        if (groupId != null && groupIdSet.contains(groupId)) {
          grouped.putIfAbsent(groupId, () => []).add(index);
        } else {
          ungrouped.add(index);
        }
      }

      for (final group in groups) {
        final indices = grouped[group.id];
        if (indices != null && indices.isNotEmpty) {
          return (device: filter, index: indices.first);
        }
      }

      if (ungrouped.isNotEmpty) return (device: filter, index: ungrouped.first);
      return null;
    }

    // All view: flat list order matches mouse, keyboard, pointer,
    // touchpad, touchscreen
    for (final device in DeviceType.values) {
      if (config.gesturesForDevice(device).isNotEmpty) {
        return (device: device, index: 0);
      }
    }
    return null;
  }

  /// Navigates to [device] filter, selecting the first gesture directly so
  /// there is no intermediate frame with an empty selection.
  void _goToDevice(DeviceType? device) {
    final location = ref.read(appLocationProvider);
    final changingFilter =
        location.view != AppView.gestures || location.filter != device;

    if (changingFilter) {
      final config = ref.read(configControllerProvider).value;
      if (config != null) {
        final first = _firstGestureForFilter(config, device);
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

    return FSidebar.raw(
      style: const .delta(
        constraints: BoxConstraints(maxWidth: 180),
        decoration: .boxDelta(color: Colors.transparent),
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
                  // const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      left: 16,
                    ),
                    child: Row(
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
                  // const FDivider(
                  //   style: .delta(
                  //     padding: .value(
                  //       EdgeInsets.symmetric(horizontal: 16),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  // Padding(
                  //   padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  //   child: Row(
                  //     // mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       FTooltip(
                  //         tipBuilder: (_, _) => const Text('Load from file'),
                  //         child: FButton.icon(
                  //           variant: .ghost,
                  //           size: .lg,
                  //           onPress: () => ref
                  //               .read(configControllerProvider.notifier)
                  //               .loadFromPicker(),
                  //           child: const Icon(FLucideIcons.folderOpen),
                  //         ),
                  //       ),
                  //       FTooltip(
                  //         tipBuilder: (_, _) => const Text('Save to file'),
                  //         child: FButton.icon(
                  //           variant: .ghost,
                  //           size: .lg,
                  //           onPress: () => ref
                  //               .read(configControllerProvider.notifier)
                  //               .save(),
                  //           child: const Icon(FLucideIcons.save),
                  //         ),
                  //       ),
                  //       FTooltip(
                  //         tipBuilder: (_, _) => const Text('Reset'),
                  //         child: FButton.icon(
                  //           variant: .ghost,
                  //           size: .lg,
                  //           onPress: () => ref
                  //               .read(configControllerProvider.notifier)
                  //               .reload(),
                  //           child: const Icon(FLucideIcons.refreshCw),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                onPress: () async {
                  await context.pushSettings();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
