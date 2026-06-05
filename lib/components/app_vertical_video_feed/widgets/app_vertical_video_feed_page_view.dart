import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:oolaf_flutted/components/app_vertical_video_feed/controller/app_vertical_video_feed_controller.dart';

class AppVerticalVideoFeedPageView<T> extends StatelessWidget {
  const AppVerticalVideoFeedPageView({
    super.key,
    required this.controller,
    required this.items,
    required this.dragDevices,
    required this.onPageChanged,
    required this.itemBuilder,
  });

  final AppVerticalVideoFeedController controller;
  final List<T> items;
  final Set<PointerDeviceKind> dragDevices;
  final Future<void> Function(int index) onPageChanged;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const CupertinoScrollBehavior().copyWith(
        dragDevices: dragDevices,
      ),
      child: PageView.builder(
        controller: controller.pageController,
        scrollDirection: Axis.vertical,
        itemCount: items.length,
        onPageChanged: (index) {
          unawaited(onPageChanged(index));
        },
        itemBuilder: (context, index) {
          return itemBuilder(context, index, items[index]);
        },
      ),
    );
  }
}
