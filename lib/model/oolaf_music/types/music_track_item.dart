import './music_entry.dart';

class OolafMusicTrackItem {
  const OolafMusicTrackItem({
    required this.key,
    required this.parentKey,
    required this.ancestorKeys,
    required this.entry,
  });

  final String key;
  final String parentKey;
  final List<String> ancestorKeys;
  final OolafMusicEntry entry;

  String get title => entry.displayName;
  String get cdnUrl => entry.cdnUri.toString();
}

List<OolafMusicTrackItem> flattenOolafMusicTracks(
  Map<String, OolafMusicEntry> entries, {
  String parentKey = '',
  List<String> ancestorKeys = const <String>[],
}) {
  final folders = <MapEntry<String, OolafMusicEntry>>[];
  final files = <MapEntry<String, OolafMusicEntry>>[];

  for (final item in entries.entries) {
    if (item.value.isFolder) {
      folders.add(item);
    } else if (item.value.isFile) {
      files.add(item);
    }
  }

  int compareByName(
    MapEntry<String, OolafMusicEntry> a,
    MapEntry<String, OolafMusicEntry> b,
  ) {
    return a.key.compareTo(b.key);
  }

  folders.sort(compareByName);
  files.sort(compareByName);

  final result = <OolafMusicTrackItem>[];

  for (final folder in folders) {
    final key = parentKey.isEmpty ? folder.key : '$parentKey/${folder.key}';
    final children = folder.value.children;
    if (children != null && children.isNotEmpty) {
      result.addAll(
        flattenOolafMusicTracks(
          children,
          parentKey: key,
          ancestorKeys: <String>[...ancestorKeys, key],
        ),
      );
    }
  }

  for (final file in files) {
    final key = parentKey.isEmpty ? file.key : '$parentKey/${file.key}';
    result.add(
      OolafMusicTrackItem(
        key: key,
        parentKey: parentKey.isEmpty ? '__root__' : parentKey,
        ancestorKeys: ancestorKeys,
        entry: file.value,
      ),
    );
  }

  return result;
}
