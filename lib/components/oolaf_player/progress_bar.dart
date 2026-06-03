import 'package:flutter/cupertino.dart';
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
    final progress = maxMs <= 0 ? 0.0 : valueMs / maxMs;
    final resolvedActiveColor = activeColor ?? const Color(0xFFD43C33);
    final labelStyle = CupertinoTheme.of(context).textTheme.textStyle.copyWith(
      color: const Color(0x8A000000),
      fontSize: 11,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: sliderPadding ?? EdgeInsets.zero,
          child: _CompactSeekBar(
            progress: progress.clamp(0.0, 1.0),
            activeColor: resolvedActiveColor,
            onChanged: (nextProgress) {
              onSeek(
                Duration(
                  milliseconds: (maxMs * nextProgress).round(),
                ),
              );
            },
            enabled: maxMs > 0,
          ),
        ),
        if (showTimeLabels)
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 2, top: 3),
            child: Row(
              children: [
                Text(
                  formatDuration(position),
                  style: labelStyle,
                ),
                const Spacer(),
                Text(
                  formatDuration(duration),
                  style: labelStyle,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CompactSeekBar extends StatelessWidget {
  const _CompactSeekBar({
    required this.progress,
    required this.activeColor,
    required this.onChanged,
    required this.enabled,
  });

  final double progress;
  final Color activeColor;
  final ValueChanged<double> onChanged;
  final bool enabled;

  void _updateFromLocalPosition(BuildContext context, Offset localPosition) {
    if (!enabled) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 0;
    if (width <= 0) {
      return;
    }
    onChanged((localPosition.dx / width).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        _updateFromLocalPosition(context, details.localPosition);
      },
      onHorizontalDragUpdate: (details) {
        _updateFromLocalPosition(context, details.localPosition);
      },
      child: SizedBox(
        height: 24,
        child: CustomPaint(
          painter: _CompactSeekBarPainter(
            progress: progress,
            activeColor: activeColor,
            enabled: enabled,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CompactSeekBarPainter extends CustomPainter {
  const _CompactSeekBarPainter({
    required this.progress,
    required this.activeColor,
    required this.enabled,
  });

  final double progress;
  final Color activeColor;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final start = Offset(0, centerY);
    final end = Offset(size.width, centerY);
    final thumbX = size.width * progress.clamp(0.0, 1.0);
    final thumbCenter = Offset(thumbX, centerY);
    final inactivePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE1DAD8);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = enabled ? activeColor : const Color(0x668E8E93);
    final thumbPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = enabled ? activeColor : const Color(0xFFB8B8BD);
    final thumbShadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawLine(start, end, inactivePaint);
    canvas.drawLine(start, thumbCenter, activePaint);
    canvas.drawCircle(thumbCenter.translate(0, 1.5), 8, thumbShadowPaint);
    canvas.drawCircle(thumbCenter, 6.5, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _CompactSeekBarPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.enabled != enabled;
  }
}
