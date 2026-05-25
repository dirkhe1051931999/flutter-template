import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:oolaf_flutted/model/weather/index.dart';

class WeatherCityRepository {
  WeatherCityRepository._();

  static final WeatherCityRepository instance = WeatherCityRepository._();

  List<WeatherCity>? _cachedCities;

  Future<List<WeatherCity>> loadCities() async {
    if (_cachedCities != null) {
      return _cachedCities!;
    }

    final raw = await rootBundle.loadString('assets/weather/cities.json');
    final jsonList = jsonDecode(raw) as List<dynamic>;
    _cachedCities = jsonList
        .whereType<Map<String, dynamic>>()
        .map(WeatherCity.fromJson)
        .toList();
    return _cachedCities!;
  }

  Future<List<WeatherCity>> searchCities(String keyword) async {
    final cities = await loadCities();
    final trimmedKeyword = keyword.trim().toLowerCase();
    if (trimmedKeyword.isEmpty) {
      return cities.take(50).toList();
    }

    return cities
        .where((city) => city.searchText.contains(trimmedKeyword))
        .take(50)
        .toList();
  }
}
