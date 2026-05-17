import 'package:shared_preferences/shared_preferences.dart';

class ShortVideoSearchHistoryPersistence {
  ShortVideoSearchHistoryPersistence._();

  static const String _key = 'short_video_search_history_v1';
  static const int _maxCount = 20;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? const <String>[];
    return list.where((item) => item.trim().isNotEmpty).toList(growable: false);
  }

  static Future<void> add(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current.removeWhere((item) => item == trimmed);
    current.insert(0, trimmed);
    if (current.length > _maxCount) {
      current.removeRange(_maxCount, current.length);
    }
    await prefs.setStringList(_key, current);
  }

  static Future<void> remove(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? <String>[];
    current.removeWhere((item) => item == keyword);
    await prefs.setStringList(_key, current);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
