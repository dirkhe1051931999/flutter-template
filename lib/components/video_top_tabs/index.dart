import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class VideoTopTabItem {
  const VideoTopTabItem({
    required this.id,
    required this.label,
    required this.page,
  });

  final String id;
  final String label;
  final Widget page;
}

class VideoTopTabs extends StatefulWidget {
  const VideoTopTabs({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  final List<VideoTopTabItem> items;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  @override
  State<VideoTopTabs> createState() => _VideoTopTabsState();
}

class _VideoTopTabsState extends State<VideoTopTabs> {
  static const double _barHeight = 44;
  static const Set<PointerDeviceKind> _dragDevices = <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  late final PageController _pageController;
  late final ScrollController _tabScrollController;
  late final ValueNotifier<int> _currentIndexNotifier;

  int get _currentIndex => _currentIndexNotifier.value;

  @override
  void initState() {
    super.initState();
    final initialIndex = _sanitizeIndex(widget.initialIndex);
    _currentIndexNotifier = ValueNotifier<int>(initialIndex);
    _pageController = PageController(initialPage: initialIndex);
    _tabScrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant VideoTopTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.items.isEmpty) {
      return;
    }

    if (_currentIndex >= widget.items.length) {
      final nextIndex = widget.items.length - 1;
      _updateIndex(nextIndex, notify: true);
      _pageController.jumpToPage(nextIndex);
      return;
    }

    if (oldWidget.initialIndex != widget.initialIndex) {
      final nextIndex = _sanitizeIndex(widget.initialIndex);
      if (nextIndex != _currentIndex) {
        _updateIndex(nextIndex, notify: false);
        _pageController.jumpToPage(nextIndex);
      }
    }
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose();
    _tabScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  int _sanitizeIndex(int index) {
    if (widget.items.isEmpty) {
      return 0;
    }
    return index.clamp(0, widget.items.length - 1);
  }

  void _ensureActiveTabVisible(int index) {
    if (!_tabScrollController.hasClients || widget.items.isEmpty) {
      return;
    }

    final target = (index * 88.0).clamp(
      0.0,
      _tabScrollController.position.maxScrollExtent,
    );
    _tabScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _updateIndex(int index, {required bool notify}) {
    if (index == _currentIndex || widget.items.isEmpty) {
      return;
    }
    _currentIndexNotifier.value = index;
    _ensureActiveTabVisible(index);
    if (notify) {
      widget.onIndexChanged?.call(index);
    }
  }

  void _onTapTab(int index) {
    if (index == _currentIndex || widget.items.isEmpty) {
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          child: SizedBox(
            height: _barHeight,
            child: ScrollConfiguration(
              behavior: const CupertinoScrollBehavior().copyWith(
                dragDevices: _dragDevices,
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, _) {
                  return ListView.builder(
                    controller: _tabScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      final isActive = index == currentIndex;

                      return CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        onPressed: () => _onTapTab(index),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isActive
                                    ? CupertinoColors.white
                                    : CupertinoColors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: isActive
                                    ? CupertinoColors.white
                                    : const Color(0xB3FFFFFF),
                                fontSize: isActive ? 18 : 16,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: RepaintBoundary(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              allowImplicitScrolling: true,
              physics: const PageScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              onPageChanged: (index) {
                _updateIndex(index, notify: true);
              },
              scrollBehavior: const CupertinoScrollBehavior().copyWith(
                dragDevices: _dragDevices,
              ),
              itemBuilder: (context, index) {
                return widget.items[index].page;
              },
            ),
          ),
        ),
      ],
    );
  }
}
