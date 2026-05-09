import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OolafMusicFavorites {
  static const _key = 'oolaf_music_favorites_v1';

  static Future<Set<String>> readUrls() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.whereType<String>().toSet();
    }
    return <String>{};
  }

  static Future<void> writeUrls(Set<String> urls) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(urls.toList()));
  }

  static Future<Set<String>> toggleUrl(String url) async {
    final urls = await readUrls();
    if (urls.contains(url)) {
      urls.remove(url);
    } else {
      urls.add(url);
    }
    await writeUrls(urls);
    return urls;
  }
}
