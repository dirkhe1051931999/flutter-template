import 'package:flutter/foundation.dart';

class AppConfig {
  static const appName = 'FlutterTemplate';
  static const appDescription = 'FlutterTemplate';
  static const appRefreshToken = 'refresh_token';
  static const appRefreshTokenPath = '/refresh_token';
  static const apheliosClientPostAuthorId = '1';
  static const apheliosClientApiBaseUrl = String.fromEnvironment(
    'APHELIOS_CLIENT_API_BASE_URL',
    defaultValue: 'https://mono.oolaf.top/',
  );
  static const oolafMusicCdnBaseUrl = String.fromEnvironment(
    'OOLAF_MUSIC_CDN_BASE_URL',
    defaultValue: 'https://s1.oolaf.top',
  );
  static const shortVideoApiBaseUrl = String.fromEnvironment(
    'SHORT_VIDEO_API_BASE_URL',
    defaultValue: 'https://nine.ifeng.com',
  );
  static const shortVideoCommentApiBaseUrl = String.fromEnvironment(
    'SHORT_VIDEO_COMMENT_API_BASE_URL',
    defaultValue: 'https://comment.ifeng.com',
  );
  static const shortVideoCommentUploadInitUrl = String.fromEnvironment(
    'SHORT_VIDEO_COMMENT_UPLOAD_INIT_URL',
    defaultValue: 'https://ugc.ifeng.com/user/getid',
  );
  static const shortVideoCommentUploadUrl = String.fromEnvironment(
    'SHORT_VIDEO_COMMENT_UPLOAD_URL',
    defaultValue: 'https://transmission.ifeng.com/upload',
  );
  static const hupuGamesBaseUrl = String.fromEnvironment(
    'HUPU_GAMES_BASE_URL',
    defaultValue: 'https://games.mobileapi.hupu.com',
  );
  static const hupuBbsBaseUrl = String.fromEnvironment(
    'HUPU_BBS_BASE_URL',
    defaultValue: 'https://bbs.mobileapi.hupu.com',
  );
  static const shortVideoCommentLToken = String.fromEnvironment(
    'SHORT_VIDEO_COMMENT_LTOKEN',
    defaultValue:
        r'$2kJyeiQHbwIiOiwiIuxGZiojIsICMjRmI6ISesIiIwRmI6IicsIiIyBnIpZ3blNmbiojIiwiI0l2Y6ISesIiIpRmIyR3c0NWaiojI00nIfr34g',
  );
  static const qWeatherBaseUrl = String.fromEnvironment(
    'QWEATHER_BASE_URL',
    defaultValue: 'https://nm359gputx.re.qweatherapi.com',
  );
  static const qWeatherApiKey = String.fromEnvironment(
    'QWEATHER_API_KEY',
    defaultValue: 'be88e6cf8065496ab8e1021babe950de',
  );
  static const proxyEnabled =
      bool.fromEnvironment('PROXY') || bool.fromEnvironment('proxy');
  static const proxyBaseUrl = String.fromEnvironment(
    'PROXY_BASE_URL',
    defaultValue: String.fromEnvironment('url'),
  );
  static const proxyToken = String.fromEnvironment(
    'PROXY_TOKEN',
    defaultValue: String.fromEnvironment('proxyToken'),
  );
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:3101',
  );
  static const connectTimeout = 10;
  static const receiveTimeout = 30;
  static const cookiePath = '/$appName/.cookies/';

  static bool get shouldUseProxy =>
      kIsWeb && proxyEnabled && proxyBaseUrl.trim().isNotEmpty;
}
