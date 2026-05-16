import 'package:flutter/widgets.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/video_top_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/recomend_page.dart';

class VideoTabsRegistry {
  const VideoTabsRegistry._();

  static const String recommendTabId = 'recomend';

  static const List<VideoTabChannelMeta> channelMetas = <VideoTabChannelMeta>[
    VideoTabChannelMeta(
      id: 'vch_phoenix',
      label: '凤凰卫视',
      request: PhoenixTvChannelRequest(
        channel: 'vch_phoenix',
        listId: 'VIDEOPHOENIX',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_mrmdm',
      label: '名人面对面',
      request: PhoenixTvChannelRequest(
        channel: 'vch_mrmdm',
        listId: 'VIDEOMRMDM',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_jqgcs',
      label: '军事观察室',
      request: PhoenixTvChannelRequest(
        channel: 'vch_jqgcs',
        listId: 'VIDEOJQGCS',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_ssztc',
      label: '时事直通车',
      request: PhoenixTvChannelRequest(
        channel: 'vch_ssztc',
        listId: 'VIDEOSSZTC',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_lyyy',
      label: '鲁豫有约',
      request: PhoenixTvChannelRequest(
        channel: 'vch_lyyy',
        listId: 'VIDEOLYYY',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_fydh',
      label: '风云对话',
      request: PhoenixTvChannelRequest(
        channel: 'vch_fydh',
        listId: 'VIDEOFYDH',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_dxwdls',
      label: '大新闻大历史',
      request: PhoenixTvChannelRequest(
        channel: 'vch_dxwdls',
        listId: 'VIDEODXWDLS',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
    VideoTabChannelMeta(
      id: 'vch_sslld',
      label: '实事亮亮点',
      request: PhoenixTvChannelRequest(
        channel: 'vch_sslld',
        listId: 'VIDEOSSLLD',
        pullTotal: 2,
        pullNum: 1,
      ),
    ),
  ];

  static const int feedTabCount = 9;

  static List<String> get defaultChannelOrderIds {
    return channelMetas.map((meta) => meta.id).toList(growable: false);
  }

  static List<VideoTabChannelMeta> resolveChannelOrder(List<String> orderedIds) {
    final byId = <String, VideoTabChannelMeta>{
      for (final meta in channelMetas) meta.id: meta,
    };
    final result = <VideoTabChannelMeta>[];
    final used = <String>{};

    for (final id in orderedIds) {
      final meta = byId[id];
      if (meta == null || !used.add(id)) {
        continue;
      }
      result.add(meta);
    }

    for (final meta in channelMetas) {
      if (used.add(meta.id)) {
        result.add(meta);
      }
    }

    return result;
  }

  static List<VideoTopTabItem> buildTabs({
    required List<GlobalKey<VideoTabRecomendPageState>> feedPageKeys,
    List<String>? orderedChannelIds,
  }) {
    final orderedChannels = resolveChannelOrder(
      orderedChannelIds ?? defaultChannelOrderIds,
    );

    final items = <VideoTopTabItem>[
      VideoTopTabItem(
        id: recommendTabId,
        label: '推荐',
        page: VideoTabRecomendPage(
          key: feedPageKeys[0],
          initialFeedVisible: true,
        ),
      ),
    ];

    for (var i = 0; i < orderedChannels.length; i += 1) {
      final channel = orderedChannels[i];
      items.add(
        VideoTopTabItem(
          id: channel.id,
          label: channel.label,
          page: VideoTabRecomendPage(
            key: feedPageKeys[i + 1],
            channelRequest: channel.request,
            initialFeedVisible: false,
          ),
        ),
      );
    }

    return items;
  }
}

class VideoTabChannelMeta {
  const VideoTabChannelMeta({
    required this.id,
    required this.label,
    required this.request,
  });

  final String id;
  final String label;
  final PhoenixTvChannelRequest request;
}
