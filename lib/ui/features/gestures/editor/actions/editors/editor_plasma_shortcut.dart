import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/services/kglobalaccel_service.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/kglobalaccel_provider.dart'
    show
        kGlobalAccelComponentsProvider,
        kGlobalAccelShortcutsProvider,
        shortcutFilterProvider;
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/helpers/use_synced_text_controller.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

bool _isApp(KGlobalAccelComponent c) {
  final n = c.uniqueName;
  return n.endsWith('_desktop') ||
      n.startsWith('com_') ||
      n.startsWith('org_') ||
      n.startsWith('net_') ||
      n.startsWith('io_');
}

class EditorPlasmaShortcut extends HookConsumerWidget {
  const EditorPlasmaShortcut({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manualEntry = useState(false);
    final l10n = context.l10n;
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final componentField = ref.actionSchemaField(context, actionComponentField);
    final shortcutField = ref.actionSchemaField(context, actionShortcutField);
    final componentController = useSyncedTextController(
      componentField.text,
      componentField.onTextChanged,
    );
    final shortcutController = useSyncedTextController(
      shortcutField.text,
      shortcutField.onTextChanged,
    );

    final currentComponent = componentField.value;
    final currentShortcut = shortcutField.value;

    final component = ref
        .watch(kGlobalAccelComponentsProvider)
        .value
        ?.where((c) => c.uniqueName == currentComponent)
        .firstOrNull;

    final componentLabel = component?.friendlyName ?? currentComponent;

    final shortcutLabel =
        ref
            .watch(kGlobalAccelShortcutsProvider(currentComponent))
            .value
            ?.where((s) => s.uniqueName == currentShortcut)
            .firstOrNull
            ?.friendlyName ??
        currentShortcut;

    Future<void> openSheet() async {
      final container = ProviderScope.containerOf(context);
      await showFSheet<void>(
        context: context,
        side: FLayout.rtl,
        mainAxisMaxRatio: null,
        draggable: false,
        builder: (sheetContext) => UncontrolledProviderScope(
          container: container,
          child: _ShortcutPickerSheet(
            initialComponent: currentComponent,
            initialShortcut: currentShortcut,
            onSelected: (comp, shortcut) {
              if (comp != currentComponent) {
                componentField.onChanged(comp);
                shortcutField.onChanged('');
              }
              shortcutField.onChanged(shortcut);
            },
          ),
        ),
      );
    }

    final manualLink = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => manualEntry.value = !manualEntry.value,
        child: Text(
          manualEntry.value
              ? l10n.plasmaShortcutPickerUsePicker
              : l10n.plasmaShortcutPickerManualEntry,
          style: typography.sm.copyWith(color: colors.primary),
        ),
      ),
    );

    if (manualEntry.value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FTextField(
            control: FTextFieldControl.managed(
              controller: componentController,
            ),
            label: UnsavedLabel(
              state: componentField.dirty,
              onRevert: componentField.onRevert,
              child: LabelWithTooltip(
                label: l10n.actionPlasmaComponentLabel,
                tooltip: l10n.actionPlasmaComponentTooltip,
              ),
            ),
            hint: l10n.actionPlasmaComponentHint,
          ),
          const SizedBox(height: 6),
          FTextField(
            control: FTextFieldControl.managed(
              controller: shortcutController,
            ),
            label: UnsavedLabel(
              state: shortcutField.dirty,
              onRevert: shortcutField.onRevert,
              child: LabelWithTooltip(
                label: l10n.actionPlasmaShortcutLabel,
                tooltip: l10n.actionPlasmaShortcutTooltip,
              ),
            ),
            hint: l10n.actionPlasmaShortcutHint,
          ),
          const SizedBox(height: 6),
          manualLink,
        ],
      );
    }

    final combinedDirtyState =
        componentField.dirty == DirtyMarkState.changedFromSaved ||
            shortcutField.dirty == DirtyMarkState.changedFromSaved
        ? DirtyMarkState.changedFromSaved
        : componentField.dirty.isDirty || shortcutField.dirty.isDirty
        ? DirtyMarkState.newUnsaved
        : DirtyMarkState.clean;

    final combinedLabel = UnsavedLabel(
      state: combinedDirtyState,
      onRevert: () {
        componentField.onRevert?.call();
        shortcutField.onRevert?.call();
      },
      child: LabelWithTooltip(
        label: l10n.plasmaShortcutPickerCombinedLabel,
        tooltip: l10n.plasmaShortcutPickerCombinedTooltip,
        textStyle: context.theme.typography.sm.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (currentShortcut.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          combinedLabel,
          const SizedBox(height: 6),
          FButton(
            variant: .outline,
            onPress: openSheet,
            child: Text(l10n.plasmaShortcutPickerSelectShortcut),
          ),
          const SizedBox(height: 6),
          manualLink,
        ],
      );
    }

    final fallbackIcon = component != null && _isApp(component)
        ? FLucideIcons.appWindowMac
        : FLucideIcons.monitorCog;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        combinedLabel,
        const SizedBox(height: 6),
        FTile(
          onPress: openSheet,
          prefix: _ComponentIcon(
            fallbackIcon: fallbackIcon,
            iconPath: component?.iconPath,
            size: 40,
          ),
          title: Text(componentLabel),
          subtitle: Text(shortcutLabel),
          suffix: const Icon(FLucideIcons.chevronRight),
        ),
        const SizedBox(height: 4),
        manualLink,
      ],
    );
  }
}

class _ShortcutPickerSheet extends ConsumerStatefulWidget {
  const _ShortcutPickerSheet({
    required this.initialComponent,
    required this.initialShortcut,
    required this.onSelected,
  });

  final String initialComponent;
  final String initialShortcut;
  final void Function(String component, String shortcut) onSelected;

  @override
  ConsumerState<_ShortcutPickerSheet> createState() =>
      _ShortcutPickerSheetState();
}

class _ShortcutPickerSheetState extends ConsumerState<_ShortcutPickerSheet> {
  late String _selectedComponent;
  TextEditingValue _searchValue = TextEditingValue.empty;

  @override
  void initState() {
    super.initState();
    _selectedComponent = widget.initialComponent;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;
    final componentsAsync = ref.watch(kGlobalAccelComponentsProvider);
    final filter = ref.watch(shortcutFilterProvider);

    ref.listen(shortcutFilterProvider, (_, next) {
      final matching = next.matchingComponents;
      if (!next.active || matching.isEmpty) return;
      if (matching.contains(_selectedComponent)) return;
      final components = componentsAsync.value ?? const [];
      final first = components.firstWhere(
        (c) => matching.contains(c.uniqueName),
        orElse: () => components.first,
      );
      setState(() => _selectedComponent = first.uniqueName);
    });

    final body = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(left: BorderSide(color: colors.border)),
      ),
      child: SizedBox(
        width: 560,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 12),
                const Icon(FLucideIcons.keyboard, size: 24),
                const SizedBox(width: 8),
                Text(
                  context.l10n.plasmaShortcutPickerCombinedLabel,
                  style: typography.md.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                FButton.icon(
                  variant: .ghost,
                  size: .xs,
                  onPress: () => Navigator.of(context).pop(),
                  child: const Icon(FLucideIcons.x),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FTextField(
                control: FTextFieldControl.lifted(
                  value: _searchValue,
                  onChange: (v) async {
                    setState(() => _searchValue = v);
                    await ref
                        .read(shortcutFilterProvider.notifier)
                        .setQuery(v.text);
                  },
                ),
                hint: context.l10n.plasmaShortcutPickerSearch,
                clearable: (value) => value.text.isNotEmpty,
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.border),
            Expanded(
              child: componentsAsync.when(
                data: (components) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ComponentSidebar(
                      components: components,
                      selected: _selectedComponent,
                      onSelect: (name) =>
                          setState(() => _selectedComponent = name),
                    ),
                    Expanded(
                      child: _selectedComponent.isEmpty && !filter.active
                          ? Center(
                              child: Text(
                                context
                                    .l10n
                                    .plasmaShortcutPickerSelectComponent,
                                style: typography.sm.copyWith(
                                  color: colors.mutedForeground,
                                ),
                              ),
                            )
                          : _ShortcutList(
                              component: _selectedComponent,
                              initialShortcut: widget.initialShortcut,
                              onSelected: (shortcut) {
                                Navigator.of(context).pop();
                                widget.onSelected(
                                  _selectedComponent,
                                  shortcut,
                                );
                              },
                            ),
                    ),
                  ],
                ),
                loading: () => const Center(child: FCircularProgress.loader()),
                error: (_, _) => const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );

    // While the sheet slides out, the clearable search field's "Clear" button
    // keeps a transient inverted (left > right) semantics rect that trips the
    // framework's invisible-semantics assertion. The closing sheet's semantics
    // are irrelevant, so drop them for the duration of the reverse animation.
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return body;
    return AnimatedBuilder(
      animation: animation,
      child: body,
      builder: (context, child) => ExcludeSemantics(
        excluding: animation.status == AnimationStatus.reverse,
        child: child,
      ),
    );
  }
}

class _ComponentSidebar extends ConsumerWidget {
  const _ComponentSidebar({
    required this.components,
    required this.selected,
    required this.onSelect,
  });

  final List<KGlobalAccelComponent> components;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.watch(shortcutFilterProvider);

    final visible = filter.active
        ? components
              .where((c) => filter.matchingComponents.contains(c.uniqueName))
              .toList()
        : components;

    final grouped = <bool, List<KGlobalAccelComponent>>{};
    for (final c in visible) {
      grouped.putIfAbsent(_isApp(c), () => []).add(c);
    }
    final categories = [
      (true, l10n.plasmaShortcutPickerApplications),
      (false, l10n.plasmaShortcutPickerSystemServices),
    ];

    return FSidebar(
      style: const .delta(
        constraints: BoxConstraints.tightFor(width: 210),
      ),
      children: [
        const SizedBox(height: 8),
        for (final (isApp, label) in categories)
          if (grouped[isApp]?.isNotEmpty ?? false)
            FSidebarGroup(
              label: Text(label),
              children: [
                for (final comp in grouped[isApp]!)
                  FSidebarItem(
                    icon: _ComponentIcon(
                      iconPath: comp.iconPath,
                      fallbackIcon: isApp
                          ? FLucideIcons.appWindowMac
                          : FLucideIcons.monitorCog,
                    ),
                    label: Text(comp.friendlyName),
                    selected: comp.uniqueName == selected,
                    onPress: () => onSelect(comp.uniqueName),
                  ),
              ],
            ),
      ],
    );
  }
}

class _ShortcutList extends ConsumerWidget {
  const _ShortcutList({
    required this.component,
    required this.initialShortcut,
    required this.onSelected,
  });

  final String component;
  final String initialShortcut;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(shortcutFilterProvider);
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (filter.active) {
      final shortcuts = filter.shortcutsFor(component);
      return Column(
        children: [
          if (filter.isLoading)
            FDeterminateProgress(
              style: const .delta(
                trackDecoration: .boxDelta(borderRadius: BorderRadius.zero),
                fillDecoration: .boxDelta(borderRadius: BorderRadius.zero),
              ),
              value: filter.total > 0 ? filter.loaded / filter.total : 0,
            ),
          Expanded(
            child: shortcuts.isEmpty && !filter.isLoading
                ? Center(
                    child: Text(
                      context.l10n.plasmaShortcutPickerNoResults,
                      style: typography.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  )
                : _buildList(shortcuts),
          ),
        ],
      );
    }

    return ref
        .watch(kGlobalAccelShortcutsProvider(component))
        .when(
          data: _buildList,
          loading: () => const Center(child: FCircularProgress.loader()),
          error: (_, _) => const SizedBox(),
        );
  }

  Widget _buildList(List<KGlobalAccelShortcut> shortcuts) {
    if (shortcuts.isEmpty) return const SizedBox();
    return ListView.builder(
      itemCount: shortcuts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (_, i) {
        final s = shortcuts[i];
        final isSelected = s.uniqueName == initialShortcut;
        return FItem(
          title: Text(s.friendlyName),
          subtitle: Text(
            s.keySequences.isEmpty ? '-' : s.keySequences.join('  ·  '),
          ),
          suffix: isSelected ? const Icon(FLucideIcons.check, size: 14) : null,
          selected: isSelected,
          onPress: () => onSelected(s.uniqueName),
        );
      },
    );
  }
}

class _ComponentIcon extends StatelessWidget {
  const _ComponentIcon({
    required this.fallbackIcon,
    this.iconPath,
    this.size = 20,
  });

  final String? iconPath;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final path = iconPath;
    if (path == null) {
      return Icon(fallbackIcon, size: size);
    }
    if (path.endsWith('.svg')) {
      return SvgPicture.file(File(path), width: size, height: size);
    }
    return Image.file(File(path), width: size, height: size);
  }
}
