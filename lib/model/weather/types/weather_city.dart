class WeatherCity {
  const WeatherCity({
    required this.locationCode,
    required this.name,
    required this.nameEn,
    required this.country,
    required this.province,
    required this.city,
    required this.timezone,
    required this.latitude,
    required this.longitude,
    required this.adCode,
    required this.searchText,
  });

  final String locationCode;
  final String name;
  final String nameEn;
  final String country;
  final String province;
  final String city;
  final String timezone;
  final String latitude;
  final String longitude;
  final String adCode;
  final String searchText;

  String get id => locationCode;

  String get displayName {
    if (city.isEmpty || city == name) {
      return name;
    }
    return '$city · $name';
  }

  factory WeatherCity.fromJson(Map<String, dynamic> json) {
    return WeatherCity(
      locationCode: json['locationCode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      adCode: json['adCode']?.toString() ?? '',
      searchText: json['searchText']?.toString() ?? '',
    );
  }
}

class WeatherCityCatalog {
  static const xian = WeatherCity(
    locationCode: '101110101',
    name: '西安',
    nameEn: 'Xi\'an',
    country: '中国',
    province: '陕西省',
    city: '西安市',
    timezone: 'Asia/Shanghai',
    latitude: '34.3432',
    longitude: '108.9397',
    adCode: '610100',
    searchText: '西安 xi\'an 陕西省 西安市 610100',
  );

  static const supportedCities = <WeatherCity>[
    xian,
  ];
}
