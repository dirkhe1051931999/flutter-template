import 'package:oolaf_flutted/app.config.dart';

class OolafMusicEntry {
  const OolafMusicEntry({
    required this.displayName,
    required this.path,
    required this.type,
    this.lastModified,
    this.etag,
    this.size,
    this.url,
    this.children,
  });

  final String displayName;
  final String path;
  final String type;
  final DateTime? lastModified;
  final String? etag;
  final int? size;
  final String? url;
  final Map<String, OolafMusicEntry>? children;

  bool get isFile => type == 'file';
  bool get isFolder => type == 'folder';

  Uri get cdnUri {
    final directUrl = url;
    if (directUrl != null && directUrl.isNotEmpty) {
      return Uri.parse(directUrl);
    }
    final base = Uri.parse(AppConfig.oolafMusicCdnBaseUrl);
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return base.resolve(Uri.encodeFull(normalizedPath));
  }

  factory OolafMusicEntry.fromJson(
    Map<String, dynamic> json, {
    String? displayName,
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
    } else if (childrenJson is List<dynamic>) {
      children = <String, OolafMusicEntry>{};
      for (final value in childrenJson) {
        if (value is Map<String, dynamic>) {
          final child = OolafMusicEntry.fromJson(value);
          children[child.displayName] = child;
        }
      }
    }

    final lastModifiedString = json['lastModified'];
    final name = (json['name'] as String?) ?? displayName ?? '';

    return OolafMusicEntry(
      displayName: displayName ?? name,
      path: (json['path'] as String?) ?? (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'unknown',
      lastModified: lastModifiedString is String
          ? DateTime.tryParse(lastModifiedString)
          : null,
      etag: json['etag'] as String?,
      size: json['size'] is int ? json['size'] as int : null,
      url: json['url'] as String?,
      children: children,
    );
  }
}
