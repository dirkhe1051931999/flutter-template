import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/hupu/follow-tab/follow_tab_view.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_search_page.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/recommend_tab_view.dart';
import 'package:oolaf_flutted/pages/hupu/sports-tabs/sports_tab_view.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

class HupuHomePage extends StatefulWidget {
  const HupuHomePage({super.key});

  @override
  State<HupuHomePage> createState() => _HupuHomePageState();
}

class _HupuHomePageState extends State<HupuHomePage> {
  static const List<String> _topTabs = <String>['关注', '推荐', '赛事'];
  static const List<Widget> _topTabPages = <Widget>[
    HupuFollowTabView(),
    HupuRecommendTabView(),
    HupuSportsTabView(),
  ];

  int _activeTopTabIndex = 1;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CupertinoColors.white,
      child: Column(
        children: [
          _HupuHomeHeader(
            tabs: _topTabs,
            activeIndex: _activeTopTabIndex,
            onTapTab: (index) {
              setState(() {
                _activeTopTabIndex = index;
              });
            },
            onDoubleTapLogo: () {
              Application.router.navigateTo(
                context,
                Routes.root,
                clearStack: true,
                replace: true,
                transition: TransitionType.inFromLeft,
              );
            },
            onTapSearch: () {
              Navigator.of(context).push<void>(
                CupertinoPageRoute<void>(
                  builder: (_) => const HupuSearchPage(),
                ),
              );
            },
          ),
          Expanded(
            child: IndexedStack(
              index: _activeTopTabIndex,
              children: _topTabPages,
            ),
          ),
        ],
      ),
    );
  }
}

class _HupuHomeHeader extends StatelessWidget {
  const _HupuHomeHeader({
    required this.tabs,
    required this.activeIndex,
    required this.onTapTab,
    required this.onDoubleTapLogo,
    required this.onTapSearch,
  });

  final List<String> tabs;
  final int activeIndex;
  final ValueChanged<int> onTapTab;
  final VoidCallback onDoubleTapLogo;
  final VoidCallback onTapSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F1F4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: onDoubleTapLogo,
            child: const Padding(
              padding: EdgeInsets.only(left: 2, right: 12),
              child: Text(
                '虎扑',
                style: TextStyle(
                  color: Color(0xFFE31B23),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: List<Widget>.generate(tabs.length, (index) {
                final isActive = activeIndex == index;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTapTab(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 28),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          tabs[index],
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFF9A9AA3),
                            fontSize: isActive ? 18 : 16,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE93B3D)
                                : CupertinoColors.transparent,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          GestureDetector(
            onTap: onTapSearch,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                CupertinoIcons.search,
                size: 22,
                color: Color(0xFF202127),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
