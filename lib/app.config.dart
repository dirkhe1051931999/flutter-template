class AppConfig {
  static const appName = 'FlutterTemplate';
  static const appVersion = '1.0.0';
  static const appDescription = 'FlutterTemplate';
  static const appRefreshToken = 'refresh_token';
  static const appRefreshTokenPath = '/refresh_token';
  static const oolafHubBaseUrl = String.fromEnvironment(
    'OOLAF_HUB_BASE_URL',
    defaultValue: 'https://hub.oolaf.top',
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
  static const qWeatherBaseUrl = String.fromEnvironment(
    'QWEATHER_BASE_URL',
    defaultValue: 'https://nm359gputx.re.qweatherapi.com',
  );
  static const qWeatherApiKey = String.fromEnvironment(
    'QWEATHER_API_KEY',
    defaultValue: 'be88e6cf8065496ab8e1021babe950de',
  );
  static const appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const customBaseUrl = String.fromEnvironment('BASE_URL');
  static const developmentBaseUrl = String.fromEnvironment(
    'DEV_BASE_URL',
    defaultValue: 'https://aphelios-api.oolaf.top',
  );
  static const testBaseUrl = String.fromEnvironment('TEST_BASE_URL');
  static const productionBaseUrl = String.fromEnvironment(
    'PROD_BASE_URL',
    defaultValue: 'https://aphelios-api.oolaf.top',
  );
  static const connectTimeout = 10;
  static const receiveTimeout = 30;
  static const cookiePath = '/$appName/.cookies/';

  static String get baseUrl {
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }

    return switch (appEnv) {
      'development' => developmentBaseUrl,
      'test' => _requiredBaseUrl(testBaseUrl, 'TEST_BASE_URL'),
      'production' => _requiredBaseUrl(productionBaseUrl, 'PROD_BASE_URL'),
      _ => throw UnsupportedError('Unsupported APP_ENV: $appEnv'),
    };
  }

  static String _requiredBaseUrl(String value, String envName) {
    if (value.isEmpty) {
      throw StateError('$envName is required when APP_ENV=$appEnv');
    }

    return value;
  }
}
