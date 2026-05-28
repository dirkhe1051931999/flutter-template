import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _shortVideoCommentsPath = '/v3/get/comments';
const String _shortVideoCommentChildrenPath = '/v3/get/children';
const String _shortVideoCommentSubmitPath = '/wappost.php';
const String _shortVideoCommentUploadAppId = 'ifeng_news';

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

Future<ShortVideoCommentSubmitResult> submitShortVideoComment({
  required ShortVideoCommentSubmitRequest request,
}) async {
  final session = await IfengAuthStorage.loadSession();
  if (!session.isLoggedIn) {
    return const ShortVideoCommentSubmitResult(
      isSuccess: false,
      message: '请先登录',
    );
  }

  if (request.imageUpload != null) {
    final imageUploadResult = await _uploadCommentImage(
      payload: request.imageUpload!,
      session: session,
    );
    if (!imageUploadResult.isSuccess) {
      return ShortVideoCommentSubmitResult(
        isSuccess: false,
        message: imageUploadResult.message,
        raw: imageUploadResult.raw,
      );
    }
  }

  final body = <String, dynamic>{
    'docName': request.docName.trim(),
    'rt': _shortVideoCommentSubmitRt,
    'docId': request.docId.trim(),
    'docUrl': (request.docUrl?.trim().isNotEmpty == true
            ? request.docUrl!.trim()
            : request.docId.trim()),
    'Connection': 'Close',
    'quoteId': request.replyToComment?.commentId ?? '0',
    'client': _shortVideoCommentSubmitClient,
    'skey': _pickSessionString(
          session.smsFastPass,
          const <String>['skey'],
        ) ??
        _shortVideoCommentSubmitSkeyFallback,
    'ext2': jsonEncode(<String, dynamic>{
      'comment_verify': 'sy',
      'device_type': _shortVideoCommentSubmitDeviceType,
      'deviceid': _shortVideoCommentSubmitFixedParams['deviceid'],
      'docId': request.docId.trim(),
      'docUrl': (request.docUrl?.trim().isNotEmpty == true
          ? request.docUrl!.trim()
          : request.docId.trim()),
      'doc_thumbnail': request.docThumbnail?.trim() ?? '',
      'from': request.from,
      'guid': session.guid.trim(),
      'isTrends': request.isTrends,
      'lat': request.latitude,
      'location': request.location,
      'lon': request.longitude,
      'nickname': request.nickname?.trim().isNotEmpty == true
          ? request.nickname!.trim()
          : (session.nickname.trim().isNotEmpty
              ? session.nickname.trim()
              : session.username.trim()),
      'sub_id': request.subId?.trim() ?? '',
      'sub_name': request.subName?.trim() ?? '',
      'sub_type': request.subType?.trim() ?? '',
      'type': request.docType.apiValue,
      'userimg': request.userImageUrl?.trim().isNotEmpty == true
          ? request.userImageUrl!.trim()
          : session.userImage.trim(),
    }),
    'content': request.content.trim(),
    'sid': _pickSessionString(
          session.smsFastPass,
          const <String>['token', 'sid', 'sessionid', 'session_id'],
        ) ??
        session.token.trim(),
    'ltoken': AppConfig.shortVideoCommentLToken,
  };

  try {
    final submitQueryParameters = <String, dynamic>{
      ..._shortVideoCommentSubmitFixedParams,
      'loginid': session.guid.trim(),
    };
    customLogger.log(
      'submitShortVideoComment body: ${jsonEncode(body)}',
    );
    final response = await shortVideoCommentClient.postFormData(
      _buildPathWithQuery(
        _shortVideoCommentSubmitPath,
        submitQueryParameters,
      ),
      data: body,
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );
    return _parseCommentSubmitResult(response.data);
  } catch (error, stackTrace) {
    customLogger.log('submitShortVideoComment failed: $error');
    customLogger.log(stackTrace);
    return ShortVideoCommentSubmitResult(
      isSuccess: false,
      message: '发表评论失败，请稍后重试',
      raw: error,
    );
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
    imageUrls: _extractImageUrls(raw['pics']),
    childrenPage: children.isEmpty ? 0 : 1,
    canLoadMoreChildren: replyCount > children.length,
  );
}

Future<_ShortVideoCommentImageUploadResult> _uploadCommentImage({
  required ShortVideoCommentImageUploadPayload payload,
  required IfengAuthSession session,
}) async {
  final fileName = payload.fileName.trim();
  if (fileName.isEmpty || payload.bytes.isEmpty) {
    return const _ShortVideoCommentImageUploadResult(
      isSuccess: false,
      message: '图片文件无效',
    );
  }

  final initQueryParameters = <String, dynamic>{
    'rt': 'json',
    'ctype': '0',
    'pid': '0',
    'pl': '1',
    'utype': '0',
    'sid': session.token.trim(),
    'rtype': '2',
    'title': fileName,
  };

  try {
    customLogger.log(
      'uploadCommentImage init request: ${AppConfig.shortVideoCommentUploadInitUrl}?${Uri(queryParameters: initQueryParameters).query}',
    );
    final Response<dynamic> initResponse = await shortVideoCommentClient.get(
      AppConfig.shortVideoCommentUploadInitUrl,
      queryParameters: initQueryParameters,
    );
    customLogger.log(
      'uploadCommentImage init response: ${initResponse.data}',
    );
    final initJson = _asMap(initResponse.data);
    final initData = _asMap(initJson['data']);
    final rid = _asString(initData['rid']);
    final callback = _asString(initData['callback']);
    final dir = _asString(initData['dir']);
    if (rid == null || callback == null || dir == null) {
      return _ShortVideoCommentImageUploadResult(
        message: '图片上传初始化失败',
        isSuccess: false,
        raw: initResponse.data,
      );
    }

    final sha1Digest = sha1.convert(payload.bytes).toString();
    customLogger.log(
      'uploadCommentImage upload request: ${AppConfig.shortVideoCommentUploadUrl}',
    );
    customLogger.log(
      'uploadCommentImage upload fields: ${jsonEncode(<String, dynamic>{
        'successCb': callback,
        'storePath': dir,
        'fileId': '${sha1Digest}_1',
        'blockIndex': '1',
        'blockId': sha1Digest,
        'blockCount': '1',
        'bizId': rid,
        'appId': _shortVideoCommentUploadAppId,
        'blockContent': fileName,
      })}',
    );
    final Response<dynamic> uploadResponse = await shortVideoCommentClient.postFormData(
      AppConfig.shortVideoCommentUploadUrl,
      data: <String, dynamic>{
        'successCb': callback,
        'storePath': dir,
        'fileId': '${sha1Digest}_1',
        'blockIndex': '1',
        'blockId': sha1Digest,
        'blockCount': '1',
        'blockContent': MultipartFile.fromBytes(
          payload.bytes,
          filename: fileName,
        ),
        'bizId': rid,
        'appId': _shortVideoCommentUploadAppId,
      },
      options: Options(
        contentType: Headers.multipartFormDataContentType,
      ),
    );
    customLogger.log(
      'uploadCommentImage upload response: ${uploadResponse.data}',
    );
    final uploadText = uploadResponse.data?.toString().trim() ?? '';
    if (uploadResponse.statusCode == 200 &&
        (uploadText.isEmpty ||
            uploadText.contains('success') ||
            uploadText.contains('SUCCESS') ||
            uploadText.contains('"code":0'))) {
      return _ShortVideoCommentImageUploadResult(
        isSuccess: true,
        message: '图片上传成功',
        raw: uploadResponse.data,
      );
    }
    return _ShortVideoCommentImageUploadResult(
      isSuccess: true,
      message: '图片上传成功',
      raw: uploadResponse.data,
    );
  } catch (error, stackTrace) {
    customLogger.log('uploadCommentImage failed: $error');
    customLogger.log(stackTrace);
    return _ShortVideoCommentImageUploadResult(
      isSuccess: false,
      message: '图片上传失败，请稍后重试',
      raw: error,
    );
  }
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

ShortVideoCommentSubmitResult _parseCommentSubmitResult(dynamic responseData) {
  if (responseData == 1 || responseData == '1') {
    return const ShortVideoCommentSubmitResult(
      isSuccess: true,
      message: '评论发送成功',
      raw: '1',
    );
  }

  final json = _asMap(responseData);
  if (json.isNotEmpty) {
    final successValues = <dynamic>[
      json['result'],
      json['success'],
      json['code'],
      json['errno'],
      json['status'],
      json['ret'],
    ];
    for (final value in successValues) {
      if (value == true || value == 1 || value == '1' || value == 200 || value == '200') {
        return ShortVideoCommentSubmitResult(
          isSuccess: true,
          message: _pickSubmitMessage(json) ?? '评论发送成功',
          raw: responseData,
        );
      }
    }

    final message = _pickSubmitMessage(json);
    if (message != null && _looksLikeSuccessMessage(message)) {
      return ShortVideoCommentSubmitResult(
        isSuccess: true,
        message: message,
        raw: responseData,
      );
    }

    return ShortVideoCommentSubmitResult(
      isSuccess: false,
      message: message ?? '发表评论失败，请稍后重试',
      raw: responseData,
    );
  }

  final text = responseData?.toString().trim() ?? '';
  if (text == '1') {
    return const ShortVideoCommentSubmitResult(
      isSuccess: true,
      message: '评论发送成功',
      raw: '1',
    );
  }
  if (_looksLikeSuccessMessage(text)) {
    return ShortVideoCommentSubmitResult(
      isSuccess: true,
      message: text.isEmpty ? '评论发送成功' : text,
      raw: responseData,
    );
  }
  return ShortVideoCommentSubmitResult(
    isSuccess: false,
    message: text.isEmpty ? '发表评论失败，请稍后重试' : text,
    raw: responseData,
  );
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

List<String> _extractImageUrls(dynamic rawPics) {
  if (rawPics is! List) {
    return const <String>[];
  }
  final urls = <String>[];
  for (final item in rawPics) {
    String? url;
    if (item is String) {
      url = _asString(item);
    } else if (item is Map<String, dynamic>) {
      url = _asString(item['url']) ??
          _asString(item['pic']) ??
          _asString(item['src']) ??
          _asString(item['origin']);
    } else if (item is Map) {
      final map = item.map((key, value) => MapEntry(key.toString(), value));
      url = _asString(map['url']) ??
          _asString(map['pic']) ??
          _asString(map['src']) ??
          _asString(map['origin']);
    }
    if (url != null && !urls.contains(url)) {
      urls.add(url);
    }
  }
  return List<String>.unmodifiable(urls);
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      return _asMap(decoded);
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, mapValue) => MapEntry(key.toString(), mapValue));
  }
  return const <String, dynamic>{};
}

String? _pickSubmitMessage(Map<String, dynamic> json) {
  final candidates = <dynamic>[
    json['msg'],
    json['message'],
    json['info'],
    json['desc'],
    json['reason'],
  ];
  for (final candidate in candidates) {
    final value = _asString(candidate);
    if (value != null) {
      return value;
    }
  }
  return null;
}

bool _looksLikeSuccessMessage(String text) {
  if (text.isEmpty) {
    return false;
  }
  return text.contains('成功') || text.contains('审核') || text.contains('发表');
}

String? _pickSessionString(
  Map<String, dynamic> source,
  List<String> keys,
) {
  for (final key in keys) {
    final value = _asString(source[key]);
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
