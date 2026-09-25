import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/data/config_encoder.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:yaml/yaml.dart';

const _wiki = r'''
anchors:
  - &mouse_stroke_button [ back ]
  - &stroke_up [ 'MGQA0DMnPMwwAGQA' ]
  - &stroke_down [ 'MAAAMTNkZAA=' ]

mouse:
  gestures:
    - conditions: $window_class == firefox
      gestures:
        # Firefox triggers
        - type: stroke
          mouse_buttons: *mouse_stroke_button

          gestures:
            # Stroke triggers
            - strokes: *stroke_up
              actions:
                - input:
                    - keyboard: [ leftctrl+t ]

            - strokes: *stroke_down
              actions:
                - input:
                    - keyboard: [ leftctrl+n ]

        # Other Firefox triggers
        - type: press
          mouse_buttons: [ side ]

          actions:
            - input:
                - mouse: [ back ]

    - conditions: $window_class == VSCodium
      gestures:
        # VSCodium triggers
        - type: stroke
          mouse_buttons: *mouse_stroke_button

          gestures:
            # Stroke triggers
            - strokes: *stroke_up
              actions:
                - input:
                    - keyboard: [ leftctrl+pageup ]

            - strokes: *stroke_down
              actions:
                - input:
                    - keyboard: [ leftctrl+pagedown ]
''';

const _anchorsSection = '''
anchors:
  - &mouse_stroke_button [ back ]
  - &stroke_up [ 'MGQA0DMnPMwwAGQA' ]
  - &stroke_down [ 'MAAAMTNkZAA=' ]
''';

int _count(String text, String pattern) => pattern.allMatches(text).length;

GestureGroupNode _group(List<GestureNode> nodes, int index) =>
    nodes[index] as GestureGroupNode;

Config _withMouse(Config config, List<GestureNode> nodes) =>
    config.copyWith(mouseNodes: nodes);

void main() {
  final decoded = decodeConfig(_wiki);
  final firefox = _group(decoded.mouseNodes, 0);
  final codium = _group(decoded.mouseNodes, 1);
  final firefoxStrokes = _group(firefox.children, 0);

  test('an untouched file keeps its anchors and aliases', () {
    final encoded = encodeConfig(decoded, _wiki);

    expect(encoded, startsWith(_anchorsSection.trimLeft()));
    expect(_count(encoded, '*mouse_stroke_button'), 2);
    expect(_count(encoded, '*stroke_up'), 2);
    expect(_count(encoded, '*stroke_down'), 2);
    expect(decodeConfig(encoded), decoded);
    expect(encodeConfig(decodeConfig(encoded), encoded), encoded);
  });

  test('an edit keeps the anchors and every alias', () {
    final edited = _withMouse(decoded, [
      firefox,
      codium.copyWith(name: 'Codium'),
    ]);
    final encoded = encodeConfig(edited, _wiki);

    expect(encoded, startsWith(_anchorsSection.trimLeft()));
    expect(_count(encoded, '*mouse_stroke_button'), 2);
    expect(_count(encoded, '*stroke_up'), 2);
    expect(_count(encoded, '*stroke_down'), 2);
    expect(decodeConfig(encoded), edited);
  });

  test('a value changed away from its anchor is written literally', () {
    final edited = _withMouse(decoded, [
      firefox.copyWith(
        children: [
          firefoxStrokes.copyWith(mouseButtons: [MouseButtonValue.middle]),
          ...firefox.children.skip(1),
        ],
      ),
      codium,
    ]);
    final encoded = encodeConfig(edited, _wiki);

    expect(_count(encoded, '*mouse_stroke_button'), 1);
    expect(decodeConfig(encoded), edited);
  });

  test('a duplicated gesture keeps its aliases', () {
    final strokeUp = firefoxStrokes.children.first;
    final edited = _withMouse(decoded, [
      firefox.copyWith(
        children: [
          firefoxStrokes.copyWith(
            children: [strokeUp, strokeUp, ...firefoxStrokes.children.skip(1)],
          ),
          ...firefox.children.skip(1),
        ],
      ),
      codium,
    ]);
    final encoded = encodeConfig(edited, _wiki);

    expect(_count(encoded, '*stroke_up'), 3);
    expect(decodeConfig(encoded), edited);
  });

  test('a disabled group keeps its aliases inside the comment', () {
    final edited = _withMouse(decoded, [
      firefox,
      codium.copyWith(enabled: false),
    ]);
    final encoded = encodeConfig(edited, _wiki);

    expect(encoded, contains('# - strokes: *stroke_up'));
    expect(decodeConfig(encoded), edited);
  });

  test('aliases to an anchor lost with its gesture list are expanded', () {
    const original = '''
mouse:
  gestures:
    - type: stroke
      strokes: &up [ 'MGQA0DMnPMwwAGQA' ]
    - type: stroke
      strokes: *up

touchpad:
  gestures:
    - type: stroke
      fingers: 2
      strokes: *up
''';
    final config = decodeConfig(original);
    final first = config.mouseGestures.first as StrokeGesture;
    final edited = _withMouse(config, [
      GestureNode.leaf(first.copyWith(strokes: [const Stroke('MAAAMTNkZAA=')])),
      ...config.mouseNodes.skip(1),
    ]);
    final encoded = encodeConfig(edited, original);

    expect(encoded, isNot(contains('*up')));
    expect(() => loadYaml(encoded), returnsNormally);
    expect(decodeConfig(encoded), edited);
  });
}
