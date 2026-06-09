enum ValueStringKind {
  empty,
  literal,
  knownVariable,
  unknownVariable,
  invalidVariableExpression,
}

class ValueStringAnalysis {
  const ValueStringAnalysis({
    required this.kind,
    this.variableName,
  });

  final ValueStringKind kind;
  final String? variableName;

  bool get isVariable =>
      kind == ValueStringKind.knownVariable ||
      kind == ValueStringKind.unknownVariable;
}

final _variableValuePattern = RegExp(r'^\$([A-Za-z_][A-Za-z0-9_]*)$');

ValueStringAnalysis analyzeValueString(
  String text, {
  required Set<String> knownVariables,
}) {
  if (text.isEmpty) {
    return const ValueStringAnalysis(kind: ValueStringKind.empty);
  }

  final match = _variableValuePattern.firstMatch(text);
  if (match != null) {
    final variableName = match.group(1)!;
    return ValueStringAnalysis(
      kind: knownVariables.contains(variableName)
          ? ValueStringKind.knownVariable
          : ValueStringKind.unknownVariable,
      variableName: variableName,
    );
  }

  if (text.contains(r'$')) {
    return const ValueStringAnalysis(
      kind: ValueStringKind.invalidVariableExpression,
    );
  }

  return const ValueStringAnalysis(kind: ValueStringKind.literal);
}
