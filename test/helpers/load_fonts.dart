import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers the real Inter, so widget tests measure text the way the app does.
/// Without it every glyph is the test font's square box, far wider than Inter,
/// and layouts that fit in the running app overflow in the harness.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const asset = 'packages/forui/assets/fonts/inter/Inter.ttf';
  await (FontLoader(
    'packages/forui/Inter',
  )..addFont(rootBundle.load(asset))).load();
}
