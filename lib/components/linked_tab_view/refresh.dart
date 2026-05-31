import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import 'types.dart';

class LinkedTabPageRefresh extends StatelessWidget {
  const LinkedTabPageRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.triggerOffset = 92,
    this.completeDisplayDuration = const Duration(milliseconds: 280),
    this.indicatorBuilder,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double triggerOffset;
  final Duration completeDisplayDuration;
  final LinkedTabRefreshIndicatorBuilder? indicatorBuilder;

  @override
  Widget build(BuildContext context) {
    return _LinkedTabRefreshWrapper(
      config: LinkedTabRefreshConfig(
        onRefresh: onRefresh,
        triggerOffset: triggerOffset,
        completeDisplayDuration: completeDisplayDuration,
        indicatorBuilder: indicatorBuilder,
      ),
      child: child,
    );
  }
}

class _LinkedTabRefreshWrapper extends StatefulWidget {
  const _LinkedTabRefreshWrapper({
    required this.config,
    required this.child,
  });

  final LinkedTabRefreshConfig config;
  final Widget child;

  @override
  State<_LinkedTabRefreshWrapper> createState() =>
      _LinkedTabRefreshWrapperState();
}

class _LinkedTabRefreshWrapperState extends State<_LinkedTabRefreshWrapper> {
  double _pulledExtent = 0;
  LinkedTabRefreshState _state = LinkedTabRefreshState.idle;
  bool _isDragActive = false;
  bool _isRefreshing = false;

  double get _progress {
    return (_pulledExtent / widget.config.triggerOffset).clamp(0.0, 1.2);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) {
      return false;
    }

    if (notification is ScrollStartNotification) {
      _isDragActive = notification.dragDetails != null;
      return false;
    }

    if (notification is ScrollUpdateNotification &&
        notification.metrics.axis == Axis.vertical &&
        notification.metrics.pixels <= notification.metrics.minScrollExtent &&
        (notification.scrollDelta ?? 0) < 0) {
      _isDragActive = notification.dragDetails != null || _isDragActive;
      final delta = (notification.scrollDelta ?? 0).abs();
      if (delta <= 0) {
        return false;
      }
      final nextExtent = (_pulledExtent + (delta * 0.9))
          .clamp(0.0, widget.config.triggerOffset * 1.35);
      final nextState = nextExtent >= widget.config.triggerOffset
          ? LinkedTabRefreshState.armed
          : LinkedTabRefreshState.pulling;
      if (nextExtent != _pulledExtent || nextState != _state) {
        setState(() {
          _pulledExtent = nextExtent;
          _state = nextState;
        });
      }
      return false;
    }

    if (notification is OverscrollNotification &&
        notification.metrics.axis == Axis.vertical &&
        notification.metrics.pixels <= notification.metrics.minScrollExtent) {
      final delta = notification.overscroll.abs();
      if (delta <= 0) {
        return false;
      }
      _isDragActive = notification.dragDetails != null || _isDragActive;
      final nextExtent = (_pulledExtent + (delta * 0.55))
          .clamp(0.0, widget.config.triggerOffset * 1.35);
      final nextState = nextExtent >= widget.config.triggerOffset
          ? LinkedTabRefreshState.armed
          : LinkedTabRefreshState.pulling;
      if (nextExtent != _pulledExtent || nextState != _state) {
        setState(() {
          _pulledExtent = nextExtent;
          _state = nextState;
        });
      }
      return false;
    }

    if (notification is ScrollUpdateNotification &&
        notification.metrics.axis == Axis.vertical &&
        notification.metrics.pixels > notification.metrics.minScrollExtent &&
        _pulledExtent > 0) {
      setState(() {
        _pulledExtent = 0;
        _state = LinkedTabRefreshState.idle;
      });
      return false;
    }

    if (notification is ScrollEndNotification ||
        (notification is UserScrollNotification &&
            notification.direction == ScrollDirection.idle)) {
      final shouldTriggerRefresh =
          _state == LinkedTabRefreshState.armed && _isDragActive;
      _isDragActive = false;
      if (shouldTriggerRefresh) {
        unawaited(_triggerRefresh());
      } else if (_pulledExtent > 0) {
        setState(() {
          _pulledExtent = 0;
          _state = LinkedTabRefreshState.idle;
        });
      }
    }

    return false;
  }

  Future<void> _triggerRefresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
      _state = LinkedTabRefreshState.refreshing;
      _pulledExtent = widget.config.triggerOffset;
    });

    try {
      await widget.config.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _state = LinkedTabRefreshState.complete;
        });
      }
      await Future<void>.delayed(widget.config.completeDisplayDuration);
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _pulledExtent = 0;
          _state = LinkedTabRefreshState.idle;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final indicator = widget.config.indicatorBuilder?.call(
          context,
          _state,
          _progress,
        ) ??
        _DefaultLinkedTabRefreshIndicator(
          state: _state,
          progress: _progress,
        );

    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: _state == LinkedTabRefreshState.idle ? 0 : 1,
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      _state == LinkedTabRefreshState.refreshing
                          ? 0.0
                          : (1 - _progress.clamp(0.0, 1.0)) * -18,
                    ),
                    child: indicator,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultLinkedTabRefreshIndicator extends StatelessWidget {
  const _DefaultLinkedTabRefreshIndicator({
    required this.state,
    required this.progress,
  });

  final LinkedTabRefreshState state;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final String title;
    switch (state) {
      case LinkedTabRefreshState.armed:
        title = '释放立即刷新';
      case LinkedTabRefreshState.refreshing:
        title = '正在刷新';
      case LinkedTabRefreshState.complete:
        title = '刷新完成';
      case LinkedTabRefreshState.idle:
      case LinkedTabRefreshState.pulling:
        title = '下拉刷新';
    }

    return Opacity(
      opacity: math.max(0.0, normalizedProgress),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xF9FFFFFF),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CupertinoActivityIndicator.partiallyRevealed(
                  progress: state == LinkedTabRefreshState.refreshing
                      ? 1.0
                      : normalizedProgress,
                  radius: 8,
                  color: const Color(0xFFE5484D),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1F2329),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
