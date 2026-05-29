import 'package:dio/dio.dart';
import 'package:oolaf_flutted/app.config.dart';

Options createQWeatherOptions() {
  return Options(
    headers: {
      'X-QW-Api-Key': AppConfig.qWeatherApiKey,
    },
  );
}

Map<String, dynamic> requireQWeatherPayload(
  dynamic data, {
  required String errorMessage,
}) {
  if (data is! Map<String, dynamic>) {
    throw StateError(errorMessage);
  }

  return data;
}

void ensureQWeatherApiKey() {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }
}
