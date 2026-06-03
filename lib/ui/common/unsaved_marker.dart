import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';

const Color kUnsavedMarkerColor = Color(0xFFF59E0B);

class UnsavedMarker extends StatelessWidget {
  const UnsavedMarker({
    this.state,
    this.isDirty,
    this.onRevert,
    this.revertLabel = 'Restore saved value',
    super.key,
  }) : assert(
         state == null || isDirty == null,
         'Pass either state or isDirty, not both.',
       );

  final DirtyMarkState? state;
  final bool? isDirty;
  final VoidCallback? onRevert;
  final String revertLabel;

  DirtyMarkState get _state =>
      state ??
      ((isDirty ?? false) ? DirtyMarkState.newUnsaved : DirtyMarkState.clean);

  @override
  Widget build(BuildContext context) {
    if (!_state.isDirty) return const SizedBox.shrink();

    final marker = Text(
      '*',
      style: TextStyle(
        color: context.theme.colors.primary.withAlpha(150),
        // color: FThemes.violet.dark.desktop.colors.primary,
        fontWeight: FontWeight.w700,
      ),
    );

    if (!_state.canRevert || onRevert == null) return marker;

    return FPopover(
      constraints: const FPortalConstraints(maxWidth: 220),
      builder: (context, controller, child) => GestureDetector(
        onTap: controller.toggle,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
      popoverBuilder: (context, controller) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unsaved change',
              style: context.theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Restore the last saved value for this setting.',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            const SizedBox(height: 12),
            FButton(
              variant: .outline,
              size: .sm,
              onPress: () async {
                onRevert!();
                await controller.hide();
              },
              child: Text(revertLabel),
            ),
          ],
        ),
      ),
      child: marker,
    );
  }
}

class UnsavedLabel extends StatelessWidget {
  const UnsavedLabel({
    required this.child,
    this.isDirty,
    this.state,
    this.onRevert,
    this.revertLabel = 'Restore saved value',
    super.key,
  }) : assert(
         state == null || isDirty == null,
         'Pass either state or isDirty, not both.',
       );

  final Widget child;
  final bool? isDirty;
  final DirtyMarkState? state;
  final VoidCallback? onRevert;
  final String revertLabel;

  DirtyMarkState get _state =>
      state ??
      ((isDirty ?? false) ? DirtyMarkState.newUnsaved : DirtyMarkState.clean);

  @override
  Widget build(BuildContext context) {
    // if (!_state.isDirty) return child;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: UnsavedMarker(
            state: _state,
            onRevert: onRevert,
            revertLabel: revertLabel,
          ),
        ),
        // ).appearToggle(
        //   visible: _state.isDirty,
        //   duration: Durations.medium1,
        //   axis: Axis.horizontal,
        // ),
      ],
    );
  }
}
