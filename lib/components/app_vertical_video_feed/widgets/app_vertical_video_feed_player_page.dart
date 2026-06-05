import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class AppVerticalVideoFeedPlayerPage extends StatelessWidget {
  const AppVerticalVideoFeedPlayerPage({
    super.key,
    required this.controller,
    required this.onSwipeUp,
    required this.onSwipeDown,
    this.overlayBuilder,
    this.backgroundBuilder,
    this.onSingleTap,
    this.onLongPress,
    this.onDoubleTap,
    this.progressBarBottomOffset = 0,
    this.fit,
    this.enableVerticalSwipeGestures = true,
  });

  final OolafVideoController? controller;
  final Future<void> Function() onSwipeUp;
  final Future<void> Function() onSwipeDown;
  final WidgetBuilder? overlayBuilder;
  final WidgetBuilder? backgroundBuilder;
  final VoidCallback? onSingleTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final double progressBarBottomOffset;
  final BoxFit? fit;
  final bool enableVerticalSwipeGestures;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundBuilder != null) backgroundBuilder!(context),
        ShortVideoPlayerWrapper(
          controller: controller,
          onSingleTap: onSingleTap ?? () {},
          onLongPress: onLongPress ?? () {},
          onDoubleTap: onDoubleTap ?? () {},
          onSwipeUp: () {
            unawaited(onSwipeUp());
          },
          onSwipeDown: () {
            unawaited(onSwipeDown());
          },
          progressBarBottomOffset: progressBarBottomOffset,
          fit: fit,
          enableVerticalSwipeGestures: enableVerticalSwipeGestures,
        ),
        if (overlayBuilder != null) overlayBuilder!(context),
      ],
    );
  }
}
