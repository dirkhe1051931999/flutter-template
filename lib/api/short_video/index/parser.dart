part of 'index.dart';

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
  dynamic responseData,
) {
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
  final jumpUrlSign =
      _asString(raw['jump_url_sign']) ?? _asString(extra['credit_jpurl']) ?? '';
  return ShortVideoProfileSummary(
    guid: _asString(raw['guid']) ?? _asString(rootData['guid']) ?? fallbackGuid,
    nickname: _asString(raw['nickname']) ?? fallbackNickname,
    avatarUrl: _asString(raw['userimg']) ?? fallbackAvatarUrl,
    introduction: _asString(raw['introduction']) ?? '',
    location:
        _asString(raw['userLocation']) ?? _asString(raw['location']) ?? '',
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
  final userName =
      _asString(raw['uname']) ?? _asString(raw['nickname']) ?? '凤凰网友';
  final content = _asString(raw['comment_contents']) ?? '';
  final articleSource =
      _asMap(raw['parent']).isNotEmpty ? _asMap(raw['parent']) : raw;
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
      detailUrl:
          _asString(rawLink['url']) ?? _asString(parentLink['url']) ?? '',
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
