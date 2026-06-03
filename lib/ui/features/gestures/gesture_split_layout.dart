import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/ui/common/resize_divider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/gesture_editor.dart';
import 'package:input_actions_editor/ui/features/gestures/list/gesture_list_section.dart';

class GestureListWidthController extends Notifier<double> {
  @override
  double build() => 0.3;

  @override
  set state(double value) => super.state = value;
}

final gestureListWidthProvider =
    NotifierProvider<GestureListWidthController, double>(
      GestureListWidthController.new,
    );

class GestureSplitLayout extends ConsumerWidget {
  const GestureSplitLayout({
    // required this.onGestureListWidthFractionChanged,
    this.dividerLayout = ResizeDividerLayout.float,
    this.dividerWidth = 12,
    this.dividerLinePlacement = ResizeDividerLinePlacement.center,
    super.key,
  });

  static const _minGestureListWidth = 260.0;
  static const _minGestureDetailWidth = 360.0;

  // final double gestureListWidthFraction;
  // final ValueChanged<double> onGestureListWidthFractionChanged;
  final ResizeDividerLayout dividerLayout;
  final double dividerWidth;
  final ResizeDividerLinePlacement dividerLinePlacement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fraction = ref.watch(gestureListWidthProvider);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = _availableWidth(constraints.maxWidth);
        final gestureListWidth = _resolvedGestureListWidth(
          availableWidth,
          fraction,
        );
        final gestureDetailWidth = math.max(
          0,
          availableWidth - gestureListWidth,
        );

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
                onDragUpdate: (delta) {
                  final newFraction = _calculateGestureListWidth(
                    delta,
                    availableWidth,
                    fraction,
                  );
                  if (newFraction != null) {
                    ref.read(gestureListWidthProvider.notifier).state =
                        newFraction;
                  }
                },
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
                  onDragUpdate: (delta) {
                    final newFraction = _calculateGestureListWidth(
                      delta,
                      availableWidth,
                      fraction,
                    );
                    if (newFraction != null) {
                      ref.read(gestureListWidthProvider.notifier).state =
                          newFraction;
                    }
                  },
                ),
              ),
            ],
          ),
        };
      },
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

  double _resolvedGestureListWidth(double availableWidth, double fraction) {
    if (availableWidth <= 0) {
      return 0;
    }

    final preferredWidth = availableWidth * fraction;
    final minimumWidths = _minimumWidths(availableWidth);
    final maxGestureWidth = math.max(
      minimumWidths.gestureList,
      availableWidth - minimumWidths.gestureDetail,
    );

    return preferredWidth.clamp(minimumWidths.gestureList, maxGestureWidth);
  }

  double _overlayDividerOffset(double gestureListWidth) =>
      switch (dividerLinePlacement) {
        ResizeDividerLinePlacement.left => gestureListWidth,
        ResizeDividerLinePlacement.center =>
          gestureListWidth - (dividerWidth / 2),
        ResizeDividerLinePlacement.right => gestureListWidth - dividerWidth,
      };

  double? _calculateGestureListWidth(
    double delta,
    double availableWidth,
    double fraction,
  ) {
    if (availableWidth <= 0) {
      return null;
    }

    final nextWidth =
        _resolvedGestureListWidth(availableWidth, fraction) + delta;
    final minimumWidths = _minimumWidths(availableWidth);
    final maxGestureWidth = math.max(
      minimumWidths.gestureList,
      availableWidth - minimumWidths.gestureDetail,
    );
    final clampedWidth = nextWidth.clamp(
      minimumWidths.gestureList,
      maxGestureWidth,
    );

    return clampedWidth / availableWidth;
  }
}
