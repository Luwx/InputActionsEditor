import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/common/fade_slide_in.dart';
import 'package:input_actions_editor/ui/common/warm_up_scope.dart';

void main() {
  testWidgets('warm-up does not consume the entrance animation', (
    tester,
  ) async {
    final revealed = ValueNotifier(false);
    addTearDown(revealed.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WarmUpScope(
          warming: true,
          revealed: revealed,
          child: const FadeSlideIn(
            duration: Duration(milliseconds: 200),
            offset: 20,
            child: SizedBox(key: ValueKey('content'), width: 40, height: 40),
          ),
        ),
      ),
    );

    double opacity() => tester
        .widget<Opacity>(
          find.ancestor(
            of: find.byKey(const ValueKey('content')),
            matching: find.byType(Opacity),
          ),
        )
        .opacity;
    double translationY() => tester
        .widget<Transform>(
          find.ancestor(
            of: find.byKey(const ValueKey('content')),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .getTranslation()
        .y;

    await tester.pump(const Duration(seconds: 5));
    expect(opacity(), kWarmUpPaintFloor);
    expect(translationY(), 20);

    revealed.value = true;
    await tester.pump();
    expect(opacity(), kWarmUpPaintFloor);
    expect(translationY(), 20);

    await tester.pump(const Duration(milliseconds: 50));
    expect(opacity(), greaterThan(kWarmUpPaintFloor));
    expect(opacity(), lessThan(1));
    expect(translationY(), greaterThan(0));
    expect(translationY(), lessThan(20));

    await tester.pump(const Duration(milliseconds: 200));
    expect(opacity(), 1);
    expect(translationY(), 0);
  });

  testWidgets('warm-up animation is mounted but starts at reveal', (
    tester,
  ) async {
    final revealed = ValueNotifier(false);
    addTearDown(revealed.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: WarmUpScope(
          warming: true,
          revealed: revealed,
          child: WarmUpAnimation(
            builder: (context, onInit) =>
                const SizedBox(
                      key: ValueKey('animation'),
                    )
                    .animate(autoPlay: false, onInit: onInit)
                    .fadeIn(
                      duration: const Duration(milliseconds: 200),
                    ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 5));
    Animation<double> opacity() =>
        tester.widget<FadeTransition>(find.byType(FadeTransition)).opacity;
    expect(find.byKey(const ValueKey('animation')), findsOneWidget);
    expect(opacity().value, 0);

    revealed.value = true;
    await tester.pump();
    expect(opacity().value, 0);

    await tester.pump(const Duration(milliseconds: 50));
    expect(opacity().value, greaterThan(0));
    expect(opacity().value, lessThan(1));
  });
}
