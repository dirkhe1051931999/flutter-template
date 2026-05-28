import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _hupuSalt = 'HUPU_SALT_AKJfoiwer394Jeiow4u309';

class HupuHotListResponse {
  const HupuHotListResponse({
    required this.items,
    required this.notice,
    required this.isEmpty,
  });

  final List<HupuFeedItem> items;
  final String notice;
  final bool isEmpty;

  factory HupuHotListResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu payload');
    }

    return HupuHotListResponse(
      items: _parseFeedItems(result['data']),
      notice: result['notice']?.toString() ?? '',
      isEmpty: result['empty'] == true,
    );
  }
}

class HupuFeedItem {
  const HupuFeedItem({
    required this.xid,
    required this.label,
    required this.schemaUrl,
    required this.type,
    required this.itemId,
    required this.tid,
    required this.title,
    required this.summary,
    required this.nickname,
    required this.header,
    required this.forumName,
    required this.topicName,
    required this.createTime,
    required this.lastPostTime,
    required this.replies,
    required this.lights,
    required this.shareNum,
    required this.visits,
    required this.pics,
    required this.lightReplies,
    required this.video,
  });

  final String xid;
  final String label;
  final String schemaUrl;
  final String type;
  final String itemId;
  final String tid;
  final String title;
  final String summary;
  final String nickname;
  final String header;
  final String forumName;
  final String topicName;
  final int createTime;
  final int lastPostTime;
  final int replies;
  final int lights;
  final int shareNum;
  final int visits;
  final List<HupuImageItem> pics;
  final List<HupuLightReply> lightReplies;
  final HupuVideoItem? video;

  String get uniqueKey => itemId.isNotEmpty ? itemId : xid;

  factory HupuFeedItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final payload = data is Map<String, dynamic> ? data : const <String, dynamic>{};

    return HupuFeedItem(
      xid: json['xid']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      schemaUrl: json['schema_url']?.toString() ?? '',
      type: payload['type']?.toString() ?? json['type']?.toString() ?? '',
      itemId: payload['itemId']?.toString() ?? json['itemId']?.toString() ?? '',
      tid: payload['tid']?.toString() ?? '',
      title: payload['title']?.toString() ?? '',
      summary: payload['summary']?.toString() ?? '',
      nickname: payload['nickname']?.toString() ?? '',
      header: payload['header']?.toString() ?? '',
      forumName: payload['forum_name']?.toString() ?? '',
      topicName: payload['topic_name']?.toString() ?? '',
      createTime: _parseInt(payload['create_time']),
      lastPostTime: _parseInt(payload['lastpost_time']),
      replies: _parseInt(payload['replies']),
      lights: _parseInt(payload['lights']),
      shareNum: _parseInt(payload['share_num']),
      visits: _parseInt(payload['visits']),
      pics: _parseImageItems(payload['pics']),
      lightReplies: _parseLightReplies(payload['light_replies']),
      video: payload['video'] is Map<String, dynamic>
          ? HupuVideoItem.fromJson(payload['video'] as Map<String, dynamic>)
          : null,
    );
  }
}

class HupuImageItem {
  const HupuImageItem({
    required this.url,
    required this.width,
    required this.height,
    required this.type,
  });

  final String url;
  final double width;
  final double height;
  final String type;

  factory HupuImageItem.fromJson(Map<String, dynamic> json) {
    return HupuImageItem(
      url: json['url']?.toString() ?? '',
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),
      type: json['type']?.toString() ?? '',
    );
  }
}

class HupuLightReply {
  const HupuLightReply({
    required this.nickname,
    required this.content,
    required this.header,
    required this.lightCount,
    required this.pics,
    required this.quoteNickname,
    required this.quoteContent,
  });

  final String nickname;
  final String content;
  final String header;
  final int lightCount;
  final List<HupuImageItem> pics;
  final String quoteNickname;
  final String quoteContent;

  factory HupuLightReply.fromJson(Map<String, dynamic> json) {
    final quote = json['quote'];

    return HupuLightReply(
      nickname: json['nickname']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      lightCount: _parseInt(json['light_count']),
      pics: _parseImageItems(json['pics']),
      quoteNickname: quote is Map<String, dynamic>
          ? quote['nickname']?.toString() ?? ''
          : '',
      quoteContent: quote is Map<String, dynamic>
          ? quote['content']?.toString() ?? ''
          : '',
    );
  }
}

class HupuVideoItem {
  const HupuVideoItem({
    required this.cover,
    required this.duration,
    required this.playCount,
  });

  final String cover;
  final String duration;
  final String playCount;

  factory HupuVideoItem.fromJson(Map<String, dynamic> json) {
    return HupuVideoItem(
      cover: json['img']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      playCount: json['play_num']?.toString() ?? '',
    );
  }
}

Future<HupuHotListResponse> getHupuHotList({
  required bool isFirst,
  required bool isRefresh,
}) async {
  final queryParameters = <String, String>{
    'is_first': isFirst ? '1' : '0',
    'is_refresh': isRefresh ? '1' : '0',
    'deviceRegisterTime': '',
    'ab_items': '1',
    'puid': '0',
    'personalized': '1',
    'clientId': '174865444',
    'crt': '1779962471925',
    'night': '0',
    'channel': 'wandoujia',
    'client': 'bc9e1ef8570ddf7e',
    '_ssid': 'PHVua25vd24gc3NpZD4=',
    '_imei': 'bc9e1ef8570ddf7e',
    'android_id': 'bc9e1ef8570ddf7e',
    'time_zone': 'Asia/Shanghai',
    'deviceId': 'BHSHUue6eR8rYvoib0Qy4I8IE5PG8/LWFCIdPwp2qYat891x8RjOXItQM1tuvSMmwCQYI9ibVYg4Pqtg5AjPrDQ==',
  };

  queryParameters['sign'] = _buildHupuSign(queryParameters);

  final response = await hupuClient.get(
    '/1/8.0.32/buffer/hotList',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  final bytes = response.data;
  if (bytes is! List<int>) {
    throw StateError('Unexpected Hupu response bytes');
  }

  final decoded = jsonDecode(utf8.decode(bytes));
  if (decoded is! Map<String, dynamic>) {
    throw StateError('Unexpected Hupu response payload');
  }

  return HupuHotListResponse.fromJson(decoded);
}

String _buildHupuSign(Map<String, String> queryParameters) {
  final keys = queryParameters.keys.toList()..sort();
  final content = keys.map((key) => "$key=${queryParameters[key] ?? ''}").join('&');
  return md5.convert(utf8.encode('$content$_hupuSalt')).toString();
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<HupuFeedItem> _parseFeedItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuFeedItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuFeedItem.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<HupuImageItem> _parseImageItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuImageItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuImageItem.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<HupuLightReply> _parseLightReplies(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuLightReply>[];
  }

  return rawItems
      .whereType<Map>()
      .map((item) => HupuLightReply.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}
