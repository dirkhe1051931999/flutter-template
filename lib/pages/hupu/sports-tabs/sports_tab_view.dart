import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_home_team_page.dart';
import 'package:oolaf_flutted/pages/hupu/sports-tabs/nba-news-tab.dart';
import 'package:oolaf_flutted/pages/hupu/sports-tabs/placeholder-tab.dart';

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
      child: HupuSportsNbaNewsTab(),
    ),
    LinkedTabItem(
      id: 'china-basketball',
      label: '中国篮球',
      child: HupuSportsPlaceholderTab(
        title: '中国篮球',
        description: '中国篮球页先占位，后续再接实际内容。',
      ),
    ),
    LinkedTabItem(
      id: 'international-football',
      label: '国际足球',
      child: HupuSportsPlaceholderTab(
        title: '国际足球',
        description: '国际足球页先占位，后续再接实际内容。',
      ),
    ),
    LinkedTabItem(
      id: 'china-football',
      label: '中国足球',
      child: HupuSportsPlaceholderTab(
        title: '中国足球',
        description: '中国足球页先占位，后续再接实际内容。',
      ),
    ),
    LinkedTabItem(
      id: 'league-of-legends',
      label: '英雄联盟',
      child: HupuSportsPlaceholderTab(
        title: '英雄联盟',
        description: '英雄联盟页先占位，后续再接实际内容。',
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
