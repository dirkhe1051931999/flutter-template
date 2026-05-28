import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
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

const int _commentDanmakuTargetCount = 24;
const int _commentDanmakuFetchPageSize = 30;
const int _commentDanmakuTimelineWindowMs = 75 * 1000;

final Map<String, List<DanmakuItem>> _commentDanmakuCache =
    <String, List<DanmakuItem>>{};

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

Future<ShortVideoProfileSummary?> getShortVideoProfileSummary() async {
  try {
    final session = await IfengAuthStorage.loadSession();
    final queryParameters = await buildIfengQueryParameters(
      options: const IfengRequestOptions(),
    );
    final Response response = await IfengRequestClients.userClient.get(
      _shortVideoUserTimelinePath,
      queryParameters: queryParameters,
    );
    final json = _asMap(response.data);
    final data = _asMap(json['data']);
    final userInfo = _asMap(data['user_info']);
    if (userInfo.isEmpty) {
      return null;
    }
    final extra = _asMap(data['extra']);
    return _mapShortVideoProfileSummary(
      userInfo,
      extra: extra,
      rootData: data,
      fallbackGuid: session.guid,
      fallbackNickname: session.nickname.isNotEmpty ? session.nickname : session.username,
      fallbackAvatarUrl: session.userImage,
    );
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoProfileSummary failed: $error');
    customLogger.log(stackTrace);
    return null;
  }
}

Future<ShortVideoProfileFeedPageResult> getShortVideoProfileFeedPage({
  required String guid,
  int page = 1,
  int limit = 20,
}) async {
  try {
    final queryParameters = await buildIfengQueryParameters(
      options: IfengRequestOptions(
        extraQueryParameters: <String, dynamic>{
          'guid_feeds': guid,
          'page': page.toString(),
          'limit': limit.toString(),
          'type': '1',
        },
      ),
    );
    final Response response = await IfengRequestClients.userClient.get(
      _shortVideoUserFeedsPath,
      queryParameters: queryParameters,
    );
    final json = _asMap(response.data);
    final data = _asMap(json['data']);
    final userInfo = _asMap(data['userinfo']);
    final feeds = _asMap(data['feeds']);
    final rawList = _asList(feeds['list']);
    return ShortVideoProfileFeedPageResult(
      userSummary: userInfo.isEmpty
          ? null
          : _mapShortVideoProfileSummary(
              userInfo,
              extra: const <String, dynamic>{},
              rootData: const <String, dynamic>{},
              fallbackGuid: guid,
              fallbackNickname: '',
              fallbackAvatarUrl: '',
            ),
      items: rawList
          .map(_mapShortVideoProfileFeedItem)
          .whereType<ShortVideoProfileFeedItem>()
          .toList(growable: false),
      currentPage: _asInt(feeds['current_page']) ?? page,
      totalPage: _asInt(feeds['total_page']) ?? page,
      limit: _asInt(feeds['limit']) ?? limit,
    );
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoProfileFeedPage failed: $error');
    customLogger.log(stackTrace);
    return ShortVideoProfileFeedPageResult(
      userSummary: null,
      items: const <ShortVideoProfileFeedItem>[],
      currentPage: page,
      totalPage: page,
      limit: limit,
    );
  }
}

Future<List<DanmakuItem>> getDanmaku(ShortVideoItem item) async {
  if (item.type == 'phvideo') {
    final commentDanmakuItems = await _getCommentDanmakuItems(item);
    if (commentDanmakuItems.isNotEmpty) {
      return commentDanmakuItems;
    }
  }
  return generateMockDanmakuItems(item.id);
}

Future<List<DanmakuItem>> _getCommentDanmakuItems(ShortVideoItem item) async {
  final docUrl = item.commentsUrl?.trim().isNotEmpty == true
      ? item.commentsUrl!.trim()
      : item.id;
  if (docUrl.isEmpty) {
    return const <DanmakuItem>[];
  }

  final cacheKey = '${item.id}::$docUrl';
  final cached = _commentDanmakuCache[cacheKey];
  if (cached != null) {
    return cached;
  }

  final result = await getShortVideoComments(
    query: ShortVideoCommentQuery(
      docUrl: docUrl,
      page: 1,
      pageSize: _commentDanmakuFetchPageSize,
      sortBy: ShortVideoCommentSortBy.hot,
    ),
  );
  final danmakuItems = _buildCommentDanmakuItems(
    comments: result.comments,
    seed: cacheKey,
  );
  _commentDanmakuCache[cacheKey] = danmakuItems;
  return danmakuItems;
}

List<DanmakuItem> _buildCommentDanmakuItems({
  required List<ShortVideoCommentItem> comments,
  required String seed,
}) {
  if (comments.isEmpty) {
    return const <DanmakuItem>[];
  }

  final uniqueTexts = <String>{};
  final filteredComments = <ShortVideoCommentItem>[];
  for (final comment in comments) {
    final normalized = _normalizeDanmakuText(comment.content);
    if (normalized == null) {
      continue;
    }
    if (!uniqueTexts.add(normalized)) {
      continue;
    }
    filteredComments.add(comment.copyWith(content: normalized));
    if (filteredComments.length >= _commentDanmakuTargetCount) {
      break;
    }
  }

  if (filteredComments.isEmpty) {
    return const <DanmakuItem>[];
  }

  final random = seed.hashCode;
  final count = filteredComments.length;
  const windowMs = _commentDanmakuTimelineWindowMs;
  final spacingMs = count <= 1 ? 0 : (windowMs / count).floor();
  const colors = <String>[
    '#FFFFFF',
    '#FFE7A7',
    '#B7F1FF',
    '#FFC7D8',
    '#D5FFBF',
  ];

  return List<DanmakuItem>.generate(count, (index) {
    final comment = filteredComments[index];
    final jitterSeed = (random + index * 97).abs();
    final jitterMs = count <= 1 ? 0 : (jitterSeed % 1200) - 600;
    final atMs =
        (2000 + index * spacingMs + jitterMs).clamp(1200, windowMs).toInt();
    final isHot = index < 6 || comment.likeCount >= 20;
    return DanmakuItem(
      atMs: atMs,
      text: comment.content,
      type: isHot ? 'hot' : 'normal',
      color: colors[jitterSeed % colors.length],
      priority: isHot ? 2 : 1,
    );
  });
}

String? _normalizeDanmakuText(String rawText) {
  final normalized = rawText.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return null;
  }
  if (normalized.length > 18) {
    return null;
  }
  if (!_containsMeaningfulDanmakuCharacter(normalized)) {
    return null;
  }
  const blockedTexts = <String>{
    '转发微博',
    '图片评论',
    '网页链接',
  };
  if (blockedTexts.contains(normalized)) {
    return null;
  }
  return normalized;
}

bool _containsMeaningfulDanmakuCharacter(String text) {
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (RegExp(r'[A-Za-z0-9\u4E00-\u9FFF]').hasMatch(char)) {
      return true;
    }
  }
  return false;
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
    commentsCount: _asString(body['commentsCount']) ??
        _asString(body['commentsall']) ??
        _asString(body['comments']) ??
        '0',
    htmlText: htmlText,
    subscribeId: _asString(body['subscribe']?['cateid']) ?? '',
    subscribeName: _asString(body['subscribe']?['catename']) ?? '',
    subscribeType: _asString(body['subscribe']?['type']) ?? '',
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
    type: 'phvideo',
    commentsUrl: _pickCommentsUrl(raw),
    commentsCount: _pickCommentsCount(raw),
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

String? _pickCommentsUrl(Map<String, dynamic> raw) {
  final direct = _asString(raw['commentsUrl']) ?? _asString(raw['comments_url']);
  if (direct != null && direct.isNotEmpty) {
    return direct;
  }

  final link = raw['link'];
  if (link is Map<String, dynamic>) {
    final fromLink = _asString(link['commentsUrl']) ??
        _asString(link['comments_url']) ??
        _asString(link['doc_url']);
    if (fromLink != null && fromLink.isNotEmpty) {
      return fromLink;
    }
  }

  return _asString(raw['staticId']) ?? _asString(raw['documentId']);
}

String _pickCommentsCount(Map<String, dynamic> raw) {
  return _asString(raw['commentsCount']) ??
      _asString(raw['commentsall']) ??
      _asString(raw['comments']) ??
      '0';
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

ShortVideoProfileSummary _mapShortVideoProfileSummary(
  Map<String, dynamic> raw, {
  required Map<String, dynamic> extra,
  required Map<String, dynamic> rootData,
  required String fallbackGuid,
  required String fallbackNickname,
  required String fallbackAvatarUrl,
}) {
  final credit = _asMap(raw['credit']);
  final jumpUrlSign = _asString(raw['jump_url_sign']) ?? _asString(extra['credit_jpurl']) ?? '';
  return ShortVideoProfileSummary(
    guid: _asString(raw['guid']) ?? _asString(rootData['guid']) ?? fallbackGuid,
    nickname: _asString(raw['nickname']) ?? fallbackNickname,
    avatarUrl: _asString(raw['userimg']) ?? fallbackAvatarUrl,
    introduction: _asString(raw['introduction']) ?? '',
    location: _asString(raw['userLocation']) ?? _asString(raw['location']) ?? '',
    followCount: _asInt(raw['follow_num']) ?? 0,
    fansCount: _asInt(raw['fans_num']) ?? 0,
    feedCount: _asInt(raw['feeds_num']) ?? 0,
    level: _asInt(credit['lev']) ?? _asInt(raw['lev']) ?? 0,
    levelTitle: _asString(credit['title_1']) ?? _asString(raw['title_1']) ?? '',
    assistantLabel: jumpUrlSign.isNotEmpty ? '勋章墙' : '',
    canOpenPersonalHome: true,
  );
}

ShortVideoProfileFeedItem? _mapShortVideoProfileFeedItem(dynamic rawValue) {
  final raw = _asMap(rawValue);
  if (raw.isEmpty) {
    return null;
  }
  final commentId = _asString(raw['comment_id']) ?? '';
  final userName = _asString(raw['uname']) ?? _asString(raw['nickname']) ?? '凤凰网友';
  final content = _asString(raw['comment_contents']) ?? '';
  final articleSource = _asMap(raw['parent']).isNotEmpty ? _asMap(raw['parent']) : raw;
  final rawLink = _asMap(raw['link']);
  final parentLink = _asMap(articleSource['link']);
  final articleId = _asString(articleSource['documentId']) ??
      _asString(articleSource['staticId']) ??
      _asString(articleSource['id']) ??
      commentId;
  final articleType = _asString(articleSource['type']) ?? 'doc';
  final articleTitle = _asString(articleSource['title']) ?? '';
  if (commentId.isEmpty || articleTitle.isEmpty || articleId.isEmpty) {
    return null;
  }
  return ShortVideoProfileFeedItem(
    commentId: commentId,
    content: content,
    likeCount: _asInt(raw['like']) ?? 0,
    publishTimeText: _asString(raw['createTime']) ?? '',
    userName: userName,
    userAvatarUrl: '',
    articlePreview: ShortVideoProfileFeedArticlePreview(
      id: articleId,
      type: articleType,
      title: articleTitle,
      thumbnail: _asString(articleSource['thumbnail']) ?? '',
      detailUrl: _asString(rawLink['url']) ??
          _asString(parentLink['url']) ??
          '',
      videoUrl: _pickVideoUrl(articleSource) ?? '',
      source: _asString(articleSource['source']) ??
          _asString(articleSource['subscribe']?['catename']) ??
          '',
      updateTime: _pickUpdateTime(articleSource),
      commentsUrl: _pickCommentsUrl(articleSource) ?? '',
      commentsCount: _asString(articleSource['commentsCount']) ??
          _asString(articleSource['commentsall']) ??
          _asString(articleSource['comments']) ??
          '0',
    ),
  );
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return const <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  if (value is List) {
    return value.toList(growable: false);
  }
  return const <dynamic>[];
}

String? _asString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
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

