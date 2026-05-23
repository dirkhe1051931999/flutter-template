import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/like_animation_layer.dart';
import 'package:oolaf_flutted/components/short_video/video_progress_bar.dart';
import 'package:oolaf_flutted/tools/developer_tools_center.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class ShortVideoPlayerWrapper extends StatefulWidget {
  const ShortVideoPlayerWrapper({
    super.key,
    required this.controller,
    required this.onSingleTap,
    required this.onLongPress,
    required this.onDoubleTap,
    required this.onSwipeUp,
    required this.onSwipeDown,
    this.onProgressInteractionChanged,
    this.onVerticalDragOffsetChanged,
    this.onRetry,
    this.onSkip,
    this.onCopyLink,
    this.onMarkUnavailable,
    this.progressBarBottomOffset = 0,
    this.fit,
  });

  final OolafVideoController? controller;
  final VoidCallback onSingleTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final ValueChanged<bool>? onProgressInteractionChanged;
  final ValueChanged<double>? onVerticalDragOffsetChanged;
  final Future<void> Function()? onRetry;
  final Future<void> Function()? onSkip;
  final Future<void> Function()? onCopyLink;
  final Future<void> Function()? onMarkUnavailable;
  final double progressBarBottomOffset;
  final BoxFit? fit;

  @override
  State<ShortVideoPlayerWrapper> createState() =>
      _ShortVideoPlayerWrapperState();
}

class _ShortVideoPlayerWrapperState extends State<ShortVideoPlayerWrapper> {
  static const double _swipeVelocityThreshold = 280;

  Offset? _lastDoubleTapPosition;
  double _verticalDragOffset = 0;
  VoidCallback? _videoStatusListener;
  OolafVideoController? _observedController;

  bool _isLandscapeVideo(Size? videoSize) {
    return videoSize != null &&
        videoSize.width > 0 &&
        videoSize.height > 0 &&
        videoSize.width > videoSize.height;
  }

  @override
  void initState() {
    super.initState();
    _bindVideoStatusListener(widget.controller);
  }

  @override
  void didUpdateWidget(covariant ShortVideoPlayerWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      _bindVideoStatusListener(widget.controller);
    }
  }

  @override
  void dispose() {
    _unbindVideoStatusListener();
    super.dispose();
  }

  void _bindVideoStatusListener(OolafVideoController? controller) {
    if (identical(_observedController, controller)) {
      return;
    }
    _unbindVideoStatusListener();
    if (controller == null) {
      return;
    }

    void listener() {
      DeveloperToolsCenter.instance.updateVideoStatus(
        DeveloperVideoStatus(
          time: DateTime.now(),
          source: widget.runtimeType.toString(),
          controllerHash: identityHashCode(controller).toString(),
          isInitialized: controller.isInitialized.value,
          isPlaying: controller.isPlaying.value,
          isBuffering: controller.isBuffering.value,
          position: controller.position.value,
          duration: controller.duration.value,
          outputStatus: controller.videoOutputStatus.value,
          videoSize: controller.videoSize.value,
        ),
      );
    }

    _observedController = controller;
    _videoStatusListener = listener;
    controller.isInitialized.addListener(listener);
    controller.isPlaying.addListener(listener);
    controller.isBuffering.addListener(listener);
    controller.position.addListener(listener);
    controller.duration.addListener(listener);
    controller.videoOutputStatus.addListener(listener);
    controller.videoSize.addListener(listener);
    listener();
  }

  void _unbindVideoStatusListener() {
    final controller = _observedController;
    final listener = _videoStatusListener;
    if (controller != null && listener != null) {
      controller.isInitialized.removeListener(listener);
      controller.isPlaying.removeListener(listener);
      controller.isBuffering.removeListener(listener);
      controller.position.removeListener(listener);
      controller.duration.removeListener(listener);
      controller.videoOutputStatus.removeListener(listener);
      controller.videoSize.removeListener(listener);
    }
    _observedController = null;
    _videoStatusListener = null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    final body = controller == null
        ? const Center(
            child: CupertinoActivityIndicator(radius: 14),
          )
        : ValueListenableBuilder<Size?>(
            valueListenable: controller.videoSize,
            builder: (context, videoSize, __) {
              final isLandscape = _isLandscapeVideo(videoSize);
              final fit =
                  widget.fit ?? (isLandscape ? BoxFit.contain : BoxFit.cover);

              return Stack(
                fit: StackFit.expand,
                children: [
                  controller.buildView(fit: fit),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.isBuffering,
                    builder: (context, isBuffering, __) {
                      if (!isBuffering) {
                        return const SizedBox.shrink();
                      }
                      return const Center(
                        child: CupertinoActivityIndicator(radius: 14),
                      );
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.isPlaying,
                    builder: (context, isPlaying, __) {
                      if (isPlaying) {
                        return const SizedBox.shrink();
                      }
                      return Center(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            await controller.play();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              CupertinoIcons.play_fill,
                              color: Color(0x33FFFFFF),
                              size: 76,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  ValueListenableBuilder<OolafVideoOutputStatus>(
                    valueListenable: controller.videoOutputStatus,
                    builder: (context, status, __) {
                      if (status == OolafVideoOutputStatus.normal) {
                        return const SizedBox.shrink();
                      }
                      return _ShortVideoPlaybackErrorOverlay(
                        status: status,
                        onRetry: widget.onRetry,
                        onSkip: widget.onSkip,
                        onCopyLink: widget.onCopyLink,
                        onMarkUnavailable: widget.onMarkUnavailable,
                      );
                    },
                  ),
                ],
              );
            },
          );

    return RepaintBoundary(
      child: LikeBurstLayer(
        child: Builder(
          builder: (layerContext) {
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onSingleTap,
                  onLongPress: widget.onLongPress,
                  onSecondaryTap: widget.onLongPress,
                  onVerticalDragStart: (_) {
                    _verticalDragOffset = 0;
                    widget.onVerticalDragOffsetChanged?.call(0);
                  },
                  onVerticalDragUpdate: (details) {
                    final delta = details.primaryDelta;
                    if (delta == null) {
                      return;
                    }
                    _verticalDragOffset += delta;
                    widget.onVerticalDragOffsetChanged?.call(
                      _verticalDragOffset,
                    );
                  },
                  onVerticalDragEnd: (details) {
                    final velocity = details.primaryVelocity;
                    _verticalDragOffset = 0;
                    widget.onVerticalDragOffsetChanged?.call(0);
                    if (velocity == null) {
                      return;
                    }

                    if (velocity <= -_swipeVelocityThreshold) {
                      widget.onSwipeUp();
                      return;
                    }
                    if (velocity >= _swipeVelocityThreshold) {
                      widget.onSwipeDown();
                    }
                  },
                  onVerticalDragCancel: () {
                    _verticalDragOffset = 0;
                    widget.onVerticalDragOffsetChanged?.call(0);
                  },
                  onDoubleTapDown: (details) {
                    _lastDoubleTapPosition = details.localPosition;
                  },
                  onDoubleTap: () {
                    widget.onDoubleTap();
                    final pos = _lastDoubleTapPosition;
                    if (pos != null) {
                      layerContext.emitLikeBurst(pos);
                    }
                  },
                  child: RepaintBoundary(child: body),
                ),
                if (controller != null)
                  ShortVideoProgressBar(
                    position: controller.position,
                    duration: controller.duration,
                    onSeek: (target) async {
                      await controller.seekTo(target);
                    },
                    onInteractionVisibilityChanged:
                        widget.onProgressInteractionChanged,
                    bottomOffset: widget.progressBarBottomOffset,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShortVideoPlaybackErrorOverlay extends StatelessWidget {
  const _ShortVideoPlaybackErrorOverlay({
    required this.status,
    this.onRetry,
    this.onSkip,
    this.onCopyLink,
    this.onMarkUnavailable,
  });

  final OolafVideoOutputStatus status;
  final Future<void> Function()? onRetry;
  final Future<void> Function()? onSkip;
  final Future<void> Function()? onCopyLink;
  final Future<void> Function()? onMarkUnavailable;

  String get _title {
    return switch (status) {
      OolafVideoOutputStatus.codecUnsupported => '视频编码暂不兼容',
      OolafVideoOutputStatus.loadFailed => '视频加载失败',
      OolafVideoOutputStatus.loadTimeout => '视频加载超时',
      OolafVideoOutputStatus.normal => '',
    };
  }

  String get _message {
    return switch (status) {
      OolafVideoOutputStatus.codecUnsupported => '当前设备暂时无法解码这个视频。',
      OolafVideoOutputStatus.loadFailed => '网络或视频源异常，稍后可以重试。',
      OolafVideoOutputStatus.loadTimeout => '加载时间过长，可能是网络不稳定。',
      OolafVideoOutputStatus.normal => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC000000),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                color: CupertinoColors.white,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (onRetry != null)
                    _ErrorActionButton(label: '重试', onPressed: onRetry!),
                  if (onSkip != null)
                    _ErrorActionButton(label: '跳过', onPressed: onSkip!),
                  if (onCopyLink != null)
                    _ErrorActionButton(label: '复制链接', onPressed: onCopyLink!),
                  if (onMarkUnavailable != null)
                    _ErrorActionButton(
                      label: '标记不可播放',
                      isDanger: true,
                      onPressed: onMarkUnavailable!,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorActionButton extends StatelessWidget {
  const _ErrorActionButton({
    required this.label,
    required this.onPressed,
    this.isDanger = false,
  });

  final String label;
  final Future<void> Function() onPressed;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(16),
      color: isDanger ? CupertinoColors.systemRed : const Color(0x33FFFFFF),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
