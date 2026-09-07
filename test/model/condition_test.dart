import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/model/condition.dart';

void main() {
  group('normalizeConditionOrder', () {
    test(
      'moves groups after non-group siblings and preserves relative order',
      () {
        const leafA = VariableCondition(
          variable: ConditionVariableRef.custom('window_class'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('firefox'),
        );
        const leafB = VariableCondition(
          variable: ConditionVariableRef.custom('fingers'),
          operator: ConditionOperator.equals,
          value: ConditionValue.text('3'),
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
        variable: ConditionVariableRef.custom('window_class'),
        operator: ConditionOperator.equals,
        value: ConditionValue.text('firefox'),
      );
      const leafB = VariableCondition(
        variable: ConditionVariableRef.custom('fingers'),
        operator: ConditionOperator.equals,
        value: ConditionValue.text('3'),
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
}
