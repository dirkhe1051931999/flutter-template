part of 'index.dart';

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
      fallbackNickname:
          session.nickname.isNotEmpty ? session.nickname : session.username,
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
