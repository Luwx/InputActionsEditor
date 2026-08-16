import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/model/condition.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/action_list/widgets/action_group_flow.dart';

Condition _windowClassIs(String value) => ConditionGroup(
  children: [
    VariableCondition(
      variable: const ConditionVariableRef.known('window_class'),
      operator: ConditionOperator.equals,
      value: ConditionValue.text(value),
    ),
  ],
);

Condition _titleContains(String value) => VariableCondition(
  variable: const ConditionVariableRef.known('window_title'),
  operator: ConditionOperator.contains,
  value: ConditionValue.text(value),
);

Condition _isTrue(String variable) => VariableCondition(
  variable: ConditionVariableRef.known(variable),
  operator: ConditionOperator.equals,
  value: const ConditionValue.boolean(true),
);

TriggerAction _keys(String token) => TriggerAction(
  action: InputAction(
    entries: [
      InputEntry(device: InputDevice.keyboard, tokens: [token]),
    ],
  ),
);

/// Two levels of nesting, a negated list rule, a disabled step, a function
/// guard, a catch-all, and one action stranded behind it.
final List<TriggerAction> _complexGroup = [
  TriggerAction(
    conditions: _windowClassIs('firefox'),
    action: ActionGroup(
      actions: [
        TriggerAction(
          conditions: ConditionGroup(children: [_titleContains('YouTube')]),
          action: _keys('k').action,
        ),
        TriggerAction(
          conditions: ConditionGroup(
            mode: ConditionGroupMode.any,
            children: [_titleContains('GitHub'), _titleContains('GitLab')],
          ),
          action: ActionGroup(
            actions: [
              TriggerAction(
                conditions: ConditionGroup(
                  children: [_isTrue('window_fullscreen')],
                ),
                action: const CommandAction(
                  command: 'wmctrl -r :ACTIVE: -b remove,fullscreen',
                ),
              ),
              const TriggerAction(
                action: PlasmaShortcutAction(
                  component: 'kwin',
                  shortcut: 'Window Maximize',
                ),
              ),
            ],
          ),
        ),
        _keys('leftctrl+w'),
      ],
    ),
  ),
  const TriggerAction(
    conditions: ConditionGroup(
      children: [
        VariableCondition(
          variable: ConditionVariableRef.known('window_class'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('kitty'),
        ),
        VariableCondition(
          variable: ConditionVariableRef.custom('workspace'),
          operator: ConditionOperator.oneOf,
          value: ConditionValue.list(['2', '3']),
          negate: true,
        ),
      ],
    ),
    action: CommandAction(command: 'kitty @ new-window'),
  ),
  TriggerAction(
    enabled: false,
    conditions: ConditionGroup(children: [_isTrue('window_maximized')]),
    action: const SleepAction(milliseconds: 150),
  ),
  const TriggerAction(
    conditions: FunctionCondition(
      expression: '() => new Date().getHours() < 9',
    ),
    action: CommandAction(command: 'notify-send "too early"'),
  ),
  const TriggerAction(
    action: ActivateWindowAction(windowId: 'org.kde.dolphin'),
  ),
  TriggerAction(
    conditions: _windowClassIs('code'),
    action: const CommandAction(command: 'code --new-window'),
  ),
];

Widget _host(List<TriggerAction> actions) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: FTheme(
    data: AppThemes.zinc.dark.desktop,
    child: FScaffold(
      child: SingleChildScrollView(
        child: SizedBox(width: 560, child: ActionGroupFlow(actions: actions)),
      ),
    ),
  ),
);

Finder _richText(String text) => find.textContaining(text, findRichText: true);

void main() {
  testWidgets('reads a guarded action back as a sentence', (tester) async {
    await tester.pumpWidget(
      _host([
        TriggerAction(
          action: const CommandAction(command: 'firefox --new-window'),
          conditions: _windowClassIs('firefox'),
        ),
      ]),
    );

    expect(_richText('is firefox'), findsOneWidget);
    expect(_richText('Command'), findsOneWidget);
    expect(_richText('firefox --new-window'), findsOneWidget);
  });

  testWidgets('marks actions after an unconditional one as unreachable', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        TriggerAction(
          action: const CommandAction(command: 'guarded'),
          conditions: _windowClassIs('kitty'),
        ),
        const TriggerAction(action: CommandAction(command: 'fallback')),
        const TriggerAction(action: CommandAction(command: 'dead')),
      ]),
    );

    expect(_richText('Otherwise'), findsNWidgets(2));
    expect(find.text('never runs'), findsOneWidget);
  });

  testWidgets('unfolds sub-groups under a dotted step number', (tester) async {
    tester.view
      ..physicalSize = const Size(700, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(_complexGroup));

    // Numbered under the step that owns it.
    for (final label in ['1', '1.1', '1.2', '1.2.1', '1.2.2', '1.3', '6']) {
      expect(find.text(label), findsOneWidget, reason: 'step $label');
    }

    // Group lines hand off to their children instead of counting them.
    expect(_richText('First match   '), findsNothing);
    expect(
      _richText('contains GitHub or Active window - title contains GitLab'),
      findsOneWidget,
    );

    // Each level restarts at "If"; the rest fall through from it.
    expect(
      _richText('If Active window - app class is firefox'),
      findsOneWidget,
    );
    expect(_richText('Else if'), findsNWidgets(5));

    // Booleans read as statements; negation survives.
    expect(_richText('If Active window is fullscreen'), findsOneWidget);
    expect(_richText(r'not $workspace is one of 2, 3'), findsOneWidget);

    // Each level's last branch falls through; step 6 sits behind step 5.
    expect(_richText('Otherwise'), findsNWidgets(3));
    expect(find.text('never runs'), findsOneWidget);
    expect(find.text('disabled'), findsOneWidget);
  });

  testWidgets('says the first action always runs when nothing is guarded', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host([
        const TriggerAction(action: CommandAction(command: 'first')),
        const TriggerAction(action: CommandAction(command: 'second')),
      ]),
    );

    expect(_richText('Always'), findsOneWidget);
    expect(
      find.text(
        'The first action has no conditions, so it always runs and the ones '
        'below it never do.',
      ),
      findsOneWidget,
    );
  });
}
