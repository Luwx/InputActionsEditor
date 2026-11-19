import 'package:flutter/widgets.dart';
import 'package:input_actions_editor/services/ui_scale_binding.dart';

class ScaledMediaQuery extends StatelessWidget {
  const ScaledMediaQuery({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
    valueListenable: UiScaleBinding.scaleListenable,
    child: child,
    builder: (context, scale, child) {
      // MediaQuery reads the raw view, without the binding's scale.
      final data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(
          size: data.size / scale,
          devicePixelRatio: data.devicePixelRatio * scale,
          padding: data.padding / scale,
          viewPadding: data.viewPadding / scale,
          viewInsets: data.viewInsets / scale,
          systemGestureInsets: data.systemGestureInsets / scale,
        ),
        child: child!,
      );
    },
  );
}
