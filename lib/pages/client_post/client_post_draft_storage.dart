import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ClientPostDraft {
  const ClientPostDraft({
    required this.text,
    required this.imagePaths,
    required this.videoPath,
    required this.visibility,
    required this.restrictedOptions,
    required this.linkTitle,
    required this.linkUrl,
  });

  final String text;
  final List<String> imagePaths;
  final String? videoPath;
  final String visibility;
  final String restrictedOptions;
  final String linkTitle;
  final String linkUrl;

  Map<String, dynamic> toJson() => {
        'text': text,
        'imagePaths': imagePaths,
        'videoPath': videoPath,
        'visibility': visibility,
        'restrictedOptions': restrictedOptions,
        'linkTitle': linkTitle,
        'linkUrl': linkUrl,
      };

  factory ClientPostDraft.fromJson(Map<String, dynamic> json) {
    return ClientPostDraft(
      text: json['text']?.toString() ?? '',
      imagePaths: (json['imagePaths'] as List<dynamic>? ?? <dynamic>[]).map((item) => item.toString()).toList(),
      videoPath: json['videoPath']?.toString(),
      visibility: json['visibility']?.toString() ?? 'public',
      restrictedOptions: json['restrictedOptions']?.toString() ?? '',
      linkTitle: json['linkTitle']?.toString() ?? '',
      linkUrl: json['linkUrl']?.toString() ?? '',
    );
  }
}

class ClientPostDraftStorage {
  static const _key = 'client_post_latest_draft';

  static Future<ClientPostDraft?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final json = jsonDecode(raw);
    return json is Map<String, dynamic> ? ClientPostDraft.fromJson(json) : null;
  }

  static Future<void> save(ClientPostDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(draft.toJson()));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
