import 'dart:async';

import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';

/// Formats [v] with at most [decimalPlaces] fraction digits, dropping trailing
/// zeros (and a bare trailing dot) so e.g. `0.3300` shows as `0.33` and
/// `0.3330` as `0.333`, while `0.3333` keeps its precision.
String _formatSpinValue(double v, int decimalPlaces) {
  var text = v.toStringAsFixed(decimalPlaces);
  if (text.contains('.')) {
    text = text
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

class FSpinBox extends HookWidget {
  const FSpinBox({
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.label,
    this.unit,
    this.width = 110,
    this.step = 1,
    this.decimalPlaces = 1,
    this.hint,
    super.key,
  });

  final double value;
  final double width;
  final ValueChanged<double> onChanged;
  final Widget? label;
  final String? unit;
  final double min;
  final double max;
  final double step;
  final int decimalPlaces;
  final String? hint;

  int get maxInputLength {
    final maxLength = max.toStringAsFixed(decimalPlaces).length;
    final minLength = min.toStringAsFixed(decimalPlaces).length;
    return maxLength > minLength ? maxLength : minLength;
  }

  String _fmt(double v) => _formatSpinValue(v, decimalPlaces);

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: _fmt(value));
    final focusNode = useFocusNode();
    final repeatTimer = useRef<Timer?>(null);
    final isSyncingText = useRef(false);

    // Always-fresh refs so timer and focus callbacks read current props.
    final valueRef = useRef(value);
    final minRef = useRef(min);
    final maxRef = useRef(max);
    final decimalPlacesRef = useRef(decimalPlaces);
    final onChangedRef = useRef(onChanged);
    valueRef.value = value;
    minRef.value = min;
    maxRef.value = max;
    decimalPlacesRef.value = decimalPlaces;
    onChangedRef.value = onChanged;

    // Sync controller text when external value changes and field is not focused
    // (replaces didUpdateWidget).
    final prevValue = usePrevious(value);
    if (prevValue != null && prevValue != value && !focusNode.hasFocus) {
      final text = _fmt(value);
      if (controller.text != text) {
        isSyncingText.value = true;
        try {
          controller.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        } finally {
          isSyncingText.value = false;
        }
      }
    }

    // Cancel timer on dispose.
    useEffect(
      () =>
          () => repeatTimer.value?.cancel(),
      const [],
    );

    // Focus listener: commit text on unfocus (reads through refs).
    useEffect(() {
      void handleFocusChange() {
        if (focusNode.hasFocus) return;
        final curMin = minRef.value;
        final curMax = maxRef.value;
        final curDp = decimalPlacesRef.value;
        final curValue = valueRef.value;
        final notify = onChangedRef.value;
        String localFmt(double v) => _formatSpinValue(v, curDp);

        final parsed = double.tryParse(controller.text);
        if (parsed == null) {
          final text = localFmt(curValue);
          if (controller.text != text) {
            isSyncingText.value = true;
            try {
              controller.value = TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            } finally {
              isSyncingText.value = false;
            }
          }
          return;
        }
        final next = parsed.clamp(curMin, curMax);
        notify(next);
        final text = localFmt(next);
        if (controller.text != text) {
          isSyncingText.value = true;
          try {
            controller.value = TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length),
            );
          } finally {
            isSyncingText.value = false;
          }
        }
      }

      focusNode.addListener(handleFocusChange);
      return () => focusNode.removeListener(handleFocusChange);
    }, const []);

    void syncText(double v) {
      final text = _fmt(v);
      if (controller.text == text) return;
      isSyncingText.value = true;
      try {
        controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      } finally {
        isSyncingText.value = false;
      }
    }

    void setValue(double v) {
      final next = v.clamp(min, max);
      onChanged(next);
      syncText(next);
    }

    // Uses valueRef so timer callbacks always read the current value.
    void stepBy(double delta) => setValue(valueRef.value + delta);

    void startRepeating(double delta) {
      repeatTimer.value?.cancel();
      stepBy(delta);
      repeatTimer.value = Timer(const Duration(milliseconds: 350), () {
        repeatTimer.value = Timer.periodic(
          const Duration(milliseconds: 65),
          (_) => stepBy(delta),
        );
      });
    }

    void stopRepeating() {
      repeatTimer.value?.cancel();
      repeatTimer.value = null;
    }

    void handleTextChanged(String text) {
      if (isSyncingText.value) return;
      final parsed = double.tryParse(text);
      if (parsed != null) onChanged(parsed.clamp(min, max));
    }

    final canIncrement = value < max;
    final canDecrement = value > min;
    final formatter = decimalPlaces == 0
        ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$'))
        : FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'));
    final rangeFormatter = TextInputFormatter.withFunction((old, newVal) {
      final text = newVal.text;
      if (text.isEmpty || text == '-' || text == '.' || text == '-.') {
        return newVal;
      }
      final parsed = double.tryParse(text);
      if (parsed == null || parsed < min || parsed > max) return old;
      return newVal;
    });

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp): _SpinIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _SpinIntent(-1),
      },
      child: Actions(
        actions: {
          _SpinIntent: CallbackAction<_SpinIntent>(
            onInvoke: (intent) {
              stepBy(intent.direction * step);
              return null;
            },
          ),
        },
        child: SizedBox(
          width: width,
          child: FTextField(
            label: label,
            control: FTextFieldControl.managed(
              controller: controller,
              onChange: (next) => handleTextChanged(next.text),
            ),
            focusNode: focusNode,
            keyboardType: TextInputType.numberWithOptions(
              decimal: decimalPlaces > 0,
              signed: min < 0,
            ),
            textAlign: TextAlign.center,
            hint: hint,
            inputFormatters: [
              formatter,
              LengthLimitingTextInputFormatter(maxInputLength),
              rangeFormatter,
            ],
            onSubmit: (_) {
              final parsed = double.tryParse(controller.text);
              if (parsed == null) {
                syncText(value);
                return;
              }
              setValue(parsed);
            },
            suffixBuilder: (context, style, variants) {
              final stepper = _SpinStepper(
                style: style,
                variants: variants,
                canIncrement: canIncrement,
                canDecrement: canDecrement,
                onIncrement: () => stepBy(step),
                onDecrement: () => stepBy(-step),
                onLongIncrementStart: () => startRepeating(step),
                onLongDecrementStart: () => startRepeating(-step),
                onLongPressEnd: stopRepeating,
                onScroll: (direction) => stepBy(direction * step),
                onTapIntoStepper: focusNode.requestFocus,
              );
              if (unit == null) return stepper;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Text(
                      unit!,
                      style: context.theme.typography.body.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                  stepper,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

@Deprecated('Use FSpinBox instead.')
class Spinbox extends FSpinBox {
  @Deprecated('Use FSpinBox instead.')
  const Spinbox({
    required super.value,
    required super.onChanged,
    required super.label,
    required super.min,
    required super.max,
    super.step = 1,
    super.decimalPlaces = 1,
    super.hint,
    super.key,
  });
}

class _SpinIntent extends Intent {
  const _SpinIntent(this.direction);

  final int direction;
}

class _SpinStepper extends StatelessWidget {
  const _SpinStepper({
    required this.style,
    required this.variants,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
    required this.onLongIncrementStart,
    required this.onLongDecrementStart,
    required this.onLongPressEnd,
    required this.onScroll,
    required this.onTapIntoStepper,
  });

  final FTextFieldStyle style;
  final Set<FTextFieldVariant> variants;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onLongIncrementStart;
  final VoidCallback onLongDecrementStart;
  final VoidCallback onLongPressEnd;
  final ValueChanged<double> onScroll;
  final VoidCallback onTapIntoStepper;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final resolvedBorder = style.border.resolve(variants);
    final borderRadius = switch (resolvedBorder) {
      final OutlineInputBorder border => border.borderRadius.resolve(
        Directionality.of(context),
      ),
      _ => BorderRadius.zero,
    };
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          onScroll(event.scrollDelta.dy < 0 ? 1 : -1);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: borderRadius.topRight,
          bottomRight: borderRadius.bottomRight,
        ),
        child: Container(
          width: 22,
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colors.border)),
          ),
          child: SizedBox(
            height: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 16,
                  child: _SpinStepperSegment(
                    icon: FLucideIcons.chevronUp,
                    enabled: canIncrement,
                    showDivider: true,
                    onPressed: onIncrement,
                    onLongPressStart: onLongIncrementStart,
                    onLongPressEnd: onLongPressEnd,
                    onTapIntoStepper: onTapIntoStepper,
                    iconStyle: style.iconStyle.resolve(variants),
                  ),
                ),
                SizedBox(
                  height: 16,
                  child: _SpinStepperSegment(
                    icon: FLucideIcons.chevronDown,
                    enabled: canDecrement,
                    showDivider: false,
                    onPressed: onDecrement,
                    onLongPressStart: onLongDecrementStart,
                    onLongPressEnd: onLongPressEnd,
                    onTapIntoStepper: onTapIntoStepper,
                    iconStyle: style.iconStyle.resolve(variants),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpinStepperSegment extends StatelessWidget {
  const _SpinStepperSegment({
    required this.icon,
    required this.enabled,
    required this.showDivider,
    required this.onPressed,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onTapIntoStepper,
    required this.iconStyle,
  });

  final IconData icon;
  final bool enabled;
  final bool showDivider;
  final VoidCallback onPressed;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onTapIntoStepper;
  final IconThemeData iconStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final overlayColor = colors.primary.withValues(alpha: 0.08);

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: enabled ? (_) => onLongPressStart() : null,
        onLongPressEnd: enabled ? (_) => onLongPressEnd() : null,
        onLongPressCancel: onLongPressEnd,
        child: InkWell(
          onTapDown: (_) => onTapIntoStepper(),
          onTap: enabled ? onPressed : null,
          hoverColor: overlayColor,
          highlightColor: overlayColor,
          splashColor: colors.primary.withValues(alpha: 0.12),
          child: Ink(
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: colors.border))
                  : null,
            ),
            child: Center(
              child: IconTheme(
                data: enabled
                    ? iconStyle
                    : iconStyle.copyWith(
                        color: colors.disable(
                          iconStyle.color ?? colors.mutedForeground,
                        ),
                      ),
                child: Icon(icon, size: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
