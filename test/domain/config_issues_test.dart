import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_codec.dart';
import 'package:input_actions_editor/domain/config_issues.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:yaml/yaml.dart';

List<String> issuesIn(String yaml) =>
    findConfigIssues(decodeConfig(yaml)).map((i) => i.raw).toList();

void main() {
  group('clean configs report nothing', () {
    test('quoted negation', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: '!$cursor_shape == pointer'
'''),
        isEmpty,
      );
    });

    test('nested groups', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions:
        all:
          - $window_class == firefox
          - any:
              - $window_maximized == true
              - $window_fullscreen == true
'''),
        isEmpty,
      );
    });

    test('the full fixture', () {
      expect(findConfigIssues(decodeConfig(_fixtureLike)), isEmpty);
    });

    test('unquoted negation is recovered, not flagged', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: !$cursor_shape == pointer
    - type: press
      conditions:
        - all:
            - !$cursor_shape == pointer
            - $window_class == firefox
    - type: press
      end_conditions: !$window_fullscreen
device_rules:
  - conditions: !$name == Foo
    grab: true
'''),
        isEmpty,
      );
    });
  });

  group('detected: malformed conditions', () {
    test('unknown operator nested inside a group', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions:
        - all:
            - $cursor_shape ~~ pointer
            - $window_class == firefox
'''),
        [r'$cursor_shape ~~ pointer'],
      );
    });

    test('unknown operator', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: $window_class ~~ firefox
'''),
        [r'$window_class ~~ firefox'],
      );
    });

    test(r'missing $ prefix', () {
      expect(
        issuesIn('''
mouse:
  gestures:
    - type: press
      conditions: window_class == firefox
'''),
        ['window_class == firefox'],
      );
    });

    test('truncated expression', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: $window_class ==
'''),
        [r'$window_class =='],
      );
    });

    test('unknown group mode', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions:
        or:
          - $window_class == firefox
'''),
        [r'{or: [$window_class == firefox]}'],
      );
    });

    test('end_conditions and action conditions are walked too', () {
      expect(
        issuesIn(r'''
touchpad:
  gestures:
    - type: tap
      fingers: 3
      end_conditions: $window_fullscreen ~~ a
      actions:
        - conditions: $window_maximized ~~ b
          command: echo hi
'''),
        [r'$window_fullscreen ~~ a', r'$window_maximized ~~ b'],
      );
    });

    test('device rule conditions carry no device or gesture', () {
      final issues = findConfigIssues(
        decodeConfig(r'''
device_rules:
  - conditions: $name ~~ Foo
    grab: true
'''),
      );
      expect(issues.single.raw, r'$name ~~ Foo');
      expect(issues.single.device, isNull);
      expect(issues.single.gestureName, isNull);
    });

    test('issue carries its device and gesture name', () {
      final issues = findConfigIssues(
        decodeConfig(r'''
touchscreen:
  gestures:
    - type: tap
      name: Broken One
      conditions: $cursor_shape ~~ pointer
'''),
      );
      expect(issues.single.device, DeviceType.touchscreen);
      expect(issues.single.gestureName, 'Broken One');
    });

    test('several broken conditions across devices', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: $cursor_shape ~~ pointer
keyboard:
  gestures:
    - type: shortcut
      shortcut: [meta, a]
      conditions: window_class == firefox
touchpad:
  gestures:
    - type: tap
      fingers: 3
      conditions: $foo ~~ bar
''').length,
        3,
      );
    });
  });

  group('surface as load failures, not issues', () {
    void expectThrows(String yaml) =>
        expect(() => decodeConfig(yaml), throwsA(isA<Object>()));

    test('tab indentation', () {
      expectThrows('mouse:\n\tgestures:\n\t\t- type: press\n');
    });

    test('duplicate mapping key', () {
      expectThrows('''
mouse:
  gestures:
    - type: press
      name: A
      name: B
''');
    });

    test('unclosed quote', () {
      expectThrows('''
mouse:
  gestures:
    - type: press
      name: "unclosed
''');
    });

    test('wrong scalar type for a typed field', () {
      expect(
        () => decodeConfig('''
touchpad:
  gestures:
    - type: tap
      fingers: "3"
'''),
        throwsA(isA<TypeError>()),
      );
    });

    test('YamlException is what the load path reports', () {
      expect(
        () => decodeConfig('mouse:\n\tgestures: []\n'),
        throwsA(isA<YamlException>()),
      );
    });
  });

  // Mistakes that currently pass silently. Asserted so a future fix flips them
  // visibly rather than going unnoticed.
  group('undetected: silent drops and coercions', () {
    test('misspelled gesture type drops the gesture', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: swip
      name: Gone
''');
      expect(config.mouseGestures, isEmpty);
      expect(findConfigIssues(config), isEmpty);
    });

    test('missing type drops the gesture', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - name: Gone
      actions:
        - command: echo hi
''');
      expect(config.mouseGestures, isEmpty);
      expect(findConfigIssues(config), isEmpty);
    });

    test('gestures written as a map drops every gesture', () {
      final config = decodeConfig('''
mouse:
  gestures:
    type: press
''');
      expect(config.mouseGestures, isEmpty);
      expect(findConfigIssues(config), isEmpty);
    });

    test('actions written as a map drops every action', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        command: echo hi
''');
      expect(config.mouseGestures.single.common.actions, isEmpty);
      expect(findConfigIssues(config), isEmpty);
    });

    test('invalid direction silently becomes "any"', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: wheel
      direction: upp
''');
      final gesture = config.mouseGestures.single as WheelGesture;
      expect(gesture.direction, WheelDirection.any);
      expect(findConfigIssues(config), isEmpty);
    });

    test('invalid speed silently becomes null', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: swipe
      direction: left
      speed: superfast
''');
      expect(config.mouseGestures, hasLength(1));
      expect(findConfigIssues(config), isEmpty);
    });

    test('unknown variable is accepted as a custom one', () {
      expect(
        issuesIn(r'''
mouse:
  gestures:
    - type: press
      conditions: $made_up_variable == 1
'''),
        isEmpty,
      );
    });

    test('misspelled top-level key is kept in extra', () {
      final config = decodeConfig('''
mouses:
  gestures:
    - type: press
''');
      expect(config.extra.keys, ['mouses']);
      expect(config.mouseGestures, isEmpty);
      expect(findConfigIssues(config), isEmpty);
    });

    test('misspelled action key falls back to a raw action', () {
      final config = decodeConfig('''
mouse:
  gestures:
    - type: press
      actions:
        - commnd: echo hi
''');
      expect(config.mouseGestures.single.common.actions, hasLength(1));
      expect(findConfigIssues(config), isEmpty);
    });
  });

  group('source location', () {
    ConfigIssue only(String yaml) =>
        findConfigIssues(decodeConfig(yaml), yaml).single;

    test('resolves the line and original text', () {
      const yaml = r'''
mouse:
  gestures:
    - type: press
      name: First
      conditions: $window_class == firefox
    - type: wheel
      name: Second
      conditions: $cursor_shape ~~ pointer
''';
      final issue = only(yaml);
      expect(issue.line, 8);
      expect(issue.sourceLine, r'      conditions: $cursor_shape ~~ pointer');
      expect(issue.gestureName, 'Second');
      expect(issue.source, ConfigIssueSource.conditions);
    });

    test('points at the offending line inside a nested group', () {
      const yaml = r'''
mouse:
  gestures:
    - type: press
      name: Nested
      conditions:
        - all:
            - $window_class == firefox
            - $cursor_shape ~~ pointer
''';
      final issue = only(yaml);
      expect(issue.line, 8);
      expect(issue.sourceLine!.trim(), r'- $cursor_shape ~~ pointer');
    });

    test('locates end_conditions and action conditions separately', () {
      const yaml = r'''
touchpad:
  gestures:
    - type: tap
      fingers: 3
      name: Tap
      end_conditions: $window_fullscreen ~~ a
      actions:
        - conditions: $window_maximized ~~ b
          command: echo hi
''';
      final issues = findConfigIssues(decodeConfig(yaml), yaml);
      expect(issues.map((i) => i.line), [6, 8]);
      expect(issues.map((i) => i.source), [
        ConfigIssueSource.endConditions,
        ConfigIssueSource.actionConditions,
      ]);
    });

    test('locates device rules', () {
      const yaml = r'''
device_rules:
  - grab: true
  - conditions: $name ~~ Foo
    ignore: true
''';
      final issue = only(yaml);
      expect(issue.line, 3);
      expect(issue.source, ConfigIssueSource.deviceRule);
    });

    test('no line when source text is not supplied', () {
      final issue = findConfigIssues(
        decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: $cursor_shape ~~ pointer
'''),
      ).single;
      expect(issue.line, isNull);
      expect(issue.sourceLine, isNull);
      expect(issue.context, isEmpty);
    });

    test('context is the whole enclosing gesture', () {
      const yaml = r'''
mouse:
  gestures:
    - type: press
      name: Ignored
    - type: wheel
      name: Target
      direction: up
      conditions: $cursor_shape ~~ pointer
      actions:
        - command: echo hi
''';
      final issue = only(yaml);
      expect(issue.contextStart, 5);
      expect(issue.context, [
        '    - type: wheel',
        '      name: Target',
        '      direction: up',
        r'      conditions: $cursor_shape ~~ pointer',
        '      actions:',
        '        - command: echo hi',
      ]);
      expect(issue.sourceLine, issue.context[3]);
    });

    test('context for an action condition is just that action', () {
      const yaml = r'''
mouse:
  gestures:
    - type: press
      name: Multi
      actions:
        - command: echo one
        - conditions: $window_maximized ~~ b
          command: echo two
        - command: echo three
''';
      final issue = only(yaml);
      expect(issue.contextStart, 7);
      expect(issue.context, [
        r'        - conditions: $window_maximized ~~ b',
        '          command: echo two',
      ]);
    });

    test('context for a device rule is just that rule', () {
      const yaml = r'''
device_rules:
  - grab: true
  - conditions: $name ~~ Foo
    ignore: true
''';
      final issue = only(yaml);
      expect(issue.contextStart, 3);
      expect(issue.context, [
        r'  - conditions: $name ~~ Foo',
        '    ignore: true',
      ]);
    });

    test('locates past a commented-out disabled gesture', () {
      // The disabled gesture is decoded but absent from the source list, so
      // every index after it shifts and only the content fallback resolves.
      const yaml = r'''
mouse:
  gestures:
    # - type: press
    #   name: Disabled
    - type: wheel
      name: Real
      conditions: $cursor_shape ~~ pointer
''';
      final issue = only(yaml);
      expect(issue.gestureName, 'Real');
      expect(issue.line, 7);
    });

    test('no location when the text does not contain the condition', () {
      final config = decodeConfig(r'''
mouse:
  gestures:
    - type: press
      conditions: $cursor_shape ~~ pointer
''');
      final issue = findConfigIssues(config, '''
mouse:
  gestures:
    - type: press
''').single;
      expect(issue.line, isNull);
      expect(issue.context, isEmpty);
    });

    test('locates inside an untyped group, which the decoder flattens', () {
      const yaml = r'''
mouse:
  gestures:

    - conditions:
        - $window_fullscreen == false

      gestures:
        - type: press
          instant: true
          conditions:
            - $cursor_shape == pointer

        - type: press
          instant: true
          conditions:
            - all:
                - $cursor_shape ~~ pointer
                - $window_class == firefox

          actions:
            - on: begin
              input:
                - keyboard: [ leftctrl+t ]
''';
      final issue = only(yaml);
      expect(issue.line, 17);
      expect(issue.sourceLine!.trim(), r'- $cursor_shape ~~ pointer');
      // The enclosing gesture, not the whole group, and the second one — the
      // first gesture's '$cursor_shape == pointer' must not match.
      expect(issue.contextStart, 13);
      expect(issue.context.first.trim(), '- type: press');
      expect(issue.context.last.trim(), '- keyboard: [ leftctrl+t ]');
    });

    test('identical conditions on two gestures get distinct lines', () {
      const yaml = r'''
mouse:
  gestures:
    - type: press
      name: A
      conditions: $cursor_shape ~~ pointer
    - type: wheel
      name: B
      conditions: $cursor_shape ~~ pointer
''';
      expect(
        findConfigIssues(decodeConfig(yaml), yaml).map((i) => i.line),
        [5, 8],
      );
    });
  });
}

const _fixtureLike = r'''
mouse:
  gestures:
    - type: press
      name: Good
      conditions: $window_class == firefox
      actions:
        - command: echo hi
touchpad:
  gestures:
    - type: swipe
      fingers: 3
      direction: left
      conditions:
        none:
          - $window_fullscreen == true
device_rules:
  - conditions: $name == Synaptics
    grab: true
''';
