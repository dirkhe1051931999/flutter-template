part of 'index.dart';

const String _shortVideoCommentsPath = '/v3/get/comments';
const String _shortVideoCommentChildrenPath = '/v3/get/children';
const String _shortVideoCommentSubmitPath = '/wappost.php';
const String _shortVideoCommentUploadAppId = 'ifeng_news';

const int _commentDanmakuTargetCount = 24;
const int _commentDanmakuFetchPageSize = 30;
const int _commentDanmakuTimelineWindowMs = 75 * 1000;

final Map<String, List<DanmakuItem>> _commentDanmakuCache =
    <String, List<DanmakuItem>>{};

const Map<String, String> _shortVideoCommentFixedParams = {
  ...kShortVideoCommonFixedParams,
  ...kShortVideoAndroid28DeviceFixedParams,
  'st': '17797771826970',
  'sn': 'afe7b2000b7ee2ac1692b2b043faf8de',
};

const Map<String, String> _shortVideoCommentSubmitFixedParams = {
  'gv': '7.30.3',
  'av': '7.30.3',
  'uid': '71ac5c9a66200b87',
  'deviceid': '71ac5c9a66200b87',
  'proid': 'ifengnews',
  'os': 'android_32',
  'df': 'androidphone',
  'vt': '5',
  'screen': '720x1280',
  'publishid': '2011',
  'nw': 'wifi',
  'adAid': '',
  'hw': 'redmi_22041211a',
  'ps': '1',
  'st': '17799550563213',
  'sn': 'df3c47edbc4c31d68524e31a5131ab7a',
};

const String _shortVideoCommentSubmitClient = '1';
const String _shortVideoCommentSubmitRt = 'sj';
const String _shortVideoCommentSubmitSkeyFallback = 'C1A54B';
const String _shortVideoCommentSubmitDeviceType = '22041211A';

enum ShortVideoCommentDocType {
  doc,
  phvideo,
}

extension ShortVideoCommentDocTypeX on ShortVideoCommentDocType {
  String get apiValue {
    return switch (this) {
      ShortVideoCommentDocType.doc => 'doc',
      ShortVideoCommentDocType.phvideo => 'phvideo',
    };
  }
}

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
    this.imageUrls = const <String>[],
    this.localImageBytes,
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
  final List<String> imageUrls;
  final Uint8List? localImageBytes;
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
    List<String>? imageUrls,
    Uint8List? localImageBytes,
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
      imageUrls: imageUrls ?? this.imageUrls,
      localImageBytes: localImageBytes ?? this.localImageBytes,
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

class ShortVideoCommentSubmitRequest {
  const ShortVideoCommentSubmitRequest({
    required this.docId,
    required this.docName,
    required this.content,
    required this.docType,
    this.docUrl,
    this.docThumbnail,
    this.subId,
    this.subName,
    this.subType,
    this.nickname,
    this.userImageUrl,
    this.from = 'sj',
    this.isTrends = '0',
    this.location = '',
    this.latitude = '',
    this.longitude = '',
    this.imageUpload,
    this.replyToComment,
  });

  final String docId;
  final String docName;
  final String content;
  final ShortVideoCommentDocType docType;
  final String? docUrl;
  final String? docThumbnail;
  final String? subId;
  final String? subName;
  final String? subType;
  final String? nickname;
  final String? userImageUrl;
  final String from;
  final String isTrends;
  final String location;
  final String latitude;
  final String longitude;
  final ShortVideoCommentImageUploadPayload? imageUpload;
  final ShortVideoCommentItem? replyToComment;
}

class ShortVideoCommentImageUploadPayload {
  const ShortVideoCommentImageUploadPayload({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final Uint8List bytes;
}

class ShortVideoCommentSubmitResult {
  const ShortVideoCommentSubmitResult({
    required this.isSuccess,
    required this.message,
    this.raw,
  });

  final bool isSuccess;
  final String message;
  final dynamic raw;
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

class _ShortVideoCommentImageUploadResult {
  const _ShortVideoCommentImageUploadResult({
    required this.isSuccess,
    required this.message,
    this.raw,
  });

  final bool isSuccess;
  final String message;
  final dynamic raw;
}
