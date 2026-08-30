import 'package:input_actions_editor/domain/misc/keyboard_scancodes.dart';
import 'package:input_actions_editor/model/action.dart';

// ---------------------------------------------------------------------------
// Key resolution
// ---------------------------------------------------------------------------

/// Friendly aliases users are likely to type instead of the raw evdev names.
const Map<String, String> _keyAliases = {
  'ctrl': 'leftctrl',
  'lctrl': 'leftctrl',
  'control': 'leftctrl',
  'rctrl': 'rightctrl',
  'rightcontrol': 'rightctrl',
  'shift': 'leftshift',
  'lshift': 'leftshift',
  'rshift': 'rightshift',
  'alt': 'leftalt',
  'lalt': 'leftalt',
  'ralt': 'rightalt',
  'altgr': 'rightalt',
  'meta': 'leftmeta',
  'super': 'leftmeta',
  'win': 'leftmeta',
  'windows': 'leftmeta',
  'lmeta': 'leftmeta',
  'lsuper': 'leftmeta',
  'rmeta': 'rightmeta',
  'rsuper': 'rightmeta',
  'rwin': 'rightmeta',
  'return': 'enter',
  'ret': 'enter',
  'del': 'delete',
  'ins': 'insert',
  'pgup': 'pageup',
  'pgdn': 'pagedown',
  'pgdown': 'pagedown',
  'prtsc': 'sysrq',
  'print': 'sysrq',
  'printscreen': 'sysrq',
  'scrlock': 'scrolllock',
  'caps': 'capslock',
  'numlk': 'numlock',
  'back': 'backspace',
  'bksp': 'backspace',
  'bkspace': 'backspace',
  'arrowleft': 'left',
  'arrowright': 'right',
  'arrowup': 'up',
  'arrowdown': 'down',
  // Mouse button names used in token format (+left, -middle, etc.)
  'middle': 'middle',
  'task': 'task',
  'side': 'side',
  'extra': 'extra',
};

/// Resolves a user-typed key name to a valid evdev scancode, or `null` if
/// unrecognised.  Look-up is case-insensitive.
String? resolveKey(String name) {
  final lower = name.toLowerCase().trim();
  if (lower.isEmpty) return null;
  if (keyboardScancodes.contains(lower)) return lower;
  return _keyAliases[lower];
}

/// Returns a short, display-friendly label for a known [scancode].
String keyDisplayName(String scancode) {
  const names = <String, String>{
    'leftctrl': 'Ctrl',
    'rightctrl': 'RCtrl',
    'leftshift': 'Shift',
    'rightshift': 'RShift',
    'leftalt': 'Alt',
    'rightalt': 'AltGr',
    'leftmeta': 'Super',
    'rightmeta': 'RSuper',
    'enter': 'Enter',
    'kpenter': 'KpEnter',
    'space': 'Space',
    'backspace': 'BkSp',
    'tab': 'Tab',
    'escape': 'Esc',
    'delete': 'Del',
    'insert': 'Ins',
    'home': 'Home',
    'end': 'End',
    'pageup': 'PgUp',
    'pagedown': 'PgDn',
    'left': '←',
    'right': '→',
    'up': '↑',
    'down': '↓',
    'capslock': 'Caps',
    'numlock': 'Num',
    'scrolllock': 'Scrl',
    'pause': 'Pause',
    'sysrq': 'PrtSc',
    'leftbrace': '[',
    'rightbrace': ']',
    'semicolon': ';',
    'apostrophe': "'",
    'grave': '`',
    'comma': ',',
    'dot': '.',
    'slash': '/',
    'backslash': r'\',
    'minus': '-',
    'equal': '=',
  };
  if (names.containsKey(scancode)) return names[scancode]!;
  if (scancode.startsWith('f') && int.tryParse(scancode.substring(1)) != null) {
    return scancode.toUpperCase(); // f1 → F1
  }
  if (scancode.length == 1) return scancode.toUpperCase(); // a → A
  return scancode;
}

// ---------------------------------------------------------------------------
// AST types
// ---------------------------------------------------------------------------

/// A segment of the input covering characters [start, end) of the original
/// text.  The entire input is covered by a flat, ordered list of segments.
sealed class KsSegment {
  const KsSegment({
    required this.start,
    required this.end,
    required this.raw,
  });

  /// Start offset (inclusive) in the full text.
  final int start;

  /// End offset (exclusive) in the full text.
  final int end;

  /// The exact substring `text.substring(start, end)`.
  final String raw;
}

/// Whitespace or comma separators between segments.
final class KsSeparator extends KsSegment {
  const KsSeparator({
    required super.start,
    required super.end,
    required super.raw,
  });
}

/// A single key name inside a chord or token, with its resolved scancode and
/// exact character range in the full text.
final class KsKeyPart {
  const KsKeyPart({
    required this.typedName,
    required this.scancode,
    required this.start,
    required this.end,
  });

  final String typedName;

  /// `null` when the key name could not be resolved.
  final String? scancode;

  /// Offset of the first character of [typedName] in the full text.
  final int start;

  /// Offset of the first character after [typedName] in the full text.
  final int end;

  bool get isValid => scancode != null;
}

/// A chord like `ctrl+o` or `shift+ctrl+a`.
final class KsChord extends KsSegment {
  const KsChord({
    required super.start,
    required super.end,
    required super.raw,
    required this.keys,
  });

  final List<KsKeyPart> keys;

  bool get isFullyValid => keys.isNotEmpty && keys.every((k) => k.isValid);

  List<InputToken> toTokens() {
    final valid = keys.where((k) => k.isValid).toList();
    if (valid.isEmpty) return const [];
    return [
      InputToken.combo([for (final k in valid) k.scancode!]),
    ];
  }
}

/// An explicit press (`+key`) or release (`-key`) token.
final class KsToken extends KsSegment {
  const KsToken({
    required super.start,
    required super.end,
    required super.raw,
    required this.key,
    required this.pressed,
  });

  final KsKeyPart key;
  final bool pressed;

  /// Returns the normalised token, or `null` if the key is invalid.
  InputToken? toToken() {
    final sc = key.scancode;
    if (sc == null) return null;
    return pressed ? InputToken.press(sc) : InputToken.release(sc);
  }
}

class KeySequenceParser {
  /// Alias map: user-friendly name → canonical scancode.
  static Map<String, String> get keyAliases => _keyAliases;

  /// Parses [text] into a list of [KsSegment]s covering every character.
  ///
  /// Grammar (per comma-separated item):
  /// * `+key` / `-key`  → [KsToken]  (explicit press / release)
  /// * `key+key+…`      → [KsChord]  (simultaneous chord)
  /// * whitespace / `,` → [KsSeparator]
  static List<KsSegment> parse(String text) {
    final result = <KsSegment>[];
    var i = 0;

    while (i < text.length) {
      final c = text[i];

      // whitespace
      if (c == ' ' || c == '\t') {
        final s = i;
        while (i < text.length && (text[i] == ' ' || text[i] == '\t')) {
          i++;
        }
        result.add(KsSeparator(start: s, end: i, raw: text.substring(s, i)));
        continue;
      }

      // ── Comma ───────────────────────────────────────────────────────────
      if (c == ',') {
        result.add(KsSeparator(start: i, end: i + 1, raw: ','));
        i++;
        continue;
      }

      // token: '+key' or '-key'
      // The + / - must be followed by at least one non-separator character
      // that is itself not another + or -.
      if ((c == '+' || c == '-') &&
          i + 1 < text.length &&
          text[i + 1] != ' ' &&
          text[i + 1] != '\t' &&
          text[i + 1] != ',' &&
          text[i + 1] != '+' &&
          text[i + 1] != '-') {
        final segStart = i;
        final pressed = c == '+';
        i++; // skip the + / -
        final keyStart = i;
        while (i < text.length &&
            text[i] != ',' &&
            text[i] != ' ' &&
            text[i] != '\t') {
          i++;
        }
        final keyName = text.substring(keyStart, i);
        result.add(
          KsToken(
            start: segStart,
            end: i,
            raw: text.substring(segStart, i),
            key: KsKeyPart(
              typedName: keyName,
              scancode: resolveKey(keyName),
              start: keyStart,
              end: i,
            ),
            pressed: pressed,
          ),
        );
        continue;
      }

      // chord: 'key1+key2+…'
      {
        final segStart = i;
        final keys = <KsKeyPart>[];

        while (i < text.length &&
            text[i] != ',' &&
            text[i] != ' ' &&
            text[i] != '\t') {
          final keyStart = i;
          // Read one key name up to the next '+', comma, or space.
          while (i < text.length &&
              text[i] != '+' &&
              text[i] != ',' &&
              text[i] != ' ' &&
              text[i] != '\t') {
            i++;
          }
          if (i > keyStart) {
            final keyName = text.substring(keyStart, i);
            keys.add(
              KsKeyPart(
                typedName: keyName,
                scancode: resolveKey(keyName),
                start: keyStart,
                end: i,
              ),
            );
          }
          // Consume the '+' chord separator (if present).
          if (i < text.length && text[i] == '+') i++;
        }

        result.add(
          KsChord(
            start: segStart,
            end: i,
            raw: text.substring(segStart, i),
            keys: keys,
          ),
        );
      }
    }

    return result;
  }

  /// Converts parsed segments to the token list the rest of the app uses.
  static List<InputToken> toTokens(List<KsSegment> segments) {
    final tokens = <InputToken>[];
    for (final seg in segments) {
      switch (seg) {
        case KsChord():
          tokens.addAll(seg.toTokens());
        case KsToken():
          final t = seg.toToken();
          if (t != null) tokens.add(t);
        default:
          break;
      }
    }
    return tokens;
  }

  /// Returns true when [tokens] (a list of `+key`/`-key` strings) can be
  /// expressed as one or more chords in `key1+key2+…, key3+…` notation.
  ///
  /// A token sequence is chord-expressible when it consists of one or more
  /// contiguous groups where each group has all presses before any release and
  /// every pressed key is released exactly once before the next group begins.
  static bool canExpressAsShortcut(List<InputToken> tokens) {
    if (tokens.isEmpty) return false;
    final held = <String>{};
    var seenReleaseInGroup = false;
    for (final token in tokens) {
      switch (token) {
        case PressInputToken(:final key):
          if (seenReleaseInGroup) return false; // press after release in group
          if (!held.add(key)) return false; // duplicate press
        case ReleaseInputToken(:final key):
          if (!held.remove(key)) return false; // release without press
          seenReleaseInGroup = true;
          if (held.isEmpty) seenReleaseInGroup = false; // group complete
        default:
          return false;
      }
    }
    return held.isEmpty;
  }

  /// Converts a token list that satisfies [canExpressAsShortcut] into a
  /// comma-separated chord string, e.g. `ctrl+shift+t` or `a, s, d`.
  static String tokensToShortcutString(List<InputToken> tokens) {
    final chords = <String>[];
    final currentGroup = <String>[];
    final held = <String>{};
    for (final token in tokens) {
      switch (token) {
        case PressInputToken(:final key):
          currentGroup.add(key);
          held.add(key);
        case ReleaseInputToken(:final key):
          held.remove(key);
          if (held.isEmpty) {
            chords.add(currentGroup.join('+'));
            currentGroup.clear();
          }
        default:
          break;
      }
    }
    return chords.join(', ');
  }
}
