import 'package:flutter/cupertino.dart';

class AppStepper extends StatefulWidget {
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.step = 1,
    this.integer = false,
    this.disabled = false,
    this.disablePlus = false,
    this.disableMinus = false,
    this.disableInput = false,
    this.decimalLength,
    this.inputWidth = 54,
    this.buttonSize = 34,
    this.themeColor = const Color(0xFF2563EB),
    this.placeholder,
  });

  final num value;
  final ValueChanged<num> onChanged;
  final num min;
  final num? max;
  final num step;
  final bool integer;
  final bool disabled;
  final bool disablePlus;
  final bool disableMinus;
  final bool disableInput;
  final int? decimalLength;
  final double inputWidth;
  final double buttonSize;
  final Color themeColor;
  final String? placeholder;

  @override
  State<AppStepper> createState() => _AppStepperState();
}

class _AppStepperState extends State<AppStepper> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
    _focusNode = FocusNode();
    _focusNode.addListener(_handleBlur);
  }

  @override
  void didUpdateWidget(covariant AppStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = _format(widget.value);
    if (_controller.text != nextText && !_focusNode.hasFocus) {
      _controller.text = nextText;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleBlur)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _canMinus {
    return !widget.disabled &&
        !widget.disableMinus &&
        widget.value > widget.min;
  }

  bool get _canPlus {
    final max = widget.max;
    return !widget.disabled &&
        !widget.disablePlus &&
        (max == null || widget.value < max);
  }

  void _handleBlur() {
    if (_focusNode.hasFocus) {
      return;
    }
    _commitTextValue();
  }

  void _commitTextValue() {
    if (widget.disableInput) {
      _controller.text = _format(widget.value);
      return;
    }

    final parsed = num.tryParse(_controller.text);
    if (parsed == null) {
      _controller.text = _format(widget.value);
      return;
    }

    final normalized = _normalize(parsed);
    _controller.text = _format(normalized);
    if (normalized != widget.value) {
      widget.onChanged(normalized);
    }
  }

  void _increment() {
    if (!_canPlus) {
      return;
    }
    widget.onChanged(_normalize(widget.value + widget.step));
  }

  void _decrement() {
    if (!_canMinus) {
      return;
    }
    widget.onChanged(_normalize(widget.value - widget.step));
  }

  num _normalize(num raw) {
    num next = raw;
    if (next < widget.min) {
      next = widget.min;
    }
    final max = widget.max;
    if (max != null && next > max) {
      next = max;
    }
    if (widget.integer) {
      next = next.round();
    } else if (widget.decimalLength != null) {
      next = num.parse(next.toStringAsFixed(widget.decimalLength!));
    }
    return next;
  }

  String _format(num value) {
    if (widget.integer) {
      return value.round().toString();
    }
    if (widget.decimalLength != null) {
      return value.toStringAsFixed(widget.decimalLength!);
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final buttonRadius = BorderRadius.circular(widget.buttonSize * 0.38);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(widget.buttonSize * 0.48),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperButton(
              icon: CupertinoIcons.minus,
              enabled: _canMinus,
              size: widget.buttonSize,
              radius: buttonRadius,
              themeColor: widget.themeColor,
              onTap: _decrement,
            ),
            SizedBox(
              width: widget.inputWidth,
              child: CupertinoTextField.borderless(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !widget.disabled && !widget.disableInput,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: !widget.integer,
                  signed: false,
                ),
                placeholder: widget.placeholder,
                style: const TextStyle(
                  color: Color(0xFF202127),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                placeholderStyle: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                onSubmitted: (_) => _commitTextValue(),
              ),
            ),
            _StepperButton(
              icon: CupertinoIcons.plus,
              enabled: _canPlus,
              size: widget.buttonSize,
              radius: buttonRadius,
              themeColor: widget.themeColor,
              onTap: _increment,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.size,
    required this.radius,
    required this.themeColor,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final double size;
  final BorderRadius radius;
  final Color themeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: enabled ? themeColor.withValues(alpha: 0.12) : const Color(0xFFF2F4F7),
          borderRadius: radius,
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? themeColor : const Color(0xFFB6BDC9),
        ),
      ),
    );
  }
}
