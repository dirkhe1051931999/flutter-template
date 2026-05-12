import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShortVideoProgressBar extends StatelessWidget {
  const ShortVideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
  });

  final ValueListenable<Duration> position;
  final ValueListenable<Duration> duration;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: position,
      builder: (context, pos, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: duration,
          builder: (context, dur, __) {
            final total = dur.inMilliseconds;
            final value =
                total <= 0 ? 0.0 : (pos.inMilliseconds / total).clamp(0.0, 1.0);

            return Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 2,
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0x33FFFFFF),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
