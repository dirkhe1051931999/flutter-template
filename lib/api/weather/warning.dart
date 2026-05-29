import 'package:oolaf_flutted/api/weather/common.dart';
import 'package:oolaf_flutted/model/weather/index.dart';
import 'package:oolaf_flutted/model/weather/types/weather_warning.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<WeatherWarningResponse> getWeatherWarning({
  required WeatherCity city,
}) async {
  ensureQWeatherApiKey();

  final response = await qWeatherClient.get(
    '/weatheralert/v1/current/${city.latitude}/${city.longitude}',
    queryParameters: {
      'localTime': 'true',
    },
    options: createQWeatherOptions(),
  );

  return WeatherWarningResponse.fromJson(
    requireQWeatherPayload(
      response.data,
      errorMessage: 'Unexpected QWeather warning response payload',
    ),
  );
}
