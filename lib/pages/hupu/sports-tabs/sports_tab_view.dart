import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_home_team_page.dart';
import 'package:oolaf_flutted/pages/hupu/sports-tabs/nba-news-tab.dart';
import 'package:oolaf_flutted/pages/hupu/sports-tabs/sports-news-tab.dart';

class HupuSportsTabView extends StatelessWidget {
  const HupuSportsTabView({super.key});

  static const List<LinkedTabItem> _tabs = <LinkedTabItem>[
    LinkedTabItem(
      id: 'home-team-news',
      label: '主队资讯',
      child: HupuHomeTeamPage(showPageHeader: false),
    ),
    LinkedTabItem(
      id: 'nba',
      label: 'NBA',
      fontSizeScale: 1.1,
      child: HupuSportsNbaNewsTab(),
    ),
    LinkedTabItem(
      id: 'china-basketball',
      label: '中国篮球',
      child: HupuSportsNewsTab(
        config: HupuSportsNewsConfig(
          title: '中国篮球',
          categoryCode: 'basketball',
          tagCode: 'cba',
          pinnedSubtitle: 'CBA 焦点动态',
          hotSubtitle: '实时更新热门资讯',
        ),
      ),
    ),
    LinkedTabItem(
      id: 'international-football',
      label: '国际足球',
      child: HupuSportsNewsTab(
        config: HupuSportsNewsConfig(
          title: '国际足球',
          categoryCode: 'football',
          tagCode: 'fifa',
          pinnedSubtitle: 'FIFA 焦点动态',
          hotSubtitle: '实时更新热门资讯',
        ),
      ),
    ),
    LinkedTabItem(
      id: 'china-football',
      label: '中国足球',
      child: HupuSportsNewsTab(
        config: HupuSportsNewsConfig(
          title: '中国足球',
          categoryCode: 'football',
          tagCode: 'csl',
          pinnedSubtitle: '',
          hotSubtitle: '',
          showPinned: false,
          showHot: false,
          showNewsFeed: true,
          showTopics: true,
        ),
      ),
    ),
    LinkedTabItem(
      id: 'league-of-legends',
      label: '英雄联盟',
      child: HupuSportsNewsTab(
        config: HupuSportsNewsConfig(
          title: '英雄联盟',
          categoryCode: 'esports',
          tagCode: 'lol',
          pinnedSubtitle: '',
          hotSubtitle: '',
          showPinned: false,
          showHot: false,
          showNewsFeed: true,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LinkedTabView(
      items: _tabs,
      initialIndex: 1,
      tabBarHeight: 44,
      tabBarPadding: EdgeInsets.symmetric(horizontal: 13),
      tabSpacing: 28,
      activeTabColor: Color(0xFF202127),
      inactiveTabColor: Color(0xFF9398A5),
      activeIndicatorColor: Color(0xFFE5484D),
      activeFontSize: 17,
      inactiveFontSize: 17,
    );
  }
}
