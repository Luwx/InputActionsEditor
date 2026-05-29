import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/data/yaml_io.dart';
import 'package:input_actions_editor/model/condition.dart';

void main() {
  group('normalizeConditionOrder', () {
    test(
      'moves groups after non-group siblings and preserves relative order',
      () {
        const leafA = VariableCondition(
          variable: 'window_class',
          operator: '==',
          value: 'firefox',
        );
        const leafB = VariableCondition(
          variable: 'fingers',
          operator: '==',
          value: '3',
        );
        const raw = RawCondition(raw: r'$window_title contains docs');
        const nestedA = ConditionGroup(children: [leafA]);
        const nestedB = ConditionGroup(children: [leafB]);

        final normalized =
            normalizeConditionOrder(
                  const ConditionGroup(
                    children: [nestedA, leafA, raw, nestedB, leafB],
                  ),
                )
                as ConditionGroup;

        expect(normalized.children, [leafA, raw, leafB, nestedA, nestedB]);
      },
    );

    test('normalizes nested groups recursively', () {
      const leafA = VariableCondition(
        variable: 'window_class',
        operator: '==',
        value: 'firefox',
      );
      const leafB = VariableCondition(
        variable: 'fingers',
        operator: '==',
        value: '3',
      );
      const inner = ConditionGroup(
        children: [
          ConditionGroup(children: [leafB]),
          leafA,
        ],
      );

      final normalized =
          normalizeConditionOrder(
                const ConditionGroup(children: [inner]),
              )
              as ConditionGroup;
      final normalizedInner = normalized.children.single as ConditionGroup;

      expect(normalizedInner.children, [
        leafA,
        const ConditionGroup(children: [leafB]),
      ]);
    });
  });

  group('conditionToYaml', () {
    test('writes groups after non-group siblings recursively', () {
      const leafA = VariableCondition(
        variable: 'window_class',
        operator: '==',
        value: 'firefox',
      );
      const leafB = VariableCondition(
        variable: 'fingers',
        operator: '==',
        value: '3',
      );
      const condition = ConditionGroup(
        children: [
          ConditionGroup(
            mode: ConditionGroupMode.any,
            children: [
              ConditionGroup(children: [leafB]),
              leafA,
            ],
          ),
          leafB,
        ],
      );

      expect(conditionToYaml(condition), {
        'all': [
          r'$fingers == 3',
          {
            'any': [
              r'$window_class == firefox',
              r'$fingers == 3',
            ],
          },
        ],
      });
    });
  });
}
