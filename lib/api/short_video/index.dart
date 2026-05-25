import 'package:dio/dio.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/model/short_video/danmaku_item.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/danmu_data.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _shortVideoFeedPath = '/recomlist';
const String _phoenixTvChannelPath = '/phoenixTvChannel';
const String _shortVideoSearchPath = '/searchTagList';
const String _shortVideoHeadlinePath = '/headline';
const String _shortVideoNewsDocPath = '/getNewsDocs';

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
    required this.htmlText,
  });

  final String id;
  final String title;
  final String source;
  final String updateTime;
  final String htmlText;
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

Future<List<ShortVideoItem>> getPhoenixTvChannelPage({
  required PhoenixTvChannelRequest request,
}) async {
  final params = <String, dynamic>{
    ..._phoenixTvChannelFixedParams,
    'ch': request.channel,
    'id': request.listId,
    'pullTotal': request.pullTotal.toString(),
    'pullNum': request.pullNum.toString(),
  };

  try {
    final Response response = await httpClient.get(
      _phoenixTvChannelUrl,
      queryParameters: params,
    );

    return _extractShortVideoItems(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getPhoenixTvChannelPage failed: $error');
    customLogger.log(stackTrace);
    return const <ShortVideoItem>[];
  }
}

Future<List<ShortVideoItem>> getShortVideoPage({
  required int pullNum,
  int dailyOpenNum = 1,
}) async {
  final params = <String, dynamic>{
    ..._shortVideoFixedParams,
    'dailyOpenNum': dailyOpenNum.toString(),
    'pullNum': pullNum.toString(),
    'pullTotal': pullNum.toString(),
  };

  try {
    final Response response = await httpClient.get(
      _shortVideoFeedUrl,
      queryParameters: params,
    );
    return _extractShortVideoItems(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoPage failed: $error');
    customLogger.log(stackTrace);
    return const <ShortVideoItem>[];
  }
}

Future<ShortVideoSearchPageResult> getShortVideoSearchPage({
  required String keyword,
  required int page,
}) async {
  final params = <String, dynamic>{
    ..._shortVideoSearchFixedParams,
    'k': keyword,
    'page': page.toString(),
    'type': 'video',
  };

  try {
    final Response response = await httpClient.get(
      _shortVideoSearchUrl,
      queryParameters: params,
    );
    return _extractShortVideoSearchPageResult(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoSearchPage failed: $error');
    customLogger.log(stackTrace);
    return const ShortVideoSearchPageResult(
      items: <ShortVideoItem>[],
      currentPage: 1,
      totalPage: 1,
      expiredTime: 0,
    );
  }
}

Future<List<HeadlineFeedItem>> getShortVideoHeadlinePage({
  required int pullNum,
  int dailyOpenNum = 1,
}) async {
  final params = <String, dynamic>{
    ..._shortVideoHeadlineFixedParams,
    'pullNum': pullNum.toString(),
    'pullTotal': pullNum.toString(),
    'dailyOpenNum': dailyOpenNum.toString(),
  };

  try {
    final Response response = await httpClient.get(
      _shortVideoHeadlineUrl,
      queryParameters: params,
    );
    return _extractHeadlineFeedItems(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoHeadlinePage failed: $error');
    customLogger.log(stackTrace);
    return const <HeadlineFeedItem>[];
  }
}

Future<HeadlineNewsDocDetail?> getShortVideoNewsDocDetail({
  required String detailUrl,
}) async {
  final uri = Uri.tryParse(detailUrl);
  if (uri == null) {
    return null;
  }

  final mergedParams = <String, dynamic>{
    ...uri.queryParameters,
    ..._shortVideoNewsDocFixedParams,
  };

  try {
    final Response response = await httpClient.get(
      _shortVideoNewsDocUrl,
      queryParameters: mergedParams,
    );
    return _extractHeadlineNewsDocDetail(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoNewsDocDetail failed: $error');
    customLogger.log(stackTrace);
    return null;
  }
}

Future<List<DanmakuItem>> getDanmaku(String videoId) async {
  return generateMockDanmakuItems(videoId);
}

List<HeadlineFeedItem> _extractHeadlineFeedItems(dynamic responseData) {
  if (responseData is! List<dynamic> || responseData.isEmpty) {
    return const <HeadlineFeedItem>[];
  }

  final items = <HeadlineFeedItem>[];
  for (final sectionRaw in responseData) {
    if (sectionRaw is! Map<String, dynamic>) {
      continue;
    }
    final sectionItems = sectionRaw['item'];
    if (sectionItems is! List<dynamic>) {
      continue;
    }

    for (final raw in sectionItems) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }

      final type = _asString(raw['type']);
      if (type == 'phvideo') {
        final video = _mapToShortVideoItem(raw);
        if (video != null) {
          items.add(HeadlineFeedItem.video(video: video));
        }
      } else if (type == 'doc') {
        final doc = _mapToHeadlineDocPreview(raw);
        if (doc != null) {
          items.add(HeadlineFeedItem.doc(doc: doc));
        }
      }
    }
  }
  return items;
}

HeadlineFeedDocPreview? _mapToHeadlineDocPreview(Map<String, dynamic> raw) {
  final title = _asString(raw['title']);
  final id = _asString(raw['documentId']) ??
      _asString(raw['staticId']) ??
      _asString(raw['id']);
  final detailUrl = _asString(raw['link']?['url']);
  if (title == null || id == null || detailUrl == null) {
    return null;
  }

  return HeadlineFeedDocPreview(
    id: id,
    title: title,
    intro: _asString(raw['intro']) ?? '',
    source: _asString(raw['source']) ??
        _asString(raw['subscribe']?['catename']) ??
        '凤凰资讯',
    updateTime: _pickUpdateTime(raw),
    commentsCount: _asString(raw['commentsCount']) ??
        _asString(raw['commentsall']) ??
        _asString(raw['comments']) ??
        '0',
    coverUrl: _pickCoverUrl(raw) ?? '',
    detailUrl: detailUrl,
  );
}

HeadlineNewsDocDetail? _extractHeadlineNewsDocDetail(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) {
    return null;
  }
  final body = responseData['body'];
  if (body is! Map<String, dynamic>) {
    return null;
  }
  final id = _asString(body['documentId']) ?? _asString(body['staticId']);
  final title = _asString(body['title']);
  final htmlText = _asString(body['text']);
  if (id == null || title == null || htmlText == null) {
    return null;
  }
  return HeadlineNewsDocDetail(
    id: id,
    title: title,
    source: _asString(body['source']) ??
        _asString(body['subscribe']?['catename']) ??
        '',
    updateTime:
        _asString(body['updateTime']) ?? _asString(body['editTime']) ?? '',
    htmlText: htmlText,
  );
}

List<ShortVideoItem> _extractShortVideoItems(dynamic responseData) {
  if (responseData is! List<dynamic> || responseData.isEmpty) {
    return const <ShortVideoItem>[];
  }

  final firstSection = responseData.first;
  if (firstSection is! Map<String, dynamic>) {
    return const <ShortVideoItem>[];
  }

  final itemList = firstSection['item'];
  if (itemList is! List<dynamic>) {
    return const <ShortVideoItem>[];
  }

  final items = <ShortVideoItem>[];
  for (final raw in itemList) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }

    final mapped = _mapToShortVideoItem(raw);
    if (mapped != null) {
      items.add(mapped);
    }
  }

  return items;
}

ShortVideoSearchPageResult _extractShortVideoSearchPageResult(
    dynamic responseData) {
  if (responseData is! List<dynamic> || responseData.isEmpty) {
    return const ShortVideoSearchPageResult(
      items: <ShortVideoItem>[],
      currentPage: 1,
      totalPage: 1,
      expiredTime: 0,
    );
  }

  final firstSection = responseData.first;
  if (firstSection is! Map<String, dynamic>) {
    return const ShortVideoSearchPageResult(
      items: <ShortVideoItem>[],
      currentPage: 1,
      totalPage: 1,
      expiredTime: 0,
    );
  }

  final itemList = firstSection['item'];
  if (itemList is! List<dynamic>) {
    return ShortVideoSearchPageResult(
      items: const <ShortVideoItem>[],
      currentPage: _asInt(firstSection['currentPage']) ?? 1,
      totalPage: _asInt(firstSection['totalPage']) ?? 1,
      expiredTime: _asInt(firstSection['expiredTime']) ?? 0,
    );
  }

  final items = <ShortVideoItem>[];
  for (final raw in itemList) {
    if (raw is! Map<String, dynamic>) {
      continue;
    }

    final mapped = _mapToShortVideoItem(raw);
    if (mapped != null) {
      items.add(mapped);
    }
  }

  return ShortVideoSearchPageResult(
    items: items,
    currentPage: _asInt(firstSection['currentPage']) ?? 1,
    totalPage: _asInt(firstSection['totalPage']) ?? 1,
    expiredTime: _asInt(firstSection['expiredTime']) ?? 0,
  );
}

ShortVideoItem? _mapToShortVideoItem(Map<String, dynamic> raw) {
  if (raw['type'] != 'phvideo') {
    return null;
  }

  final title = _asString(raw['title']);
  final source =
      _asString(raw['source']) ?? _asString(raw['subscribe']?['catename']);
  final id = _asString(raw['staticId']) ?? _asString(raw['documentId']);
  final coverUrl = _pickCoverUrl(raw);
  final videoUrl = _pickVideoUrl(raw);
  final updateTime = _pickUpdateTime(raw);
  final avatarUrl = _pickAvatarUrl(raw);

  if (id == null || title == null || videoUrl == null || videoUrl.isEmpty) {
    return null;
  }

  return ShortVideoItem(
    id: id,
    source: source ?? '凤凰网视频',
    avatarUrl: avatarUrl ?? '',
    title: title,
    updateTime: updateTime,
    videoUrl: videoUrl,
    coverUrl: coverUrl ?? '',
  );
}

String _pickUpdateTime(Map<String, dynamic> raw) {
  return _asString(raw['updateTime']) ??
      _asString(raw['update_time']) ??
      _asString(raw['newsTime']) ??
      _asString(raw['time']) ??
      _asString(raw['date']) ??
      '';
}

String? _pickVideoUrl(Map<String, dynamic> raw) {
  final link = raw['link'];
  if (link is Map<String, dynamic>) {
    final fromLink = _asString(link['mp4']);
    if (fromLink != null && fromLink.isNotEmpty) {
      return fromLink;
    }
  }

  final phvideo = raw['phvideo'];
  if (phvideo is Map<String, dynamic>) {
    final fallback = _asString(phvideo['videoPlayUrl']);
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
  }

  return null;
}

String? _pickCoverUrl(Map<String, dynamic> raw) {
  final thumbnail = _asString(raw['thumbnail']);
  if (thumbnail != null && thumbnail.isNotEmpty) {
    return thumbnail;
  }

  final imageList = raw['imageList'];
  if (imageList is List<dynamic> && imageList.isNotEmpty) {
    final first = imageList.first;
    if (first is Map<String, dynamic>) {
      final imageUrl = _asString(first['url']);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }
  }

  return null;
}

String? _pickAvatarUrl(Map<String, dynamic> raw) {
  final subscribe = raw['subscribe'];
  if (subscribe is Map<String, dynamic>) {
    final logo = _asString(subscribe['logo']);
    if (logo != null && logo.isNotEmpty) {
      return logo;
    }
  }

  final shareInfo = raw['shareInfo'];
  if (shareInfo is Map<String, dynamic>) {
    final thumbnail = _asString(shareInfo['thumbnail']);
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return thumbnail;
    }
  }

  return null;
}

String? _asString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

int? _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

