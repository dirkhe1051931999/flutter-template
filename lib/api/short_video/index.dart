import 'package:dio/dio.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _shortVideoFeedUrl = 'https://nine.ifeng.com/recomlist';
const String _phoenixTvChannelUrl = 'https://nine.ifeng.com/phoenixTvChannel';

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

int _shortVideoDailyOpenNumCounter = 0;

int nextShortVideoDailyOpenNum() {
  _shortVideoDailyOpenNumCounter += 1;
  return _shortVideoDailyOpenNumCounter;
}

const Map<String, String> _commonVideoFixedParams = {
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

const Map<String, String> _shortVideoFixedParams = {
  'id': 'RECOMVIDEO',
  'ch': 'sp',
  ..._commonVideoFixedParams,
  'uid': '867241265475337',
  'deviceid': '867241265475337',
  'os': 'android_25',
  'publishid': '6010',
  'hw': 'oppo_pcrt00',
  'st': '16395595277916',
  'sn': 'fcb480832205d27372f8e66d260e69d8',
};

const Map<String, String> _phoenixTvChannelFixedParams = {
  ..._commonVideoFixedParams,
  'dailyOpenNum': '1',
  'uid': '860250745769422',
  'deviceid': '860250745769422',
  'os': 'android_28',
  'publishid': '2011',
  'hw': 'asus_asus_ai2401_a',
  'st': '17787276464257',
  'sn': '5805d8aefff865576632c46fa573537f',
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

ShortVideoItem? _mapToShortVideoItem(Map<String, dynamic> raw) {
  if (raw['type'] != 'phvideo') {
    return null;
  }

  final title = _asString(raw['title']);
  final source = _asString(raw['source']) ?? _asString(raw['subscribe']?['catename']);
  final id = _asString(raw['staticId']) ?? _asString(raw['documentId']);
  final coverUrl = _pickCoverUrl(raw);
  final videoUrl = _pickVideoUrl(raw);
  final updateTime = _pickUpdateTime(raw);

  if (id == null || title == null || videoUrl == null || videoUrl.isEmpty) {
    return null;
  }

  return ShortVideoItem(
    id: id,
    source: source ?? '凤凰网视频',
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

String? _asString(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}
