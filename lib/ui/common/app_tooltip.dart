import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class AppTooltip extends StatelessWidget {
  const AppTooltip({
    required this.tipBuilder,
    this.control = const FTooltipManagedControl(),
    this.style = const FTooltipStyleDelta.context(),
    this.tipAnchor = Alignment.bottomCenter,
    this.childAnchor = Alignment.topCenter,
    this.spacing = const FPortalSpacing.spacing(4),
    this.overflow = FPortalOverflow.flip,
    this.hover,
    this.longPress,
    this.useViewPadding = true,
    this.useViewInsets = true,
    this.builder = FTooltip.defaultBuilder,
    this.child,
    super.key,
  }) : assert(
         builder != FTooltip.defaultBuilder || child != null,
         'Either builder or child must be provided.',
       );

  static const BoxConstraints _tipConstraints = BoxConstraints(
    maxWidth: 300,
    maxHeight: 600,
  );

  final Widget Function(BuildContext context, FTooltipController controller)
  tipBuilder;
  final FTooltipControl control;
  final FTooltipStyleDelta style;
  final AlignmentGeometry tipAnchor;
  final AlignmentGeometry childAnchor;
  final FPortalSpacing spacing;
  final FPortalOverflow overflow;
  final bool? hover;
  final bool? longPress;
  final bool useViewPadding;
  final bool useViewInsets;
  final ValueWidgetBuilder<FTooltipController> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      control: control,
      style: style,
      tipAnchor: tipAnchor,
      childAnchor: childAnchor,
      spacing: spacing,
      overflow: overflow,
      hover: hover,
      longPress: longPress,
      useViewPadding: useViewPadding,
      useViewInsets: useViewInsets,
      builder: builder,
      tipBuilder: (context, controller) => ConstrainedBox(
        constraints: _tipConstraints,
        child: tipBuilder(context, controller),
      ),
      child: child,
    );
  }
}
