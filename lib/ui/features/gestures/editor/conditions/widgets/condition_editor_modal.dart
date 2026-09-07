import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart' show Colors, Curves, Material;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/inheritance/group_inheritance.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/catalog/variable_catalog.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/conditions/condition_editor.dart';

/// Builds a full-screen overlay route (not opaque) that shows an expanded
/// [ConditionEditor] with Hero-animated expand/collapse button.
PageRouteBuilder<void> buildConditionsExpandRoute({
  required FThemeData theme,
  required Object heroTag,
  required Color backgroundColor,
  required String title,
  required String? titleTooltip,
  required List<VariableGroup>? groups,
  required bool isDirty,
  required DirtyMarkState? dirtyState,
  required VoidCallback? onRevert,
  required Condition? initialCondition,
  required void Function(Condition?) onConditionChanged,
  Widget? titleTooltipContent,
  String? emptyMessage,
  List<InheritedCondition> inherited = const [],
  bool inheritedForGroup = false,
  ValueChanged<InheritedCondition>? onOpenInheritedGroup,
}) {
  return PageRouteBuilder<void>(
    opaque: false,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return FTheme(
        data: theme,
        child: _ConditionsExpandModal(
          animation: animation,
          heroTag: heroTag,
          backgroundColor: backgroundColor,
          title: title,
          titleTooltip: titleTooltip,
          titleTooltipContent: titleTooltipContent,
          emptyMessage: emptyMessage,
          groups: groups,
          isDirty: isDirty,
          dirtyState: dirtyState,
          onRevert: onRevert,
          initialCondition: initialCondition,
          onConditionChanged: onConditionChanged,
          inherited: inherited,
          inheritedForGroup: inheritedForGroup,
          onOpenInheritedGroup: onOpenInheritedGroup,
        ),
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}

Widget buildConditionsFieldHeroFlight({
  required FThemeData theme,
  required HeroFlightDirection flightDirection,
  required BuildContext fromHeroContext,
  required BuildContext toHeroContext,
}) {
  final hero =
      (flightDirection == HeroFlightDirection.push
              ? toHeroContext.widget
              : fromHeroContext.widget)
          as Hero;

  return FTheme(
    data: theme,
    child: DefaultTextStyle(
      style: theme.typography.body.md.copyWith(color: theme.colors.foreground),
      child: Material(color: Colors.transparent, child: hero.child),
    ),
  );
}

class _ConditionsExpandModal extends StatelessWidget {
  const _ConditionsExpandModal({
    required this.animation,
    required this.heroTag,
    required this.backgroundColor,
    required this.title,
    required this.titleTooltip,
    required this.groups,
    required this.isDirty,
    required this.dirtyState,
    required this.onRevert,
    required this.initialCondition,
    required this.onConditionChanged,
    required this.inherited,
    required this.inheritedForGroup,
    required this.onOpenInheritedGroup,
    this.titleTooltipContent,
    this.emptyMessage,
  });

  final Animation<double> animation;
  final Object heroTag;
  final Color backgroundColor;
  final String title;
  final String? titleTooltip;
  final Widget? titleTooltipContent;
  final String? emptyMessage;
  final List<VariableGroup>? groups;
  final bool isDirty;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;
  final Condition? initialCondition;
  final void Function(Condition?) onConditionChanged;
  final List<InheritedCondition> inherited;
  final bool inheritedForGroup;
  final ValueChanged<InheritedCondition>? onOpenInheritedGroup;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final barrierCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    final fadeCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    final scaleCurve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    final scale = Tween<double>(begin: 0.985, end: 1).animate(scaleCurve);

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: barrierCurve,
            builder: (context, _) => BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: barrierCurve.value * 5,
                sigmaY: barrierCurve.value * 5,
              ),
              child: ColoredBox(
                color:
                    Color.lerp(
                      Colors.transparent,
                      colors.barrier,
                      barrierCurve.value,
                    ) ??
                    Colors.transparent,
              ),
            ),
          ),
          Align(
            child: GestureDetector(
              onTap: () {},
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 800,
                  maxHeight: screenHeight * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FadeTransition(
                    opacity: fadeCurve,
                    child: ScaleTransition(
                      scale: scale,
                      child: DefaultTextStyle(
                        style: typography.body.md.copyWith(
                          color: colors.foreground,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.background,
                              border: Border.all(color: colors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SingleChildScrollView(
                                child: _ConditionsWrapper(
                                  heroTag: heroTag,
                                  backgroundColor: backgroundColor,
                                  title: title,
                                  titleTooltip: titleTooltip,
                                  titleTooltipContent: titleTooltipContent,
                                  emptyMessage: emptyMessage,
                                  groups: groups,
                                  isDirty: isDirty,
                                  dirtyState: dirtyState,
                                  onRevert: onRevert,
                                  initialCondition: initialCondition,
                                  onConditionChanged: onConditionChanged,
                                  inherited: inherited,
                                  inheritedForGroup: inheritedForGroup,
                                  onOpenInheritedGroup: onOpenInheritedGroup,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConditionsWrapper extends StatefulWidget {
  const _ConditionsWrapper({
    required this.heroTag,
    required this.backgroundColor,
    required this.title,
    required this.titleTooltip,
    required this.groups,
    required this.isDirty,
    required this.dirtyState,
    required this.onRevert,
    required this.initialCondition,
    required this.onConditionChanged,
    required this.inherited,
    required this.inheritedForGroup,
    required this.onOpenInheritedGroup,
    this.titleTooltipContent,
    this.emptyMessage,
  });

  final Object heroTag;
  final Color backgroundColor;
  final String title;
  final String? titleTooltip;
  final Widget? titleTooltipContent;
  final String? emptyMessage;
  final List<VariableGroup>? groups;
  final bool isDirty;
  final DirtyMarkState? dirtyState;
  final VoidCallback? onRevert;
  final Condition? initialCondition;
  final void Function(Condition?) onConditionChanged;
  final List<InheritedCondition> inherited;
  final bool inheritedForGroup;
  final ValueChanged<InheritedCondition>? onOpenInheritedGroup;

  @override
  State<_ConditionsWrapper> createState() => _ConditionsWrapperState();
}

class _ConditionsWrapperState extends State<_ConditionsWrapper> {
  late Condition? _condition;

  @override
  void initState() {
    super.initState();
    _condition = widget.initialCondition;
  }

  @override
  Widget build(BuildContext context) {
    return ConditionEditor.generic(
      condition: _condition,
      onConditionChanged: (c) {
        setState(() => _condition = c);
        widget.onConditionChanged(c);
      },
      title: widget.title,
      titleTooltip: widget.titleTooltip,
      titleTooltipContent: widget.titleTooltipContent,
      emptyMessage: widget.emptyMessage,
      groups: widget.groups,
      isDirty: widget.isDirty,
      dirtyState: widget.dirtyState,
      onRevert: widget.onRevert,
      expandable: false,
      inherited: widget.inherited,
      inheritedForGroup: widget.inheritedForGroup,
      onOpenInheritedGroup: widget.onOpenInheritedGroup,
      heroTag: widget.heroTag,
      bodyBackgroundColor: widget.backgroundColor,
      onCollapse: () => Navigator.of(context).pop(),
    );
  }
}
