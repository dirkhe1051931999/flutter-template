import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _shortVideoCommentsPath = '/v3/get/comments';
const String _shortVideoCommentChildrenPath = '/v3/get/children';

const Map<String, String> _shortVideoCommentFixedParams = {
  ...kShortVideoCommonFixedParams,
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17797771826970',
  'sn': 'afe7b2000b7ee2ac1692b2b043faf8de',
};

enum ShortVideoCommentSortBy {
  hot,
  latest,
}

extension ShortVideoCommentSortByX on ShortVideoCommentSortBy {
  String get apiValue {
    return switch (this) {
      ShortVideoCommentSortBy.hot => 'integral',
      ShortVideoCommentSortBy.latest => 'create_time',
    };
  }

  String get label {
    return switch (this) {
      ShortVideoCommentSortBy.hot => '按热度',
      ShortVideoCommentSortBy.latest => '按时间',
    };
  }
}

class ShortVideoCommentQuery {
  const ShortVideoCommentQuery({
    required this.docUrl,
    this.page = 1,
    this.pageSize = 10,
    this.sortBy = ShortVideoCommentSortBy.hot,
  });

  final String docUrl;
  final int page;
  final int pageSize;
  final ShortVideoCommentSortBy sortBy;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      ..._shortVideoCommentFixedParams,
      'doc_url': docUrl,
      'p': page.toString(),
      'orderby': sortBy.apiValue,
      'pagesize': pageSize.toString(),
    };
  }
}

class ShortVideoCommentChildrenQuery {
  const ShortVideoCommentChildrenQuery({
    required this.docUrl,
    required this.commentId,
    this.page = 1,
    required this.pageSize,
  });

  final String docUrl;
  final String commentId;
  final int page;
  final int pageSize;

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      ..._shortVideoCommentFixedParams,
      'action': 'down',
      'doc_url': docUrl,
      'comment_id': commentId,
      'p': page.toString(),
      'pagesize': pageSize.toString(),
    };
  }
}

class ShortVideoCommentUser {
  const ShortVideoCommentUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.isAnonymous,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final bool isAnonymous;
}

class ShortVideoCommentItem {
  const ShortVideoCommentItem({
    required this.commentId,
    required this.docUrl,
    required this.contentType,
    required this.user,
    required this.content,
    this.replyToUserId,
    this.replyToUserName,
    required this.publishTimeText,
    required this.likeCount,
    required this.replyCount,
    required this.children,
    this.childrenPage = 0,
    required this.canLoadMoreChildren,
  });

  final String commentId;
  final String docUrl;
  final String contentType;
  final ShortVideoCommentUser user;
  final String content;
  final String? replyToUserId;
  final String? replyToUserName;
  final String publishTimeText;
  final int likeCount;
  final int replyCount;
  final List<ShortVideoCommentItem> children;
  final int childrenPage;
  final bool canLoadMoreChildren;

  ShortVideoCommentItem copyWith({
    String? commentId,
    String? docUrl,
    String? contentType,
    ShortVideoCommentUser? user,
    String? content,
    String? replyToUserId,
    String? replyToUserName,
    String? publishTimeText,
    int? likeCount,
    int? replyCount,
    List<ShortVideoCommentItem>? children,
    int? childrenPage,
    bool? canLoadMoreChildren,
  }) {
    return ShortVideoCommentItem(
      commentId: commentId ?? this.commentId,
      docUrl: docUrl ?? this.docUrl,
      contentType: contentType ?? this.contentType,
      user: user ?? this.user,
      content: content ?? this.content,
      replyToUserId: replyToUserId ?? this.replyToUserId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      publishTimeText: publishTimeText ?? this.publishTimeText,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      children: children ?? this.children,
      childrenPage: childrenPage ?? this.childrenPage,
      canLoadMoreChildren: canLoadMoreChildren ?? this.canLoadMoreChildren,
    );
  }
}

class ShortVideoCommentPageResult {
  const ShortVideoCommentPageResult({
    required this.comments,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  final List<ShortVideoCommentItem> comments;
  final int totalCount;
  final int page;
  final int pageSize;
  final bool hasMore;
}

Future<ShortVideoCommentPageResult> getShortVideoComments({
  required ShortVideoCommentQuery query,
}) async {
  try {
    final Response response = await shortVideoCommentClient.post(
      _buildPathWithQuery(
        _shortVideoCommentsPath,
        query.toQueryParameters(),
      ),
      options: Options(
        contentType: Headers.jsonContentType,
      ),
      data: const <String, dynamic>{},
    );
    return _extractCommentPageResult(
      response.data,
      page: query.page,
      pageSize: query.pageSize,
    );
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoComments failed: $error');
    customLogger.log(stackTrace);
    return ShortVideoCommentPageResult(
      comments: const <ShortVideoCommentItem>[],
      totalCount: 0,
      page: query.page,
      pageSize: query.pageSize,
      hasMore: false,
    );
  }
}

Future<List<ShortVideoCommentItem>> getShortVideoCommentChildren({
  required ShortVideoCommentChildrenQuery query,
}) async {
  try {
    final Response response = await shortVideoCommentClient.post(
      _buildPathWithQuery(
        _shortVideoCommentChildrenPath,
        query.toQueryParameters(),
      ),
      options: Options(
        contentType: Headers.jsonContentType,
      ),
      data: const <String, dynamic>{},
    );
    return _extractCommentItems(response.data);
  } catch (error, stackTrace) {
    customLogger.log('getShortVideoCommentChildren failed: $error');
    customLogger.log(stackTrace);
    return const <ShortVideoCommentItem>[];
  }
}

String _buildPathWithQuery(
  String path,
  Map<String, dynamic> queryParameters,
) {
  final query = queryParameters.entries.map((entry) {
    return '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}';
  }).join('&');
  return '$path?$query';
}

ShortVideoCommentPageResult _extractCommentPageResult(
  dynamic responseData, {
  required int page,
  required int pageSize,
}) {
  final comments = _extractCommentItems(responseData);
  final totalCount = _pickCommentTotalCount(responseData) ?? comments.length;
  final hasMore = comments.length >= pageSize;
  return ShortVideoCommentPageResult(
    comments: comments,
    totalCount: totalCount,
    page: page,
    pageSize: pageSize,
    hasMore: hasMore,
  );
}

List<ShortVideoCommentItem> _extractCommentItems(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) {
    return const <ShortVideoCommentItem>[];
  }

  final rawComments = responseData['comments'];
  if (rawComments is! List<dynamic>) {
    return const <ShortVideoCommentItem>[];
  }

  return rawComments
      .whereType<Map<String, dynamic>>()
      .map(_mapToCommentItem)
      .whereType<ShortVideoCommentItem>()
      .toList(growable: false);
}

ShortVideoCommentItem? _mapToCommentItem(Map<String, dynamic> raw) {
  final extInfo = _parseExtInfo(raw['ext2']);
  final commentId = _asString(raw['comment_id']) ?? _asString(raw['commentId']);
  final docUrl = _asString(raw['doc_url']) ??
      _asString(raw['docUrl']) ??
      extInfo.docId;
  final content = _asString(raw['comment_contents']) ??
      _asString(raw['commentContents']) ??
      _asString(raw['comment_content']) ??
      _asString(raw['content']);
  if (commentId == null || docUrl == null || content == null) {
    return null;
  }

  final user = ShortVideoCommentUser(
    id: _asString(raw['uname']) ?? _asString(raw['user_id']) ?? commentId,
    name: _asString(raw['uname']) ?? _asString(raw['user_name']) ?? '凤凰网友',
    avatarUrl: _asString(raw['faceurl']) ??
        _asString(raw['userFace']) ??
        _asString(raw['userface']) ??
        _asString(raw['avatar']) ??
        extInfo.userImageUrl ??
        '',
    isAnonymous: (_asInt(raw['isAnonymous']) ?? 0) == 1,
  );

  final children = _extractChildren(raw['children']);
  final replyCount = _pickChildrenCount(raw['children']) ?? children.length;

  return ShortVideoCommentItem(
    commentId: commentId,
    docUrl: docUrl,
    contentType: extInfo.contentType,
    user: user,
    content: content,
    replyToUserId: _asString(raw['reply_uid']),
    replyToUserName: _asString(raw['reply_uname']),
    publishTimeText: formatRelativeCommentTime(
          raw['create_time'],
          secondaryValue: raw['comment_date'],
          fallbackValue: raw['create_time_format'],
        ) ??
        '',
    likeCount: _asInt(raw['uptimes']) ?? _asInt(raw['like_count']) ?? 0,
    replyCount: replyCount,
    children: children,
    childrenPage: children.isEmpty ? 0 : 1,
    canLoadMoreChildren: replyCount > children.length,
  );
}

List<ShortVideoCommentItem> _extractChildren(dynamic rawChildren) {
  if (rawChildren is Map<String, dynamic>) {
    final childComments = rawChildren['comments'];
    if (childComments is List<dynamic>) {
      return childComments
          .whereType<Map<String, dynamic>>()
          .map(_mapToCommentItem)
          .whereType<ShortVideoCommentItem>()
          .toList(growable: false);
    }
  }

  if (rawChildren is List<dynamic>) {
    return rawChildren
        .whereType<Map<String, dynamic>>()
        .map(_mapToCommentItem)
        .whereType<ShortVideoCommentItem>()
        .toList(growable: false);
  }

  return const <ShortVideoCommentItem>[];
}

int? _pickChildrenCount(dynamic rawChildren) {
  if (rawChildren is Map<String, dynamic>) {
    return _asInt(rawChildren['count']) ?? _asInt(rawChildren['total']);
  }
  return null;
}

_ShortVideoCommentExtInfo _parseExtInfo(dynamic rawExt) {
  if (rawExt is! String || rawExt.trim().isEmpty) {
    return const _ShortVideoCommentExtInfo();
  }

  try {
    final decoded = jsonDecode(rawExt);
    if (decoded is! Map<String, dynamic>) {
      return const _ShortVideoCommentExtInfo();
    }
    return _ShortVideoCommentExtInfo(
      contentType: _asString(decoded['type']) ??
          _asString(decoded['doc_type']) ??
          'comment',
      docId: _asString(decoded['docId']) ?? _asString(decoded['doc_url']),
      userImageUrl: _asString(decoded['userimg']),
    );
  } catch (_) {
    return const _ShortVideoCommentExtInfo();
  }
}

class _ShortVideoCommentExtInfo {
  const _ShortVideoCommentExtInfo({
    this.contentType = 'comment',
    this.docId,
    this.userImageUrl,
  });

  final String contentType;
  final String? docId;
  final String? userImageUrl;
}

int? _pickCommentTotalCount(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) {
    return null;
  }

  final candidates = <dynamic>[
    responseData['count'],
    responseData['total'],
    responseData['total_count'],
    responseData['comments_count'],
  ];

  for (final candidate in candidates) {
    final value = _asInt(candidate);
    if (value != null) {
      return value;
    }
  }
  return null;
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
