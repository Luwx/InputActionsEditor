import 'dart:async';

import 'package:flutter/gestures.dart' show PointerScrollEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

class FSpinBox extends StatefulWidget {
  const FSpinBox({
    required this.value,
    required this.onChanged,
    required this.label,
    required this.min,
    required this.max,
    this.width = 110,
    this.step = 1,
    this.decimalPlaces = 1,
    this.hint,
    super.key,
  });

  final double value;
  final double width;
  final ValueChanged<double> onChanged;
  final Widget label;
  final double min;
  final double max;
  final double step;
  final int decimalPlaces;
  final String? hint;

  @override
  State<FSpinBox> createState() => _FSpinBoxState();
}

class _FSpinBoxState extends State<FSpinBox> {
  static const Duration _repeatDelay = Duration(milliseconds: 350);
  static const Duration _repeatInterval = Duration(milliseconds: 65);

  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  Timer? _repeatTimer;
  bool _isSyncingText = false;

  String get _formattedValue => widget.value.toStringAsFixed(
    widget.decimalPlaces,
  );

  int get _maxInputLength {
    final maxLength = widget.max.toStringAsFixed(widget.decimalPlaces).length;
    final minLength = widget.min.toStringAsFixed(widget.decimalPlaces).length;
    return maxLength > minLength ? maxLength : minLength;
  }

  TextInputFormatter get _rangeFormatter => TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty || text == '-' || text == '.' || text == '-.') {
      return newValue;
    }

    final parsed = double.tryParse(text);
    if (parsed == null || parsed < widget.min || parsed > widget.max) {
      return oldValue;
    }

    return newValue;
  });

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formattedValue);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FSpinBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _syncText(widget.value);
    }
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _commitText();
    }
  }

  double _clamp(double value) => value.clamp(widget.min, widget.max);

  void _syncText(double value) {
    final text = value.toStringAsFixed(widget.decimalPlaces);
    if (_controller.text == text) {
      return;
    }
    _isSyncingText = true;
    try {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } finally {
      _isSyncingText = false;
    }
  }

  void _setValue(double value) {
    final nextValue = _clamp(value);
    widget.onChanged(nextValue);
    _syncText(nextValue);
  }

  void _commitText() {
    final parsed = double.tryParse(_controller.text);
    if (parsed == null) {
      _syncText(widget.value);
      return;
    }
    _setValue(parsed);
  }

  void _stepBy(double delta) {
    _setValue(widget.value + delta);
  }

  void _startRepeating(double delta) {
    _repeatTimer?.cancel();
    _stepBy(delta);
    _repeatTimer = Timer(_repeatDelay, () {
      _repeatTimer = Timer.periodic(_repeatInterval, (_) {
        _stepBy(delta);
      });
    });
  }

  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  void _handleTextChanged(String text) {
    if (_isSyncingText) {
      return;
    }
    final parsed = double.tryParse(text);
    if (parsed != null) {
      widget.onChanged(_clamp(parsed));
    }
  }

  @override
  Widget build(BuildContext context) {
    final canIncrement = widget.value < widget.max;
    final canDecrement = widget.value > widget.min;
    final formatter = widget.decimalPlaces == 0
        ? FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$'))
        : FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*$'));

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowUp): _SpinIntent(1),
        SingleActivator(LogicalKeyboardKey.arrowDown): _SpinIntent(-1),
      },
      child: Actions(
        actions: {
          _SpinIntent: CallbackAction<_SpinIntent>(
            onInvoke: (intent) {
              _stepBy(intent.direction * widget.step);
              return null;
            },
          ),
        },
        child: SizedBox(
          width: widget.width,
          child: FTextField(
            label: widget.label,
            control: FTextFieldControl.managed(
              controller: _controller,
              onChange: (next) => _handleTextChanged(next.text),
            ),
            focusNode: _focusNode,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.decimalPlaces > 0,
              signed: widget.min < 0,
            ),
            textAlign: TextAlign.center,
            hint: widget.hint,
            inputFormatters: [
              formatter,
              LengthLimitingTextInputFormatter(_maxInputLength),
              _rangeFormatter,
            ],
            onSubmit: (_) => _commitText(),
            // style: const .delta(
            //   contentPadding: .value(
            //     EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            //   ),
            // ),
            suffixBuilder: (context, style, variants) => _SpinStepper(
              style: style,
              variants: variants,
              canIncrement: canIncrement,
              canDecrement: canDecrement,
              onIncrement: () => _stepBy(widget.step),
              onDecrement: () => _stepBy(-widget.step),
              onLongIncrementStart: () => _startRepeating(widget.step),
              onLongDecrementStart: () => _startRepeating(-widget.step),
              onLongPressEnd: _stopRepeating,
              onScroll: (direction) => _stepBy(direction * widget.step),
              onTapIntoStepper: _focusNode.requestFocus,
            ),
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
