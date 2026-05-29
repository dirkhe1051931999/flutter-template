import 'package:oolaf_flutted/api/weather/common.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/model/weather/types/weather_air_quality.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<WeatherAirQualityResponse> getWeatherAirQuality({
  required WeatherCity city,
}) async {
  ensureQWeatherApiKey();

  final response = await qWeatherClient.get(
    '/airquality/v1/current/${city.latitude}/${city.longitude}',
    options: createQWeatherOptions(),
  );

  return WeatherAirQualityResponse.fromJson(
    requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather air quality response payload',
    ),
  );
}
