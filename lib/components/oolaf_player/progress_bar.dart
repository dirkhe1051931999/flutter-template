import 'package:flutter/material.dart';
import 'package:oolaf_flutted/utils/duration_format.dart';

class OolafProgressBar extends StatelessWidget {
  const OolafProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.activeColor,
    this.showTimeLabels = true,
    this.sliderPadding,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final Color? activeColor;
  final bool showTimeLabels;
  final EdgeInsetsGeometry? sliderPadding;

  @override
  Widget build(BuildContext context) {
    final maxMs = duration.inMilliseconds;
    final valueMs = position.inMilliseconds.clamp(0, maxMs);

    final value = maxMs == 0 ? 0.0 : valueMs.toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: sliderPadding ?? EdgeInsets.zero,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: const Color(0xFFE9E9E9),
              thumbColor: activeColor,
              overlayColor: activeColor?.withValues(alpha: 0.15),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: maxMs.toDouble().clamp(0.0, double.infinity),
              onChanged: (v) {
                onSeek(Duration(milliseconds: v.round()));
              },
            ),
          ),
        ),
        if (showTimeLabels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  formatDuration(position),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  formatDuration(duration),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
