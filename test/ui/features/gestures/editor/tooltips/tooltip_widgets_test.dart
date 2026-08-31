import 'package:flutter/material.dart' hide Action;
import 'package:flutter_test/flutter_test.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/tooltips/tooltip_widgets.dart';

import '../../../../../helpers/load_fonts.dart';
import '../../../../../helpers/themed_app.dart';

/// Mirrors the tip constraints in [AppTooltip].
const _tipConstraints = BoxConstraints(maxWidth: 300, maxHeight: 600);

const _tooltips = <String, Widget>{
  'ActionConditions': ActionConditionsTooltip(),
  'ConditionFunction': ConditionFunctionTooltip(),
  'ActionFunction': ActionFunctionTooltip(),
  'ActionActivateWindow': ActionActivateWindowTooltip(),
  'ActionReplaceText': ActionReplaceTextTooltip(),
  'ActionReplaceTextCommand': ActionReplaceTextCommandTooltip(),
  'ActionTriggerOn': ActionTriggerOnTooltip(),
  'ActionInterval': ActionIntervalTooltip(),
  'ActionThreshold': ActionThresholdTooltip(),
  'ActionConflicting': ActionConflictingTooltip(),
  'ActionLimit': ActionLimitTooltip(),
  'TriggerConditions': TriggerConditionsTooltip(),
  'TriggerEndConditions': TriggerEndConditionsTooltip(),
  'TriggerId': TriggerIdTooltip(),
  'TriggerThreshold': TriggerThresholdTooltip(),
  'TriggerResumeTimeout': TriggerResumeTimeoutTooltip(),
  'TriggerAccelerated': TriggerAcceleratedTooltip(),
  'TriggerBlockEvents': TriggerBlockEventsTooltip(),
  'TriggerClearModifiers': TriggerClearModifiersTooltip(),
  'TriggerSetLastTrigger': TriggerSetLastTriggerTooltip(),
  'KeySequence': KeySequenceTooltip(),
  'ButtonSequence': ButtonSequenceTooltip(),
  'ConvertToShortcut': ConvertToShortcutTooltip(),
  'PointPixelPreview': PointPixelPreviewTooltip(),
};

void main() {
  setUpAll(loadAppFonts);

  for (final MapEntry(key: name, value: tooltip) in _tooltips.entries) {
    testWidgets('$name tooltip fits the tip constraints', (tester) async {
      tester.view
        ..physicalSize = const Size(800, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        themedApp(
          Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: _tipConstraints,
              child: tooltip,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
