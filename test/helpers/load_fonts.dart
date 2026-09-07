import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registers the fonts the app ships, so widget tests measure text and draw
/// icons the way the app does. Without them every glyph is the test font's
/// square box, far wider than Inter, and layouts that fit in the running app
/// overflow in the harness.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const fonts = {
    'packages/forui/Inter': 'packages/forui/assets/fonts/inter/Inter.ttf',
    'packages/forui_assets/ForuiLucideIcons':
        'packages/forui_assets/assets/lucide.ttf',
    'PlasmaIcons': 'assets/fonts/PlasmaIcons.ttf',
  };

  for (final MapEntry(key: family, value: asset) in fonts.entries) {
    await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
  }
}
