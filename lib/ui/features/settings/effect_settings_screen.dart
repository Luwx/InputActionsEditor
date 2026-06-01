import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/model/effective_config_values.dart';
import 'package:input_actions_editor/model/global_settings.dart';
import 'package:input_actions_editor/state/config_dirty_providers.dart';
import 'package:input_actions_editor/state/edit/editable_field.dart';
import 'package:input_actions_editor/state/edit/lenses/settings_lenses.dart';
import 'package:input_actions_editor/ui/common/layout/sliver_header_support.dart';
import 'package:input_actions_editor/ui/common/section_card.dart';
import 'package:input_actions_editor/ui/common/unsaved_marker.dart';
import 'package:input_actions_editor/ui/features/settings/state/settings_editor_notifier.dart';

class EffectSettingsScreen extends ConsumerWidget {
  const EffectSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(settingsEditorProvider);
    final config = vm.config;
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    if (config == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final gs = config.globalSettings;
    final savedSettings = ref.watch(savedGlobalSettingsProvider);
    final notifier = ref.read(settingsEditorProvider.notifier);

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

    void update(GlobalSettings Function(GlobalSettings) m) =>
        notifier.updateGlobalSettings(m);
    final autoreloadField = ref.field(
      globalAutoreloadLens,
      fallbackValue: () => gs.autoreload,
    );
    final externalVariableAccessField = ref.field(
      globalExternalVariableAccessLens,
      fallbackValue: () => gs.externalVariableAccess,
    );
    final notificationsConfigErrorField = ref.field(
      globalNotificationsConfigErrorLens,
      fallbackValue: () => gs.notificationsConfigError,
    );
    final emergencyCombinationField = ref.field(
      globalEmergencyCombinationLens,
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
                  : () => update((_) => savedSettings),
              child: Text(
                'Effect Settings',
                style: typography.lg.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
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
                          : () => update(
                              (s) => s.copyWith(
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
                          : () => update(
                              (s) => s.copyWith(
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

class _EmergencyCombinationSection extends StatefulWidget {
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

  @override
  State<_EmergencyCombinationSection> createState() =>
      _EmergencyCombinationSectionState();
}

class _EmergencyCombinationSectionState
    extends State<_EmergencyCombinationSection> {
  late final TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(_EmergencyCombinationSection old) {
    super.didUpdateWidget(old);
    if (!_focused && old.value != widget.value) {
      _ctrl.text = _fmt(widget.value);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _fmt(List<String>? v) {
    if (v == null) return '';
    return v.join(', ');
  }

  void _commit(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      widget.onChanged(null);
      return;
    }
    final keys = trimmed
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
    widget.onChanged(keys.isEmpty ? null : keys);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final typography = widget.typography;

    return SectionCard(
      titleWidget: UnsavedLabel(
        state: widget.dirtyState,
        onRevert: widget.onRevert,
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
            onFocusChange: (focused) {
              _focused = focused;
              if (!focused) _commit(_ctrl.text);
            },
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: _ctrl,
                onChange: (_) {},
              ),
              hint: 'backspace, enter, space',
              label: UnsavedLabel(
                state: widget.fieldState,
                onRevert: widget.onRevert,
                child: const Text('Keys (comma-separated scancodes)'),
              ),
              description: const Text(
                'Keyboard keys that can be pressed in any'
                ' order and held for 2 seconds to suspend'
                ' InputActions until the next config reload.'
                ' Set to empty to disable.',
              ),
              onSubmit: _commit,
            ),
          ),
          if (widget.value != null)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final key in widget.value!)
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
