import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/data/config_encoder.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';

/// The block from issue #4: a whole config kept as a comment for reference.
const referenceBlock = r'''
#device_rules:
#  - conditions:
#      all:
#        - any: # remove some conditions if you don't use triggers for a device
#          - $types contains keyboard # keyboards must be grabbed
#          - $types contains mouse # ungrabbed mice are currently very buggy
#        - not: # blacklist
#          - $name == Yubico YubiKey OTP+FIDO+CCID
#    grab: true
#    ignore: false
#
#  - conditions: $types != keyboard
#    ignore: true # ignore all devices other than keyboards

#mouse:
#  gestures:
#    - type: stroke
#      strokes: [ 'N2QAyywAZAA=' ]
#      mouse_buttons: [ extra1 ] # comment
##      mouse_buttons: [ extra1 ] # comment
#
#      actions:
#        - on: begin
#          input:
#            - keyboard: [ a ]
''';

const realConfig = '''
mouse:
  gestures:
    - type: press
      mouse_buttons: [ side ]
      actions:
        - command: echo hi
''';

void main() {
  group('commented-out reference configs are left alone', () {
    test('a commented config on its own loads as an empty config', () {
      final config = decodeConfig(referenceBlock);
      expect(config.totalGestureCount, 0);
      expect(config.deviceRules, isEmpty);
    });

    test('a commented config above a real one does not disturb it', () {
      final config = decodeConfig(referenceBlock + realConfig);
      expect(config.mouseGestures, hasLength(1));
      expect(config.mouseGestures.single.triggerType, MouseTriggerType.press);
      expect(config.deviceRules, isEmpty);
    });

    test('the commented block survives a save unchanged', () {
      const source = '$referenceBlock$realConfig';
      final encoded = encodeConfig(decodeConfig(source), source);
      expect(encoded, contains(referenceBlock.trimRight()));
    });

    test('a commented gestures: key does not turn prose into gestures', () {
      final config = decodeConfig('''
$realConfig
# An example from the wiki:
#  gestures:
#    - type: stroke
#      strokes: [ 'N2QAyywAZAA=' ]
''');
      expect(config.mouseGestures, hasLength(1));
    });

    test('a commented condition inside a live conditions block is prose', () {
      final config = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions:
        all:
          - $device_name == Mouse
          # - $window_class == firefox
      actions:
        - command: echo hi
''');
      expect(config.mouseGestures, hasLength(1));
    });
  });

  group('disabled items still round-trip', () {
    test('a disabled gesture written by the editor is recovered', () {
      const source = '''
mouse:
  gestures:
    # - type: press
      # actions:
        # # - command: echo hi
          # # _extra:
            # # enabled: false
      # _extra:
        # enabled: false
''';
      final config = decodeConfig(source);
      expect(config.mouseGestures, hasLength(1));
      expect(config.mouseGestures.single.common.enabled, false);
      expect(config.mouseGestures.single.common.actions, hasLength(1));
    });

    test('a disabled gesture survives decode -> encode -> decode', () {
      const source = '''
mouse:
  gestures:
    - type: press
      actions:
        - command: echo hi
      _extra:
        enabled: false
''';
      final encoded = encodeConfig(decodeConfig(source), source);
      final back = decodeConfig(encoded);
      expect(back.mouseGestures, hasLength(1));
      expect(back.mouseGestures.single.common.enabled, false);
      expect(back.mouseGestures.single.common.actions, hasLength(1));
    });

    test('a disabled action inside a live gesture is recovered', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - command: echo hi
        # - command: echo bye
          # _extra:
            # enabled: false
''');
      expect(config.mouseGestures.single.common.actions, hasLength(2));
      expect(
        config.mouseGestures.single.common.actions.last.enabled,
        false,
      );
    });
  });

  group('unparseable materialization falls back to the text as written', () {
    test('prose at item indent under a live gestures key', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - command: echo hi
    # - and then it broke: [ unclosed
''');
      expect(config.mouseGestures, hasLength(1));
    });

    test('a genuinely malformed config still reports its own error', () {
      expect(
        () => decodeConfig('mouse:\n  gestures: [ unclosed\n'),
        throwsA(anything),
      );
    });
  });

  test('an edit near an anchor saves, written out in full', () {
    const source = '''
anchors:
  - &button [ back ]

custom_key: kept

mouse:
  gestures:
    - type: press
      mouse_buttons: *button
''';
    final config = decodeConfig(source);
    final press = config.mouseGestures.single as PressGesture;
    final edited = config.withNodesForDevice(DeviceType.mouse, [
      GestureNode.leaf(
        press.copyWith(common: press.common.copyWith(name: 'Back')),
      ),
    ]);
    final encoded = encodeConfig(edited, source);

    expect(encoded, isNot(contains('*button')));
    expect(encoded, contains('custom_key: kept'));
    expect(decodeConfig(encoded), edited);
  });
}
