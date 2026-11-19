import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_actions_editor/services/ui_scale_binding.dart';
import 'package:input_actions_editor/ui/features/gestures/editor/actions/state/input_recording_provider.dart';
import 'package:input_actions_editor/ui/l10n/context_ext.dart';
import 'package:input_actions_editor/ui/shell/ui_scale_intents.dart';

class UiScaleShortcuts extends HookConsumerWidget {
  const UiScaleShortcuts({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasterKey = useMemoized(GlobalKey<FToasterState>.new);
    final toast = useRef<FToasterEntry?>(null);
    final timer = useRef<Timer?>(null);
    useEffect(
      () =>
          () => timer.value?.cancel(),
      const [],
    );

    void showScale() {
      timer.value?.cancel();
      if (!(toast.value?.showing ?? false)) {
        toast.value = toasterKey.currentState!.show(
          context: context,
          alignment: FToastAlignment.bottomRight,
          duration: null,
          builder: (context, entry) => FToast(
            title: ValueListenableBuilder<double>(
              valueListenable: UiScaleBinding.scaleListenable,
              builder: (context, scale, _) => Text('${(scale * 100).round()}%'),
            ),
            suffix: FButton(
              variant: .outline,
              size: .sm,
              onPress: () {
                UiScaleBinding.scale = 1;
                timer.value?.cancel();
                entry.dismiss();
              },
              child: Text(context.l10n.actionReset),
            ),
          ),
        );
      }
      timer.value = Timer(
        const Duration(seconds: 2),
        () => toast.value?.dismiss(),
      );
    }

    void zoomIn() {
      UiScaleBinding.zoomIn();
      showScale();
    }

    void zoomOut() {
      UiScaleBinding.zoomOut();
      showScale();
    }

    void reset() {
      UiScaleBinding.scale = 1;
      showScale();
    }

    return CallbackShortcuts(
      bindings: ref.watch(isInputRecordingProvider)
          ? const {}
          : {
              const SingleActivator(LogicalKeyboardKey.equal, control: true):
                  zoomIn,
              const SingleActivator(
                LogicalKeyboardKey.equal,
                control: true,
                shift: true,
              ): zoomIn,
              const SingleActivator(LogicalKeyboardKey.add, control: true):
                  zoomIn,
              const SingleActivator(
                LogicalKeyboardKey.add,
                control: true,
                shift: true,
              ): zoomIn,
              const SingleActivator(
                LogicalKeyboardKey.numpadAdd,
                control: true,
              ): zoomIn,
              const SingleActivator(LogicalKeyboardKey.minus, control: true):
                  zoomOut,
              const SingleActivator(
                LogicalKeyboardKey.numpadSubtract,
                control: true,
              ): zoomOut,
              const SingleActivator(LogicalKeyboardKey.digit0, control: true):
                  reset,
              const SingleActivator(LogicalKeyboardKey.numpad0, control: true):
                  reset,
            },
      child: Actions(
        actions: {
          ZoomInIntent: CallbackAction<ZoomInIntent>(
            onInvoke: (_) {
              zoomIn();
              return null;
            },
          ),
          ZoomOutIntent: CallbackAction<ZoomOutIntent>(
            onInvoke: (_) {
              zoomOut();
              return null;
            },
          ),
        },
        child: FToaster(key: toasterKey, child: child),
      ),
    );
  }
}
