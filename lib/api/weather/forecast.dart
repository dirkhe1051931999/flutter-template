import 'package:oolaf_flutted/api/weather/common.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<WeatherDailyForecastResponse> getWeatherDailyForecast({
  required WeatherCity city,
  String days = '3d',
}) async {
  ensureQWeatherApiKey();

  final response = await qWeatherClient.get(
    '/v7/weather/$days',
    queryParameters: {
      'location': city.locationCode,
    },
    options: createQWeatherOptions(),
  );

  final weatherResponse = WeatherDailyForecastResponse.fromJson(
    requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError(
      'QWeather request failed with code ${weatherResponse.code}',
    );
  }

  return weatherResponse;
}

Future<WeatherHourlyForecastResponse> getWeatherHourlyForecast({
  required WeatherCity city,
}) async {
  ensureQWeatherApiKey();

  final response = await qWeatherClient.get(
    '/v7/weather/24h',
    queryParameters: {
      'location': city.locationCode,
    },
    options: createQWeatherOptions(),
  );

  final weatherResponse = WeatherHourlyForecastResponse.fromJson(
    requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather hourly response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError(
      'QWeather hourly request failed with code ${weatherResponse.code}',
    );
  }

  return weatherResponse;
}
