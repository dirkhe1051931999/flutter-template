part of 'index.dart';

const String _hotspotFeedPath = '/hotspotlistv2';
const String _mustSeeFeedPath = '/mustseelist';
const String _hotspotDetailPath = '/hotSpotDetailListV2';

const String _hotspotFeedUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_hotspotFeedPath';
const String _mustSeeFeedUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_mustSeeFeedPath';
const String _hotspotDetailUrl =
    '${AppConfig.shortVideoApiBaseUrl}$_hotspotDetailPath';

const Map<String, String> _hotTabSharedParams = {
  ...kShortVideoCommonFixedParams,
  ...kShortVideoAndroid28DeviceFixedParams,
  'token': '',
};

class HotTabRequest {
  const HotTabRequest({
    required this.type,
    required this.page,
    this.st = '17796904577820',
    this.sn = 'fa76b12bab87ceb060232746cc713f08',
  });

  final HotTabFeedType type;
  final int page;
  final String st;
  final String sn;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      ..._hotTabSharedParams,
      'st': st,
      'sn': sn,
      'page': page.toString(),
    };
  }
}

class HotTabDetailRequest {
  const HotTabDetailRequest({
    required this.eventName,
    this.groupId = '',
    this.docId = '',
    this.st = '17796924997830',
    this.sn = '939f4066d44ffb46a8aef7fb30788ce3',
  });

  final String eventName;
  final String groupId;
  final String docId;
  final String st;
  final String sn;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      ..._hotTabSharedParams,
      'eventName': eventName,
      'groupid': groupId,
      'docid': docId,
      'st': st,
      'sn': sn,
    };
  }
}

enum HotTabFeedType {
  hotspot,
  mustSee,
}

enum HotTabFeedItemType {
  article,
  video,
}

class HotTabFeedPageResult {
  const HotTabFeedPageResult({
    required this.items,
    required this.currentPage,
    required this.totalPage,
  });

  final List<HotTabFeedItem> items;
  final int currentPage;
  final int totalPage;

  bool get hasMore => currentPage < totalPage;
}

class HotTabFeedItem {
  const HotTabFeedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.source,
    required this.coverUrl,
    required this.updateTime,
    required this.commentsCount,
    required this.rankLabel,
    required this.hotLabel,
    required this.hotTag,
    required this.intro,
    required this.detailUrl,
    required this.shareUrl,
    required this.videoUrl,
    required this.commentsUrl,
    required this.durationSeconds,
    required this.playCountText,
    required this.eventName,
  });

  final String id;
  final HotTabFeedItemType type;
  final String title;
  final String source;
  final String coverUrl;
  final String updateTime;
  final String commentsCount;
  final String rankLabel;
  final String hotLabel;
  final String hotTag;
  final String intro;
  final String detailUrl;
  final String shareUrl;
  final String videoUrl;
  final String commentsUrl;
  final int durationSeconds;
  final String playCountText;
  final String eventName;

  bool get isVideo => type == HotTabFeedItemType.video;
}

class HotTabDetailPageResult {
  const HotTabDetailPageResult({
    required this.title,
    required this.subscribeCountText,
    required this.bannerImageUrl,
    required this.shareUrl,
    required this.items,
  });

  final String title;
  final String subscribeCountText;
  final String bannerImageUrl;
  final String shareUrl;
  final List<HotTabDetailNewsItem> items;
}

class HotTabDetailNewsItem {
  const HotTabDetailNewsItem({
    required this.id,
    required this.type,
    required this.title,
    required this.intro,
    required this.source,
    required this.updateTime,
    required this.commentsCount,
    required this.coverUrls,
    required this.detailUrl,
    required this.shareUrl,
    required this.videoUrl,
    required this.commentsUrl,
    required this.durationSeconds,
    required this.playCountText,
  });

  final String id;
  final HotTabFeedItemType type;
  final String title;
  final String intro;
  final String source;
  final String updateTime;
  final String commentsCount;
  final List<String> coverUrls;
  final String detailUrl;
  final String shareUrl;
  final String videoUrl;
  final String commentsUrl;
  final int durationSeconds;
  final String playCountText;

  bool get isVideo => type == HotTabFeedItemType.video;
  String get primaryCoverUrl => coverUrls.isEmpty ? '' : coverUrls.first;
}
