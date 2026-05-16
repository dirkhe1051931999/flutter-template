import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/like_animation_layer.dart';
import 'package:oolaf_flutted/components/short_video/video_progress_bar.dart';
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
    this.onVerticalDragOffsetChanged,
    this.progressBarBottomOffset = 0,
    this.fit,
  });

  final OolafVideoController? controller;
  final VoidCallback onSingleTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final ValueChanged<double>? onVerticalDragOffsetChanged;
  final double progressBarBottomOffset;
  final BoxFit? fit;

  @override
  State<ShortVideoPlayerWrapper> createState() =>
      _ShortVideoPlayerWrapperState();
}

class _ShortVideoPlayerWrapperState extends State<ShortVideoPlayerWrapper> {
  static const double _swipeVelocityThreshold = 280;
  static const double _tabBarHeight = 50;

  Offset? _lastDoubleTapPosition;
  double _verticalDragOffset = 0;

  bool _isLandscapeVideo(Size? videoSize) {
    return videoSize != null &&
        videoSize.width > 0 &&
        videoSize.height > 0 &&
        videoSize.width > videoSize.height;
  }

  Future<void> _seekBy(Duration delta) async {
    final controller = widget.controller;
    if (controller == null) {
      return;
    }

    final current = controller.position.value;
    final total = controller.duration.value;
    final target = current + delta;

    if (target <= Duration.zero) {
      await controller.seekTo(Duration.zero);
      return;
    }
    if (total > Duration.zero && target >= total) {
      await controller.seekTo(total);
      return;
    }
    await controller.seekTo(target);
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
              final fit = widget.fit ?? (isLandscape ? BoxFit.contain : BoxFit.cover);

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
                  ShortVideoProgressBar(
                    position: controller.position,
                    duration: controller.duration,
                    bottomOffset: widget.progressBarBottomOffset,
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.isPlaying,
                    builder: (context, isPlaying, __) {
                      final bottomOffset =
                          _tabBarHeight +
                          MediaQuery.of(context).viewPadding.bottom +
                          6;

                      return Stack(
                        children: [
                          Positioned(
                            left: 6,
                            bottom: bottomOffset,
                            child: _ActionButton(
                              icon: CupertinoIcons.gobackward_10,
                              onTap: () async {
                                await _seekBy(const Duration(seconds: -10));
                              },
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: bottomOffset,
                            child: _ActionButton(
                              icon: CupertinoIcons.goforward_10,
                              onTap: () async {
                                await _seekBy(const Duration(seconds: 10));
                              },
                            ),
                          ),
                          if (!isPlaying)
                            Center(
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
                            ),
                        ],
                      );
                    },
                  ),
                  ValueListenableBuilder<OolafVideoOutputStatus>(
                    valueListenable: controller.videoOutputStatus,
                    builder: (context, status, __) {
                      if (status != OolafVideoOutputStatus.codecUnsupported) {
                        return const SizedBox.shrink();
                      }

                      return const ColoredBox(
                        color: Color(0x99000000),
                        child: Center(
                          child: Text(
                            '当前视频编码不兼容，已暂停',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );

    return RepaintBoundary(
      child: LikeBurstLayer(
        child: GestureDetector(
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
            widget.onVerticalDragOffsetChanged?.call(_verticalDragOffset);
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
              context.emitLikeBurst(pos);
            }
          },
          child: RepaintBoundary(child: body),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap();
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0x4D000000),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xE6FFFFFF),
          size: 22,
        ),
      ),
    );
  }
}
