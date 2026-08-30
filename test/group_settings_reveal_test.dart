import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:input_actions_editor/domain/edit/config_edit.dart';
import 'package:input_actions_editor/domain/edit/edit_scope.dart';
import 'package:input_actions_editor/domain/edit/schema/edit_schema.dart';
import 'package:input_actions_editor/l10n/app_localizations.dart';
import 'package:input_actions_editor/model/config.dart';
import 'package:input_actions_editor/model/enums.dart';
import 'package:input_actions_editor/model/gesture_node.dart';
import 'package:input_actions_editor/model/mouse_gesture.dart';
import 'package:input_actions_editor/model/trigger_common.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/group/group_settings_view.dart';

import 'helpers/load_fonts.dart';

const _groupEditId = 901;

class _SeededController extends ConfigController {
  @override
  Future<EditSession> build() {
    final normalized = assignEditIds(
      const Config(
        mouseNodes: [
          GestureNode.group(
            name: 'G1',
            editId: _groupEditId,
            children: [GestureNode.leaf(PressGesture(common: TriggerCommon()))],
          ),
        ],
      ),
    );
    return SynchronousFuture(EditSession(draft: normalized, saved: normalized));
  }
}

void main() {
  setUpAll(loadAppFonts);

  const location = GestureGroupLocation(
    device: DeviceType.mouse,
    editId: _groupEditId,
  );

  Finder litFields() => find.byWidgetPredicate(
    (widget) =>
        widget is AttentionFlash &&
        widget.trigger != null &&
        widget.expand != EdgeInsets.zero,
  );

  testWidgets('undoing a group property flashes its field', (tester) async {
    tester.view
      ..physicalSize = const Size(1000, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        configControllerProvider.overrideWith(_SeededController.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FTheme(
            data: AppThemes.zinc.dark.desktop,
            child: const FScaffold(
              child: GroupSettingsView(location: location),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(litFields(), findsNothing);

    // Shut the accordion the field lives in: the reveal has to open it again.
    await tester.tap(find.text('Other Options'));
    await tester.pumpAndSettle();
    expect(find.text('Threshold').hitTestable(), findsNothing);

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureGroupThresholdLens(location), '42'),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(find.text('Threshold').hitTestable(), findsOneWidget);
    expect(litFields(), findsOneWidget);
  });
}
