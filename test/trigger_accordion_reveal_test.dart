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
import 'package:input_actions_editor/services/kwin_window_service.dart';
import 'package:input_actions_editor/store/config_controller.dart';
import 'package:input_actions_editor/ui/common/attention_flash.dart';
import 'package:input_actions_editor/ui/common/theme/forui_color_themes.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/state/edit_location_scope.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/trigger/trigger_editor.dart';

class _SeededConfig extends ConfigController {
  static const config = Config(
    mouseNodes: [
      GestureNode.leaf(PressGesture(common: TriggerCommon(name: 'press'))),
    ],
  );

  @override
  Future<EditSession> build() {
    final draft = assignEditIds(config);
    return SynchronousFuture(EditSession(draft: draft, saved: draft));
  }
}

Widget _host(ProviderContainer container, GestureLocation location) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FTheme(
          data: AppThemes.zinc.dark.desktop,
          child: FScaffold(
            child: SingleChildScrollView(
              child: EditLocationScope(
                gesture: location,
                child: const TriggerEditor(
                  sections: [],
                  initialAdvancedFields: {},
                ),
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('an undo of a hidden field opens Other options', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(_SeededConfig.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    // Nothing is pinned, so every advanced field sits inside the accordion,
    // whose own height is what the fold changes.
    final body = find.byType(FAccordion);
    final collapsedHeight = tester.getSize(body).height;

    final notifier = container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureThresholdLens(location), '99'),
        scope: const GesturesScope(),
      );
    await tester.pumpAndSettle();
    expect(tester.getSize(body).height, collapsedHeight);

    notifier.undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(tester.getSize(body).height, greaterThan(collapsedHeight));
  });

  testWidgets('only the changed field flashes', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(_SeededConfig.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    Finder litFields() => find.byWidgetPredicate(
      (widget) => widget is AttentionFlash && widget.trigger != null,
    );

    expect(litFields(), findsNothing);

    final notifier = container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<String?>(gestureThresholdLens(location), '99'),
        scope: const GesturesScope(),
      );
    await tester.pumpAndSettle();
    expect(litFields(), findsNothing);

    notifier.undo(scope: const GesturesScope());
    await tester.pumpAndSettle();
    // The flash arms once the row has stopped moving.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);

    // The reveal stays put; editing another field afterwards is not part of it.
    notifier.add(
      SetLens<String?>(gestureIdLens(location), 'renamed'),
      scope: const GesturesScope(),
    );
    await tester.pumpAndSettle();

    expect(litFields(), findsOneWidget);
  });

  testWidgets('a checkbox field flashes too', (tester) async {
    tester.view
      ..physicalSize = const Size(900, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: [
        kwinSupportedProvider.overrideWith((ref) => false),
        configControllerProvider.overrideWith(_SeededConfig.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(configControllerProvider.future);

    final location = gestureLocationAt(
      container.read(configControllerProvider).requireValue.draft,
      DeviceType.mouse,
      0,
    )!;

    await tester.pumpWidget(_host(container, location));
    await tester.pumpAndSettle();

    container.read(configControllerProvider.notifier)
      ..coalesceEnabled = false
      ..add(
        SetLens<bool>(gestureBlockEventsLens(location), false),
        scope: const GesturesScope(),
      )
      ..undo(scope: const GesturesScope());
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) => widget is AttentionFlash && widget.trigger != null,
      ),
      findsOneWidget,
    );
  });
}
