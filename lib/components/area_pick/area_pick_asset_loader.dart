import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:oolaf_flutted/model/area/area_item.dart';

class AreaPickAssetLoader {
  AreaPickAssetLoader._();

  static List<AreaItem>? _cachedItems;

  static Future<List<AreaItem>> load() async {
    if (_cachedItems != null) {
      return _cachedItems!;
    }

    final jsonText = await rootBundle.loadString('lib/assets/pcas-code.json');
    final rawList = jsonDecode(jsonText);
    if (rawList is! List) {
      _cachedItems = const <AreaItem>[];
      return _cachedItems!;
    }

    _cachedItems = rawList
        .whereType<Map<String, dynamic>>()
        .map(AreaItem.fromJson)
        .toList(growable: false);
    return _cachedItems!;
  }
}
