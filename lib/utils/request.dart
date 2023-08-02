// ignore_for_file: slash_for_doc_comments, constant_identifier_names, camel_case_types

/// 一个包含错误处理，日志，取消请求，动态 Headers，响应数据处理，文件上传和下载，持久化 Cookie，刷新令牌和请求队列和并发控制的Dio封装

import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_template_start/app.config.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:logger/logger.dart';

class DioClient {
  DioClient() {
    _init();
  }

  /// Token 是否正在刷新
  bool isTokenBeingRefreshed = false;

  /// lock 用于锁定dio，防止重复请求
  final requestLock = RequestLock();

  /// 请求队列
  final List<Completer<void>> _pendingRequests = [];

  /// log日志打印
  final logger = Logger(
    printer: PrettyPrinter(),
  );

  /// cancel token
  /// cancelToken.cancel("Request was cancelled by user!");
  final cancelToken = CancelToken();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: APP_CONFIG.BASE_URL,
    connectTimeout: const Duration(seconds: APP_CONFIG.CONNECT_TIMEOUT),
    receiveTimeout: const Duration(seconds: APP_CONFIG.RECEIVE_TIMEOUT),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  /// 初始化函数
  Future<void> _init() async {
    /// 初始化自己的cookie管理器，并设置cookie 持久化
    final myAppCookieManager =
        await MyAppCookieManager.create(APP_CONFIG.BASE_URL);

    /// 拦截器
    _dio.interceptors.addAll(
      [
        CookieManager(myAppCookieManager.cookieJar),
        InterceptorsWrapper(
          onError: (error, handler) async {
            if (error.response?.statusCode == 401) {
              logger.d("401错误");
              if (!isTokenBeingRefreshed) {
                isTokenBeingRefreshed = true;
                requestLock.lock();
                try {
                  final response = await _dio.post(
                    APP_CONFIG.APP_REFRESH_TOKEN_PATH,
                    data: {'refreshToken': APP_CONFIG.APP_REFRESH_TOKEN},
                  );
                  final newToken = response.data['token'];
                  RequestOptions requestOptions =
                      error.response?.requestOptions ??
                          RequestOptions(path: "");
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  Options options = Options(
                    method: requestOptions.method,
                    headers: requestOptions.headers,
                  );
                  return _dio
                      .request(requestOptions.path, options: options)
                      .then((_) {
                    isTokenBeingRefreshed = false;
                    requestLock.unlock();
                    return handler.resolve(_);
                  });
                } catch (e) {
                  isTokenBeingRefreshed = false;
                  requestLock.unlock();
                  logger.d("刷新token失败 $e");
                  return handler.next(error);
                }
              }
            }
            if (error.type == DioExceptionType.unknown) {
              logger.d("可能是一个无效的URL或其他网络问题");
            } else if (error.type == DioExceptionType.connectionTimeout) {
              logger.d("连接超时");
            } else if (error.type == DioExceptionType.sendTimeout) {
              logger.d("请求超时");
            } else if (error.type == DioExceptionType.receiveTimeout) {
              logger.d("响应超时");
            } else if (error.type == DioExceptionType.cancel) {
              logger.d("请求取消");
            } else {
              logger.d("其他错误: ${error.message}");
            }
            return handler.next(error);
          },
          onRequest: (RequestOptions options,
              RequestInterceptorHandler handler) async {
            if (isTokenBeingRefreshed) {
              await requestLock.ensureUnlocked();
            }
            final completer = Completer<void>();
            _pendingRequests.add(completer);
            completer.future.whenComplete(() {
              _pendingRequests.remove(completer);
              if (!isTokenBeingRefreshed && _pendingRequests.isEmpty) {
                requestLock.unlock();
              }
            });
            options.headers['Authorization'] =
                'Bearer Authorization test uhhhhh';
            return handler.next(options);
          },
          onResponse: (Response response, ResponseInterceptorHandler handler) {
            //  _pendingRequests列表中找到第一个未完成的Completer。如果没有找到任何未完成的Completer，它会返回Completer
            _pendingRequests.firstWhere(
              (element) => !element.isCompleted,
              orElse: () => Completer(),
            );
            return handler.next(response);
          },
        ),

        // 拦截哪些日志
        LogInterceptor(
          request: false,
          requestHeader: true,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          error: true,
        ),
      ],
    );
  }

  /// get 请求
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// post 请求
  Future<Response> post(String path,
      {Map<String, dynamic>? data, Options? options}) {
    return _dio.post(
      path,
      data: data,
      cancelToken: cancelToken,
      options: options,
    );
  }

  /// 上传文件
  /**
    dioClient.uploadFiles("/uploadEndpoint", filePaths: ["/path/to/file1.jpg", "/path/to/file2.jpg"], data: {"key": "value"});
  */

  Future<Response> uploadFiles(String path,
      {List<String>? filePaths,
      Map<String, dynamic>? data,
      Options? options}) async {
    var formData = FormData.fromMap(data ?? {});

    if (filePaths != null && filePaths.isNotEmpty) {
      for (var i = 0; i < filePaths.length; i++) {
        String filePath = filePaths[i];
        String fileName = filePath.split('/').last;
        formData.files.add(
          MapEntry('file$i',
              await MultipartFile.fromFile(filePath, filename: fileName)),
        );
      }
    }
    return _dio.post(path,
        data: formData, cancelToken: cancelToken, options: options);
  }

  /// 下载文件
  /**
    downloadFile(
      "your_path_here",
      "your_save_path_here",
      onProgress: (int receivedBytes, int totalBytes) {
        double progressPercent = (receivedBytes / totalBytes) * 100;
        print("下载进度: $progressPercent %");
        // 你也可以在此处进行其他操作，如更新 UI
      },
    );
   */
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required ProgressCallback onProgress,
  }) {
    return _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: options,
    );
  }

  /// put 请求
  Future<Response> put(String path,
      {Map<String, dynamic>? data, Options? options}) {
    return _dio.put(path,
        data: data, cancelToken: cancelToken, options: options);
  }

  /// delete 请求
  Future<Response> delete(String path,
      {Map<String, dynamic>? data, Options? options}) {
    return _dio.delete(path,
        data: data, cancelToken: cancelToken, options: options);
  }
}

/// request lock 实现

class RequestLock {
  final _queue = Queue<Completer>();
  bool _isLocked = false;

  void lock() {
    _isLocked = true;
  }

  void unlock() {
    _isLocked = false;

    while (_queue.isNotEmpty) {
      final nextCompleter = _queue.removeFirst();
      nextCompleter.complete();
    }
  }

  Future<void> ensureUnlocked() async {
    if (_isLocked) {
      final completer = Completer();
      _queue.add(completer);
      await completer.future;
    }
  }
}
