import 'package:oolaf_flutted/model/weather/types/weather_daily_forecast.dart';

class WeatherIndicesForecastResponse {
  const WeatherIndicesForecastResponse({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.daily,
    required this.refer,
  });

  final String code;
  final String updateTime;
  final String fxLink;
  final List<WeatherIndicesForecast> daily;
  final WeatherRefer refer;

  factory WeatherIndicesForecastResponse.fromJson(Map<String, dynamic> json) {
    final dailyList = json['daily'] as List<dynamic>? ?? const [];

    return WeatherIndicesForecastResponse(
      code: json['code']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
      fxLink: json['fxLink']?.toString() ?? '',
      daily: dailyList
          .whereType<Map<String, dynamic>>()
          .map(WeatherIndicesForecast.fromJson)
          .toList(),
      refer: WeatherRefer.fromJson(
        json['refer'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherIndicesForecast {
  const WeatherIndicesForecast({
    required this.date,
    required this.type,
    required this.name,
    required this.level,
    required this.category,
    required this.text,
  });

  final String date;
  final String type;
  final String name;
  final String level;
  final String category;
  final String text;

  factory WeatherIndicesForecast.fromJson(Map<String, dynamic> json) {
    return WeatherIndicesForecast(
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
    );
  }
}
