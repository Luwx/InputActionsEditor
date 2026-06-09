import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/domain/misc/keyboard_physical_key_map.dart';

class KeyEntry {
  const KeyEntry({
    required this.scancode,
    required this.label,
    required this.searchTerms,
  });

  final String scancode;
  final String label;
  final List<String> searchTerms;

  bool matches(String query) {
    final q = query.toLowerCase();
    return searchTerms.any((t) => t.contains(q));
  }
}

/// Extra search terms that can't be derived from the scancode name or display
/// label alone — e.g. "media" for "playpause", "escape" for "esc".
const _extra = <String, List<String>>{
  'esc': ['escape'],
  'enter': ['return'],
  'backspace': ['back'],
  'delete': ['del'],
  'insert': ['ins'],
  'pageup': ['pgup'],
  'pagedown': ['pgdn', 'pgdown'],
  'sysrq': ['printscreen', 'screenshot', 'prtsc', 'print'],
  'left': ['arrow'],
  'right': ['arrow'],
  'up': ['arrow'],
  'down': ['arrow'],
  'leftctrl': ['ctrl', 'control', 'modifier'],
  'rightctrl': ['ctrl', 'control', 'modifier'],
  'leftshift': ['shift', 'modifier'],
  'rightshift': ['shift', 'modifier'],
  'leftalt': ['alt', 'modifier'],
  'rightalt': ['altgr', 'alt', 'modifier'],
  'leftmeta': ['meta', 'super', 'win', 'windows', 'command', 'modifier'],
  'rightmeta': ['meta', 'super', 'win', 'windows', 'modifier'],
  'leftbrace': ['bracket', 'brace'],
  'rightbrace': ['bracket', 'brace'],
  'apostrophe': ['quote'],
  'grave': ['backtick', 'tilde'],
  'mute': ['audio', 'volume', 'media', 'sound'],
  'volumedown': ['audio', 'media', 'sound'],
  'volumeup': ['audio', 'media', 'sound'],
  'playpause': ['media', 'play', 'pause', 'audio'],
  'nextsong': ['media', 'next', 'track', 'audio', 'forward'],
  'previoussong': ['media', 'previous', 'prev', 'back', 'track', 'audio'],
  'stopcd': ['media', 'stop', 'audio'],
  'power': ['shutdown'],
  'sleep': ['suspend', 'hibernate'],
  'wakeup': ['wake'],
  'back': ['browser'],
  'forward': ['browser'],
  'refresh': ['browser', 'reload'],
  'stop': ['browser'],
  'homepage': ['browser'],
  'www': ['browser', 'search'],
  'mail': ['email'],
  'kpdot': ['decimal', 'point'],
  'kpplus': ['add', 'plus'],
  'kpminus': ['subtract'],
  'kpasterisk': ['multiply', 'asterisk', 'star'],
  'kpslash': ['divide'],
  'kpleftparen': ['paren', 'parenthesis'],
  'kprightparen': ['paren', 'parenthesis'],
};

/// Ordered list of keyboard scancodes with labels and full-text search terms.
/// Derived from the physical key map so it covers the keys most users care
/// about. Built lazily on first access.
final List<KeyEntry> keySearchIndex = _build();

List<KeyEntry> _build() {
  final reverseAliases = <String, List<String>>{};
  for (final e in KeySequenceParser.keyAliases.entries) {
    reverseAliases.putIfAbsent(e.value, () => []).add(e.key);
  }

  final seen = <String>{};
  final entries = <KeyEntry>[];
  for (final scancode in physicalKeyToScancode.values) {
    if (!seen.add(scancode)) continue;
    entries.add(_entry(scancode, reverseAliases));
  }
  return entries;
}

KeyEntry _entry(String scancode, Map<String, List<String>> reverseAliases) {
  final label = keyDisplayName(scancode);
  return KeyEntry(
    scancode: scancode,
    label: label,
    searchTerms: {
      scancode,
      label.toLowerCase(),
      ...?reverseAliases[scancode],
      ...?_extra[scancode],
      // All kp-prefixed keys are numpad keys
      if (scancode.startsWith('kp')) ...['numpad', 'keypad'],
    }.toList(),
  );
}
