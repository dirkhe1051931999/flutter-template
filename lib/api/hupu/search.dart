import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/hupu/common.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<List<HupuSearchHotKeyword>> getHupuSearchHotKeywords() async {
  final queryParameters = <String, String>{
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  queryParameters['sign'] = buildHupuSign(queryParameters);

  final response = await hupuGamesClient.get(
    '/1/8.0.32/search/v2/hotkeylist',
    queryParameters: queryParameters,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  final json = decodeHupuJson(response.data);
  final result = json['result'];
  if (result is! Map<String, dynamic>) {
    throw StateError('Unexpected Hupu hot keyword payload');
  }

  return parseHupuSearchHotKeywords(result['list']);
}

Future<HupuSearchResponse> searchHupuAll({
  required String keyword,
}) async {
  final body = _buildSearchRequestBody(keyword: keyword);
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/all',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchResponse.fromJson(decodeHupuJson(response.data));
}

Future<HupuSearchPostPage> searchHupuPosts({
  required String keyword,
  required int page,
}) async {
  final body = _buildSearchRequestBody(
    keyword: keyword,
    page: page,
    type: 'posts',
  );
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/all',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchPostPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuSearchPostListPage> searchHupuPostList({
  required String keyword,
  int page = 1,
  String postSort = 'general',
}) async {
  final body = _buildSearchRequestBody(
    keyword: keyword,
    page: page,
    type: 'posts',
    extra: <String, String>{
      'fid': '0',
      'topic_id': '0',
      'postSort': postSort,
    },
  );
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/list',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchPostListPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuSearchTopicListPage> searchHupuTopicList({
  required String keyword,
  int page = 1,
}) async {
  final body = _buildSearchRequestBody(
    keyword: keyword,
    page: page,
    type: 'bbsTag',
  );
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/list',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchTopicListPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuSearchUserListPage> searchHupuUserList({
  required String keyword,
  int page = 1,
}) async {
  final body = _buildSearchRequestBody(
    keyword: keyword,
    page: page,
    type: 'users',
  );
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/list',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchUserListPage.fromJson(decodeHupuJson(response.data));
}

Future<HupuSearchUserPage> searchHupuUsers({
  required String keyword,
  required int page,
}) async {
  final body = _buildSearchRequestBody(
    keyword: keyword,
    page: page,
    type: 'users',
  );
  final response = await hupuGamesClient.post(
    '/1/8.0.32/search/all',
    data: body,
    options: Options(
      responseType: ResponseType.bytes,
      headers: const <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  return HupuSearchUserPage.fromJson(decodeHupuJson(response.data));
}

Map<String, dynamic> _buildSearchRequestBody({
  required String keyword,
  int? page,
  String? type,
  Map<String, String>? extra,
}) {
  final body = <String, String>{
    'puid': '0',
    'keyword': keyword,
    ...createHupuCommonQueryParameters(
      crt: '${DateTime.now().millisecondsSinceEpoch}',
    ),
  };
  if (page != null) {
    body['page'] = '$page';
  }
  if (type != null && type.trim().isNotEmpty) {
    body['type'] = type;
  }
  if (extra != null && extra.isNotEmpty) {
    body.addAll(extra);
  }
  body['sign'] = buildHupuSign(body);
  return body;
}
