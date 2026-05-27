import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:logger/logger.dart';
import 'package:oolaf_flutted/utils/IHelper.dart';
import 'package:path_provider/path_provider.dart';

/// 一些需要初始化的工具类
final customLogger = MyLogger();

class ColorHelpers {
  static int fromHexString(String argbHexString) {
    String useString = argbHexString;
    if (useString.startsWith("#")) {
      useString = useString.substring(1);
    }
    if (useString.length < 8) {
      useString = "FF$useString";
    }
    if (!useString.startsWith("0x")) {
      useString = "0x$useString";
    }
    return int.parse(useString);
  }

  static const double _kMinContrastModifierRange = 0.35;
  static const double _kMaxContrastModifierRange = 0.65;

  /// 根据源颜色是否较暗返回黑色或白色
  /// 或更轻。如果较暗，将返回白色。如果较轻，将返回
  /// 黑色的。如果颜色在光谱的 35-65% 范围内并且更喜欢
  /// 指定值，则首选白色或黑色。
  static Color blackOrWhiteContrastColor(Color sourceColor,
      {ContrastPreference prefer = ContrastPreference.none}) {
    // Will return a value between 0.0 (black) and 1.0 (white)
    final red = (sourceColor.r * 255.0).round().clamp(0, 255);
    final green = (sourceColor.g * 255.0).round().clamp(0, 255);
    final blue = (sourceColor.b * 255.0).round().clamp(0, 255);
    double value =
        (((red * 299.0) + (green * 587.0) + (blue * 114.0)) / 1000.0) / 255.0;
    if (prefer != ContrastPreference.none) {
      if (value >= _kMinContrastModifierRange &&
          value <= _kMaxContrastModifierRange) {
        return prefer == ContrastPreference.light
            ? const Color(0xFFFFFFFF)
            : const Color(0xFF000000);
      }
    }
    return value > 0.6 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }
}

class MyLogger {
  final logger = Logger(
    printer: PrettyPrinter(), // 使用 PrettyPrinter 作为日志打印机
  );

  void log(dynamic message) {
    logger.i(message);
  }

  void error(dynamic message) {
    logger.e(message);
  }
}

class MyAppCookieManager {
  late final PersistCookieJar cookieJar;
  final String baseUrl;
  // 私有构造函数_
  MyAppCookieManager._(this.baseUrl);
  // 异步的工厂构造函数 MyAppCookieManager.create
  static Future<MyAppCookieManager> create(String baseUrl) async {
    var manager = MyAppCookieManager._(baseUrl);
    await manager._initCookieJar();
    return manager;
  }

  Future<void> _initCookieJar() async {
    cookieJar = PersistCookieJar(
      storage: FileStorage(
          "${(await getApplicationDocumentsDirectory()).path}/${AppConfig.appName}/.cookies/"),
    );
  }

  // 增
  /// myAppCookieManager.setCookie('cookieName', 'cookieValue', millisecondsToExpire: 24 * 60 * 60 * 1000);
  void setCookie(String name, String value, {int? millisecondsToExpire}) {
    var expiryDate = millisecondsToExpire != null
        ? DateTime.now().add(Duration(milliseconds: millisecondsToExpire))
        : null;

    var cookie = Cookie(name, value)
      ..domain = Uri.parse(baseUrl).host
      ..path = '/'
      ..expires = expiryDate;

    cookieJar.saveFromResponse(Uri.parse(baseUrl), [cookie]);
  }

  /// 查
  /// var cookies = await myAppCookieManager.getCookies();
  Future<List<Cookie>> getCookies() async {
    return cookieJar.loadForRequest(Uri.parse(baseUrl));
  }

  /// 改 (与设置相同，只需要使用同名覆盖)
  /// myAppCookieManager.updateCookie('cookieName', 'cookieValue2', millisecondsToExpire: 24 * 60 * 60 * 1000);
  void updateCookie(String name, String value, {int? millisecondsToExpire}) {
    setCookie(name, value, millisecondsToExpire: millisecondsToExpire);
  }

  /// 删
  /// myAppCookieManager.removeCookie('cookieName');
  Future<void> removeCookie(String name) async {
    var cookies = await getCookies();
    var updatedCookies =
        cookies.where((cookie) => cookie.name != name).toList();
    cookieJar.delete(Uri.parse(baseUrl));
    cookieJar.saveFromResponse(Uri.parse(baseUrl), updatedCookies);
  }
}

String? formatRelativeCommentTime(
  dynamic primaryValue, {
  dynamic secondaryValue,
  dynamic fallbackValue,
  DateTime? now,
}) {
  final publishAt = parseFlexibleDateTime(primaryValue) ??
      parseFlexibleDateTime(secondaryValue) ??
      parseFlexibleDateTime(fallbackValue);
  if (publishAt == null) {
    return _asNonEmptyString(primaryValue) ??
        _asNonEmptyString(secondaryValue) ??
        _asNonEmptyString(fallbackValue);
  }

  final currentTime = now ?? DateTime.now();
  final localPublishAt = publishAt.isUtc ? publishAt.toLocal() : publishAt;
  final diff = currentTime.difference(localPublishAt);
  final startOfToday = DateTime(
    currentTime.year,
    currentTime.month,
    currentTime.day,
  );
  final startOfPublishDay = DateTime(
    localPublishAt.year,
    localPublishAt.month,
    localPublishAt.day,
  );
  final dayDiff = startOfToday.difference(startOfPublishDay).inDays;

  if (dayDiff == 0) {
    if (!diff.isNegative && diff < const Duration(minutes: 1)) {
      return '刚刚';
    }
    return formatHourMinute(localPublishAt);
  }

  if (dayDiff == 1) {
    return '昨天 ${formatHourMinute(localPublishAt)}';
  }

  if (dayDiff == 2) {
    return '前天 ${formatHourMinute(localPublishAt)}';
  }

  if (localPublishAt.year == currentTime.year) {
    return '${pad2(localPublishAt.month)}-${pad2(localPublishAt.day)}';
  }

  return '${localPublishAt.year}-${pad2(localPublishAt.month)}-${pad2(localPublishAt.day)}';
}

DateTime? parseFlexibleDateTime(dynamic value) {
  if (value is int) {
    return _dateTimeFromEpoch(value);
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final epochValue = int.tryParse(trimmed);
    if (epochValue != null) {
      return _dateTimeFromEpoch(epochValue);
    }

    final normalized = trimmed.replaceAll('/', '-');
    final parsed = DateTime.tryParse(normalized);
    if (parsed != null) {
      return parsed;
    }

    final withSpace = normalized.replaceFirst(' ', 'T');
    return DateTime.tryParse(withSpace);
  }
  return null;
}

String formatHourMinute(DateTime value) {
  return '${pad2(value.hour)}:${pad2(value.minute)}';
}

String pad2(int value) {
  return value.toString().padLeft(2, '0');
}

DateTime? _dateTimeFromEpoch(int value) {
  if (value <= 0) {
    return null;
  }
  final isMilliseconds = value.abs() >= 1000000000000;
  return DateTime.fromMillisecondsSinceEpoch(
    isMilliseconds ? value : value * 1000,
  );
}

String? _asNonEmptyString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

/// 递归更新 Map
Map<String, dynamic> recursiveMerge(
    Map<String, dynamic> original, Map<String, dynamic> changes) {
  Map<String, dynamic> result = Map.from(original);

  for (String key in changes.keys) {
    if (changes[key] is Map && original[key] is Map) {
      result[key] = recursiveMerge(original[key], changes[key]);
    } else {
      result[key] = changes[key];
    }
  }

  return result;
}
