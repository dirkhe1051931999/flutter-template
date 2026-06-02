import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_swipe/app_swipe_types.dart';

class AppSwipe extends StatefulWidget {
  const AppSwipe({
    super.key,
    required this.children,
    this.initialIndex = 0,
    this.autoplay = false,
    this.interval = const Duration(milliseconds: 3000),
    this.duration = const Duration(milliseconds: 280),
    this.loop = true,
    this.showIndicators = true,
    this.indicatorPosition = AppSwipeIndicatorPosition.center,
    this.height,
    this.viewportFraction = 1,
  });

  final List<Widget> children;
  final int initialIndex;
  final bool autoplay;
  final Duration interval;
  final Duration duration;
  final bool loop;
  final bool showIndicators;
  final AppSwipeIndicatorPosition indicatorPosition;
  final double? height;
  final double viewportFraction;

  @override
  State<AppSwipe> createState() => _AppSwipeState();
}

class _AppSwipeState extends State<AppSwipe> {
  late final PageController _pageController;
  Timer? _autoplayTimer;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final maxIndex = widget.children.isEmpty ? 0 : widget.children.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: widget.viewportFraction,
    );
    _startAutoplayIfNeeded();
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplayIfNeeded() {
    if (!widget.autoplay || widget.children.length <= 1) {
      return;
    }
    _autoplayTimer = Timer.periodic(widget.interval, (_) {
      if (!_pageController.hasClients) {
        return;
      }
      var next = _currentIndex + 1;
      if (next >= widget.children.length) {
        if (!widget.loop) {
          _autoplayTimer?.cancel();
          return;
        }
        next = 0;
      }
      _pageController.animateToPage(
        next,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) {
      return SizedBox(height: widget.height);
    }

    final content = Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const <PointerDeviceKind>{
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown,
            },
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.children.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (_, index) => widget.children[index],
          ),
        ),
        if (widget.showIndicators && widget.children.length > 1)
          Positioned(
            left: widget.indicatorPosition == AppSwipeIndicatorPosition.center
                ? 0
                : null,
            right: widget.indicatorPosition == AppSwipeIndicatorPosition.right
                ? 14
                : 0,
            bottom: 12,
            child: Align(
              alignment: widget.indicatorPosition == AppSwipeIndicatorPosition.center
                  ? Alignment.center
                  : Alignment.centerRight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0x66000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List<Widget>.generate(widget.children.length, (index) {
                      final active = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(right: index == widget.children.length - 1 ? 0 : 6),
                        width: active ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFFFFFFFF)
                              : const Color(0x88FFFFFF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.height != null) {
      return SizedBox(
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: content,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: content,
    );
  }
}
