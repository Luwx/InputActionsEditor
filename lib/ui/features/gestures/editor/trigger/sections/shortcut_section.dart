import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/data/keyboard_scancodes.dart';
import 'package:input_actions_editor/ui/widgets/label_with_tooltip.dart';

/// Modifier key descriptor - a canonical logical name and its left/right variants.
class _Modifier {
  const _Modifier({
    required this.label,
    required this.left,
    required this.right,
  });

  final String label;
  final String left;
  final String right;
}

const _modifiers = [
  _Modifier(label: 'Ctrl', left: 'leftctrl', right: 'rightctrl'),
  _Modifier(label: 'Shift', left: 'leftshift', right: 'rightshift'),
  _Modifier(label: 'Alt', left: 'leftalt', right: 'rightalt'),
  _Modifier(label: 'Meta', left: 'leftmeta', right: 'rightmeta'),
];

final Set<String> _modifierKeys = {
  for (final m in _modifiers) m.left,
  for (final m in _modifiers) m.right,
};

final List<String> _nonModifierKeys = keyboardScancodes
    .where((k) => !_modifierKeys.contains(k) && k != 'reserved')
    .toList();

class ShortcutSection extends StatelessWidget {
  const ShortcutSection({
    required this.keys,
    required this.onKeysChanged,
    super.key,
  });

  final List<String> keys;
  final void Function(List<String>) onKeysChanged;

  String? get _mainKey =>
      keys.where((k) => !_modifierKeys.contains(k)).firstOrNull;

  void _toggleKey(String key) {
    final updated = List<String>.of(keys);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    onKeysChanged(updated);
  }

  void _setMainKey(String? key) {
    final updated = keys.where(_modifierKeys.contains).toList();
    if (key != null) updated.add(key);
    onKeysChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final mainKey = _mainKey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelWithTooltip(
            label: 'Modifier',
            tooltip:
                'Keyboard modifier keys that must be held. '
                'Click to cycle: (none) → Left → Right → (none). ',
            textStyle: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          // Modifier chips
          Row(
            spacing: 6,
            // runSpacing: 6,
            children: [
              for (final mod in _modifiers)
                _ModifierChip(
                  modifier: mod,
                  activeKeys: keys,
                  onToggle: _toggleKey,
                  onSetModifier: (key) {
                    final updated = keys
                        .where(
                          (k) => k != mod.left && k != mod.right,
                        )
                        .toList();
                    if (key != null) updated.add(key);
                    onKeysChanged(updated);
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Main key picker
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 240,
                child: FSelect<String>.searchBuilder(
                  key: ValueKey(mainKey),
                  format: (v) => v,
                  filter: (query) => query.isEmpty
                      ? _nonModifierKeys
                      : _nonModifierKeys
                            .where(
                              (k) => k.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                            )
                            .toList(),
                  contentBuilder: (_, _, values) => [
                    for (final k in values)
                      FSelectItem(value: k, title: Text(k)),
                  ],
                  control: FSelectManagedControl<String>(
                    initial: mainKey,
                    onChange: _setMainKey,
                  ),
                  label: const LabelWithTooltip(
                    label: 'Key',
                    tooltip:
                        'The main key of the shortcut. '
                        'Combined with any selected modifier keys above.',
                  ),
                ),
              ),
              if (mainKey != null) ...[
                const SizedBox(width: 8),
                FButton.icon(
                  onPress: () => _setMainKey(null),
                  child: const Icon(FLucideIcons.delete),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Preview
          if (keys.isNotEmpty) _ShortcutPreview(keys: keys),
        ],
      ),
    );
  }
}

class _ModifierChip extends StatelessWidget {
  const _ModifierChip({
    required this.modifier,
    required this.activeKeys,
    required this.onToggle,
    required this.onSetModifier,
  });

  final _Modifier modifier;
  final List<String> activeKeys;
  final void Function(String) onToggle;
  // Sets this modifier atomically: null = unselected, left/right key = selected
  final void Function(String?) onSetModifier;

  bool get _leftActive => activeKeys.contains(modifier.left);
  bool get _rightActive => activeKeys.contains(modifier.right);
  bool get _anyActive => _leftActive || _rightActive;

  @override
  Widget build(BuildContext context) {
    final label = _leftActive
        ? '${modifier.label} L'
        : _rightActive
        ? '${modifier.label} R'
        : modifier.label;

    return FButton(
      variant: _anyActive ? .primary : .outline,
      size: .sm,
      onPress: () => _handleTap(context),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Text(label),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (!_leftActive && !_rightActive) {
      onSetModifier(modifier.left);
    } else if (_leftActive) {
      onSetModifier(modifier.right);
    } else {
      onSetModifier(null);
    }
  }
}

// ---------------------------------------------------------------------------
// Shortcut combo preview
// ---------------------------------------------------------------------------

class _ShortcutPreview extends StatelessWidget {
  const _ShortcutPreview({required this.keys});

  final List<String> keys;

  String _display(String key) {
    return switch (key) {
      'leftctrl' => 'L.Ctrl',
      'rightctrl' => 'R.Ctrl',
      'leftshift' => 'L.Shift',
      'rightshift' => 'R.Shift',
      'leftalt' => 'L.Alt',
      'rightalt' => 'R.Alt',
      'leftmeta' => 'L.Meta',
      'rightmeta' => 'R.Meta',
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    // Sort: modifiers first, then main key
    final sorted = [
      ...keys.where(_modifierKeys.contains),
      ...keys.where((k) => !_modifierKeys.contains(k)),
    ];

    return Wrap(
      spacing: 4,
      children: [
        for (final (i, key) in sorted.indexed) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: colors.secondary,
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _display(key),
              style: typography.xs.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          if (i < sorted.length - 1)
            Text(
              '+',
              style: typography.xs.copyWith(
                color: colors.mutedForeground,
              ),
            ),
        ],
      ],
    );
  }
}
