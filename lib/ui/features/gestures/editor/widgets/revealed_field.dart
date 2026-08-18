import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/projections/reveal_providers.dart';
import 'package:input_actions_editor/store/edit_reveal_provider.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';

/// Marks [child] as the editor for [field]: when an undo or redo changes that
/// field, the row flashes, label and control together, and scrolls into view.
///
/// Reads the location from the enclosing [EditLocationScope], so an action
/// field resolves against its action and everything else against the gesture.
class RevealedField extends HookConsumerWidget {
  RevealedField({
    required ConfigDirtyField field,
    required this.child,
    super.key,
  }) : fields = {field};

  /// For a control that edits several fields at once, such as a swipe mode.
  const RevealedField.any({
    required this.fields,
    required this.child,
    super.key,
  });

  final Set<ConfigDirtyField> fields;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = EditLocationScope.maybeOf(context);
    final action = scope?.action;
    final group = scope?.group;
    final gesture = scope?.gesture ?? action?.gesture;
    final changed = action != null
        ? ref.watch(revealedActionFieldsProvider(action))
        : group != null
        ? ref.watch(revealedGroupFieldsProvider(group))
        : gesture == null
        ? const <ConfigDirtyField>{}
        : ref.watch(revealedGestureFieldsProvider(gesture));
    final ticket = ref.watch(
      editRevealProvider.select((reveal) => reveal?.ticket),
    );
    final trigger = changed.any(fields.contains) ? ticket : null;

    final anchor = useMemoized(GlobalKey.new);
    useEffect(() {
      if (trigger == null) return null;
      var cancelled = false;
      Future<void> bringIntoView() async {
        await WidgetsBinding.instance.endOfFrame;
        if (cancelled) return;
        final row = anchor.currentContext;
        if (row == null || !row.mounted || _isFullyVisible(row)) return;
        await Scrollable.ensureVisible(
          row,
          alignment: 0.15,
          duration: Durations.short4,
          curve: Easing.standard,
        );
      }

      unawaited(bringIntoView());
      return () => cancelled = true;
    }, [trigger]);

    return KeyedSubtree(
      key: anchor,
      child: AttentionFlash.expanded(
        trigger: trigger,
        borderRadius: BorderRadius.circular(12),
        strength: 0.15,
        pulseDuration: const Duration(seconds: 1),
        child: child,
      ),
    );
  }
}

/// Whether the whole row already sits inside its viewport, in which case
/// scrolling would only shuffle something the reader is looking at.
bool _isFullyVisible(BuildContext context) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.hasSize) return false;
  final viewport = RenderAbstractViewport.maybeOf(box);
  final position = Scrollable.maybeOf(context)?.position;
  if (viewport == null || position == null || !position.hasContentDimensions) {
    return false;
  }
  final top = viewport.getOffsetToReveal(box, 0).offset;
  final bottom = viewport.getOffsetToReveal(box, 1).offset;
  return position.pixels <= top && position.pixels >= bottom;
}
