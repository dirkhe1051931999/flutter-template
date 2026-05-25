import 'package:oolaf_flutted/model/weather/types/weather_daily_forecast.dart';

class WeatherHourlyForecastResponse {
  const WeatherHourlyForecastResponse({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.hourly,
    required this.refer,
  });

  final String code;
  final String updateTime;
  final String fxLink;
  final List<WeatherHourlyForecast> hourly;
  final WeatherRefer refer;

  factory WeatherHourlyForecastResponse.fromJson(Map<String, dynamic> json) {
    final hourlyList = json['hourly'] as List<dynamic>? ?? const [];

    return WeatherHourlyForecastResponse(
      code: json['code']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
      fxLink: json['fxLink']?.toString() ?? '',
      hourly: hourlyList
          .whereType<Map<String, dynamic>>()
          .map(WeatherHourlyForecast.fromJson)
          .toList(),
      refer: WeatherRefer.fromJson(
        json['refer'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherHourlyForecast {
  const WeatherHourlyForecast({
    required this.fxTime,
    required this.temp,
    required this.icon,
    required this.text,
    required this.wind360,
    required this.windDir,
    required this.windScale,
    required this.windSpeed,
    required this.humidity,
    required this.pop,
    required this.precip,
    required this.pressure,
    required this.cloud,
    required this.dew,
  });

  final String fxTime;
  final String temp;
  final String icon;
  final String text;
  final String wind360;
  final String windDir;
  final String windScale;
  final String windSpeed;
  final String humidity;
  final String pop;
  final String precip;
  final String pressure;
  final String cloud;
  final String dew;

  DateTime? get dateTime {
    final parsedDateTime = DateTime.tryParse(fxTime);
    if (parsedDateTime == null) {
      return null;
    }
    return parsedDateTime.toLocal();
  }

  factory WeatherHourlyForecast.fromJson(Map<String, dynamic> json) {
    return WeatherHourlyForecast(
      fxTime: json['fxTime']?.toString() ?? '',
      temp: json['temp']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      wind360: json['wind360']?.toString() ?? '',
      windDir: json['windDir']?.toString() ?? '',
      windScale: json['windScale']?.toString() ?? '',
      windSpeed: json['windSpeed']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      pop: json['pop']?.toString() ?? '',
      precip: json['precip']?.toString() ?? '',
      pressure: json['pressure']?.toString() ?? '',
      cloud: json['cloud']?.toString() ?? '',
      dew: json['dew']?.toString() ?? '',
    );
  }
}
