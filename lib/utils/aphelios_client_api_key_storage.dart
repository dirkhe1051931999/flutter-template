import 'package:shared_preferences/shared_preferences.dart';

class ApheliosClientApiKeyStorage {
  static const _key = 'aphelios_client_api_key';

  static Future<String> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key)?.trim() ?? '';
  }

  static Future<void> save(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.trim());
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
