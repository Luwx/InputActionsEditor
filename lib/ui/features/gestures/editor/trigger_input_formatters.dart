import 'package:flutter/services.dart' show TextInputFormatter;

final _partialThreshold = RegExp(r'^\d*\.?\d*(-\d*\.?\d*)?$');
final _partialInterval = RegExp(r'^[+-]?\d*\.?\d*$');

/// Rejects text that is not on its way to a number or a `min-max` range.
final thresholdInputFormatters = <TextInputFormatter>[
  _accepting(_partialThreshold),
];

/// Rejects text that is not on its way to a signed number, or a bare `+`/`-`.
final intervalInputFormatters = <TextInputFormatter>[
  _accepting(_partialInterval),
];

TextInputFormatter _accepting(RegExp pattern) =>
    TextInputFormatter.withFunction(
      (old, next) => pattern.hasMatch(next.text) ? next : old,
    );
