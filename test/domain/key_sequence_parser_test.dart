import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/model/action.dart';

InputToken press(String key) => InputToken.press(key);
InputToken release(String key) => InputToken.release(key);

void main() {
  group('KeySequenceParser.canExpressAsShortcut', () {
    group('returns true', () {
      test('single key press-release', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([press('a'), release('a')]),
          isTrue,
        );
      });

      test('modifier + key chord (standard release order)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('leftctrl'),
            press('leftshift'),
            press('t'),
            release('t'),
            release('leftshift'),
            release('leftctrl'),
          ]),
          isTrue,
        );
      });

      test('modifier + key chord (non-standard release order)', () {
        // ctrl released before t — still the same chord semantically
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('leftctrl'),
            press('t'),
            release('leftctrl'),
            release('t'),
          ]),
          isTrue,
        );
      });

      test('sequential single-key presses (a then s then d then f)', () {
        // NOT the same as a+s+d+f — these are four separate chords
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('a'),
            release('a'),
            press('s'),
            release('s'),
            press('d'),
            release('d'),
            press('f'),
            release('f'),
          ]),
          isTrue,
        );
      });

      test('two-key chord followed by single-key chord', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('leftctrl'),
            press('z'),
            release('z'),
            release('leftctrl'),
            press('a'),
            release('a'),
          ]),
          isTrue,
        );
      });

      test('a held while s is pressed then released (a+s)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('a'),
            press('s'),
            release('s'),
            release('a'),
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
            press('leftctrl'),
            press('t'),
            release('t'),
            press('a'),
            release('a'),
            release('leftctrl'),
          ]),
          isFalse,
        );
      });

      test('key released without being pressed', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([press('a'), release('b')]),
          isFalse,
        );
      });

      test('key pressed twice without release', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('a'),
            press('a'),
            release('a'),
          ]),
          isFalse,
        );
      });

      test('group left open (key never released)', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            press('a'),
            press('s'),
            release('s'),
          ]),
          isFalse,
        );
      });

      test('a chord is not a press/release sequence', () {
        expect(
          KeySequenceParser.canExpressAsShortcut([
            const InputToken.combo(['left', 'right']),
          ]),
          isFalse,
        );
      });
    });
  });

  group('KeySequenceParser.tokensToShortcutString', () {
    test('single key → bare key name', () {
      expect(
        KeySequenceParser.tokensToShortcutString([press('a'), release('a')]),
        equals('a'),
      );
    });

    test('modifier + key chord → joined with +', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          press('leftctrl'),
          press('leftshift'),
          press('t'),
          release('t'),
          release('leftshift'),
          release('leftctrl'),
        ]),
        equals('leftctrl+leftshift+t'),
      );
    });

    test('a held while s pressed then released → a+s', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          press('a'),
          press('s'),
          release('s'),
          release('a'),
        ]),
        equals('a+s'),
      );
    });

    test('sequential presses → comma-separated single keys, NOT one chord', () {
      // a, s, d, f — four chords — is distinct from a+s+d+f (one chord)
      expect(
        KeySequenceParser.tokensToShortcutString([
          press('a'),
          release('a'),
          press('s'),
          release('s'),
          press('d'),
          release('d'),
          press('f'),
          release('f'),
        ]),
        equals('a, s, d, f'),
      );
    });

    test('two-key chord then single key', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          press('leftctrl'),
          press('z'),
          release('z'),
          release('leftctrl'),
          press('a'),
          release('a'),
        ]),
        equals('leftctrl+z, a'),
      );
    });

    test('non-standard release order preserves press order in chord', () {
      expect(
        KeySequenceParser.tokensToShortcutString([
          press('leftctrl'),
          press('t'),
          release('leftctrl'),
          release('t'),
        ]),
        equals('leftctrl+t'),
      );
    });
  });
}
