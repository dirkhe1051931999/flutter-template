import 'dart:math' as math;

import 'package:flutter/cupertino.dart';

class LikeBurstLayer extends StatefulWidget {
  const LikeBurstLayer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<LikeBurstLayer> createState() => _LikeBurstLayerState();
}

class _LikeBurstLayerState extends State<LikeBurstLayer> {
  final _items = <_LikeBurstItem>[];
  final _rand = math.Random();
  static const List<Color> _burstColors = <Color>[
    Color(0xFFFF2D55),
    Color(0xFFFF6482),
    Color(0xFFFFC1CC),
    Color(0xFFFFFFFF),
  ];

  void addLike(Offset position) {
    final angle = (_rand.nextDouble() * 40 - 20) * math.pi / 180;
    final particles = List<_LikeBurstParticle>.generate(6, (index) {
      final theta = (-90 + (index * 24) + _rand.nextDouble() * 18) * math.pi / 180;
      final distance = 28 + _rand.nextDouble() * 24;
      final size = 7 + _rand.nextDouble() * 6;
      return _LikeBurstParticle(
        angle: theta,
        distance: distance,
        size: size,
        color: _burstColors[_rand.nextInt(_burstColors.length)],
      );
    });
    final item = _LikeBurstItem(
      id: UniqueKey().toString(),
      position: position,
      rotation: angle,
      particles: particles,
    );

    setState(() {
      _items.add(item);
    });

    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(() {
        _items.removeWhere((e) => e.id == item.id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _LikeBurstLayerScope(
      state: this,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          ..._items.map(
            (item) {
              return Positioned(
                left: item.position.dx - 52,
                top: item.position.dy - 88,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 850),
                  builder: (context, t, child) {
                    final heartScale = t < 0.18
                        ? 0.55 + (t / 0.18) * 0.75
                        : 1.3 - ((t - 0.18) / 0.82) * 0.38;
                    final heartOpacity = t < 0.72 ? 1.0 : (1.0 - ((t - 0.72) / 0.28)).clamp(0.0, 1.0);
                    return SizedBox(
                      width: 104,
                      height: 120,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          for (final particle in item.particles)
                            Positioned(
                              left: 52 + math.cos(particle.angle) * particle.distance * t - particle.size / 2,
                              top: 44 + math.sin(particle.angle) * particle.distance * t - particle.size / 2,
                              child: Opacity(
                                opacity: (1.0 - t).clamp(0.0, 1.0),
                                child: Container(
                                  width: particle.size,
                                  height: particle.size,
                                  decoration: BoxDecoration(
                                    color: particle.color,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: particle.color.withValues(alpha: 0.45),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Opacity(
                            opacity: heartOpacity,
                            child: Transform.rotate(
                              angle: item.rotation,
                              child: Transform.scale(
                                scale: heartScale,
                                child: Transform.translate(
                                  offset: Offset(0, -42 * t),
                                  child: child,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const _LikeBurstHeart(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LikeBurstHeart extends StatelessWidget {
  const _LikeBurstHeart();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.16,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CustomPaint(
              size: Size(72, 72),
              painter: _HeartGlowPainter(),
            ),
            const CustomPaint(
              size: Size(72, 72),
              painter: _HeartShapePainter(
                fillColor: Color(0xFFFF4D7A),
                strokeColor: CupertinoColors.white,
              ),
            ),
            Positioned(
              top: 17,
              right: 20,
              child: Transform.rotate(
                angle: -0.36,
                child: Container(
                  width: 13,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0x88FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartGlowPainter extends CustomPainter {
  const _HeartGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildHeartPath(size);
    final paint = Paint()
      ..color = const Color(0xFFFF2D55).withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(path.shift(const Offset(0, 2)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _HeartShapePainter extends CustomPainter {
  const _HeartShapePainter({
    required this.fillColor,
    required this.strokeColor,
  });

  final Color fillColor;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildHeartPath(size);

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final highlightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0x66FFFFFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, 0.55],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, highlightPaint);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _HeartShapePainter oldDelegate) {
    return fillColor != oldDelegate.fillColor || strokeColor != oldDelegate.strokeColor;
  }
}

Path _buildHeartPath(Size size) {
  final width = size.width;
  final height = size.height;
  final path = Path();
  path.moveTo(width * 0.5, height * 0.86);
  path.cubicTo(
    width * 0.16,
    height * 0.62,
    width * 0.05,
    height * 0.33,
    width * 0.24,
    height * 0.2,
  );
  path.cubicTo(
    width * 0.37,
    height * 0.1,
    width * 0.48,
    height * 0.18,
    width * 0.5,
    height * 0.28,
  );
  path.cubicTo(
    width * 0.52,
    height * 0.18,
    width * 0.63,
    height * 0.1,
    width * 0.76,
    height * 0.2,
  );
  path.cubicTo(
    width * 0.95,
    height * 0.33,
    width * 0.84,
    height * 0.62,
    width * 0.5,
    height * 0.86,
  );
  path.close();
  return path;
}

class _LikeBurstParticle {
  const _LikeBurstParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
}

class _LikeBurstItem {
  const _LikeBurstItem({
    required this.id,
    required this.position,
    required this.rotation,
    required this.particles,
  });

  final String id;
  final Offset position;
  final double rotation;
  final List<_LikeBurstParticle> particles;
}

class _LikeBurstLayerScope extends InheritedWidget {
  const _LikeBurstLayerScope({
    required this.state,
    required super.child,
  });

  final _LikeBurstLayerState state;

  static _LikeBurstLayerState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_LikeBurstLayerScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(_LikeBurstLayerScope oldWidget) {
    return oldWidget.state != state;
  }
}

extension LikeBurstLayerExtension on BuildContext {
  void emitLikeBurst(Offset position) {
    final state = _LikeBurstLayerScope.of(this);
    state?.addLike(position);
  }
}
