import 'feed.dart';

class HupuTagDetail {
  const HupuTagDetail({
    required this.tagId,
    required this.name,
    required this.banner,
    required this.bannerRgb,
    required this.discussNum,
    required this.followNum,
    required this.pv,
    required this.rank,
    required this.defaultTab,
    required this.tabs,
    required this.topicPostCount,
  });

  final int tagId;
  final String name;
  final String banner;
  final String bannerRgb;
  final int discussNum;
  final int followNum;
  final int pv;
  final int rank;
  final int defaultTab;
  final List<HupuTagDetailTab> tabs;
  final int topicPostCount;

  factory HupuTagDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu tag detail payload');
    }

    return HupuTagDetail(
      tagId: _parseInt(data['tagId']),
      name: data['name']?.toString() ?? '',
      banner: data['banner']?.toString() ?? '',
      bannerRgb: data['bannerRgb']?.toString() ?? '',
      discussNum: _parseInt(data['discussNum']),
      followNum: _parseInt(data['followNum']),
      pv: _parseInt(data['pv']),
      rank: _parseInt(data['rank']),
      defaultTab: _parseInt(data['defaultTab']),
      tabs: _parseTabs(data['tab']),
      topicPostCount: _parseInt(data['tNum']),
    );
  }
}

class HupuTagDetailTab {
  const HupuTagDetailTab({
    required this.name,
    required this.enName,
    required this.tabType,
  });

  final String name;
  final String enName;
  final int tabType;

  factory HupuTagDetailTab.fromJson(Map<String, dynamic> json) {
    return HupuTagDetailTab(
      name: json['name']?.toString() ?? '',
      enName: json['enName']?.toString() ?? '',
      tabType: _parseInt(json['tabType']),
    );
  }
}

class HupuTagThreadPage {
  const HupuTagThreadPage({
    required this.items,
    required this.hasNextPage,
    required this.cursor,
  });

  final List<HupuTagThreadItem> items;
  final bool hasNextPage;
  final String cursor;

  factory HupuTagThreadPage.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu tag thread payload');
    }

    return HupuTagThreadPage(
      items: _parseThreadItems(data['list']),
      hasNextPage: data['nextPage'] == true,
      cursor: data['cursor']?.toString() ?? '',
    );
  }
}

class HupuTagThreadItem {
  const HupuTagThreadItem({
    required this.tid,
    required this.fid,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.userName,
    required this.userHeader,
    required this.timeText,
    required this.createTime,
    required this.lastPostTime,
    required this.recommendCount,
    required this.replies,
    required this.shareNum,
    required this.topicName,
    required this.topicIcon,
    required this.topThread,
    required this.contentType,
    required this.containPic,
    required this.picList,
    required this.lightReply,
  });

  final String tid;
  final String fid;
  final int topicId;
  final String title;
  final String summary;
  final String userName;
  final String userHeader;
  final String timeText;
  final int createTime;
  final int lastPostTime;
  final int recommendCount;
  final int replies;
  final int shareNum;
  final String topicName;
  final String topicIcon;
  final bool topThread;
  final int contentType;
  final bool containPic;
  final List<HupuImageItem> picList;
  final HupuLightReply? lightReply;

  HupuFeedItem toFeedItem() {
    return HupuFeedItem(
      xid: tid,
      label: topThread ? '置顶' : '',
      schemaUrl: '',
      type: '$contentType',
      itemId: tid,
      tid: tid,
      fid: fid,
      topicId: topicId,
      title: title,
      summary: summary,
      nickname: userName,
      header: userHeader,
      forumName: topicName,
      topicName: topicName,
      createTime: createTime,
      lastPostTime: lastPostTime,
      replies: replies,
      lights: recommendCount,
      shareNum: shareNum,
      visits: 0,
      pics: picList,
      lightReplies: lightReply == null
          ? const <HupuLightReply>[]
          : <HupuLightReply>[lightReply!],
      video: null,
    );
  }

  factory HupuTagThreadItem.fromJson(Map<String, dynamic> json) {
    final lightReplyResult = json['lightReplyResult'];
    final lightReplyData = lightReplyResult is Map<String, dynamic>
        ? lightReplyResult['lightReplyData']
        : null;

    return HupuTagThreadItem(
      tid: json['tid']?.toString() ?? '',
      fid: json['fid']?.toString() ?? '',
      topicId: _parseInt(json['topicId']),
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userHeader: json['userHeader']?.toString() ?? '',
      timeText: json['time']?.toString() ?? '',
      createTime: _parseInt(json['createTime']),
      lastPostTime: _parseInt(json['lastPostTime']),
      recommendCount: _parseInt(json['recommendCount']),
      replies: _parseInt(json['replies']),
      shareNum: _parseInt(json['shareNum']),
      topicName: json['topicName']?.toString() ?? '',
      topicIcon: json['topicIcon']?.toString() ?? '',
      topThread: json['topThread'] == true,
      contentType: _parseInt(json['contentType']),
      containPic: json['containPic'] == true,
      picList: _parseImageItems(json['picList']),
      lightReply: lightReplyData is Map<String, dynamic>
          ? HupuLightReply.fromJson(lightReplyData)
          : null,
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

List<HupuTagDetailTab> _parseTabs(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTagDetailTab>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuTagDetailTab.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuTagThreadItem> _parseThreadItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuTagThreadItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuTagThreadItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuImageItem> _parseImageItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuImageItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuImageItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}
