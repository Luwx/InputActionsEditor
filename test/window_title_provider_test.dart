import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/state/app/window_title_provider.dart';

void main() {
  group('appWindowTitle', () {
    test('uses the base title when clean', () {
      expect(
        appWindowTitle(isDirty: false),
        appWindowBaseTitle,
      );
    });

    test('prefixes an asterisk when dirty', () {
      expect(
        appWindowTitle(isDirty: true),
        '*$appWindowBaseTitle',
      );
    });
  });
}
