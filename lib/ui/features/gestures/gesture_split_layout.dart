import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/app_state/app/app_state_provider.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_tile.dart';
import 'package:input_actions_editor/ui/features/gestures/list/state/multi_select_controller.dart';

class GestureListWidthController extends Notifier<double> {
  @override
  double build() => ref.read(initialAppStateProvider).gestureListWidth;

  @override
  set state(double value) => super.state = value;
}

final gestureListWidthProvider =
    NotifierProvider<GestureListWidthController, double>(
      GestureListWidthController.new,
    );

class GestureSplitLayout extends HookConsumerWidget {
  const GestureSplitLayout({
    this.dividerLayout = ResizeDividerLayout.float,
    this.dividerWidth = 12,
    this.dividerLinePlacement = ResizeDividerLinePlacement.center,
    super.key,
  });

  static const _minGestureListWidth = 260.0;
  static const _minGestureDetailWidth = 360.0;

  final ResizeDividerLayout dividerLayout;
  final double dividerWidth;
  final ResizeDividerLinePlacement dividerLinePlacement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferredWidth = ref.watch(gestureListWidthProvider);
    final isMultiSelectMode = ref.watch(
      multiSelectControllerProvider.select((selection) => selection != null),
    );
    final expansionTarget = isMultiSelectMode
        ? kGestureSelectionSlotWidth
        : 0.0;

    final dragStartMouseX = useState<double?>(null);
    final dragStartWidth = useState<double?>(null);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: expansionTarget, end: expansionTarget),
      duration: kGestureSelectionSlotDuration,
      curve: kGestureSelectionSlotCurve,
      builder: (context, selectionExpansion, _) => LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = _availableWidth(constraints.maxWidth);
          final baseGestureListWidth = _clampWidth(
            preferredWidth,
            availableWidth,
          );
          final gestureListWidth = _clampWidth(
            baseGestureListWidth + selectionExpansion,
            availableWidth,
          );
          final gestureDetailWidth = math.max(
            0,
            availableWidth - gestureListWidth,
          );

          void handleDragStart(double globalX) {
            dragStartMouseX.value = globalX;
            dragStartWidth.value = baseGestureListWidth;
          }

          void handleDragUpdate(double globalX) {
            final startX = dragStartMouseX.value;
            final startWidth = dragStartWidth.value;
            if (startX == null || startWidth == null || availableWidth <= 0) {
              return;
            }
            final desiredWidth = startWidth + (globalX - startX);
            ref.read(gestureListWidthProvider.notifier).state = _clampWidth(
              desiredWidth,
              availableWidth,
            );
          }

          void handleDragEnd() {
            // settle on a whole pixel
            ref.read(gestureListWidthProvider.notifier).state = ref
                .read(gestureListWidthProvider)
                .roundToDouble();
            dragStartMouseX.value = null;
            dragStartWidth.value = null;
          }

          return switch (dividerLayout) {
            ResizeDividerLayout.float => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: gestureListWidth,
                  child: const GestureListSection(),
                ),
                ResizeDivider(
                  width: dividerWidth,
                  linePlacement: dividerLinePlacement,
                  onDragStart: handleDragStart,
                  onDragUpdate: handleDragUpdate,
                  onDragEnd: handleDragEnd,
                ),
                SizedBox(
                  width: gestureDetailWidth.toDouble(),
                  child: const GestureDetailSection(),
                ),
              ],
            ),
            ResizeDividerLayout.overlay => Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: gestureListWidth,
                      child: const GestureListSection(),
                    ),
                    SizedBox(
                      width: gestureDetailWidth.toDouble(),
                      child: const GestureDetailSection(),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: _overlayDividerOffset(gestureListWidth),
                  child: ResizeDivider(
                    width: dividerWidth,
                    linePlacement: dividerLinePlacement,
                    onDragStart: handleDragStart,
                    onDragUpdate: handleDragUpdate,
                    onDragEnd: handleDragEnd,
                  ),
                ),
              ],
            ),
          };
        },
      ),
    );
  }

  double _availableWidth(double maxWidth) => switch (dividerLayout) {
    ResizeDividerLayout.float => math.max(0, maxWidth - dividerWidth),
    ResizeDividerLayout.overlay => math.max(0, maxWidth),
  };

  ({double gestureList, double gestureDetail}) _minimumWidths(
    double availableWidth,
  ) {
    final minGestureWidth = math.min(_minGestureListWidth, availableWidth);
    final minDetailWidth = math.min(_minGestureDetailWidth, availableWidth);
    return (gestureList: minGestureWidth, gestureDetail: minDetailWidth);
  }

  double _clampWidth(double width, double availableWidth) {
    final minimumWidths = _minimumWidths(availableWidth);
    final maxGestureWidth = math.max(
      minimumWidths.gestureList,
      availableWidth - minimumWidths.gestureDetail,
    );
    return width.clamp(minimumWidths.gestureList, maxGestureWidth);
  }

  double _overlayDividerOffset(double gestureListWidth) =>
      switch (dividerLinePlacement) {
        ResizeDividerLinePlacement.left => gestureListWidth,
        ResizeDividerLinePlacement.center =>
          gestureListWidth - (dividerWidth / 2),
        ResizeDividerLinePlacement.right => gestureListWidth - dividerWidth,
      };
}
