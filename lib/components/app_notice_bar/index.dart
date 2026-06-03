import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_notice_bar/app_notice_bar_types.dart';

class AppNoticeBar extends StatefulWidget {
  const AppNoticeBar({
    super.key,
    this.text,
    this.scrollable = true,
    this.delay = const Duration(milliseconds: 800),
    this.speed = 42,
    this.leftIcon = CupertinoIcons.volume_up,
    this.mode = AppNoticeBarMode.none,
    this.wrapable = false,
    this.color = const Color(0xFFB45309),
    this.backgroundColor = const Color(0xFFFFF7E8),
    this.direction = AppNoticeBarDirection.horizontal,
    this.verticalItems = const <String>[],
    this.verticalStepDuration = const Duration(milliseconds: 2200),
    this.verticalVisibleCount = 1,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.iconSize = 18,
    this.textStyle,
    this.onTap,
    this.onClose,
  });

  final String? text;
  final bool scrollable;
  final Duration delay;
  final double speed;
  final IconData leftIcon;
  final AppNoticeBarMode mode;
  final bool wrapable;
  final Color color;
  final Color backgroundColor;
  final AppNoticeBarDirection direction;
  final List<String> verticalItems;
  final Duration verticalStepDuration;
  final int verticalVisibleCount;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double iconSize;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  @override
  State<AppNoticeBar> createState() => _AppNoticeBarState();
}

class _AppNoticeBarState extends State<AppNoticeBar> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _marqueeTextKey = GlobalKey();
  Timer? _marqueeStarter;
  Timer? _verticalTimer;
  bool _visible = true;
  bool _horizontalMarqueeRunning = false;
  bool _horizontalLoopEnabled = false;
  int _verticalIndex = 0;
  double? _lastHorizontalWidth;
  double _horizontalTextWidth = 0;
  int _horizontalLayoutVersion = 0;
  static const double _marqueeGap = 36;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(covariant AppNoticeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.direction != widget.direction ||
        oldWidget.verticalItems != widget.verticalItems) {
      _cancelTimers();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _cancelTimers();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    if (widget.direction == AppNoticeBarDirection.horizontal) {
      if (!widget.scrollable) {
        return;
      }
      _scheduleHorizontalMarquee();
      return;
    }

    if (widget.verticalItems.length <= 1) {
      return;
    }
    _verticalTimer = Timer.periodic(widget.verticalStepDuration, (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _verticalIndex = (_verticalIndex + 1) % widget.verticalItems.length;
      });
    });
  }

  void _cancelTimers() {
    _marqueeStarter?.cancel();
    _verticalTimer?.cancel();
    _marqueeStarter = null;
    _verticalTimer = null;
  }

  void _scheduleHorizontalMarquee() {
    _marqueeStarter?.cancel();
    if (!widget.scrollable ||
        widget.direction != AppNoticeBarDirection.horizontal ||
        widget.wrapable) {
      return;
    }
    _marqueeStarter = Timer(widget.delay, _startHorizontalMarquee);
  }

  void _syncHorizontalMarqueeForLayout(double width) {
    if (!widget.scrollable ||
        widget.direction != AppNoticeBarDirection.horizontal ||
        widget.wrapable) {
      return;
    }
    if (_lastHorizontalWidth == width) {
      return;
    }
    _lastHorizontalWidth = width;
    _horizontalLayoutVersion += 1;
    final layoutVersion = _horizontalLayoutVersion;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      if (layoutVersion != _horizontalLayoutVersion) {
        return;
      }
      final textWidth =
          _marqueeTextKey.currentContext?.size?.width ?? _horizontalTextWidth;
      _horizontalTextWidth = textWidth;
      if (textWidth <= width) {
        if (_horizontalLoopEnabled) {
          setState(() {
            _horizontalLoopEnabled = false;
          });
        }
        _marqueeStarter?.cancel();
        if (_scrollController.offset != 0) {
          _scrollController.jumpTo(0);
        }
        return;
      }
      if (!_horizontalLoopEnabled) {
        setState(() {
          _horizontalLoopEnabled = true;
        });
      }
      if (!_horizontalMarqueeRunning) {
        if (_scrollController.offset != 0) {
          _scrollController.jumpTo(0);
        }
        _scheduleHorizontalMarquee();
      }
    });
  }

  Future<void> _startHorizontalMarquee() async {
    if (!mounted || !_scrollController.hasClients || _horizontalMarqueeRunning) {
      return;
    }
    _horizontalMarqueeRunning = true;
    final layoutVersion = _horizontalLayoutVersion;

    try {
      while (mounted &&
          widget.direction == AppNoticeBarDirection.horizontal &&
          widget.scrollable) {
        if (layoutVersion != _horizontalLayoutVersion) {
          return;
        }
        final textWidth = _horizontalTextWidth;
        final distance = textWidth + _marqueeGap;
        if (textWidth <= 0) {
          return;
        }
        if (textWidth <= (_lastHorizontalWidth ?? 0)) {
          if (_scrollController.offset != 0) {
            _scrollController.jumpTo(0);
          }
          return;
        }
        final remaining = distance - _scrollController.offset;
        final duration = Duration(
          milliseconds: (remaining / widget.speed * 1000).round(),
        );
        await _scrollController.animateTo(
          distance,
          duration: duration,
          curve: Curves.linear,
        );
        if (!mounted) {
          return;
        }
        if (layoutVersion != _horizontalLayoutVersion) {
          return;
        }
        _scrollController.jumpTo(0);
        await Future<void>.delayed(widget.delay);
      }
    } finally {
      _horizontalMarqueeRunning = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }
        if (_horizontalTextWidth > (_lastHorizontalWidth ?? 0)) {
          _scheduleHorizontalMarquee();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          border: Border.all(color: const Color(0x10B45309)),
        ),
        child: Padding(
          padding: widget.padding,
          child: Row(
            children: [
              Icon(
                widget.leftIcon,
                size: widget.iconSize,
                color: widget.color,
              ),
              SizedBox(width: widget.iconSize <= 14 ? 6 : 10),
              Expanded(
                child: widget.direction == AppNoticeBarDirection.vertical
                    ? _buildVerticalContent()
                    : _buildHorizontalContent(),
              ),
              if (widget.mode == AppNoticeBarMode.closeable) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _visible = false;
                    });
                    widget.onClose?.call();
                  },
                  child: Icon(
                    CupertinoIcons.clear_thick_circled,
                    size: 18,
                    color: widget.color.withValues(alpha: 0.7),
                  ),
                ),
              ] else if (widget.mode == AppNoticeBarMode.link) ...[
                const SizedBox(width: 10),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: widget.color.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalContent() {
    final text = widget.text ?? '';
    final textStyle =
        widget.textStyle ??
        TextStyle(
          color: widget.color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );

    if (widget.wrapable) {
      return Text(
        text,
        style: textStyle.copyWith(height: 1.35),
      );
    }

    if (!widget.scrollable) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _syncHorizontalMarqueeForLayout(constraints.maxWidth);
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                key: _marqueeTextKey,
                maxLines: 1,
                style: textStyle,
              ),
              if (_horizontalLoopEnabled) ...[
                const SizedBox(width: _marqueeGap),
                Text(
                  text,
                  maxLines: 1,
                  style: textStyle,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerticalContent() {
    final items = widget.verticalItems;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final visibleCount = widget.verticalVisibleCount.clamp(1, 4);
    const itemHeight = 22.0;
    final visibleItems = List<String>.generate(visibleCount, (offset) {
      final nextIndex = (_verticalIndex + offset) % items.length;
      return items[nextIndex];
    });

    return SizedBox(
      height: itemHeight * visibleCount,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.24),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Column(
          key: ValueKey<int>(_verticalIndex),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: visibleItems
              .map(
                (item) => SizedBox(
                  height: itemHeight,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}
