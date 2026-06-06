import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/services/kglobalaccel_service.dart';
import 'package:input_actions_editor/ui/common/label_with_tooltip.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/kglobalaccel_provider.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';

class PlasmaShortcutSelector extends ConsumerWidget {
  const PlasmaShortcutSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final componentField = ref.actionSchemaField(context, actionComponentField);
    final shortcutField = ref.actionSchemaField(context, actionShortcutField);

    final componentsAsync = ref.watch(kGlobalAccelComponentsProvider);
    final currentComponent = componentField.value;
    final shortcutsAsync = currentComponent.isEmpty
        ? null
        : ref.watch(kGlobalAccelShortcutsProvider(currentComponent));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        componentsAsync.when(
          data: (components) => _ComponentSelect(
            components: components,
            componentField: componentField,
            shortcutField: shortcutField,
          ),
          loading: () => _DisabledSelect(
            label: l10n.actionPlasmaComponentLabel,
            tooltip: l10n.actionPlasmaComponentTooltip,
          ),
          error: (_, _) => _DisabledSelect(
            label: l10n.actionPlasmaComponentLabel,
            tooltip: l10n.actionPlasmaComponentTooltip,
          ),
        ),
        const SizedBox(height: 6),
        if (shortcutsAsync != null)
          shortcutsAsync.when(
            data: (shortcuts) => _ShortcutSelect(
              shortcuts: shortcuts,
              shortcutField: shortcutField,
              currentComponent: currentComponent,
            ),
            loading: () => _DisabledSelect(
              label: l10n.actionPlasmaShortcutLabel,
              tooltip: l10n.actionPlasmaShortcutTooltip,
            ),
            error: (_, _) => _DisabledSelect(
              label: l10n.actionPlasmaShortcutLabel,
              tooltip: l10n.actionPlasmaShortcutTooltip,
            ),
          )
        else
          _DisabledSelect(
            label: l10n.actionPlasmaShortcutLabel,
            tooltip: l10n.actionPlasmaShortcutTooltip,
          ),
      ],
    );
  }
}

class _ComponentSelect extends ConsumerWidget {
  const _ComponentSelect({
    required this.components,
    required this.componentField,
    required this.shortcutField,
  });

  final List<KGlobalAccelComponent> components;
  final SchemaEditableField<String> componentField;
  final SchemaEditableField<String> shortcutField;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = componentField.value;

    KGlobalAccelComponent? findComp(String uniqueName) {
      try {
        return components.firstWhere((c) => c.uniqueName == uniqueName);
      } on Object catch (_) {
        return null;
      }
    }

    return FSelect<String>.searchBuilder(
      format: (v) => findComp(v)?.friendlyName ?? v,
      filter: (query) {
        if (query.isEmpty) return components.map((c) => c.uniqueName).toList();
        final lq = query.toLowerCase();
        return components
            .where(
              (c) =>
                  c.friendlyName.toLowerCase().contains(lq) ||
                  c.uniqueName.toLowerCase().contains(lq),
            )
            .map((c) => c.uniqueName)
            .toList();
      },
      contentBuilder: (_, _, values) => [
        for (final uniqueName in values)
          FSelectItem(
            value: uniqueName,
            prefix: _ComponentIcon(iconPath: findComp(uniqueName)?.iconPath),
            title: Text(findComp(uniqueName)?.friendlyName ?? uniqueName),
          ),
      ],
      control: FSelectManagedControl<String>(
        initial: current.isEmpty ? null : current,
        onChange: (value) {
          if (value == null) return;
          componentField.onChanged(value);
          shortcutField.onChanged('');
        },
      ),
      label: UnsavedLabel(
        state: componentField.dirty,
        onRevert: componentField.onRevert,
        child: LabelWithTooltip(
          label: l10n.actionPlasmaComponentLabel,
          tooltip: l10n.actionPlasmaComponentTooltip,
        ),
      ),
    );
  }
}

class _ShortcutSelect extends ConsumerWidget {
  const _ShortcutSelect({
    required this.shortcuts,
    required this.shortcutField,
    required this.currentComponent,
  });

  final List<KGlobalAccelShortcut> shortcuts;
  final SchemaEditableField<String> shortcutField;
  final String currentComponent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = shortcutField.value;

    KGlobalAccelShortcut? findShortcut(String uniqueName) {
      try {
        return shortcuts.firstWhere((s) => s.uniqueName == uniqueName);
      } on Object catch (_) {
        return null;
      }
    }

    return FSelect<String>.searchBuilder(
      key: ValueKey(currentComponent),
      format: (v) => findShortcut(v)?.friendlyName ?? v,
      filter: (query) {
        if (query.isEmpty) return shortcuts.map((s) => s.uniqueName).toList();
        final lq = query.toLowerCase();
        return shortcuts
            .where(
              (s) =>
                  s.friendlyName.toLowerCase().contains(lq) ||
                  s.uniqueName.toLowerCase().contains(lq),
            )
            .map((s) => s.uniqueName)
            .toList();
      },
      contentBuilder: (_, _, values) => [
        for (final uniqueName in values)
          FSelectItem(
            value: uniqueName,
            title: Text(findShortcut(uniqueName)?.friendlyName ?? uniqueName),
          ),
      ],
      control: FSelectManagedControl<String>(
        initial: current.isEmpty ? null : current,
        onChange: (value) {
          if (value == null) return;
          shortcutField.onChanged(value);
        },
      ),
      label: UnsavedLabel(
        state: shortcutField.dirty,
        onRevert: shortcutField.onRevert,
        child: LabelWithTooltip(
          label: l10n.actionPlasmaShortcutLabel,
          tooltip: l10n.actionPlasmaShortcutTooltip,
        ),
      ),
    );
  }
}

class _ComponentIcon extends StatelessWidget {
  const _ComponentIcon({this.iconPath});

  final String? iconPath;

  @override
  Widget build(BuildContext context) {
    const size = 20.0;
    final path = iconPath;
    if (path == null) return const SizedBox.square(dimension: size);
    if (path.endsWith('.svg')) {
      return SvgPicture.file(File(path), width: size, height: size);
    }
    return Image.file(File(path), width: size, height: size);
  }
}

class _DisabledSelect extends StatelessWidget {
  const _DisabledSelect({required this.label, required this.tooltip});

  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return FTextField(
      enabled: false,
      label: LabelWithTooltip(label: label, tooltip: tooltip),
    );
  }
}
