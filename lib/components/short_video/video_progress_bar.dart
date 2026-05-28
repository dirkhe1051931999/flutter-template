import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ShortVideoProgressBar extends StatefulWidget {
  const ShortVideoProgressBar({
    super.key,
    required this.position,
    required this.duration,
    this.onSeek,
    this.onInteractionVisibilityChanged,
    this.bottomOffset = 0,
  });

  final ValueListenable<Duration> position;
  final ValueListenable<Duration> duration;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<bool>? onInteractionVisibilityChanged;
  final double bottomOffset;

  @override
  State<ShortVideoProgressBar> createState() => _ShortVideoProgressBarState();
}

class _ShortVideoProgressBarState extends State<ShortVideoProgressBar> {
  static const double _hitAreaHeight = 24;
  static const double _barHeight = 3;
  static const double _hoverBarHeight = 6;
  static const double _bubbleBottomGap = 10;
  static const Duration _tapBubbleVisibilityDuration = Duration(milliseconds: 900);

  double? _dragProgress;
  Timer? _bubbleDismissTimer;
  bool _isHovered = false;

  @override
  void dispose() {
    _bubbleDismissTimer?.cancel();
    super.dispose();
  }

  double _progressFromDx(double dx, double width) {
    if (width <= 0) {
      return 0;
    }
    return (dx / width).clamp(0.0, 1.0);
  }

  Duration _durationFromProgress(double progress, Duration total) {
    final totalMs = total.inMilliseconds;
    if (totalMs <= 0) {
      return Duration.zero;
    }
    return Duration(milliseconds: (totalMs * progress).round());
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final hours = minutes ~/ 60;
    final normalizedMinutes = minutes % 60;

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(normalizedMinutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _seekAt(Offset localPosition, double width, Duration total) {
    final progress = _progressFromDx(localPosition.dx, width);
    setState(() {
      _dragProgress = progress;
    });
    widget.onInteractionVisibilityChanged?.call(true);
    widget.onSeek?.call(_durationFromProgress(progress, total));
  }

  void _scheduleBubbleDismiss() {
    _bubbleDismissTimer?.cancel();
    _bubbleDismissTimer = Timer(_tapBubbleVisibilityDuration, () {
      if (!mounted) {
        return;
      }
      _clearDragProgress();
    });
  }

  void _clearDragProgress() {
    _bubbleDismissTimer?.cancel();
    if (_dragProgress == null) {
      widget.onInteractionVisibilityChanged?.call(false);
      return;
    }
    setState(() {
      _dragProgress = null;
    });
    widget.onInteractionVisibilityChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
      valueListenable: widget.position,
      builder: (context, pos, _) {
        return ValueListenableBuilder<Duration>(
          valueListenable: widget.duration,
          builder: (context, dur, __) {
            final total = dur.inMilliseconds;
            final currentValue = total <= 0
                ? 0.0
                : (pos.inMilliseconds / total).clamp(0.0, 1.0);
            final value = _dragProgress ?? currentValue;
            final dragProgress = _dragProgress;
            final dragDuration = dragProgress == null
                ? null
                : _durationFromProgress(dragProgress, dur);
            final effectiveBarHeight = _isHovered ? _hoverBarHeight : _barHeight;

            return Positioned(
              left: 0,
              right: 0,
              bottom: widget.bottomOffset - ((_hitAreaHeight - effectiveBarHeight) / 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bubbleHalfWidth = constraints.maxWidth < 140 ? constraints.maxWidth / 2 : 70.0;
                  final bubbleCenterX = constraints.maxWidth * value;
                  final bubbleLeft = (bubbleCenterX - bubbleHalfWidth)
                      .clamp(0.0, (constraints.maxWidth - bubbleHalfWidth * 2).clamp(0.0, double.infinity));

                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) {
                      if (_isHovered) {
                        return;
                      }
                      setState(() {
                        _isHovered = true;
                      });
                    },
                    onExit: (_) {
                      if (!_isHovered) {
                        return;
                      }
                      setState(() {
                        _isHovered = false;
                      });
                    },
                    child: SizedBox(
                      height: _hitAreaHeight + 40,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (dragDuration != null)
                            Positioned(
                              left: bubbleLeft,
                              bottom: _hitAreaHeight + _bubbleBottomGap,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xCC111111),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: const Color(0x22FFFFFF),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      '${_formatDuration(dragDuration)} / ${_formatDuration(dur)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                _seekAt(details.localPosition, constraints.maxWidth, dur);
                                _scheduleBubbleDismiss();
                              },
                              onHorizontalDragStart: (details) {
                                _bubbleDismissTimer?.cancel();
                                _seekAt(details.localPosition, constraints.maxWidth, dur);
                              },
                              onHorizontalDragUpdate: (details) {
                                _seekAt(details.localPosition, constraints.maxWidth, dur);
                              },
                              onHorizontalDragEnd: (_) {
                                _clearDragProgress();
                              },
                              onHorizontalDragCancel: _clearDragProgress,
                              onVerticalDragStart: (_) {},
                              onVerticalDragUpdate: (_) {},
                              onVerticalDragEnd: (_) {
                                _clearDragProgress();
                              },
                              onVerticalDragCancel: _clearDragProgress,
                              child: SizedBox(
                                height: _hitAreaHeight,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 120),
                                      curve: Curves.easeOut,
                                      height: effectiveBarHeight,
                                      child: LinearProgressIndicator(
                                        value: value,
                                        backgroundColor: const Color(0x33FFFFFF),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
