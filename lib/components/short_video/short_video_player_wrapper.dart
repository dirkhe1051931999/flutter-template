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
  });

  final OolafVideoController? controller;
  final VoidCallback onSingleTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  @override
  State<ShortVideoPlayerWrapper> createState() =>
      _ShortVideoPlayerWrapperState();
}

class _ShortVideoPlayerWrapperState extends State<ShortVideoPlayerWrapper> {
  Offset? _lastDoubleTapPosition;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    final body = controller == null
        ? const Center(
            child: CupertinoActivityIndicator(radius: 14),
          )
        : Stack(
            fit: StackFit.expand,
            children: [
              controller.buildView(fit: BoxFit.cover),
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
              ),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isPlaying,
                builder: (context, isPlaying, __) {
                  if (isPlaying) {
                    return const SizedBox.shrink();
                  }
                  return Center(
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        color: Color(0x33000000),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.play_fill,
                        color: CupertinoColors.white,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
            ],
          );

    return RepaintBoundary(
      child: LikeBurstLayer(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onSingleTap,
          onLongPress: widget.onLongPress,
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
