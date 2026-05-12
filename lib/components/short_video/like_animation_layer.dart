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

  void addLike(Offset position) {
    final angle = (_rand.nextDouble() * 40 - 20) * math.pi / 180;
    final item = _LikeBurstItem(
      id: UniqueKey().toString(),
      position: position,
      rotation: angle,
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
                left: item.position.dx - 36,
                top: item.position.dy - 36,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 850),
                  builder: (context, t, child) {
                    final scale =
                        0.7 + (0.6 * (1 - (t - 0.2).abs() * 2).clamp(0, 1));
                    return Opacity(
                      opacity: (1.0 - (t * 0.8)).clamp(0.0, 1.0),
                      child: Transform.rotate(
                        angle: item.rotation,
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.translate(
                            offset: Offset(0, -40 * t),
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Icon(
                    CupertinoIcons.heart_solid,
                    color: Color(0xFFFF2D55),
                    size: 72,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LikeBurstItem {
  const _LikeBurstItem({
    required this.id,
    required this.position,
    required this.rotation,
  });

  final String id;
  final Offset position;
  final double rotation;
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
