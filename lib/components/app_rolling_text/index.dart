import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_rolling_text/app_rolling_text_types.dart';

class AppRollingText extends StatefulWidget {
  const AppRollingText({
    super.key,
    required this.mode,
    this.startNum = 0,
    this.targetNum = 0,
    this.texts = const <String>[],
    this.duration = const Duration(milliseconds: 1800),
    this.autoStart = true,
    this.loop = false,
    this.stopOrder,
    this.style,
  });

  final AppRollingTextMode mode;
  final int startNum;
  final int targetNum;
  final List<String> texts;
  final Duration duration;
  final bool autoStart;
  final bool loop;
  final List<int>? stopOrder;
  final TextStyle? style;

  @override
  State<AppRollingText> createState() => _AppRollingTextState();
}

class _AppRollingTextState extends State<AppRollingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _textLoopTimer;
  int _textIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.autoStart) {
      _start();
    }
  }

  @override
  void didUpdateWidget(covariant AppRollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _textLoopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (widget.mode == AppRollingTextMode.text) {
      if (widget.texts.length > 1) {
        _textLoopTimer = Timer.periodic(widget.duration, (_) {
          if (!mounted) {
            return;
          }
          setState(() {
            if (_textIndex == widget.texts.length - 1) {
              _textIndex = widget.loop ? 0 : _textIndex;
            } else {
              _textIndex += 1;
            }
          });
        });
      }
      return;
    }
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ??
        const TextStyle(
          color: Color(0xFF202127),
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1,
        );

    if (widget.mode == AppRollingTextMode.text) {
      final text = widget.texts.isEmpty ? '' : widget.texts[_textIndex];
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.24),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Text(
          text,
          key: ValueKey<String>(text),
          style: textStyle,
        ),
      );
    }

    final start = widget.startNum.toString();
    final target = widget.targetNum.toString();
    final length = start.length > target.length ? start.length : target.length;
    final paddedStart = start.padLeft(length, '0');
    final paddedTarget = target.padLeft(length, '0');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(length, (digitIndex) {
            final begin = int.parse(paddedStart[digitIndex]);
            final end = int.parse(paddedTarget[digitIndex]);
            final order = widget.stopOrder != null &&
                    digitIndex < widget.stopOrder!.length
                ? widget.stopOrder![digitIndex]
                : digitIndex;
            final segmentStart = (order * 0.08).clamp(0, 0.8);
            final progress = ((_controller.value - segmentStart) / (1 - segmentStart))
                .clamp(0, 1);
            final current = begin + ((end - begin) * progress);
            return SizedBox(
              width: textStyle.fontSize != null ? textStyle.fontSize! * 0.78 : 22,
              child: Text(
                current.round().toString(),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            );
          }),
        );
      },
    );
  }
}
