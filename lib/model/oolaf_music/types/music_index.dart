import './music_entry.dart';

class OolafMusicIndex {
  const OolafMusicIndex({
    required this.code,
    required this.msg,
    required this.entries,
  });

  final int code;
  final String msg;
  final Map<String, OolafMusicEntry> entries;

  factory OolafMusicIndex.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    final entries = <String, OolafMusicEntry>{};

    if (dataJson is Map<String, dynamic>) {
      dataJson.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          entries[key] = OolafMusicEntry.fromJson(value, displayName: key);
        }
      });
    }

    return OolafMusicIndex(
      code: json['code'] is int ? json['code'] as int : 0,
      msg: (json['msg'] as String?) ?? '',
      entries: entries,
    );
  }
}
