import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'refresh.dart';
import 'scroll_behavior.dart';
import 'types.dart';

class LinkedTabView extends StatefulWidget {
  const LinkedTabView({
    required this.items,
    super.key,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.tabBarHeight = 44,
    this.tabBarPadding = const EdgeInsets.symmetric(horizontal: 12),
    this.tabSpacing = 28,
    this.pageSpacing = 0,
    this.tabBarBackgroundColor = CupertinoColors.white,
    this.tabBarBorderColor = const Color(0xFFF0F1F4),
    this.activeTabColor = const Color(0xFF202127),
    this.inactiveTabColor = const Color(0xFF9398A5),
    this.activeIndicatorColor = const Color(0xFFE5484D),
    this.activeFontSize = 17,
    this.inactiveFontSize = 16,
    this.activeFontWeight = FontWeight.w700,
    this.inactiveFontWeight = FontWeight.w500,
    this.enablePageSwipe = true,
  });

  final List<LinkedTabItem> items;
  final int initialIndex;
  final LinkedTabIndexChanged? onIndexChanged;
  final double tabBarHeight;
  final EdgeInsets tabBarPadding;
  final double tabSpacing;
  final double pageSpacing;
  final Color tabBarBackgroundColor;
  final Color tabBarBorderColor;
  final Color activeTabColor;
  final Color inactiveTabColor;
  final Color activeIndicatorColor;
  final double activeFontSize;
  final double inactiveFontSize;
  final FontWeight activeFontWeight;
  final FontWeight inactiveFontWeight;
  final bool enablePageSwipe;

  @override
  State<LinkedTabView> createState() => _LinkedTabViewState();
}

class _LinkedTabViewState extends State<LinkedTabView> {
  late final PageController _pageController;
  late final ScrollController _tabScrollController;
  late final ValueNotifier<double> _pageValueNotifier;
  late List<GlobalKey> _tabKeys;
  LinkedTabChangeSource _pendingChangeSource = LinkedTabChangeSource.swipe;

  int get _currentIndex => _roundedPageValue;

  int get _roundedPageValue {
    if (widget.items.isEmpty) {
      return 0;
    }
    return _pageValueNotifier.value
        .round()
        .clamp(0, math.max(widget.items.length - 1, 0));
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = _sanitizeIndex(widget.initialIndex);
    _pageController = PageController(initialPage: initialIndex);
    _tabScrollController = ScrollController();
    _pageValueNotifier = ValueNotifier<double>(initialIndex.toDouble());
    _tabKeys = List<GlobalKey>.generate(
      widget.items.length,
      (_) => GlobalKey(),
    );
    _pageController.addListener(_handlePageScroll);
  }

  @override
  void didUpdateWidget(covariant LinkedTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _tabKeys = List<GlobalKey>.generate(
        widget.items.length,
        (_) => GlobalKey(),
      );
    }

    if (widget.items.isEmpty) {
      return;
    }

    final nextIndex = _sanitizeIndex(_currentIndex);
    if (nextIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _jumpToPage(nextIndex, source: LinkedTabChangeSource.programmatic);
      });
      return;
    }

    if (oldWidget.initialIndex != widget.initialIndex) {
      final targetIndex = _sanitizeIndex(widget.initialIndex);
      if (targetIndex != _currentIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _jumpToPage(
            targetIndex,
            source: LinkedTabChangeSource.programmatic,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageScroll)
      ..dispose();
    _tabScrollController.dispose();
    _pageValueNotifier.dispose();
    super.dispose();
  }

  int _sanitizeIndex(int index) {
    if (widget.items.isEmpty) {
      return 0;
    }
    return index.clamp(0, widget.items.length - 1);
  }

  void _handlePageScroll() {
    if (!_pageController.hasClients) {
      return;
    }
    final pageValue =
        _pageController.page ?? _pageController.initialPage.toDouble();
    if (_pageValueNotifier.value == pageValue) {
      return;
    }
    _pageValueNotifier.value = pageValue;
  }

  void _jumpToPage(
    int index, {
    required LinkedTabChangeSource source,
  }) {
    if (widget.items.isEmpty) {
      return;
    }
    _pendingChangeSource = source;
    _pageController.jumpToPage(index);
    _pageValueNotifier.value = index.toDouble();
    _ensureTabVisible(index);
  }

  void _animateToPage(
    int index, {
    required LinkedTabChangeSource source,
  }) {
    if (widget.items.isEmpty || index == _currentIndex) {
      return;
    }
    _pendingChangeSource = source;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
    _ensureTabVisible(index);
  }

  void _ensureTabVisible(int index) {
    if (index < 0 || index >= _tabKeys.length) {
      return;
    }
    final targetContext = _tabKeys[index].currentContext;
    if (targetContext == null) {
      return;
    }
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    );
  }

  ScrollPhysics _resolvePagePhysics() {
    if (widget.items.isEmpty || !widget.enablePageSwipe) {
      return const NeverScrollableScrollPhysics();
    }

    final currentItem = widget.items[_currentIndex];
    if (!currentItem.swipeEnabled) {
      return const NeverScrollableScrollPhysics();
    }

    return const PageScrollPhysics(
      parent: BouncingScrollPhysics(),
    );
  }

  double _tabActivation(int index, double pageValue) {
    return (1 - (pageValue - index).abs()).clamp(0.0, 1.0);
  }

  FontWeight _resolveFontWeight(double activation) {
    return activation >= 0.5
        ? widget.activeFontWeight
        : widget.inactiveFontWeight;
  }

  double _resolveFontSize(double activation) {
    return lerpDouble(
          widget.inactiveFontSize,
          widget.activeFontSize,
          activation,
        ) ??
        widget.inactiveFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: CupertinoColors.white),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildPageView()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.tabBarBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: widget.tabBarBorderColor,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: widget.tabBarHeight,
        child: ScrollConfiguration(
          behavior: const LinkedTabScrollBehavior(),
          child: SingleChildScrollView(
            controller: _tabScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: widget.tabBarPadding,
            child: ValueListenableBuilder<double>(
              valueListenable: _pageValueNotifier,
              builder: (context, pageValue, _) {
                return Row(
                  children: List<Widget>.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    final activation = _tabActivation(index, pageValue);
                    final isLast = index == widget.items.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        right: isLast ? 0 : widget.tabSpacing,
                      ),
                      child: CupertinoButton(
                        key: _tabKeys[index],
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        pressedOpacity: 0.86,
                        onPressed: () {
                          _animateToPage(
                            index,
                            source: LinkedTabChangeSource.tap,
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.label,
                              style: TextStyle(
                                color: Color.lerp(
                                  widget.inactiveTabColor,
                                  widget.activeTabColor,
                                  activation,
                                ),
                                fontSize: _resolveFontSize(activation),
                                fontWeight: _resolveFontWeight(activation),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Opacity(
                              opacity: activation,
                              child: Container(
                                width: 24 + (activation * 8),
                                height: 3,
                                decoration: BoxDecoration(
                                  color: widget.activeIndicatorColor,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return ScrollConfiguration(
      behavior: const LinkedTabScrollBehavior(),
      child: RepaintBoundary(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.items.length,
          allowImplicitScrolling: true,
          padEnds: false,
          physics: _resolvePagePhysics(),
          scrollDirection: Axis.horizontal,
          dragStartBehavior: DragStartBehavior.start,
          onPageChanged: (index) {
            _ensureTabVisible(index);
            final source = _pendingChangeSource;
            _pendingChangeSource = LinkedTabChangeSource.swipe;
            widget.onIndexChanged?.call(index, source);
          },
          itemBuilder: (context, index) {
            final item = widget.items[index];
            Widget child = item.child;
            if (item.refreshConfig != null) {
              child = LinkedTabPageRefresh(
                onRefresh: item.refreshConfig!.onRefresh,
                triggerOffset: item.refreshConfig!.triggerOffset,
                completeDisplayDuration:
                    item.refreshConfig!.completeDisplayDuration,
                indicatorBuilder: item.refreshConfig!.indicatorBuilder,
                child: child,
              );
            }
            return Padding(
              padding: EdgeInsets.only(
                right:
                    index == widget.items.length - 1 ? 0 : widget.pageSpacing,
              ),
              child: _LinkedTabKeepAlive(
                keepAlive: item.keepAlive,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LinkedTabKeepAlive extends StatefulWidget {
  const _LinkedTabKeepAlive({
    required this.keepAlive,
    required this.child,
  });

  final bool keepAlive;
  final Widget child;

  @override
  State<_LinkedTabKeepAlive> createState() => _LinkedTabKeepAliveState();
}

class _LinkedTabKeepAliveState extends State<_LinkedTabKeepAlive>
    with AutomaticKeepAliveClientMixin<_LinkedTabKeepAlive> {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  void didUpdateWidget(covariant _LinkedTabKeepAlive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keepAlive != widget.keepAlive) {
      updateKeepAlive();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
