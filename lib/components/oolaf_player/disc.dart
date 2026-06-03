import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class OolafRotatingDisc extends StatefulWidget {
  const OolafRotatingDisc({
    super.key,
    required this.isPlaying,
    this.size = 44,
    this.title,
    this.showTonearm = false,
  });

  final bool isPlaying;
  final double size;
  final String? title;
  final bool showTonearm;

  @override
  State<OolafRotatingDisc> createState() => _OolafRotatingDiscState();
}

class _OolafRotatingDiscState extends State<OolafRotatingDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant OolafRotatingDisc oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    }
    if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    Widget disc = SizedBox(
      width: s,
      height: s,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = _controller.value * 2 * math.pi;
              return Transform.rotate(
                angle: angle,
                child: child,
              );
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF4A4A4A),
                    Color(0xFF171717),
                    Color(0xFF030303),
                  ],
                  stops: [0.0, 0.58, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x12000000),
                    blurRadius: s * 0.08,
                    offset: Offset(0, s * 0.04),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (final ratio in const [0.88, 0.72, 0.56, 0.4])
                    Container(
                      width: s * ratio,
                      height: s * ratio,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0x14FFFFFF),
                          width: 1,
                        ),
                      ),
                    ),
                  Container(
                    width: s * 0.44,
                    height: s * 0.44,
                    padding: EdgeInsets.all(s * 0.06),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD43C33),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: s * 0.055,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: s * 0.1,
                    height: s * 0.1,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF2F3F4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (!widget.showTonearm) {
      return disc;
    }

    return SizedBox(
      width: s * 1.18,
      height: s * 1.06,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: s * 0.02, bottom: 0, child: disc),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            right: s * 0.08,
            top: widget.isPlaying ? s * 0.055 : 0,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              turns: widget.isPlaying ? 0.055 : -0.015,
              alignment: Alignment.topRight,
              child: SizedBox(
                width: s * 0.34,
                height: s * 0.58,
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: s * 0.14,
                      height: s * 0.14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF3A3A3A),
                      ),
                    ),
                    Positioned(
                      right: s * 0.062,
                      top: s * 0.07,
                      child: Container(
                        width: s * 0.032,
                        height: s * 0.42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9A9A9A),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    Positioned(
                      right: s * 0.015,
                      bottom: 0,
                      child: Transform.rotate(
                        angle: -0.5,
                        child: Container(
                          width: s * 0.105,
                          height: s * 0.055,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
