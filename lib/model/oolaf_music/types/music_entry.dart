import 'package:oolaf_flutted/app.config.dart';

class OolafMusicEntry {
  const OolafMusicEntry({
    required this.displayName,
    required this.path,
    required this.type,
    this.lastModified,
    this.etag,
    this.size,
    this.children,
  });

  final String displayName;
  final String path;
  final String type;
  final DateTime? lastModified;
  final String? etag;
  final int? size;
  final Map<String, OolafMusicEntry>? children;

  bool get isFile => type == 'file';
  bool get isFolder => type == 'folder';

  Uri get cdnUri {
    final base = Uri.parse(AppConfig.oolafMusicCdnBaseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(Uri.encodeFull(normalizedPath));
  }

  factory OolafMusicEntry.fromJson(
    Map<String, dynamic> json, {
    required String displayName,
  }) {
    final childrenJson = json['children'];
    Map<String, OolafMusicEntry>? children;

    if (childrenJson is Map<String, dynamic>) {
      children = childrenJson.map((key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(
            key,
            OolafMusicEntry.fromJson(value, displayName: key),
          );
        }
        return MapEntry(
          key,
          OolafMusicEntry(
            displayName: key,
            path: '',
            type: 'unknown',
          ),
        );
      });
    }

    final lastModifiedString = json['lastModified'];

    return OolafMusicEntry(
      displayName: displayName,
      path: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'unknown',
      lastModified: lastModifiedString is String
          ? DateTime.tryParse(lastModifiedString)
          : null,
      etag: json['etag'] as String?,
      size: json['size'] is int ? json['size'] as int : null,
      children: children,
    );
  }
}
