import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_start/app.config.dart';
import 'package:logger/logger.dart';
import 'package:flutter_template_start/utils/IHelper.dart';
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
    double value = (((sourceColor.red * 299.0) +
                (sourceColor.green * 587.0) +
                (sourceColor.blue * 114.0)) /
            1000.0) /
        255.0;
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
          "${(await getApplicationDocumentsDirectory()).path}/${APP_CONFIG.APP_NAME}/.cookies/"),
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
