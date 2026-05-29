import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsSdk {
  AnalyticsSdk._();

  static const String _distinctIdKey = 'analytics_distinct_id_v1';
  static final AnalyticsSdk instance = AnalyticsSdk._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.analyticsBaseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: const {
        'Content-Type': 'application/json',
      },
    ),
  );
  final Logger _logger = Logger();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _distinctId;
  String? _sessionId;
  String? _appVersion;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _appVersion = await _loadAppVersion();
    _distinctId = await _loadOrCreateDistinctId();
    _sessionId = _newSessionId();
    _initialized = true;
  }

  Future<void> track({
    required String eventName,
    Map<String, dynamic>? properties,
    String? pageUrl,
    String? ingestSource,
  }) async {
    if (!AppConfig.analyticsEnabled) {
      return;
    }
    final trimmedEventName = eventName.trim();
    if (trimmedEventName.isEmpty) {
      return;
    }

    await init();
    final session = await IfengAuthStorage.loadSession();
    final payload = <String, dynamic>{
      'event_name': trimmedEventName,
      'distinct_id': _distinctId ?? 'windows_unknown',
      'user_id': session.guid.trim(),
      'session_id': _sessionId ?? _newSessionId(),
      'trace_id': _newTraceId(),
      'page_url': pageUrl?.trim() ?? '',
      'event_time': DateTime.now().toUtc().toIso8601String(),
      'ingest_source': ingestSource ?? 'flutter_windows_sdk',
      'device_type': await _deviceType(),
      'os_name': await _osName(),
      'browser_name': '',
      'properties': <String, dynamic>{
        'platform': defaultTargetPlatform.name,
        'app_version': _appVersion ?? AppConfig.appVersion,
        if (properties != null) ...properties,
      },
    };

    try {
      await _dio.post(
        '/api/v1/public/ingest',
        data: payload,
        options: Options(
          headers: <String, dynamic>{
            'X-Ingest-Token': AppConfig.analyticsIngestToken,
          },
        ),
      );
    } catch (error, stackTrace) {
      _logger.w(
        'analytics track failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> _loadOrCreateDistinctId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_distinctIdKey)?.trim() ?? '';
    if (existing.isNotEmpty) {
      return existing;
    }
    final created = 'windows_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString(_distinctIdKey, created);
    return created;
  }

  Future<String> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return AppConfig.appVersion;
    }
  }

  Future<String> _deviceType() async {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return 'desktop';
    }
    return defaultTargetPlatform.name;
  }

  Future<String> _osName() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.windows) {
        final info = await _deviceInfo.windowsInfo;
        return 'windows_${info.majorVersion}.${info.minorVersion}.${info.buildNumber}';
      }
    } catch (_) {}
    return defaultTargetPlatform.name;
  }

  String _newSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _newTraceId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final micros = DateTime.now().microsecondsSinceEpoch;
    return 'trace_${millis}_$micros';
  }
}

String analyticsPrettyJson(Map<String, dynamic> value) {
  return const JsonEncoder.withIndent('  ').convert(value);
}
