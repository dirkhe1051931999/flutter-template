class WeatherDailyForecastResponse {
  const WeatherDailyForecastResponse({
    required this.code,
    required this.updateTime,
    required this.fxLink,
    required this.daily,
    required this.refer,
  });

  final String code;
  final String updateTime;
  final String fxLink;
  final List<WeatherDailyForecast> daily;
  final WeatherRefer refer;

  factory WeatherDailyForecastResponse.fromJson(Map<String, dynamic> json) {
    final dailyList = json['daily'] as List<dynamic>? ?? const [];

    return WeatherDailyForecastResponse(
      code: json['code']?.toString() ?? '',
      updateTime: json['updateTime']?.toString() ?? '',
      fxLink: json['fxLink']?.toString() ?? '',
      daily: dailyList
          .whereType<Map<String, dynamic>>()
          .map(WeatherDailyForecast.fromJson)
          .toList(),
      refer: WeatherRefer.fromJson(
        json['refer'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherRefer {
  const WeatherRefer({
    required this.sources,
    required this.license,
  });

  final List<String> sources;
  final List<String> license;

  factory WeatherRefer.fromJson(Map<String, dynamic> json) {
    return WeatherRefer(
      sources: (json['sources'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      license: (json['license'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class WeatherDailyForecast {
  const WeatherDailyForecast({
    required this.fxDate,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
    required this.moonPhaseIcon,
    required this.tempMax,
    required this.tempMin,
    required this.iconDay,
    required this.textDay,
    required this.iconNight,
    required this.textNight,
    required this.wind360Day,
    required this.windDirDay,
    required this.windScaleDay,
    required this.windSpeedDay,
    required this.wind360Night,
    required this.windDirNight,
    required this.windScaleNight,
    required this.windSpeedNight,
    required this.humidity,
    required this.precip,
    required this.pressure,
    required this.vis,
    required this.cloud,
    required this.uvIndex,
  });

  final String fxDate;
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;
  final String moonPhaseIcon;
  final String tempMax;
  final String tempMin;
  final String iconDay;
  final String textDay;
  final String iconNight;
  final String textNight;
  final String wind360Day;
  final String windDirDay;
  final String windScaleDay;
  final String windSpeedDay;
  final String wind360Night;
  final String windDirNight;
  final String windScaleNight;
  final String windSpeedNight;
  final String humidity;
  final String precip;
  final String pressure;
  final String vis;
  final String cloud;
  final String uvIndex;

  factory WeatherDailyForecast.fromJson(Map<String, dynamic> json) {
    return WeatherDailyForecast(
      fxDate: json['fxDate']?.toString() ?? '',
      sunrise: json['sunrise']?.toString() ?? '',
      sunset: json['sunset']?.toString() ?? '',
      moonrise: json['moonrise']?.toString() ?? '',
      moonset: json['moonset']?.toString() ?? '',
      moonPhase: json['moonPhase']?.toString() ?? '',
      moonPhaseIcon: json['moonPhaseIcon']?.toString() ?? '',
      tempMax: json['tempMax']?.toString() ?? '',
      tempMin: json['tempMin']?.toString() ?? '',
      iconDay: json['iconDay']?.toString() ?? '',
      textDay: json['textDay']?.toString() ?? '',
      iconNight: json['iconNight']?.toString() ?? '',
      textNight: json['textNight']?.toString() ?? '',
      wind360Day: json['wind360Day']?.toString() ?? '',
      windDirDay: json['windDirDay']?.toString() ?? '',
      windScaleDay: json['windScaleDay']?.toString() ?? '',
      windSpeedDay: json['windSpeedDay']?.toString() ?? '',
      wind360Night: json['wind360Night']?.toString() ?? '',
      windDirNight: json['windDirNight']?.toString() ?? '',
      windScaleNight: json['windScaleNight']?.toString() ?? '',
      windSpeedNight: json['windSpeedNight']?.toString() ?? '',
      humidity: json['humidity']?.toString() ?? '',
      precip: json['precip']?.toString() ?? '',
      pressure: json['pressure']?.toString() ?? '',
      vis: json['vis']?.toString() ?? '',
      cloud: json['cloud']?.toString() ?? '',
      uvIndex: json['uvIndex']?.toString() ?? '',
    );
  }
}
