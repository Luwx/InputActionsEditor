import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/config_decoder.dart';
import 'package:input_actions_editor/data/config_encoder.dart';
import 'package:input_actions_editor/data/yaml/stroke_yaml.dart';
import 'package:input_actions_editor/domain/edit/edits/stroke_edits.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/stroke.dart';
import 'package:input_actions_editor/model/touchpad_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:yaml/yaml.dart';

const _up = 'MGQA0DMnPMwwAGQA';
const _down = 'MAAAMTNkZAA=';

const _named =
    '''
anchors:
  - &swipe_up '$_up'


mouse:
  gestures:
    - type: stroke
      strokes: [ *swipe_up, '$_down' ]


touchpad:
  gestures:
    - type: stroke
      fingers: 2
      strokes: [ *swipe_up ]
''';

const _unnamed =
    '''
mouse:
  gestures:
    - type: stroke
      strokes: [ '$_up', '$_down' ]
''';

const _listAnchors =
    '''
anchors:
  - &button [ back ]
  - &stroke_up [ '$_up' ]
  - &stroke_down [ '$_down' ]


mouse:
  gestures:
    - type: stroke
      mouse_buttons: *button
      gestures:
        - strokes: *stroke_up
        - strokes: *stroke_down
''';

List<Stroke> _mouseStrokes(Config config) =>
    (config.mouseGestures.single as StrokeGesture).strokes;

List<Stroke> _touchpadStrokes(Config config) =>
    (config.touchpadGestures.single as TouchpadStrokeGesture).strokes;

Config _renamed(String yaml, String data, String? name) =>
    RenameStroke(data, name).apply(decodeConfig(yaml));

String _saved(String yaml, String data, String? name) =>
    encodeConfig(_renamed(yaml, data, name), yaml);

void main() {
  group('decoding', () {
    test('a stroke aliasing a root anchor carries its name', () {
      final config = decodeConfig(_named);

      expect(_mouseStrokes(config), const [
        Stroke(_up, name: 'swipe_up'),
        Stroke(_down),
      ]);
      expect(_touchpadStrokes(config), const [Stroke(_up, name: 'swipe_up')]);
    });

    test('an anchor written on the stroke itself names it', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: stroke
      strokes: [ &swipe_up '$_up' ]
    - type: stroke
      strokes: [ *swipe_up ]
''');

      expect(config.strokes, const [
        Stroke(_up, name: 'swipe_up'),
        Stroke(_up, name: 'swipe_up'),
      ]);
    });

    test('a list anchor around one stroke names it', () {
      final config = decodeConfig(_listAnchors);

      expect(config.strokes, const [
        Stroke(_up, name: 'stroke_up'),
        Stroke(_down, name: 'stroke_down'),
      ]);
    });

    test('a list anchor around several strokes names none', () {
      final config = decodeConfig('''
anchors:
  - &both [ '$_up', '$_down' ]

mouse:
  gestures:
    - type: stroke
      strokes: *both
''');

      expect(config.strokes, const [Stroke(_up), Stroke(_down)]);
    });
  });

  group('encoding', () {
    test('a list anchor around one stroke saves as a stroke anchor', () {
      final config = decodeConfig(_listAnchors);
      final saved = encodeConfig(config, _listAnchors);

      expect(saved, contains('  - &button [ back ]'));
      expect(saved, contains("  - &stroke_up '$_up'"));
      expect(saved, contains("  - &stroke_down '$_down'"));
      expect(saved, isNot(contains("[ '")));
      expect(saved, contains('mouse_buttons: *button'));
      expect(() => loadYaml(saved), returnsNormally);
      expect(decodeConfig(saved), config);
      expect(encodeConfig(decodeConfig(saved), saved), saved);
    });

    test('an untouched file with named strokes saves as it was', () {
      expect(encodeConfig(decodeConfig(_named), _named), _named);
    });

    test('naming a stroke defines it above the first key', () {
      final saved = _saved(_unnamed, _up, 'swipe_up');

      expect(saved, startsWith("anchors:\n  - &swipe_up '$_up'\n\n\nmouse:"));
      expect(saved, contains('*swipe_up'));
      expect(decodeConfig(saved), _renamed(_unnamed, _up, 'swipe_up'));
    });

    test('naming a stroke adds it to an existing anchors list', () {
      const source =
          '''
anchors:
  - &button [ back ]

mouse:
  gestures:
    - type: stroke
      mouse_buttons: *button
      strokes: [ '$_up' ]
''';
      final saved = _saved(source, _up, 'swipe_up');

      expect(saved, contains("  - &button [ back ]\n  - &swipe_up '$_up'"));
      expect(saved, contains('mouse_buttons: *button'));
      expect(decodeConfig(saved), _renamed(source, _up, 'swipe_up'));
    });

    test('a stroke saved with its quotes loads and saves without them', () {
      const source =
          '''
mouse:
  gestures:
    - type: stroke
      strokes:
        - "'$_up'"
''';
      final config = decodeConfig(source);

      expect(config.strokes, const [Stroke(_up)]);
      expect(encodeConfig(config, source), isNot(contains('"\'')));
      expect(
        _saved(source, _up, 'swipe_up'),
        contains("  - &swipe_up '$_up'"),
      );
    });

    test('renaming a stroke renames its definition and every use', () {
      final saved = _saved(_named, _up, 'up');

      expect(saved, contains("  - &up '$_up'"));
      expect('*up'.allMatches(saved), hasLength(2));
      expect(saved, isNot(contains('swipe_up')));
      expect(decodeConfig(saved), _renamed(_named, _up, 'up'));
    });

    test('clearing a name drops its definition and writes the stroke out', () {
      final saved = _saved(_named, _up, null);

      expect(saved, isNot(contains('anchors:')));
      expect(saved, isNot(contains('swipe_up')));
      expect(decodeConfig(saved).strokes, everyElement(isA<Stroke>()));
      expect(decodeConfig(saved), _renamed(_named, _up, null));
    });

    test('a name another anchor holds moves that anchor aside', () {
      const source =
          '''
anchors:
  - &up [ back ]

mouse:
  gestures:
    - type: stroke
      mouse_buttons: *up
      strokes: [ '$_up' ]
''';
      final saved = _saved(source, _up, 'up');

      expect(saved, contains('&up_2 [ back ]'));
      expect(saved, contains('mouse_buttons: *up_2'));
      expect(saved, contains('strokes:\n        - *up'));
      expect(decodeConfig(saved), _renamed(source, _up, 'up'));
    });

    test('an anchor on the stroke itself moves up to the anchors', () {
      const source =
          '''
mouse:
  gestures:
    - type: stroke
      strokes: [ &swipe_up '$_up' ]
    - type: stroke
      strokes: [ *swipe_up ]
''';
      final edited = decodeConfig(source);
      final first = edited.mouseGestures.first as StrokeGesture;
      final moved = edited.copyWith(
        mouseNodes: [
          GestureNode.leaf(first.copyWith(common: const TriggerCommon())),
          ...edited.mouseNodes.skip(1),
        ],
      );
      final saved = encodeConfig(moved, source);

      expect(saved, startsWith("anchors:\n  - &swipe_up '$_up'\n"));
      expect('&swipe_up'.allMatches(saved), hasLength(1));
      expect(decodeConfig(saved), moved);
    });

    test('an unnamed copy of a named stroke stays unnamed', () {
      final config = decodeConfig(_named);
      final mouse = config.mouseGestures.single as StrokeGesture;
      final edited = config.copyWith(
        mouseNodes: [
          GestureNode.leaf(
            mouse.copyWith(strokes: [...mouse.strokes, const Stroke(_up)]),
          ),
        ],
      );
      final saved = encodeConfig(edited, _named);

      expect(decodeConfig(saved), edited);
    });

    test('a copied gesture carries its stroke names', () {
      const gesture = StrokeGesture(
        common: TriggerCommon(),
        strokes: [Stroke(_up, name: 'swipe_up')],
      );
      final snippet = encodeConfig(
        const Config(mouseNodes: [GestureNode.leaf(gesture)]),
        '',
      );

      expect(() => loadYaml(snippet), returnsNormally);
      expect(decodeConfig(snippet).strokes, gesture.strokes);
    });
  });

  group('clipboard snippets', () {
    test('a named stroke survives the round trip', () {
      const strokes = [Stroke(_up, name: 'swipe_up'), Stroke(_down)];

      expect(decodeStrokesYaml(encodeStrokesYaml(strokes)), strokes);
    });

    test('a stroke copied with its quotes pastes without them', () {
      expect(decodeStrokesYaml('strokes:\n  - "\'$_up\'"'), const [
        Stroke(_up),
      ]);
    });
  });
}
