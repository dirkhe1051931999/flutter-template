import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/model/short_video/danmaku_item.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class ShortVideoDanmakuOverlay extends StatefulWidget {
  const ShortVideoDanmakuOverlay({
    super.key,
    required this.videoId,
    required this.title,
    required this.source,
    required this.controller,
    this.items,
    this.opacity = 0.82,
    this.fontScale = 1.0,
    this.fontWeight = 600,
    this.speed = 1.0,
    this.areaRatio = 0.7,
    this.enabled = true,
  });

  final String videoId;
  final String title;
  final String source;
  final OolafVideoController? controller;
  final List<DanmakuItem>? items;
  final double opacity;
  final double fontScale;
  final int fontWeight;
  final double speed;
  final double areaRatio;
  final bool enabled;

  @override
  State<ShortVideoDanmakuOverlay> createState() =>
      _ShortVideoDanmakuOverlayState();
}

class _ShortVideoDanmakuOverlayState extends State<ShortVideoDanmakuOverlay>
    with SingleTickerProviderStateMixin {
  static const double _trackHeight = 32;
  static const double _topOffset = 112;
  static const double _safeBottomReserve = 230;
  static const double _minSpeedPxPerSecond = 84;
  static const double _maxSpeedPxPerSecond = 138;
  static const int _defaultTimelineHorizonMs = 70 * 1000;

  final List<_DanmakuSeed> _timelineSeeds = <_DanmakuSeed>[];
  final List<_DanmakuRenderEntry> _renderEntries = <_DanmakuRenderEntry>[];

  late final AnimationController _ticker;

  OolafVideoController? _boundController;
  VoidCallback? _positionListener;
  VoidCallback? _durationListener;
  VoidCallback? _playingListener;

  Duration _basePosition = Duration.zero;
  Duration _latestDuration = Duration.zero;
  bool _isPlaying = false;
  int _baseWallClockMs = 0;

  double _lastLayoutWidth = 0;
  double _lastLayoutHeight = 0;
  double _lastTopInset = 0;
  double _lastBottomInset = 0;
  int _lastTrackCount = 0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        if (mounted && _isPlaying) {
          setState(() {});
        }
      });
    _rebuildTimelineSeeds();
    _bindController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant ShortVideoDanmakuOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoId != oldWidget.videoId ||
        widget.title != oldWidget.title ||
        widget.source != oldWidget.source ||
        widget.opacity != oldWidget.opacity ||
        widget.fontScale != oldWidget.fontScale ||
        widget.fontWeight != oldWidget.fontWeight ||
        widget.speed != oldWidget.speed ||
        widget.areaRatio != oldWidget.areaRatio ||
        !_isSameDanmakuItems(widget.items, oldWidget.items)) {
      _rebuildTimelineSeeds();
      _renderEntries.clear();
      _lastTrackCount = 0;
      _lastLayoutWidth = 0;
      _lastLayoutHeight = 0;
      _lastTopInset = 0;
      _lastBottomInset = 0;
    }

    if (!identical(widget.controller, oldWidget.controller)) {
      _bindController(widget.controller);
    }
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled) {
        _ticker.stop();
      } else if (_isPlaying) {
        _ticker.repeat(min: 0, max: 1, period: const Duration(milliseconds: 16));
      }
    }
  }

  @override
  void dispose() {
    _unbindController();
    _ticker.dispose();
    super.dispose();
  }

  void _bindController(OolafVideoController? controller) {
    _unbindController();
    _boundController = controller;
    if (controller == null) {
      _basePosition = Duration.zero;
      _latestDuration = Duration.zero;
      _isPlaying = false;
      return;
    }

    _basePosition = controller.position.value;
    _latestDuration = controller.duration.value;
    _isPlaying = controller.isPlaying.value;
    _baseWallClockMs = DateTime.now().millisecondsSinceEpoch;

    _positionListener = () {
      _basePosition = controller.position.value;
      _baseWallClockMs = DateTime.now().millisecondsSinceEpoch;
      if (mounted) {
        setState(() {});
      }
    };
    _durationListener = () {
      final duration = controller.duration.value;
      if ((_latestDuration - duration).abs().inMilliseconds <= 400) {
        return;
      }
      _latestDuration = duration;
      _renderEntries.clear();
      _lastTrackCount = 0;
      _lastLayoutWidth = 0;
      _lastLayoutHeight = 0;
      _lastTopInset = 0;
      _lastBottomInset = 0;
      if (mounted) {
        setState(() {});
      }
    };
    _playingListener = () {
      _isPlaying = controller.isPlaying.value;
      if (_isPlaying && widget.enabled) {
        _basePosition = controller.position.value;
        _baseWallClockMs = DateTime.now().millisecondsSinceEpoch;
        _ticker.repeat(
          min: 0,
          max: 1,
          period: const Duration(milliseconds: 16),
        );
      } else {
        _basePosition = controller.position.value;
        _ticker.stop();
      }
      if (mounted) {
        setState(() {});
      }
    };

    controller.position.addListener(_positionListener!);
    controller.duration.addListener(_durationListener!);
    controller.isPlaying.addListener(_playingListener!);

    if (_isPlaying && widget.enabled) {
      _ticker.repeat(
        min: 0,
        max: 1,
        period: const Duration(milliseconds: 16),
      );
    }
  }

  void _unbindController() {
    final controller = _boundController;
    if (controller != null) {
      final positionListener = _positionListener;
      if (positionListener != null) {
        controller.position.removeListener(positionListener);
      }
      final durationListener = _durationListener;
      if (durationListener != null) {
        controller.duration.removeListener(durationListener);
      }
      final playingListener = _playingListener;
      if (playingListener != null) {
        controller.isPlaying.removeListener(playingListener);
      }
    }
    _boundController = null;
    _positionListener = null;
    _durationListener = null;
    _playingListener = null;
    _ticker.stop();
  }

  int _effectivePositionMs() {
    final durationMs = _effectiveTimelineDurationMs();
    var currentMs = _basePosition.inMilliseconds;
    if (_isPlaying) {
      final elapsedMs =
          DateTime.now().millisecondsSinceEpoch - _baseWallClockMs;
      if (elapsedMs > 0) {
        currentMs += elapsedMs;
      }
    }
    if (durationMs <= 0) {
      return currentMs < 0 ? 0 : currentMs;
    }
    if (currentMs < 0) {
      return 0;
    }
    if (currentMs > durationMs) {
      return durationMs;
    }
    return currentMs;
  }

  int _effectiveTimelineDurationMs() {
    final controllerDurationMs = _latestDuration.inMilliseconds;
    if (controllerDurationMs > 0) {
      return controllerDurationMs;
    }
    return _defaultTimelineHorizonMs;
  }

  void _rebuildTimelineSeeds() {
    final serverItems = widget.items;
    if (serverItems != null && serverItems.isNotEmpty) {
      _timelineSeeds
        ..clear()
        ..addAll(_buildServerTimelineSeeds(serverItems));
      return;
    }

    _timelineSeeds
      ..clear()
      ..addAll(_buildMockTimelineSeeds());
  }

  List<_DanmakuSeed> _buildServerTimelineSeeds(List<DanmakuItem> items) {
    final seeds = <_DanmakuSeed>[];
    for (final item in items) {
      final text = item.text.trim();
      if (text.isEmpty) {
        continue;
      }
      if (item.atMs < 0) {
        continue;
      }
      seeds.add(
        _DanmakuSeed(
          atMs: item.atMs,
          text: text,
          emphasize: _shouldEmphasize(item),
          color: _resolveDanmakuColor(item.color),
          sourceSpeedBias: _speedBiasFor(item),
        ),
      );
    }
    seeds.sort((a, b) => a.atMs.compareTo(b.atMs));
    return seeds;
  }

  bool _shouldEmphasize(DanmakuItem item) {
    final type = item.type.toLowerCase();
    if (item.priority >= 3) {
      return true;
    }
    return type == 'highlight' || type == 'hot' || type == 'vip';
  }

  double _speedBiasFor(DanmakuItem item) {
    final normalizedPriority = (item.priority.clamp(0, 5)) / 5;
    final hashed = ((item.atMs + item.text.hashCode) % 1000).abs() / 1000;
    return (normalizedPriority * 0.35 + hashed * 0.65).clamp(0, 1).toDouble();
  }

  Color? _resolveDanmakuColor(String colorText) {
    final text = colorText.trim();
    if (text.isEmpty) {
      return null;
    }
    final hex = text.startsWith('#') ? text.substring(1) : text;
    if (hex.length != 6 && hex.length != 8) {
      return null;
    }
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return null;
    }
    if (hex.length == 6) {
      return Color(0xFF000000 | value);
    }
    return Color(value);
  }

  List<_DanmakuSeed> _buildMockTimelineSeeds() {
    final source = widget.source.trim().isEmpty ? 'ForYou' : widget.source.trim();
    final titleSnippet = _extractTitleSnippet(widget.title);

    final templates = <String>[
      'Nice shot',
      'LOL',
      'Replay',
      'So smooth',
      'Peak',
      'Clean move',
      'Too fast',
      'This hits',
      'Legend',
      'Hard carry',
      'Vibe',
      'No way',
      'Crazy',
      'Top tier',
      'Watch again',
      'Saved',
      'Go next',
      'Respect',
      'Absolute cinema',
      'Mood',
      'Frame by frame',
      'Timing god',
    ];

    final random = math.Random(
      widget.videoId.hashCode ^ widget.title.hashCode ^ widget.source.hashCode,
    );
    final seeds = <_DanmakuSeed>[];

    var cursorMs = 700 + random.nextInt(600);
    for (var i = 0; i < 44; i += 1) {
      cursorMs += 580 + random.nextInt(1480);

      String text;
      if (i % 9 == 0) {
        text = '#$source';
      } else if (i % 7 == 0) {
        text = '$titleSnippet ...';
      } else {
        text = templates[random.nextInt(templates.length)];
      }

      final emphasize = i % 8 == 0 || random.nextDouble() > 0.86;
      seeds.add(
        _DanmakuSeed(
          atMs: cursorMs,
          text: text,
          emphasize: emphasize,
          color: null,
          sourceSpeedBias: null,
        ),
      );
    }
    return seeds;
  }

  String _extractTitleSnippet(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return 'Must watch';
    }
    if (text.length <= 14) {
      return text;
    }
    return text.substring(0, 14);
  }

  void _ensureRenderEntries({
    required BuildContext context,
    required double width,
    required double height,
    required double topInset,
    required double bottomInset,
  }) {
    final safeTrackHeight =
        ((height - _topOffset - topInset - _safeBottomReserve - bottomInset) *
                widget.areaRatio.clamp(0.35, 1.0))
            .clamp(140, 360)
            .toDouble();
    final trackCount =
        (safeTrackHeight / _trackHeight).floor().clamp(4, 10).toInt();

    final needRebuild = _renderEntries.isEmpty ||
        (width - _lastLayoutWidth).abs() > 0.1 ||
        (height - _lastLayoutHeight).abs() > 0.1 ||
        (topInset - _lastTopInset).abs() > 0.1 ||
        (bottomInset - _lastBottomInset).abs() > 0.1 ||
        trackCount != _lastTrackCount;

    if (!needRebuild) {
      return;
    }

    final timelineDurationMs = _effectiveTimelineDurationMs();
    final seeds = _timelineSeeds
        .where((seed) => seed.atMs < timelineDurationMs + 1200)
        .toList(growable: false);
    if (seeds.isEmpty) {
      _renderEntries.clear();
      return;
    }

    final style = TextStyle(
      color: CupertinoColors.white,
      fontSize: 14 * widget.fontScale.clamp(0.85, 1.4),
      fontWeight:
          widget.fontWeight >= 700 ? FontWeight.w700 : FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.1,
    );

    final emphasizedStyle = style.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFFFFF0F0),
    );

    final lanesAvailableAtMs = List<int>.filled(trackCount, 0);
    final entries = <_DanmakuRenderEntry>[];

    for (final seed in seeds) {
      final textStyle = seed.emphasize ? emphasizedStyle : style;
      final widthWithPadding = _measureTextWidth(
            context: context,
            text: seed.text,
            style: textStyle,
          ) +
          20;
      final speedPxPerSec =
          (_minSpeedPxPerSecond +
                  (seed.speedBias * (_maxSpeedPxPerSecond - _minSpeedPxPerSecond))) *
              widget.speed.clamp(0.75, 1.5);
      final totalDistance = width + widthWithPadding;
      final durationMs = (totalDistance / speedPxPerSec * 1000).round();

      var targetTrack = 0;
      var bestAvailableAtMs = lanesAvailableAtMs[0];
      for (var i = 1; i < lanesAvailableAtMs.length; i += 1) {
        if (lanesAvailableAtMs[i] < bestAvailableAtMs) {
          bestAvailableAtMs = lanesAvailableAtMs[i];
          targetTrack = i;
        }
      }

      final appearsAtMs = math.max(seed.atMs, bestAvailableAtMs);
      lanesAvailableAtMs[targetTrack] = appearsAtMs + (durationMs * 0.35).round();
      entries.add(
        _DanmakuRenderEntry(
          text: seed.text,
          appearsAtMs: appearsAtMs,
          durationMs: durationMs,
          textWidth: widthWithPadding,
          track: targetTrack,
          emphasize: seed.emphasize,
          textColor: seed.color,
        ),
      );
    }

    _renderEntries
      ..clear()
      ..addAll(entries);
    _lastLayoutWidth = width;
    _lastLayoutHeight = height;
    _lastTopInset = topInset;
    _lastBottomInset = bottomInset;
    _lastTrackCount = trackCount;
  }

  double _measureTextWidth({
    required BuildContext context,
    required String text,
    required TextStyle style,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (!widget.enabled || controller == null) {
      return const SizedBox.shrink();
    }

    final media = MediaQuery.of(context);
    final topInset = media.padding.top;
    final bottomInset = media.padding.bottom;
    final currentMs = _effectivePositionMs();

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          if (width <= 0 || height <= 0) {
            return const SizedBox.shrink();
          }

          _ensureRenderEntries(
            context: context,
            width: width,
            height: height,
            topInset: topInset,
            bottomInset: bottomInset,
          );

          final trackTop = topInset + _topOffset;
          final visibleChildren = <Widget>[];

          for (final entry in _renderEntries) {
            if (currentMs < entry.appearsAtMs) {
              continue;
            }
            final elapsedMs = currentMs - entry.appearsAtMs;
            if (elapsedMs >= entry.durationMs) {
              continue;
            }

            final progress = elapsedMs / entry.durationMs;
            final distance = width + entry.textWidth;
            final x = width - (distance * progress);
            final y = trackTop + (entry.track * _trackHeight);

            visibleChildren.add(
              Positioned(
                left: x,
                top: y,
                child: _DanmakuBubble(
                  text: entry.text,
                  emphasize: entry.emphasize,
                  textColor: entry.textColor,
                  opacity: widget.opacity,
                  fontScale: widget.fontScale,
                  fontWeightValue: widget.fontWeight,
                ),
              ),
            );
          }

          return Stack(children: visibleChildren);
        },
      ),
    );
  }
}

class _DanmakuBubble extends StatelessWidget {
  const _DanmakuBubble({
    required this.text,
    required this.emphasize,
    this.textColor,
    required this.opacity,
    required this.fontScale,
    required this.fontWeightValue,
  });

  final String text;
  final bool emphasize;
  final Color? textColor;
  final double opacity;
  final double fontScale;
  final int fontWeightValue;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = emphasize
        ? const Color(0x5CFF2D55).withValues(alpha: opacity.clamp(0.2, 1.0))
        : const Color(0x47000000).withValues(alpha: opacity.clamp(0.2, 1.0));
    final borderColor = emphasize
        ? const Color(0xB3FF6A85)
        : const Color(0x5CFFFFFF);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor ?? CupertinoColors.white,
            fontSize: 14 * fontScale.clamp(0.85, 1.4),
            fontWeight: emphasize || fontWeightValue >= 700
                ? FontWeight.w700
                : FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

class _DanmakuSeed {
  const _DanmakuSeed({
    required this.atMs,
    required this.text,
    required this.emphasize,
    this.color,
    this.sourceSpeedBias,
  }) : speedBias = sourceSpeedBias ?? ((atMs % 1000) / 1000);

  final int atMs;
  final String text;
  final bool emphasize;
  final Color? color;
  final double? sourceSpeedBias;
  final double speedBias;
}

class _DanmakuRenderEntry {
  const _DanmakuRenderEntry({
    required this.text,
    required this.appearsAtMs,
    required this.durationMs,
    required this.textWidth,
    required this.track,
    required this.emphasize,
    this.textColor,
  });

  final String text;
  final int appearsAtMs;
  final int durationMs;
  final double textWidth;
  final int track;
  final bool emphasize;
  final Color? textColor;
}

bool _isSameDanmakuItems(List<DanmakuItem>? a, List<DanmakuItem>? b) {
  if (identical(a, b)) {
    return true;
  }
  if (a == null || b == null) {
    return a == b;
  }
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i += 1) {
    final left = a[i];
    final right = b[i];
    if (left.atMs != right.atMs ||
        left.text != right.text ||
        left.type != right.type ||
        left.color != right.color ||
        left.priority != right.priority) {
      return false;
    }
  }
  return true;
}
