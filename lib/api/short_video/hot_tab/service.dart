part of 'index.dart';

Future<HotTabFeedPageResult> getHotTabFeedPage({
  required HotTabRequest request,
}) async {
  final url = request.type == HotTabFeedType.hotspot
      ? _hotspotFeedUrl
      : _mustSeeFeedUrl;

  try {
    final Response response = await httpClient.get(
      url,
      queryParameters: request.toQueryParameters(),
    );
    return _extractHotTabFeedPageResult(
      response.data,
      request: request,
    );
  } catch (error, stackTrace) {
    customLogger.log('getHotTabFeedPage failed: $error');
    customLogger.log(stackTrace);
    return HotTabFeedPageResult(
      items: const <HotTabFeedItem>[],
      currentPage: request.page,
      totalPage: request.page,
    );
  }
}

Future<HotTabDetailPageResult?> getHotTabDetailPage({
  required HotTabDetailRequest request,
}) async {
  try {
    final Response response = await httpClient.get(
      _hotspotDetailUrl,
      queryParameters: request.toQueryParameters(),
    );
    return _extractHotTabDetailPageResult(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getHotTabDetailPage failed: $error');
    customLogger.log(stackTrace);
    return null;
  }
}

HotTabFeedPageResult _extractHotTabFeedPageResult(
  dynamic responseData, {
  required HotTabRequest request,
}) {
  if (responseData is! Map<String, dynamic>) {
    return HotTabFeedPageResult(
      items: const <HotTabFeedItem>[],
      currentPage: request.page,
      totalPage: request.page,
    );
  }

  final data = responseData['data'];
  if (data is! Map<String, dynamic>) {
    return HotTabFeedPageResult(
      items: const <HotTabFeedItem>[],
      currentPage: request.page,
      totalPage: request.page,
    );
  }

  final list = data['list'];
  final items = <HotTabFeedItem>[];
  if (list is List<dynamic>) {
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }
      final item = _mapToHotTabFeedItem(
        raw,
        type: request.type,
        rank: items.length + 1,
      );
      if (item != null) {
        items.add(item);
      }
    }
  }

  return HotTabFeedPageResult(
    items: items,
    currentPage: request.page,
    totalPage: _asInt(data['totalPage']) ?? request.page,
  );
}

HotTabFeedItem? _mapToHotTabFeedItem(
  Map<String, dynamic> raw, {
  required HotTabFeedType type,
  required int rank,
}) {
  final rawType = _asString(raw['type']);
  if (rawType == 'advert') {
    return null;
  }

  final id = _asString(raw['documentId']) ??
      _asString(raw['staticId']) ??
      _asString(raw['id']);
  final title = _asString(raw['title']);
  if (id == null || title == null) {
    return null;
  }

  final videoUrl = _pickVideoUrl(raw) ?? '';
  final itemType =
      (rawType == 'short' || rawType == 'phvideo') && videoUrl.isNotEmpty
          ? HotTabFeedItemType.video
          : HotTabFeedItemType.article;

  final hotLabel = raw['hotLabel'];
  final link = raw['link'];
  final shareInfo = raw['shareInfo'];
  final phvideo = raw['phvideo'];
  final eventName = _extractEventNameFromUrl(_asString(link?['url'])) ??
      _extractEventNameFromUrl(_asString(link?['weburl'])) ??
      _extractEventNameFromUrl(_asString(hotLabel?['link']?['url'])) ??
      _extractEventNameFromUrl(_asString(hotLabel?['link']?['weburl'])) ??
      _asString(hotLabel?['eventKeyword']) ??
      '';

  return HotTabFeedItem(
    id: id,
    type: itemType,
    title: title,
    source: _asString(raw['source']) ??
        _asString(raw['subscribe']?['catename']) ??
        '凤凰资讯',
    coverUrl: _pickCoverUrl(raw) ?? '',
    updateTime: _pickUpdateTime(raw),
    commentsCount: _asString(raw['commentsCount']) ??
        _asString(raw['commentsall']) ??
        _asString(raw['comments']) ??
        '0',
    rankLabel: rank.toString().padLeft(2, '0'),
    hotLabel: _asString(hotLabel?['hotGrade']) ?? '',
    hotTag: _asString(hotLabel?['desp']) ??
        _asString(hotLabel?['eventKeyword']) ??
        (type == HotTabFeedType.mustSee ? '必刷推荐' : ''),
    intro:
        _asString(raw['intro']) ?? _asString(hotLabel?['eventKeyword']) ?? '',
    detailUrl: _asString(link?['url']) ?? '',
    shareUrl:
        _asString(link?['weburl']) ?? _asString(shareInfo?['weburl']) ?? '',
    videoUrl: videoUrl,
    commentsUrl: _pickCommentsUrl(raw),
    durationSeconds: _asInt(phvideo?['length']) ?? 0,
    playCountText: _asString(phvideo?['playTimeStr']) ?? '',
    eventName: eventName,
  );
}

HotTabDetailPageResult? _extractHotTabDetailPageResult(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) {
    return null;
  }

  final data = responseData['data'];
  if (data is! Map<String, dynamic>) {
    return null;
  }

  final config = data['config'];
  final pageInfo = config is Map<String, dynamic> ? config['pageinfo'] : null;
  final banner = pageInfo is Map<String, dynamic> ? pageInfo['banner'] : null;
  final threeLines =
      banner is Map<String, dynamic> ? banner['threelines'] : null;
  final shareInfo = config is Map<String, dynamic> ? config['shareInfo'] : null;

  final lists = data['lists'];
  final items = <HotTabDetailNewsItem>[];
  if (lists is List<dynamic>) {
    for (final sectionRaw in lists) {
      if (sectionRaw is! Map<String, dynamic>) {
        continue;
      }
      final sectionItems = sectionRaw['items'];
      if (sectionItems is! List<dynamic>) {
        continue;
      }
      for (final entry in sectionItems) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        final content = entry['content'];
        if (content is! Map<String, dynamic>) {
          continue;
        }
        final item = _mapToHotTabDetailNewsItem(content);
        if (item != null) {
          items.add(item);
        }
      }
    }
  }

  return HotTabDetailPageResult(
    title: _asString(threeLines?['title']) ??
        _asString(config?['chInfo']?['chname']) ??
        '热点专题',
    subscribeCountText: _asString(threeLines?['desc']?['first']) ?? '',
    bannerImageUrl: _asString(threeLines?['backgroundImg']) ?? '',
    shareUrl: _asString(shareInfo?['weburl']) ?? '',
    items: List<HotTabDetailNewsItem>.unmodifiable(items),
  );
}

HotTabDetailNewsItem? _mapToHotTabDetailNewsItem(Map<String, dynamic> raw) {
  final rawType = _asString(raw['type']);
  final id = _asString(raw['documentId']) ??
      _asString(raw['staticId']) ??
      _asString(raw['id']);
  final title = _asString(raw['title']);
  if (rawType == null || id == null || title == null) {
    return null;
  }

  final videoUrl = _pickVideoUrl(raw) ?? '';
  final itemType = rawType == 'phvideo' && videoUrl.isNotEmpty
      ? HotTabFeedItemType.video
      : HotTabFeedItemType.article;
  final link = raw['link'];
  final shareInfo = raw['shareInfo'];
  final phvideo = raw['phvideo'];

  return HotTabDetailNewsItem(
    id: id,
    type: itemType,
    title: title,
    intro: _asString(raw['intro']) ?? '',
    source: _asString(raw['subscribe']?['catename']) ??
        _asString(raw['source']) ??
        '凤凰资讯',
    updateTime: _pickUpdateTime(raw),
    commentsCount: _asString(raw['commentsCount']) ??
        _asString(raw['commentsall']) ??
        _asString(raw['comments']) ??
        '',
    coverUrls: _pickCoverUrls(raw),
    detailUrl: _asString(link?['url']) ?? '',
    shareUrl:
        _asString(link?['weburl']) ?? _asString(shareInfo?['weburl']) ?? '',
    videoUrl: videoUrl,
    commentsUrl: _pickCommentsUrl(raw),
    durationSeconds: _asInt(phvideo?['length']) ?? 0,
    playCountText: _asString(phvideo?['playTimeStr']) ?? '',
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
    final previewUrl = _asString(link['previewurl']);
    if (previewUrl != null && previewUrl.isNotEmpty) {
      return previewUrl;
    }
  }

  final phvideo = raw['phvideo'];
  if (phvideo is Map<String, dynamic>) {
    final playUrl = _asString(phvideo['videoPlayUrl']);
    if (playUrl != null && playUrl.isNotEmpty) {
      return playUrl;
    }
  }

  return null;
}

String _pickCommentsUrl(Map<String, dynamic> raw) {
  final direct =
      _asString(raw['commentsUrl']) ?? _asString(raw['comments_url']);
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

  return _asString(raw['staticId']) ?? _asString(raw['documentId']) ?? '';
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
      final url = _asString(first['url']);
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }
  }

  return null;
}

List<String> _pickCoverUrls(Map<String, dynamic> raw) {
  final urls = <String>[];

  final imageList = raw['imageList'];
  if (imageList is List<dynamic>) {
    for (final item in imageList) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final url = _asString(item['url']);
      if (url != null && url.isNotEmpty && !urls.contains(url)) {
        urls.add(url);
      }
    }
  }

  final thumbnail = _asString(raw['thumbnail']);
  if (urls.isEmpty && thumbnail != null && thumbnail.isNotEmpty) {
    urls.add(thumbnail);
  }

  return List<String>.unmodifiable(urls);
}

String? _extractEventNameFromUrl(String? url) {
  if (url == null || url.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return null;
  }
  return _asString(uri.queryParameters['eventName']);
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
