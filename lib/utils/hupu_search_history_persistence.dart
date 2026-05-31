import 'package:shared_preferences/shared_preferences.dart';

class HupuSearchHistoryPersistence {
  HupuSearchHistoryPersistence._();

  static const String _key = 'hupu_search_history_v1';
  static const int _maxCount = 20;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? const <String>[];
    return items.where((item) => item.trim().isNotEmpty).toList(growable: false);
  }

  static Future<void> add(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? <String>[];
    items.removeWhere((item) => item == trimmed);
    items.insert(0, trimmed);
    if (items.length > _maxCount) {
      items.removeRange(_maxCount, items.length);
    }
    await prefs.setStringList(_key, items);
  }

  static Future<void> remove(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(_key) ?? <String>[];
    items.removeWhere((item) => item == keyword);
    await prefs.setStringList(_key, items);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
