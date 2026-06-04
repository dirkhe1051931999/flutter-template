import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';

class AppTabs extends StatefulWidget {
  const AppTabs({
    super.key,
    required this.items,
    required this.activeKey,
    required this.onChange,
    this.type = AppTabsType.line,
    this.color = const Color(0xFF2563EB),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.titleActiveColor,
    this.titleInactiveColor = const Color(0xFF667085),
    this.border = false,
    this.ellipsis = true,
    this.shrink = false,
    this.swipeThreshold = 5,
    this.swipeable = false,
    this.animated = false,
    this.lazyRender = true,
    this.showHeader = true,
    this.lineWidth = 40,
    this.lineHeight = 3,
    this.duration = const Duration(milliseconds: 280),
    this.headerHeight = 46,
  });

  final List<AppTabItemData> items;
  final int activeKey;
  final ValueChanged<int> onChange;
  final AppTabsType type;
  final Color color;
  final Color backgroundColor;
  final Color? titleActiveColor;
  final Color titleInactiveColor;
  final bool border;
  final bool ellipsis;
  final bool shrink;
  final int swipeThreshold;
  final bool swipeable;
  final bool animated;
  final bool lazyRender;
  final bool showHeader;
  final double lineWidth;
  final double lineHeight;
  final Duration duration;
  final double headerHeight;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late final PageController _pageController;
  late final ScrollController _navController;
  late final List<GlobalKey> _tabKeys;
  final Set<int> _renderedIndexes = <int>{};

  int get _activeIndex {
    if (widget.items.isEmpty) {
      return 0;
    }
    return widget.activeKey.clamp(0, widget.items.length - 1);
  }

  bool get _usesPagedContent => widget.swipeable || widget.animated;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeIndex);
    _navController = ScrollController();
    _tabKeys = List<GlobalKey>.generate(
      widget.items.length,
      (_) => GlobalKey(),
    );
    _renderedIndexes.add(_activeIndex);
  }

  @override
  void didUpdateWidget(covariant AppTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _tabKeys
        ..clear()
        ..addAll(
          List<GlobalKey>.generate(widget.items.length, (_) => GlobalKey()),
        );
    }
    _renderedIndexes.add(_activeIndex);
    if (_usesPagedContent && _pageController.hasClients) {
      if (widget.animated) {
        _pageController.animateToPage(
          _activeIndex,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
        );
      } else {
        _pageController.jumpToPage(_activeIndex);
      }
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollActiveTabIntoView());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navController.dispose();
    super.dispose();
  }

  void _handleChange(int index) {
    if (index < 0 || index >= widget.items.length) {
      return;
    }
    if (widget.items[index].disabled || index == _activeIndex) {
      return;
    }
    _renderedIndexes.add(index);
    widget.onChange(index);
  }

  void _scrollActiveTabIntoView() {
    if (_activeIndex >= _tabKeys.length) {
      return;
    }
    final context = _tabKeys[_activeIndex].currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.border
                  ? const Color(0x12000000)
                  : const Color(0x00000000),
              width: widget.border ? 0.5 : 0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showHeader) _buildHeader(),
                if (_usesPagedContent)
                  Expanded(child: _buildContent())
                else if (hasBoundedHeight)
                  Expanded(child: _buildScrollableContent())
                else
                  _buildContent(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollableContent() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: const <PointerDeviceKind>{
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildHeader() {
    final scrollable =
        widget.shrink || widget.items.length > widget.swipeThreshold;
    final tabItems = List<Widget>.generate(widget.items.length, (index) {
      final item = widget.items[index];
      final active = index == _activeIndex;
      final title = _TabTitle(
        key: _tabKeys[index],
        item: item,
        active: active,
        type: widget.type,
        color: widget.color,
        activeColor: widget.titleActiveColor ?? widget.color,
        inactiveColor: widget.titleInactiveColor,
        ellipsis: widget.ellipsis,
        scrollable: scrollable,
        lineWidth: widget.lineWidth,
        lineHeight: widget.lineHeight,
        height: widget.headerHeight,
        onTap: () => _handleChange(index),
      );
      return scrollable ? title : Expanded(child: title);
    });

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        border: widget.type == AppTabsType.line && widget.border
            ? const Border(
                bottom: BorderSide(color: Color(0x12000000), width: 0.5),
              )
            : null,
      ),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: const <PointerDeviceKind>{
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown,
          },
          scrollbars: false,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _navController,
              scrollDirection: Axis.horizontal,
              physics: scrollable
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: scrollable ? null : constraints.maxWidth,
                child: Row(
                  mainAxisSize:
                      scrollable ? MainAxisSize.min : MainAxisSize.max,
                  children: tabItems,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_usesPagedContent) {
      return ScrollConfiguration(
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
          physics: widget.swipeable
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          itemCount: widget.items.length,
          onPageChanged: _handleChange,
          itemBuilder: (context, index) {
            if (widget.lazyRender &&
                !_renderedIndexes.contains(index) &&
                index != _activeIndex) {
              return const SizedBox.shrink();
            }
            return widget.items[index].child;
          },
        ),
      );
    }

    if (widget.lazyRender) {
      return widget.items[_activeIndex].child;
    }

    return Stack(
      children: List<Widget>.generate(widget.items.length, (index) {
        return Offstage(
          offstage: index != _activeIndex,
          child: widget.items[index].child,
        );
      }),
    );
  }
}

class _TabTitle extends StatelessWidget {
  const _TabTitle({
    super.key,
    required this.item,
    required this.active,
    required this.type,
    required this.color,
    required this.activeColor,
    required this.inactiveColor,
    required this.ellipsis,
    required this.scrollable,
    required this.lineWidth,
    required this.lineHeight,
    required this.height,
    required this.onTap,
  });

  final AppTabItemData item;
  final bool active;
  final AppTabsType type;
  final Color color;
  final Color activeColor;
  final Color inactiveColor;
  final bool ellipsis;
  final bool scrollable;
  final double lineWidth;
  final double lineHeight;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = item.disabled;
    final titleColor = disabled
        ? const Color(0xFFB8BFCC)
        : active
            ? type == AppTabsType.card
                ? const Color(0xFFFFFFFF)
                : activeColor
            : inactiveColor;

    final title = Text(
      item.title,
      maxLines: 1,
      overflow: ellipsis ? TextOverflow.ellipsis : TextOverflow.visible,
      style: TextStyle(
        color: titleColor,
        fontSize: 14,
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
      ),
    );

    final child = type == AppTabsType.card
        ? _buildCardTitle(title, disabled)
        : _buildLineTitle(title, disabled);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : onTap,
      child: SizedBox(
        height: height,
        child: child,
      ),
    );
  }

  Widget _buildLineTitle(Widget title, bool disabled) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: scrollable ? 18 : 8),
      child: Opacity(
        opacity: disabled ? 0.55 : 1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            title,
            Positioned(
              bottom: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: active ? lineWidth : 0,
                height: lineHeight,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(Widget title, bool disabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: scrollable ? 16 : 8),
        decoration: BoxDecoration(
          color: active ? color : const Color(0x00000000),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? color : const Color(0x1F000000),
            width: 0.5,
          ),
        ),
        alignment: Alignment.center,
        child: Opacity(opacity: disabled ? 0.55 : 1, child: title),
      ),
    );
  }
}
