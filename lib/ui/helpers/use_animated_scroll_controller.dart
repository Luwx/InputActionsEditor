import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_animator/scroll_animator.dart';

AnimatedScrollController useAnimatedScrollController() {
  final controller = useMemoized(
    () => AnimatedScrollController(animationFactory: const ChromiumEaseInOut()),
  );
  useEffect(() => controller.dispose, const []);
  return controller;
}
