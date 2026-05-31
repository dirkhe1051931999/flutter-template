import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/hot-rank-tab.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/recommend-feed-tab.dart';
import 'package:oolaf_flutted/pages/hupu/recommend-tabs/recommend-forum-feed-tab.dart';

class HupuRecommendTabView extends StatelessWidget {
  const HupuRecommendTabView({super.key});

  static const List<LinkedTabItem> _tabs = <LinkedTabItem>[
    LinkedTabItem(
      id: 'recommend',
      label: '推荐',
      child: HupuRecommendFeedTab(),
    ),
    LinkedTabItem(
      id: 'hot',
      label: '热榜',
      child: HupuRecommendHotRankTab(),
    ),
    LinkedTabItem(
      id: 'football',
      label: '足球',
      child: HupuRecommendForumFeedTab(forumName: 'soccer'),
    ),
    LinkedTabItem(
      id: 'walking-street',
      label: '步行街',
      child: HupuRecommendForumFeedTab(forumName: 'bxj'),
    ),
    LinkedTabItem(
      id: 'game',
      label: '游戏',
      child: HupuRecommendForumFeedTab(forumName: 'games'),
    ),
    LinkedTabItem(
      id: 'video',
      label: '视频',
      child: HupuRecommendForumFeedTab(forumName: 'video'),
    ),
    LinkedTabItem(
      id: 'entertainment',
      label: '影视娱乐',
      child: HupuRecommendForumFeedTab(forumName: 'ent'),
    ),
    LinkedTabItem(
      id: 'equipment',
      label: '装备',
      child: HupuRecommendForumFeedTab(forumName: 'gear'),
    ),
    LinkedTabItem(
      id: 'digital',
      label: '数码',
      child: HupuRecommendForumFeedTab(forumName: 'digital'),
    ),
    LinkedTabItem(
      id: 'car',
      label: '汽车',
      child: HupuRecommendForumFeedTab(forumName: 'car'),
    ),
    LinkedTabItem(
      id: 'basketball',
      label: '篮球',
      child: HupuRecommendForumFeedTab(forumName: 'basketball'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LinkedTabView(
      items: _tabs,
      initialIndex: 0,
      tabBarHeight: 42,
      tabBarPadding: EdgeInsets.symmetric(horizontal: 16),
      tabSpacing: 30,
      activeTabColor: Color(0xFFE5484D),
      inactiveTabColor: Color(0xFF8F94A1),
      activeIndicatorColor: Color(0xFFE5484D),
      activeFontSize: 17,
      inactiveFontSize: 16,
    );
  }
}
