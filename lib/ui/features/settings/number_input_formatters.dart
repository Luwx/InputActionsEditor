import 'package:flutter/services.dart' show TextInputFormatter;

/// Rejects text that is not on its way to being a non-negative number.
final TextInputFormatter integerOnlyFormatter = _accepting(RegExp(r'^\d*$'));
final TextInputFormatter decimalOnlyFormatter = _accepting(
  RegExp(r'^\d*\.?\d*$'),
);

TextInputFormatter _accepting(RegExp pattern) =>
    TextInputFormatter.withFunction(
      (old, next) => pattern.hasMatch(next.text) ? next : old,
    );
