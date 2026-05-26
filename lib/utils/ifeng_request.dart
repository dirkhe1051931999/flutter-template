import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
import 'package:oolaf_flutted/utils/request.dart';

const String _ifengIdBaseUrl = 'https://id.ifeng.com';
const String _ifengUserBaseUrl = 'https://user.iclient.ifeng.com';

const Map<String, String> _ifengCommonQueryParameters = {
  'gv': '7.30.3',
  'av': '7.30.3',
  'uid': '867241265475337',
  'deviceid': '867241265475337',
  'proid': 'ifengnews',
  'os': 'android_25',
  'df': 'androidphone',
  'vt': '5',
  'screen': '720x1280',
  'publishid': '6010',
  'nw': 'wifi',
  'loginid': '',
  'adAid': '',
  'hw': 'oppo_pcrt00',
  'ps': '1',
  'st': '16395595277916',
  'sn': 'fcb480832205d27372f8e66d260e69d8',
};

class IfengRequestClients {
  IfengRequestClients._();

  static final DioClient idClient = DioClient(baseUrl: _ifengIdBaseUrl);
  static final DioClient userClient = DioClient(baseUrl: _ifengUserBaseUrl);
}

class IfengRequestOptions {
  const IfengRequestOptions({
    this.includeAuth = true,
    this.extraQueryParameters,
  });

  final bool includeAuth;
  final Map<String, dynamic>? extraQueryParameters;
}

Future<Map<String, dynamic>> buildIfengQueryParameters({
  required IfengRequestOptions options,
}) async {
  final merged = <String, dynamic>{
    ..._ifengCommonQueryParameters,
  };

  if (options.extraQueryParameters != null) {
    merged.addAll(options.extraQueryParameters!);
  }

  if (!options.includeAuth) {
    return merged;
  }

  final session = await IfengAuthStorage.loadSession();
  if (!session.isLoggedIn) {
    return merged;
  }

  merged.addAll(<String, dynamic>{
    'token': session.token,
    'guid': session.guid,
    'loginid': session.guid,
    'username': session.username,
  });
  return merged;
}

Future<Response<dynamic>> ifengPostForm(
  DioClient client,
  String path, {
  Map<String, dynamic>? formData,
  IfengRequestOptions options = const IfengRequestOptions(),
}) async {
  final queryParameters = await buildIfengQueryParameters(options: options);
  return client.postFormData(
    _buildPathWithQuery(path, queryParameters),
    data: formData,
    options: Options(
      contentType: Headers.multipartFormDataContentType,
    ),
  );
}

Future<Response<dynamic>> ifengPost(
  DioClient client,
  String path, {
  Map<String, dynamic>? data,
  IfengRequestOptions options = const IfengRequestOptions(),
}) async {
  final queryParameters = await buildIfengQueryParameters(options: options);
  return client.post(
    _buildPathWithQuery(path, queryParameters),
    data: data,
  );
}

Future<Response<dynamic>> ifengPostWithQuery(
  DioClient client,
  String path, {
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? data,
  IfengRequestOptions options = const IfengRequestOptions(),
}) async {
  final mergedQuery = await buildIfengQueryParameters(
    options: IfengRequestOptions(
      includeAuth: options.includeAuth,
      extraQueryParameters: queryParameters,
    ),
  );
  return client.post(
    _buildPathWithQuery(path, mergedQuery),
    data: data,
  );
}

String encodeCaptchaPositions(List<Map<String, dynamic>> positions) {
  return jsonEncode(positions);
}

String _buildPathWithQuery(String path, Map<String, dynamic> queryParameters) {
  final encodedQuery = queryParameters.entries
      .map(
        (entry) =>
            '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value.toString())}',
      )
      .join('&');
  if (encodedQuery.isEmpty) {
    return path;
  }
  return '$path?$encodedQuery';
}
