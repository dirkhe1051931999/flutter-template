class WeatherAirQualityResponse {
  const WeatherAirQualityResponse({
    required this.metadata,
    required this.indexes,
    required this.pollutants,
    required this.stations,
  });

  final WeatherAirQualityMetadata metadata;
  final List<WeatherAirQualityIndex> indexes;
  final List<WeatherAirQualityPollutant> pollutants;
  final List<WeatherAirQualityStation> stations;

  WeatherAirQualityIndex? get primaryIndex {
    for (final index in indexes) {
      if (index.code == 'qaqi') {
        return index;
      }
    }
    if (indexes.isEmpty) {
      return null;
    }
    return indexes.first;
  }

  factory WeatherAirQualityResponse.fromJson(Map<String, dynamic> json) {
    final indexesList = json['indexes'] as List<dynamic>? ?? const [];
    final pollutantsList = json['pollutants'] as List<dynamic>? ?? const [];
    final stationsList = json['stations'] as List<dynamic>? ?? const [];

    return WeatherAirQualityResponse(
      metadata: WeatherAirQualityMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      indexes: indexesList
          .whereType<Map<String, dynamic>>()
          .map(WeatherAirQualityIndex.fromJson)
          .toList(),
      pollutants: pollutantsList
          .whereType<Map<String, dynamic>>()
          .map(WeatherAirQualityPollutant.fromJson)
          .toList(),
      stations: stationsList
          .whereType<Map<String, dynamic>>()
          .map(WeatherAirQualityStation.fromJson)
          .toList(),
    );
  }
}

class WeatherAirQualityMetadata {
  const WeatherAirQualityMetadata({
    required this.tag,
  });

  final String tag;

  factory WeatherAirQualityMetadata.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityMetadata(
      tag: json['tag']?.toString() ?? '',
    );
  }
}

class WeatherAirQualityIndex {
  const WeatherAirQualityIndex({
    required this.code,
    required this.name,
    required this.aqi,
    required this.aqiDisplay,
    required this.level,
    required this.category,
    required this.color,
    required this.primaryPollutant,
    required this.health,
  });

  final String code;
  final String name;
  final num? aqi;
  final String aqiDisplay;
  final String level;
  final String category;
  final WeatherAirQualityColor color;
  final WeatherAirQualityPrimaryPollutant primaryPollutant;
  final WeatherAirQualityHealth health;

  factory WeatherAirQualityIndex.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityIndex(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      aqi: json['aqi'] as num?,
      aqiDisplay: json['aqiDisplay']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      color: WeatherAirQualityColor.fromJson(
        json['color'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      primaryPollutant: WeatherAirQualityPrimaryPollutant.fromJson(
        json['primaryPollutant'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      health: WeatherAirQualityHealth.fromJson(
        json['health'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherAirQualityColor {
  const WeatherAirQualityColor({
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  final int red;
  final int green;
  final int blue;
  final num alpha;

  factory WeatherAirQualityColor.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityColor(
      red: (json['red'] as num?)?.toInt() ?? 46,
      green: (json['green'] as num?)?.toInt() ?? 126,
      blue: (json['blue'] as num?)?.toInt() ?? 247,
      alpha: json['alpha'] as num? ?? 1,
    );
  }
}

class WeatherAirQualityPrimaryPollutant {
  const WeatherAirQualityPrimaryPollutant({
    required this.code,
    required this.name,
    required this.fullName,
  });

  final String code;
  final String name;
  final String fullName;

  factory WeatherAirQualityPrimaryPollutant.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityPrimaryPollutant(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
    );
  }
}

class WeatherAirQualityHealth {
  const WeatherAirQualityHealth({
    required this.effect,
    required this.advice,
  });

  final String effect;
  final WeatherAirQualityAdvice advice;

  factory WeatherAirQualityHealth.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityHealth(
      effect: json['effect']?.toString() ?? '',
      advice: WeatherAirQualityAdvice.fromJson(
        json['advice'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherAirQualityAdvice {
  const WeatherAirQualityAdvice({
    required this.generalPopulation,
    required this.sensitivePopulation,
  });

  final String generalPopulation;
  final String sensitivePopulation;

  factory WeatherAirQualityAdvice.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityAdvice(
      generalPopulation: json['generalPopulation']?.toString() ?? '',
      sensitivePopulation: json['sensitivePopulation']?.toString() ?? '',
    );
  }
}

class WeatherAirQualityPollutant {
  const WeatherAirQualityPollutant({
    required this.code,
    required this.name,
    required this.fullName,
    required this.concentration,
  });

  final String code;
  final String name;
  final String fullName;
  final WeatherAirQualityConcentration concentration;

  String get displayConcentration {
    final value = concentration.value;
    if (value == null) {
      return '--';
    }
    return '${_formatNumber(value)} ${concentration.unit}'.trim();
  }

  factory WeatherAirQualityPollutant.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityPollutant(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      concentration: WeatherAirQualityConcentration.fromJson(
        json['concentration'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
    );
  }
}

class WeatherAirQualityConcentration {
  const WeatherAirQualityConcentration({
    required this.value,
    required this.unit,
  });

  final num? value;
  final String unit;

  factory WeatherAirQualityConcentration.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityConcentration(
      value: json['value'] as num?,
      unit: json['unit']?.toString() ?? '',
    );
  }
}

class WeatherAirQualityStation {
  const WeatherAirQualityStation({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory WeatherAirQualityStation.fromJson(Map<String, dynamic> json) {
    return WeatherAirQualityStation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}
