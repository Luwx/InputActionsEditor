import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/domain/misc/value_string_parser.dart';

void main() {
  const knownVariables = {'initial_window_id', 'window_id'};

  test('empty value is incomplete', () {
    final result = analyzeValueString('', knownVariables: knownVariables);
    expect(result.kind, ValueStringKind.empty);
    expect(result.variableName, isNull);
  });

  test('plain text is a literal value', () {
    final result = analyzeValueString('abc123', knownVariables: knownVariables);
    expect(result.kind, ValueStringKind.literal);
    expect(result.variableName, isNull);
  });

  test('exact known dollar variable is recognized', () {
    final result = analyzeValueString(
      r'$initial_window_id',
      knownVariables: knownVariables,
    );
    expect(result.kind, ValueStringKind.knownVariable);
    expect(result.variableName, 'initial_window_id');
  });

  test('exact unknown dollar variable is allowed as a warning state', () {
    final result = analyzeValueString(
      r'$custom_window_id',
      knownVariables: knownVariables,
    );
    expect(result.kind, ValueStringKind.unknownVariable);
    expect(result.variableName, 'custom_window_id');
  });

  test(
    'variable-like text with extra content is invalid interpolation syntax',
    () {
      final result = analyzeValueString(
        r'$initial_window_id suffix',
        knownVariables: knownVariables,
      );
      expect(result.kind, ValueStringKind.invalidVariableExpression);
      expect(result.variableName, isNull);
    },
  );
}
