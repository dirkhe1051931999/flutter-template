import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/tools/developer_tools_center.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:logger/logger.dart';

typedef TokenGetter = FutureOr<String?> Function();
typedef TokenSetter = FutureOr<void> Function(String token);
typedef RefreshTokenGetter = FutureOr<String?> Function();

final httpClient = DioClient(baseUrl: AppConfig.baseUrl);
final oolafHubClient = DioClient(baseUrl: AppConfig.oolafHubBaseUrl);
final qWeatherClient = DioClient(baseUrl: AppConfig.qWeatherBaseUrl);

class DioClient {
  DioClient({
    required this.baseUrl,
    TokenGetter? getAccessToken,
    RefreshTokenGetter? getRefreshToken,
    TokenSetter? saveAccessToken,
  })  : _getAccessToken = getAccessToken,
        _getRefreshToken = getRefreshToken,
        _saveAccessToken = saveAccessToken,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: AppConfig.connectTimeout),
            receiveTimeout: const Duration(seconds: AppConfig.receiveTimeout),
            headers: const {
              'Content-Type': 'application/json',
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10; Redmi K30 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.101 Mobile Safari/537.36',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onRequest: _handleRequest,
        onError: _handleError,
      ),
      LogInterceptor(
        request: false,
        requestHeader: true,
        requestBody: false,
        responseBody: false,
        responseHeader: false,
        error: true,
      ),
    ]);
    _cookieReady = _setupCookieManager();
  }

  void _recordRequestLog({
    required RequestOptions requestOptions,
    Response<dynamic>? response,
    String errorMessage = '',
  }) {
    final startedAt = requestOptions.extra['devtools_request_started_at'];
    final started = startedAt is DateTime ? startedAt : null;
    final now = DateTime.now();
    final durationMs = started == null ? null : now.difference(started).inMilliseconds;

    DeveloperToolsCenter.instance.recordRequest(
      DeveloperRequestLog(
        time: now,
        method: requestOptions.method,
        url: requestOptions.uri.toString(),
        statusCode: response?.statusCode,
        durationMs: durationMs,
        requestSummary: _summarizePayload(requestOptions.data ?? requestOptions.queryParameters),
        responseSummary: _summarizePayload(response?.data),
        errorMessage: errorMessage,
      ),
    );
  }

  String _summarizePayload(dynamic payload) {
    if (payload == null) {
      return '';
    }
    final text = payload.toString();
    if (text.length <= 180) {
      return text;
    }
    return '${text.substring(0, 180)}...';
  }

  final String baseUrl;
  final Dio _dio;
  final TokenGetter? _getAccessToken;
  final RefreshTokenGetter? _getRefreshToken;
  final TokenSetter? _saveAccessToken;

  final logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<void>? _refreshingToken;
  Future<void>? _cookieReady;

  Future<void> get ready async {
    await _cookieReady;
  }

  Future<void> _setupCookieManager() async {
    if (!kIsWeb) {
      final myAppCookieManager = await MyAppCookieManager.create(baseUrl);
      _dio.interceptors.insert(0, CookieManager(myAppCookieManager.cookieJar));
    }
  }

  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await ready;

    final token = await _getAccessToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.extra['devtools_request_started_at'] = DateTime.now();

    handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    _recordRequestLog(
      requestOptions: error.requestOptions,
      response: error.response,
      errorMessage: error.message ?? error.error?.toString() ?? 'unknown error',
    );
    _logDioError(error);

    final requestOptions = error.requestOptions;
    final hasRetried = requestOptions.extra['retried'] == true;
    final skipAuthRetry = requestOptions.extra['skipAuthRetry'] == true;

    if (error.response?.statusCode != 401 || hasRetried || skipAuthRetry) {
      handler.next(error);
      return;
    }

    try {
      await _refreshTokenOnce();
      final response = await _retry(requestOptions);
      handler.resolve(response);
    } catch (refreshError) {
      logger.d('?? token ?? $refreshError');
      handler.next(error);
    }
  }

  Future<void> _refreshTokenOnce() {
    final currentRefreshing = _refreshingToken;
    if (currentRefreshing != null) {
      return currentRefreshing;
    }

    final refreshing = _refreshToken();
    _refreshingToken = refreshing;
    refreshing.whenComplete(() {
      _refreshingToken = null;
    });
    return refreshing;
  }

  Future<void> _refreshToken() async {
    final refreshToken =
        await _getRefreshToken?.call() ?? AppConfig.appRefreshToken;

    final response = await _dio.post(
      AppConfig.appRefreshTokenPath,
      data: {'refreshToken': refreshToken},
      options: Options(extra: {'skipAuthRetry': true}),
    );

    final newToken = _pickToken(response.data);
    if (newToken == null || newToken.isEmpty) {
      throw StateError('?? token ?????? token');
    }

    await _saveAccessToken?.call(newToken);
  }

  String? _pickToken(dynamic data) {
    if (data is Map<String, dynamic>) {
      final token =
          data['token'] ?? data['accessToken'] ?? data['access_token'];
      if (token is String) {
        return token;
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedToken = nestedData['token'] ??
            nestedData['accessToken'] ??
            nestedData['access_token'];
        if (nestedToken is String) {
          return nestedToken;
        }
      }
    }
    return null;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    final extra = Map<String, dynamic>.from(requestOptions.extra);

    extra['retried'] = true;

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      options: Options(
        method: requestOptions.method,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: extra,
        headers: headers,
        responseType: requestOptions.responseType,
        contentType: requestOptions.contentType,
        validateStatus: requestOptions.validateStatus,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  void _logDioError(DioException error) {
    if (error.type == DioExceptionType.unknown) {
      logger.d('????????URL???????');
    } else if (error.type == DioExceptionType.connectionTimeout) {
      logger.d('????');
    } else if (error.type == DioExceptionType.sendTimeout) {
      logger.d('????');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      logger.d('????');
    } else if (error.type == DioExceptionType.cancel) {
      logger.d('????');
    } else {
      logger.d('????: ${error.message}');
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> post(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.post(
      path,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> postFormData(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.post(
      path,
      data: FormData.fromMap(data ?? {}),
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> uploadFiles(
    String path, {
    List<String>? filePaths,
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final formData = FormData.fromMap(data ?? {});

    if (filePaths != null && filePaths.isNotEmpty) {
      for (var i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final fileName = filePath.split('/').last;
        formData.files.add(
          MapEntry(
            'file$i',
            await MultipartFile.fromFile(filePath, filename: fileName),
          ),
        );
      }
    }

    final response = await _dio.post(
      path,
      data: formData,
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required ProgressCallback onProgress,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> put(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.put(
      path,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    await ready;
    final response = await _dio.delete(
      path,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
    _recordRequestLog(requestOptions: response.requestOptions, response: response);
    return response;
  }
}
