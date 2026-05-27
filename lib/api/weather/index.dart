import 'package:dio/dio.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/model/weather/types/weather_air_quality.dart';
import 'package:oolaf_flutted/model/weather/types/weather_indices_forecast.dart';
import 'package:oolaf_flutted/model/weather/types/weather_warning.dart';
import 'package:oolaf_flutted/utils/request.dart';

Options _createQWeatherOptions() {
  return Options(
    headers: {
      'X-QW-Api-Key': AppConfig.qWeatherApiKey,
    },
  );
}

Map<String, dynamic> _requireQWeatherPayload(
  dynamic data, {
  required String errorMessage,
}) {
  if (data is! Map<String, dynamic>) {
    throw StateError(errorMessage);
  }

  return data;
}

Future<WeatherDailyForecastResponse> getWeatherDailyForecast({
  required WeatherCity city,
  String days = '3d',
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/v7/weather/$days',
    queryParameters: {
      'location': city.locationCode,
    },
    options: _createQWeatherOptions(),
  );

  final weatherResponse = WeatherDailyForecastResponse.fromJson(
    _requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError('QWeather request failed with code ${weatherResponse.code}');
  }

  return weatherResponse;
}

Future<WeatherAirQualityResponse> getWeatherAirQuality({
  required WeatherCity city,
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/airquality/v1/current/${city.latitude}/${city.longitude}',
    options: _createQWeatherOptions(),
  );

  return WeatherAirQualityResponse.fromJson(
    _requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather air quality response payload',
    ),
  );
}

Future<WeatherWarningResponse> getWeatherWarning({
  required WeatherCity city,
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/weatheralert/v1/current/${city.latitude}/${city.longitude}',
    queryParameters: {
      'localTime': 'true',
    },
    options: _createQWeatherOptions(),
  );

  return WeatherWarningResponse.fromJson(
    _requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather warning response payload',
    ),
  );
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

  final weatherResponse = WeatherHourlyForecastResponse.fromJson(
    _requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather hourly response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError('QWeather hourly request failed with code ${weatherResponse.code}');
  }

  return weatherResponse;
}

Future<WeatherIndicesForecastResponse> getWeatherIndicesForecast({
  required WeatherCity city,
  String days = '1d',
  List<String> typeIds = const ['1', '2', '3', '5'],
}) async {
  if (AppConfig.qWeatherApiKey.isEmpty) {
    throw StateError('QWEATHER_API_KEY is required');
  }

  final response = await qWeatherClient.get(
    '/v7/indices/$days',
    queryParameters: {
      'location': city.locationCode,
      'type': typeIds.join(','),
    },
    options: _createQWeatherOptions(),
  );

  final weatherResponse = WeatherIndicesForecastResponse.fromJson(
    _requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather indices response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError('QWeather indices request failed with code ${weatherResponse.code}');
  }

  return weatherResponse;
}
