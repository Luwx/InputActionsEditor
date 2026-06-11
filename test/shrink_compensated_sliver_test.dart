import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/reorderable_groupable_list/shrink_compensated_sliver.dart';

class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  const _HeaderDelegate({
    this.extent = 40,
    this.key = const ValueKey('header'),
  });

  final double extent;
  final Key key;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(
    child: ColoredBox(key: key, color: Colors.blue),
  );

  @override
  bool shouldRebuild(covariant _HeaderDelegate oldDelegate) =>
      extent != oldDelegate.extent || key != oldDelegate.key;
}

void main() {
  const headerFinderKey = ValueKey('header');

  // 600px viewport. One compensated group (40px pinned header + shrinkable
  // body) followed by enough trailing content to scroll into.
  Widget harness({
    required ScrollController controller,
    required double bodyExtent,
  }) {
    return MaterialApp(
      home: CustomScrollView(
        controller: controller,
        slivers: [
          ShrinkCompensatedSliver(
            pinnedExtent: 40,
            sliver: SliverMainAxisGroup(
              slivers: [
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: bodyExtent)),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 2000)),
        ],
      ),
    );
  }

  // Same, but under a 60px pinned app bar and shaped like the real widget's
  // build(): each group is its own ShrinkCompensatedSliver-wrapped
  // SliverMainAxisGroup, siblings in the CustomScrollView. The first group's
  // rows collapse; the 'below' group stays expanded (its pinned header is
  // what visually takes over as the first group shrinks).
  Widget appBarHarness({
    required ScrollController controller,
    required double rowHeight,
    double belowRowHeight = 40,
  }) {
    return MaterialApp(
      home: CustomScrollView(
        controller: controller,
        slivers: [
          const SliverPersistentHeader(
            pinned: true,
            delegate: _HeaderDelegate(extent: 60, key: ValueKey('appbar')),
          ),
          ShrinkCompensatedSliver(
            pinnedExtent: 40,
            sliver: SliverMainAxisGroup(
              slivers: [
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SizedBox(height: rowHeight),
                    childCount: 30,
                  ),
                ),
              ],
            ),
          ),
          ShrinkCompensatedSliver(
            pinnedExtent: 40,
            sliver: SliverMainAxisGroup(
              slivers: [
                const SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(key: ValueKey('below')),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => SizedBox(height: belowRowHeight),
                    childCount: 30,
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 2000)),
        ],
      ),
    );
  }

  testWidgets('shrink past the pin boundary corrects the offset in-frame', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(harness(controller: controller, bodyExtent: 500));
    // Scroll to the push-out boundary: group extent 540, header 40, so the
    // header starts being pushed out beyond offset 500.
    controller.jumpTo(500);
    await tester.pump();
    expect(tester.getTopLeft(find.byKey(headerFinderKey)).dy, 0);

    // Shrink the body by 200 while scrolled at the boundary. Without the
    // correction the header would be pushed 200px above the viewport.
    await tester.pumpWidget(harness(controller: controller, bodyExtent: 300));
    await tester.pump();

    expect(controller.offset, 300);
    expect(tester.getTopLeft(find.byKey(headerFinderKey)).dy, 0);
  });

  testWidgets('shrink before the pin boundary leaves the offset alone', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(harness(controller: controller, bodyExtent: 500));
    controller.jumpTo(100);
    await tester.pump();

    // 500 -> 400 keeps the body extent (400) above the offset (100): rows
    // shrink beneath the pinned header, no correction.
    await tester.pumpWidget(harness(controller: controller, bodyExtent: 400));
    await tester.pump();

    expect(controller.offset, 100);
    expect(tester.getTopLeft(find.byKey(headerFinderKey)).dy, 0);
  });

  testWidgets(
    'header stays glued below the app bar through a full collapse',
    (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        appBarHarness(controller: controller, rowHeight: 40),
      );
      // Scroll deep into the group's rows: app bar 60 + header 40 + 800 of
      // the 1200px of rows consumed. The group header pins at y=60.
      controller.jumpTo(900);
      await tester.pump();
      expect(tester.getTopLeft(find.byKey(headerFinderKey)).dy, 60);

      // Collapse rows 40 -> 0 in 80 fine steps, mimicking the per-frame
      // shrink of the AnimatedCrossFade. The header must not move on any
      // frame, including the final ones where the group's top has to sink
      // below the leading edge (group extent < header + app-bar overlap) and
      // the shrinking overlap is all that encodes the depth.
      for (var step = 1; step <= 80; step++) {
        await tester.pumpWidget(
          appBarHarness(
            controller: controller,
            rowHeight: 40 * (1 - step / 80),
          ),
        );
        await tester.pump();
        expect(
          tester.getTopLeft(find.byKey(headerFinderKey)).dy,
          moreOrLessEquals(60, epsilon: 0.1),
          reason: 'header drifted at step $step',
        );
      }
      // Settled end state: collapsed header right under the app bar, the
      // next group's header immediately after it.
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('below'))).dy,
        moreOrLessEquals(100, epsilon: 0.1),
      );
    },
  );

  testWidgets('shrinking sliver below the viewport does not scroll', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    // The 'below' group starts past the viewport (60 + 40 + 1200 of the first
    // group above it). Collapsing it must not move the viewport, even though
    // its glue term would be positive if it ever sat at the leading edge.
    await tester.pumpWidget(
      appBarHarness(controller: controller, rowHeight: 40),
    );
    controller.jumpTo(20);
    await tester.pump();

    for (var step = 1; step <= 10; step++) {
      await tester.pumpWidget(
        appBarHarness(
          controller: controller,
          rowHeight: 40,
          belowRowHeight: 40 * (1 - step / 10),
        ),
      );
      await tester.pump();
      expect(controller.offset, 20, reason: 'viewport moved at step $step');
    }
  });

  testWidgets('collapse at the top of the list never corrects out of bounds', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    // Barely scrolled: only 10px of room above. The end-of-collapse glue
    // would want to sink the group under the app bar, but must stop at
    // offset 0 instead of correcting into negative overscroll.
    await tester.pumpWidget(
      appBarHarness(controller: controller, rowHeight: 40),
    );
    controller.jumpTo(10);
    await tester.pump();

    for (var step = 1; step <= 40; step++) {
      await tester.pumpWidget(
        appBarHarness(
          controller: controller,
          rowHeight: 40 * (1 - step / 40),
        ),
      );
      await tester.pump();
      expect(
        controller.offset,
        greaterThanOrEqualTo(0),
        reason: 'overscrolled at step $step',
      );
    }
    await tester.pumpAndSettle();
    expect(controller.offset, 0);
    // Group top rests at its natural position below the fully expanded
    // app bar; the header never went under it.
    expect(tester.getTopLeft(find.byKey(headerFinderKey)).dy, 60);
  });

  testWidgets('correction composes with a ballistic fling', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(harness(controller: controller, bodyExtent: 500));
    controller.jumpTo(520);
    await tester.pump();

    // Start a fling, then shrink mid-flight; the correction must not throw or
    // leave the position out of range while momentum continues.
    await tester.fling(
      find.byType(CustomScrollView),
      const Offset(0, -200),
      1000,
    );
    await tester.pump();
    await tester.pumpWidget(harness(controller: controller, bodyExtent: 100));
    await tester.pumpAndSettle();

    final position = controller.position;
    expect(position.pixels, lessThanOrEqualTo(position.maxScrollExtent));
    expect(position.pixels, greaterThanOrEqualTo(position.minScrollExtent));
  });
}
