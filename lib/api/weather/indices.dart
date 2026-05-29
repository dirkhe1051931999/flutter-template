import 'package:oolaf_flutted/api/weather/common.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/model/weather/types/weather_indices_forecast.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<WeatherIndicesForecastResponse> getWeatherIndicesForecast({
  required WeatherCity city,
  String days = '1d',
  List<String> typeIds = const ['1', '2', '3', '5'],
}) async {
  ensureQWeatherApiKey();

  final response = await qWeatherClient.get(
    '/v7/indices/$days',
    queryParameters: {
      'location': city.locationCode,
      'type': typeIds.join(','),
    },
    options: createQWeatherOptions(),
  );

  final weatherResponse = WeatherIndicesForecastResponse.fromJson(
    requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather indices response payload',
    ),
  );

  if (weatherResponse.code != '200') {
    throw StateError(
      'QWeather indices request failed with code ${weatherResponse.code}',
    );
  }

  return weatherResponse;
}
