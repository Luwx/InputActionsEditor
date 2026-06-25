import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/bulk_edit/state/bulk_edit_active_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/sections/trigger_advanced_fields.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/widgets/mouse_buttons_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

/// Undo/redo scope key for bulk-edit fan-out writes.
const Object bulkEditScope = #bulkEditScope;

/// `id` is intentionally excluded from bulk editing, it must stay unique per
/// gesture. Everything else in [TriggerAdvancedField] is a shared-value field.
const Set<TriggerAdvancedField> _excludedFromBulk = {TriggerAdvancedField.id};

final List<TriggerAdvancedField> _bulkFields = TriggerAdvancedField.values
    .where((field) => !_excludedFromBulk.contains(field))
    .toList();

/// Seeds the visible (pinned) fields from the union of non-default fields
/// across the selection, so a field already set on at least one selected
/// gesture shows up pre-filled (shared value) or empty (mixed).
Set<TriggerAdvancedField> _seedFields(
  Config draft,
  Set<GestureLocation> selection,
) {
  final fields = <TriggerAdvancedField>{};
  for (final location in selection) {
    final common = gestureAt(draft, location)?.common;
    if (common == null) continue;
    fields.addAll(TriggerAdvancedFields.nonDefaultFields(common));
  }
  return fields..removeAll(_excludedFromBulk);
}

/// Bulk-edit page for a multi-selection. Reuses the single-gesture trigger
/// config widgets verbatim, scoping them to the whole selection via
/// [EditLocationScope.bulk]; every change fans out to all selected gestures.
class BulkEditView extends HookConsumerWidget {
  const BulkEditView({required this.selected, super.key});

  final Set<GestureLocation> selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.theme.colors;

    final pinned = useState(
      _seedFields(ref.read(draftConfigProvider), selected),
    );
    final optionsExpanded = useState(true);

    final pinnedFields = _bulkFields.where(pinned.value.contains).toList();
    final accordionFields = _bulkFields
        .where((field) => !pinned.value.contains(field))
        .toList();

    final allMouse = selected.every(
      (location) => location.device == DeviceType.mouse,
    );
    final controller = ref.read(configControllerProvider.notifier);

    final body = EditLocationScope(
      bulk: selected,
      child: SectionCard(
        color: colors.card.withValues(alpha: 0.55),
        title: l10n.triggerConfigTitle,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            if (allMouse) const MouseButtonsField(),
            if (pinnedFields.isNotEmpty)
              TriggerAdvancedFields(fields: pinnedFields),
            if (accordionFields.isNotEmpty)
              FAccordion(
                control: FAccordionControl.lifted(
                  expanded: (index) => index == 0 && optionsExpanded.value,
                  onChange: (index, exp) {
                    if (index != 0 || optionsExpanded.value == exp) return;
                    optionsExpanded.value = exp;
                  },
                ),
                style: const .delta(
                  dividerStyle: .delta(
                    color: Colors.transparent,
                    padding: .value(EdgeInsets.zero),
                  ),
                ),
                children: [
                  FAccordionItem(
                    title: Text(l10n.triggerOtherOptions),
                    child: TriggerAdvancedFields(fields: accordionFields),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): _UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true):
            _RedoIntent(),
        SingleActivator(LogicalKeyboardKey.keyY, control: true): _RedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              controller.undo(scope: bulkEditScope);
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              controller.redo(scope: bulkEditScope);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: ScrollbarMediaPadding(
            topInset: GrowingFrostedHeaderDelegate.maxHeight,
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: GrowingFrostedHeaderDelegate(
                    titleBuilder: (style) =>
                        Text(l10n.bulkEditTitle, style: style),
                    subtitle: l10n.multiSelectCount(selected.length),
                    leading: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: FButton.icon(
                        variant: .ghost,
                        size: .sm,
                        onPress: ref
                            .read(bulkEditActiveProvider.notifier)
                            .close,
                        child: const Icon(FLucideIcons.arrowLeft),
                      ),
                    ),
                    horizontalPadding: 8,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverToBoxAdapter(child: body),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}
