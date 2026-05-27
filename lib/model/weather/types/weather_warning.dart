class WeatherWarningResponse {
  const WeatherWarningResponse({
    required this.metadata,
    required this.alerts,
  });

  final WeatherWarningMetadata metadata;
  final List<WeatherWarningAlert> alerts;

  bool get hasAlerts => alerts.isNotEmpty;

  factory WeatherWarningResponse.fromJson(Map<String, dynamic> json) {
    final alertsList = json['alerts'] as List<dynamic>? ?? const [];

    return WeatherWarningResponse(
      metadata: WeatherWarningMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      alerts: alertsList
          .whereType<Map<String, dynamic>>()
          .map(WeatherWarningAlert.fromJson)
          .toList(),
    );
  }
}

class WeatherWarningMetadata {
  const WeatherWarningMetadata({
    required this.tag,
    required this.zeroResult,
    required this.attributions,
  });

  final String tag;
  final bool zeroResult;
  final List<String> attributions;

  factory WeatherWarningMetadata.fromJson(Map<String, dynamic> json) {
    return WeatherWarningMetadata(
      tag: json['tag']?.toString() ?? '',
      zeroResult: json['zeroResult'] == true,
      attributions: (json['attributions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class WeatherWarningAlert {
  const WeatherWarningAlert({
    required this.id,
    required this.senderName,
    required this.issuedTime,
    required this.messageType,
    required this.eventType,
    required this.urgency,
    required this.severity,
    required this.certainty,
    required this.icon,
    required this.color,
    required this.effectiveTime,
    required this.onsetTime,
    required this.expireTime,
    required this.headline,
    required this.description,
    required this.criteria,
    required this.responseTypes,
    required this.instruction,
  });

  final String id;
  final String senderName;
  final String issuedTime;
  final WeatherWarningMessageType messageType;
  final WeatherWarningEventType eventType;
  final String urgency;
  final String severity;
  final String certainty;
  final String icon;
  final WeatherWarningColor color;
  final String effectiveTime;
  final String onsetTime;
  final String expireTime;
  final String headline;
  final String description;
  final String criteria;
  final List<String> responseTypes;
  final String instruction;

  DateTime? get issuedDateTime => DateTime.tryParse(issuedTime)?.toLocal();
  DateTime? get expireDateTime => DateTime.tryParse(expireTime)?.toLocal();

  factory WeatherWarningAlert.fromJson(Map<String, dynamic> json) {
    return WeatherWarningAlert(
      id: json['id']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      issuedTime: json['issuedTime']?.toString() ?? '',
      messageType: WeatherWarningMessageType.fromJson(
        json['messageType'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      eventType: WeatherWarningEventType.fromJson(
        json['eventType'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      urgency: json['urgency']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      certainty: json['certainty']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: WeatherWarningColor.fromJson(
        json['color'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      ),
      effectiveTime: json['effectiveTime']?.toString() ?? '',
      onsetTime: json['onsetTime']?.toString() ?? '',
      expireTime: json['expireTime']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      criteria: json['criteria']?.toString() ?? '',
      responseTypes: (json['responseTypes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      instruction: json['instruction']?.toString() ?? '',
    );
  }
}

class WeatherWarningMessageType {
  const WeatherWarningMessageType({
    required this.code,
    required this.supersedes,
  });

  final String code;
  final List<String> supersedes;

  factory WeatherWarningMessageType.fromJson(Map<String, dynamic> json) {
    return WeatherWarningMessageType(
      code: json['code']?.toString() ?? '',
      supersedes: (json['supersedes'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class WeatherWarningEventType {
  const WeatherWarningEventType({
    required this.name,
    required this.code,
  });

  final String name;
  final String code;

  factory WeatherWarningEventType.fromJson(Map<String, dynamic> json) {
    return WeatherWarningEventType(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
    );
  }
}

class WeatherWarningColor {
  const WeatherWarningColor({
    required this.code,
    required this.red,
    required this.green,
    required this.blue,
    required this.alpha,
  });

  final String code;
  final int red;
  final int green;
  final int blue;
  final num alpha;

  factory WeatherWarningColor.fromJson(Map<String, dynamic> json) {
    return WeatherWarningColor(
      code: json['code']?.toString() ?? '',
      red: (json['red'] as num?)?.toInt() ?? 239,
      green: (json['green'] as num?)?.toInt() ?? 68,
      blue: (json['blue'] as num?)?.toInt() ?? 68,
      alpha: json['alpha'] as num? ?? 1,
    );
  }
}
