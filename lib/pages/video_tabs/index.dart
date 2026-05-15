import 'package:flutter/widgets.dart';
import 'package:oolaf_flutted/components/video_top_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/recomend_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/vch_mrmdm_page.dart';

class VideoTabsRegistry {
  const VideoTabsRegistry._();

  static List<VideoTopTabItem> buildTabs({
    required GlobalKey<VideoTabRecomendPageState> recomendPageKey,
  }) {
    return <VideoTopTabItem>[
      VideoTopTabItem(
        id: 'recomend',
        label: '推荐',
        page: VideoTabRecomendPage(key: recomendPageKey),
      ),
      const VideoTopTabItem(
        id: 'featured',
        label: '精选',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'focus',
        label: '焦点',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'vch_mrmdm',
        label: '名人面对面',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'hot',
        label: '热点',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'city',
        label: '同城',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'sports',
        label: '体育',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'finance',
        label: '财经',
        page: VideoTabVchMrmdmPage(),
      ),
      const VideoTopTabItem(
        id: 'tech',
        label: '科技',
        page: VideoTabVchMrmdmPage(),
      ),
    ];
  }
}
