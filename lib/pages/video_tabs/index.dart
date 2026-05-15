import 'package:flutter/widgets.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/video_top_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/recomend_page.dart';

class VideoTabsRegistry {
  const VideoTabsRegistry._();

  static const int feedTabCount = 6;

  static List<VideoTopTabItem> buildTabs({
    required List<GlobalKey<VideoTabRecomendPageState>> feedPageKeys,
  }) {
    return <VideoTopTabItem>[
      VideoTopTabItem(
        id: 'recomend',
        label: '推荐',
        page: VideoTabRecomendPage(
          key: feedPageKeys[0],
          initialFeedVisible: true,
        ),
      ),
      VideoTopTabItem(
        id: 'vch_mrmdm',
        label: '名人面对面',
        page: VideoTabRecomendPage(
          key: feedPageKeys[1],
          channelRequest: const PhoenixTvChannelRequest(
            channel: 'vch_mrmdm',
            listId: 'VIDEOMRMDM',
            pullTotal: 2,
            pullNum: 1,
          ),
          initialFeedVisible: false,
        ),
      ),
      VideoTopTabItem(
        id: 'vch_jqgcs',
        label: '军事观察室',
        page: VideoTabRecomendPage(
          key: feedPageKeys[2],
          channelRequest: const PhoenixTvChannelRequest(
            channel: 'vch_jqgcs',
            listId: 'VIDEOJQGCS',
            pullTotal: 2,
            pullNum: 1,
          ),
          initialFeedVisible: false,
        ),
      ),
      VideoTopTabItem(
        id: 'vch_ssztc',
        label: '时事直通车',
        page: VideoTabRecomendPage(
          key: feedPageKeys[3],
          channelRequest: const PhoenixTvChannelRequest(
            channel: 'vch_ssztc',
            listId: 'VIDEOSSZTC',
            pullTotal: 2,
            pullNum: 1,
          ),
          initialFeedVisible: false,
        ),
      ),
      VideoTopTabItem(
        id: 'vch_lyyy',
        label: '鲁豫有约',
        page: VideoTabRecomendPage(
          key: feedPageKeys[4],
          channelRequest: const PhoenixTvChannelRequest(
            channel: 'vch_lyyy',
            listId: 'VIDEOLYYY',
            pullTotal: 2,
            pullNum: 1,
          ),
          initialFeedVisible: false,
        ),
      ),
      VideoTopTabItem(
        id: 'vch_fydh',
        label: '风云对话',
        page: VideoTabRecomendPage(
          key: feedPageKeys[5],
          channelRequest: const PhoenixTvChannelRequest(
            channel: 'vch_fydh',
            listId: 'VIDEOFYDH',
            pullTotal: 2,
            pullNum: 1,
          ),
          initialFeedVisible: false,
        ),
      ),
    ];
  }
}
