import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/diff/dirty_semantics.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema_extra.dart'
    show RootConfigDirtyField, globalSettingsLens;
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/projections/dirty_providers.dart';
import 'package:input_actions_editor/projections/dirty_saved_providers.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/common/unsaved_changes_dialog.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/helpers/editable_field.dart';

class EffectSettingsScreen extends ConsumerWidget {
  const EffectSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(
      configControllerProvider.select((state) => state.value),
    );
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (config == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final gs = config.globalSettings;
    final savedSettings = ref.watch(savedGlobalSettingsProvider);
    final controller = ref.read(configControllerProvider.notifier);

    final generalState = ref.watch(
      rootConfigDirtyStateProvider(RootConfigDirtyField.effectGeneral),
    );
    final notificationsState = ref.watch(
      rootConfigDirtyStateProvider(RootConfigDirtyField.effectNotifications),
    );
    final emergencyState = ref.watch(
      rootConfigDirtyStateProvider(
        RootConfigDirtyField.effectEmergencyCombination,
      ),
    );

    final screenState =
        [generalState, notificationsState, emergencyState].any(
          (state) => state == DirtyMarkState.changedFromSaved,
        )
        ? DirtyMarkState.changedFromSaved
        : [generalState, notificationsState, emergencyState].any(
            (state) => state == DirtyMarkState.newUnsaved,
          )
        ? DirtyMarkState.newUnsaved
        : DirtyMarkState.clean;

    void revertGlobalSettings(GlobalSettings next) => controller.add(
      SetLens<GlobalSettings>(globalSettingsLens, next),
    );
    final autoreloadField = ref.field(
      globalSettingsAutoreloadLens(),
      fallbackValue: () => gs.autoreload,
    );
    final externalVariableAccessField = ref.field(
      globalSettingsExternalVariableAccessLens(),
      fallbackValue: () => gs.externalVariableAccess,
    );
    final notificationsConfigErrorField = ref.field(
      globalSettingsNotificationsConfigErrorLens(),
      fallbackValue: () => gs.notificationsConfigError,
    );
    final emergencyCombinationField = ref.field(
      globalSettingsEmergencyCombinationLens(),
      fallbackValue: () => gs.emergencyCombination,
    );

    return ScrollbarMediaPadding(
      topInset: SliverFrostedAppBar.maxHeight,
      child: CustomScrollView(
        slivers: [
          SliverFrostedAppBar(
            title: 'Effect Settings',
            titleWidget: UnsavedLabel(
              state: screenState,
              onRevert: savedSettings == null
                  ? null
                  : () => revertGlobalSettings(savedSettings),
              child: Text(
                'Effect Settings',
                style: typography.lg.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            trailing: const ScopedSaveActions(scope: SaveScope.settings),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FTileGroup(
                    divider: .full,
                    label: UnsavedLabel(
                      state: generalState,
                      onRevert: savedSettings == null
                          ? null
                          : () => revertGlobalSettings(
                              gs.copyWith(
                                autoreload: savedSettings.autoreload,
                                externalVariableAccess:
                                    savedSettings.externalVariableAccess,
                              ),
                            ),
                      child: const Text('General'),
                    ),
                    children: [
                      FTile(
                        title: UnsavedLabel(
                          state: autoreloadField.dirty,
                          onRevert: autoreloadField.onRevert,
                          child: const Text('Auto Reload'),
                        ),
                        subtitle: const Text(
                          'Automatically reload the configuration'
                          ' when the file changes.',
                        ),
                        suffix: FSwitch(
                          value: gs.effectiveAutoreload,
                          onChange: (v) =>
                              autoreloadField.onChanged(v ? null : v),
                        ),
                      ),
                      FTile(
                        title: UnsavedLabel(
                          state: externalVariableAccessField.dirty,
                          onRevert: externalVariableAccessField.onRevert,
                          child: const Text('External Variable Access'),
                        ),
                        subtitle: const Text(
                          'Allow dumping variables by'
                          ' running "inputactions variables list".',
                        ),
                        suffix: FSwitch(
                          value: gs.effectiveExternalVariableAccess,
                          onChange: (v) => externalVariableAccessField
                              .onChanged(v ? null : v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: FTileGroup(
                    divider: .full,
                    label: UnsavedLabel(
                      state: notificationsState,
                      onRevert: savedSettings == null
                          ? null
                          : () => revertGlobalSettings(
                              gs.copyWith(
                                notificationsConfigError:
                                    savedSettings.notificationsConfigError,
                              ),
                            ),
                      child: const Text('Notifications'),
                    ),
                    children: [
                      FTile(
                        title: UnsavedLabel(
                          state: notificationsConfigErrorField.dirty,
                          onRevert: notificationsConfigErrorField.onRevert,
                          child: const Text('Config Error Notification'),
                        ),
                        subtitle: const Text(
                          'Send a desktop notification when the'
                          ' configuration fails to load.',
                        ),
                        suffix: FSwitch(
                          value: gs.effectiveNotificationsConfigError,
                          onChange: (v) => notificationsConfigErrorField
                              .onChanged(v ? null : v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 20)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: _EmergencyCombinationSection(
                    value: gs.emergencyCombination,
                    dirtyState: emergencyState,
                    fieldState: emergencyCombinationField.dirty,
                    onRevert: emergencyCombinationField.onRevert,
                    onChanged: emergencyCombinationField.onChanged,
                    colors: colors,
                    typography: typography,
                  ),
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Emergency combination editor
// ---------------------------------------------------------------------------

class _EmergencyCombinationSection extends HookWidget {
  const _EmergencyCombinationSection({
    required this.value,
    required this.dirtyState,
    required this.fieldState,
    required this.onRevert,
    required this.onChanged,
    required this.colors,
    required this.typography,
  });

  final List<String>? value;
  final DirtyMarkState dirtyState;
  final DirtyMarkState fieldState;
  final VoidCallback? onRevert;
  final void Function(List<String>?) onChanged;
  final FColors colors;
  final FTypography typography;

  static String _fmt(List<String>? v) => v == null ? '' : v.join(', ');

  @override
  Widget build(BuildContext context) {
    final ctrl = useTextEditingController(text: _fmt(value));
    final focused = useRef(false);

    final prevValue = usePrevious(value);
    if (prevValue != value && !focused.value) {
      ctrl.text = _fmt(value);
    }

    void commit(String text) {
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        onChanged(null);
        return;
      }
      final keys = trimmed
          .split(',')
          .map((k) => k.trim())
          .where((k) => k.isNotEmpty)
          .toList();
      onChanged(keys.isEmpty ? null : keys);
    }

    return SectionCard(
      titleWidget: UnsavedLabel(
        state: dirtyState,
        onRevert: onRevert,
        child: Text(
          'Emergency Combination',
          style: typography.sm.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      borderRadius: 8,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Focus(
            onFocusChange: (f) {
              focused.value = f;
              if (!f) commit(ctrl.text);
            },
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: ctrl,
                onChange: (_) {},
              ),
              hint: 'backspace, enter, space',
              label: UnsavedLabel(
                state: fieldState,
                onRevert: onRevert,
                child: const Text('Keys (comma-separated scancodes)'),
              ),
              description: const Text(
                'Keyboard keys that can be pressed in any'
                ' order and held for 2 seconds to suspend'
                ' InputActions until the next config reload.'
                ' Set to empty to disable.',
              ),
              onSubmit: commit,
            ),
          ),
          if (value != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final key in value!)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: colors.border),
                    ),
                    child: Text(
                      key,
                      style: typography.xs.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
