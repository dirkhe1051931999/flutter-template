import 'package:dio/dio.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Options _createQWeatherOptions() {
  return Options(
    headers: {
      'X-QW-Api-Key': AppConfig.qWeatherApiKey,
    },
  );
}

Future<WeatherDailyForecastResponse> getWeatherDailyForecast({
  required WeatherCity city,
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/v7/weather/7d',
    queryParameters: {
      'location': city.locationCode,
    },
    options: _createQWeatherOptions(),
  );

  if (response.data is! Map<String, dynamic>) {
    throw StateError('Unexpected QWeather response payload');
  }

  final weatherResponse = WeatherDailyForecastResponse.fromJson(
    response.data as Map<String, dynamic>,
  );

  if (weatherResponse.code != '200') {
    throw StateError('QWeather request failed with code ${weatherResponse.code}');
  }

  return weatherResponse;
}

Future<WeatherHourlyForecastResponse> getWeatherHourlyForecast({
  required WeatherCity city,
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/v7/weather/24h',
    queryParameters: {
      'location': city.locationCode,
    },
    options: _createQWeatherOptions(),
  );

  if (response.data is! Map<String, dynamic>) {
    throw StateError('Unexpected QWeather hourly response payload');
  }

  final weatherResponse = WeatherHourlyForecastResponse.fromJson(
    response.data as Map<String, dynamic>,
  );

  if (weatherResponse.code != '200') {
    throw StateError('QWeather hourly request failed with code ${weatherResponse.code}');
  }

  return weatherResponse;
}
