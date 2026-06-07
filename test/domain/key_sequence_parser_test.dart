import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';

void main() {
  group('KeySequenceParser.canExpressAsShortcut', () {
    group('returns true', () {
      test('single key press-release', () {
        expect(
          KeySequenceParser.canExpressAsShortcut(['+a', '-a']),
          isTrue,
        );
      });

      test('modifier + key chord (standard release order)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+leftctrl',
            '+leftshift',
            '+t',
            '-t',
            '-leftshift',
            '-leftctrl',
          ]),
          isTrue,
        );
      });

      test('modifier + key chord (non-standard release order)', () {
        // ctrl released before t — still the same chord semantically
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+leftctrl',
            '+t',
            '-leftctrl',
            '-t',
          ]),
          isTrue,
        );
      });

      test('sequential single-key presses (a then s then d then f)', () {
        // NOT the same as a+s+d+f — these are four separate chords
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+a',
            '-a',
            '+s',
            '-s',
            '+d',
            '-d',
            '+f',
            '-f',
          ]),
          isTrue,
        );
      });

      test('two-key chord followed by single-key chord', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+leftctrl',
            '+z',
            '-z',
            '-leftctrl',
            '+a',
            '-a',
          ]),
          isTrue,
        );
      });

      test('a held while s is pressed then released (a+s)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+a',
            '+s',
            '-s',
            '-a',
          ]),
          isTrue,
        );
      });
    });

    group('returns false', () {
      test('empty token list', () {
        expect(KeySequenceParser.canExpressAsShortcut([]), isFalse);
      });

      test('press after release within same group', () {
        // ctrl held, t pressed+released, then a pressed while ctrl still down
        expect(
          KeySequenceParser.canExpressAsShortcut([
            '+leftctrl',
            '+t',
            '-t',
            '+a',
            '-a',
            '-leftctrl',
          ]),
          isFalse,
        );
      });

      test('key released without being pressed', () {
        expect(
          KeySequenceParser.canExpressAsShortcut(['+a', '-b']),
          isFalse,
        );
      });

      test('key pressed twice without release', () {
        expect(
          KeySequenceParser.canExpressAsShortcut(['+a', '+a', '-a']),
          isFalse,
        );
      });

      test('group left open (key never released)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut(['+a', '+s', '-s']),
          isFalse,
        );
      });

      test('non-keyboard token', () {
        expect(
          KeySequenceParser.canExpressAsShortcut(['left+right']),
          isFalse,
        );
      });
    });
  });

  group('KeySequenceParser.tokensToShortcutString', () {
    test('single key → bare key name', () {
      expect(
        KeySequenceParser.tokensToShortcutString(['+a', '-a']),
        equals('a'),
      );
    });

    test('modifier + key chord → joined with +', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          '+leftctrl',
          '+leftshift',
          '+t',
          '-t',
          '-leftshift',
          '-leftctrl',
        ]),
        equals('leftctrl+leftshift+t'),
      );
    });

    test('a held while s pressed then released → a+s', () {
      expect(
        KeySequenceParser.tokensToShortcutString(['+a', '+s', '-s', '-a']),
        equals('a+s'),
      );
    });

    test('sequential presses → comma-separated single keys, NOT one chord', () {
      // a, s, d, f — four chords — is distinct from a+s+d+f (one chord)
      expect(
        KeySequenceParser.tokensToShortcutString([
          '+a',
          '-a',
          '+s',
          '-s',
          '+d',
          '-d',
          '+f',
          '-f',
        ]),
        equals('a, s, d, f'),
      );
    });

    test('two-key chord then single key', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          '+leftctrl',
          '+z',
          '-z',
          '-leftctrl',
          '+a',
          '-a',
        ]),
        equals('leftctrl+z, a'),
      );
    });

    test('non-standard release order preserves press order in chord', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          '+leftctrl',
          '+t',
          '-leftctrl',
          '-t',
        ]),
        equals('leftctrl+t'),
      );
    });
  });
}
