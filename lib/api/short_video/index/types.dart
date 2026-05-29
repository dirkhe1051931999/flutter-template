part of 'index.dart';

const String _shortVideoFeedPath = '/recomlist';
const String _phoenixTvChannelPath = '/phoenixTvChannel';
const String _shortVideoSearchPath = '/searchTagList';
const String _shortVideoHeadlinePath = '/headline';
const String _shortVideoNewsDocPath = '/getNewsDocs';
const String _shortVideoUserTimelinePath = '/api_user_exp/timeline';
const String _shortVideoUserFeedsPath = '/Social_Api_Feeds/myList';

const String _shortVideoFeedUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_shortVideoFeedPath';
const String _phoenixTvChannelUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_phoenixTvChannelPath';
const String _shortVideoSearchUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_shortVideoSearchPath';
const String _shortVideoHeadlineUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_shortVideoHeadlinePath';
const String _shortVideoNewsDocUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_shortVideoNewsDocPath';

class PhoenixTvChannelRequest {
  const PhoenixTvChannelRequest({
    required this.channel,
    required this.listId,
    this.pullTotal = 2,
    this.pullNum = 1,
  });

  final String channel;
  final String listId;
  final int pullTotal;
  final int pullNum;
}

class ShortVideoSearchPageResult {
  const ShortVideoSearchPageResult({
    required this.items,
    required this.currentPage,
    required this.totalPage,
    required this.expiredTime,
  });

  final List<ShortVideoItem> items;
  final int currentPage;
  final int totalPage;
  final int expiredTime;

  bool get hasMore => currentPage < totalPage;
}

enum HeadlineFeedItemType {
  phvideo,
  doc,
}

class HeadlineFeedDocPreview {
  const HeadlineFeedDocPreview({
    required this.id,
    required this.title,
    required this.intro,
    required this.source,
    required this.updateTime,
    required this.commentsCount,
    required this.coverUrl,
    required this.detailUrl,
  });

  final String id;
  final String title;
  final String intro;
  final String source;
  final String updateTime;
  final String commentsCount;
  final String coverUrl;
  final String detailUrl;
}

class HeadlineFeedItem {
  const HeadlineFeedItem.video({
    required this.video,
  })  : type = HeadlineFeedItemType.phvideo,
        doc = null;

  const HeadlineFeedItem.doc({
    required this.doc,
  })  : type = HeadlineFeedItemType.doc,
        video = null;

  final HeadlineFeedItemType type;
  final ShortVideoItem? video;
  final HeadlineFeedDocPreview? doc;
}

class HeadlineNewsDocDetail {
  const HeadlineNewsDocDetail({
    required this.id,
    required this.title,
    required this.source,
    required this.updateTime,
    required this.commentsCount,
    required this.htmlText,
    required this.subscribeId,
    required this.subscribeName,
    required this.subscribeType,
  });

  final String id;
  final String title;
  final String source;
  final String updateTime;
  final String commentsCount;
  final String htmlText;
  final String subscribeId;
  final String subscribeName;
  final String subscribeType;
}

class ShortVideoProfileBadge {
  const ShortVideoProfileBadge({
    required this.label,
    required this.isPrimary,
  });

  final String label;
  final bool isPrimary;
}

class ShortVideoProfileSummary {
  const ShortVideoProfileSummary({
    required this.guid,
    required this.nickname,
    required this.avatarUrl,
    required this.introduction,
    required this.location,
    required this.followCount,
    required this.fansCount,
    required this.feedCount,
    required this.level,
    required this.levelTitle,
    required this.assistantLabel,
    required this.canOpenPersonalHome,
  });

  final String guid;
  final String nickname;
  final String avatarUrl;
  final String introduction;
  final String location;
  final int followCount;
  final int fansCount;
  final int feedCount;
  final int level;
  final String levelTitle;
  final String assistantLabel;
  final bool canOpenPersonalHome;

  List<ShortVideoProfileBadge> get badges {
    final result = <ShortVideoProfileBadge>[];
    if (levelTitle.trim().isNotEmpty) {
      result.add(
        ShortVideoProfileBadge(label: levelTitle.trim(), isPrimary: true),
      );
    }
    if (assistantLabel.trim().isNotEmpty) {
      result.add(
        ShortVideoProfileBadge(label: assistantLabel.trim(), isPrimary: false),
      );
    }
    return result;
  }
}

class ShortVideoProfileFeedArticlePreview {
  const ShortVideoProfileFeedArticlePreview({
    required this.id,
    required this.type,
    required this.title,
    required this.thumbnail,
    required this.detailUrl,
    required this.videoUrl,
    required this.source,
    required this.updateTime,
    required this.commentsUrl,
    required this.commentsCount,
  });

  final String id;
  final String type;
  final String title;
  final String thumbnail;
  final String detailUrl;
  final String videoUrl;
  final String source;
  final String updateTime;
  final String commentsUrl;
  final String commentsCount;

  bool get isVideo => type == 'phvideo';
  bool get isDoc => type == 'doc';
}

class ShortVideoProfileFeedItem {
  const ShortVideoProfileFeedItem({
    required this.commentId,
    required this.content,
    required this.likeCount,
    required this.publishTimeText,
    required this.userName,
    required this.userAvatarUrl,
    required this.articlePreview,
  });

  final String commentId;
  final String content;
  final int likeCount;
  final String publishTimeText;
  final String userName;
  final String userAvatarUrl;
  final ShortVideoProfileFeedArticlePreview articlePreview;
}

class ShortVideoProfileFeedPageResult {
  const ShortVideoProfileFeedPageResult({
    required this.userSummary,
    required this.items,
    required this.currentPage,
    required this.totalPage,
    required this.limit,
  });

  final ShortVideoProfileSummary? userSummary;
  final List<ShortVideoProfileFeedItem> items;
  final int currentPage;
  final int totalPage;
  final int limit;

  bool get hasMore => currentPage < totalPage;
}

int _shortVideoDailyOpenNumCounter = 0;

int nextShortVideoDailyOpenNum() {
  _shortVideoDailyOpenNumCounter += 1;
  return _shortVideoDailyOpenNumCounter;
}

const Map<String, String> kShortVideoCommonFixedParams = {
  'action': 'down',
  'gv': '7.30.3',
  'av': '7.30.3',
  'proid': 'ifengnews',
  'df': 'androidphone',
  'vt': '5',
  'screen': '720x1280',
  'nw': 'wifi',
  'loginid': '',
  'adAid': '',
  'ps': '1',
};

const Map<String, String> kShortVideoAndroid28DeviceFixedParams = {
  'uid': '860250745769422',
  'deviceid': '860250745769422',
  'os': 'android_28',
  'publishid': '2011',
  'hw': 'asus_asus_ai2401_a',
};

const Map<String, String> _shortVideoFixedParams = {
  'id': 'RECOMVIDEO',
  'ch': 'sp',
  ...kShortVideoCommonFixedParams,
  'uid': '867241265475337',
  'deviceid': '867241265475337',
  'os': 'android_25',
  'publishid': '6010',
  'hw': 'oppo_pcrt00',
  'st': '16395595277916',
  'sn': 'fcb480832205d27372f8e66d260e69d8',
};

const Map<String, String> _phoenixTvChannelFixedParams = {
  ...kShortVideoCommonFixedParams,
  'dailyOpenNum': '1',
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17787276464257',
  'sn': '5805d8aefff865576632c46fa573537f',
};

const Map<String, String> _shortVideoSearchFixedParams = {
  ...kShortVideoCommonFixedParams,
  'ch': 'search',
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17795024758969',
  'sn': '5b3cd6693f010e650df9032ee375cee8',
};

final Map<String, String> _shortVideoHeadlineFixedParams = {
  ...kShortVideoCommonFixedParams,
  'action': 'up',
  'ch': 'sy',
  'cache': 'no',
  'autoPlay': '1',
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17795178013487',
  'sn': 'acf7c19c610514545ba1cf872d44f4fd',
};

const Map<String, String> _shortVideoNewsDocFixedParams = {
  ...kShortVideoCommonFixedParams,
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17795178021309',
  'sn': '999f5261a94438e26cdb86eeaa7308fd',
};
