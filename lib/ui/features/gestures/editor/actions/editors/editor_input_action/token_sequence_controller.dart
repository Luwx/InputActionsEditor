import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:input_actions_editor/domain/misc/key_sequence_parser.dart';
import 'package:input_actions_editor/model/action.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/widgets/input_action_types.dart';

class TokenSequenceController {
  const TokenSequenceController({
    required this.controller,
    required this.onTokensTyped,
  });

  final TextEditingController controller;
  final ValueChanged<List<InputToken>> onTokensTyped;

  void append(String sequence) {
    final existing = controller.text.trim();
    controller.text = existing.isEmpty ? sequence : '$existing, $sequence';
  }
}

/// Drives a sequence field from [tokens] and back, without either direction
/// round-tripping into the other.
TokenSequenceController useTokenSequenceController(
  List<InputToken> tokens,
  ValueChanged<List<InputToken>> onChanged,
) {
  final tokenKey = tokens.map(inputTokenText).join(', ');
  final controller = useTextEditingController(text: tokenKey);
  final syncing = useRef(false);
  final typedTokenKey = useRef<String?>(null);

  useEffect(() {
    if (tokenKey == typedTokenKey.value) return null;
    typedTokenKey.value = null;
    if (controller.text == tokenKey) return null;

    final typed = KeySequenceParser.toTokens(
      KeySequenceParser.parse(controller.text),
    ).map(inputTokenText).join(', ');
    // Text the parser cannot read canonicalizes to nothing, which must not
    // pass for an empty sequence.
    if (typed.isNotEmpty && typed == tokenKey) return null;

    unawaited(
      Future.microtask(() {
        syncing.value = true;
        controller.text = tokenKey;
        syncing.value = false;
      }),
    );
    return null;
  }, [tokenKey]);

  return TokenSequenceController(
    controller: controller,
    onTokensTyped: (typed) {
      if (syncing.value) return;
      typedTokenKey.value = typed.map(inputTokenText).join(', ');
      onChanged(typed);
    },
  );
}
