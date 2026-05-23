import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_play_page.dart';
import 'package:oolaf_flutted/utils/short_video_collection_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_playback_progress_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';

class ShortVideoCollectionPage extends StatefulWidget {
  const ShortVideoCollectionPage({
    super.key,
    required this.title,
    required this.emptyText,
    required this.persistence,
  });

  final String title;
  final String emptyText;
  final ShortVideoCollectionPersistence persistence;

  @override
  State<ShortVideoCollectionPage> createState() =>
      _ShortVideoCollectionPageState();
}

class _ShortVideoCollectionPageState extends State<ShortVideoCollectionPage> {
  static const int _gridCrossAxisCount = 3;
  static const double _gridGap = 4;

  bool _isLoading = true;
  List<ShortVideoCollectionEntry> _entries =
      const <ShortVideoCollectionEntry>[];
  Map<String, ShortVideoPlaybackProgressEntry> _progressByVideoId =
      const <String, ShortVideoPlaybackProgressEntry>{};

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await widget.persistence.loadAll();
    final progressByVideoId =
        await ShortVideoPlaybackProgressPersistence.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _progressByVideoId = progressByVideoId;
      _isLoading = false;
    });
  }

  Future<void> _refreshProgress() async {
    final progressByVideoId =
        await ShortVideoPlaybackProgressPersistence.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _progressByVideoId = progressByVideoId;
    });
  }

  Future<void> _clearAll() async {
    await widget.persistence.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = const <ShortVideoCollectionEntry>[];
    });
  }

  List<ShortVideoWatchHistoryEntry> _toPlayableEntries() {
    return _entries
        .map(
          (entry) => ShortVideoWatchHistoryEntry(
            videoId: entry.videoId,
            title: entry.title,
            updateTime: entry.updateTime,
            coverUrl: entry.coverUrl,
            videoUrl: entry.videoUrl,
            source: entry.source,
            watchedAtMillis: entry.savedAtMillis,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _openPlayPage(ShortVideoCollectionEntry entry) async {
    final entries = _toPlayableEntries();
    if (entries.isEmpty) {
      return;
    }

    final initialIndex = entries.indexWhere(
      (item) => item.videoId == entry.videoId,
    );
    if (initialIndex < 0) {
      return;
    }

    await Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) {
          return ShortVideoWatchHistoryPlayPage(
            entries: entries,
            initialIndex: initialIndex,
          );
        },
      ),
    );
    await _refreshProgress();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _entries.isEmpty ? null : _clearAll,
          child: Text(
            '清空',
            style: TextStyle(
              color: _entries.isEmpty
                  ? CupertinoColors.inactiveGray
                  : CupertinoColors.systemBlue,
              fontSize: 14,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _entries.isEmpty
                ? Center(
                    child: Text(
                      widget.emptyText,
                      style: const TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCrossAxisCount,
                      crossAxisSpacing: _gridGap,
                      mainAxisSpacing: _gridGap,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _CollectionGridItem(
                        entry: entry,
                        progress: _progressByVideoId[entry.videoId],
                        onTap: () {
                          _openPlayPage(entry);
                        },
                      );
                    },
                  ),
      ),
    );
  }
}

class _CollectionGridItem extends StatelessWidget {
  const _CollectionGridItem({
    required this.entry,
    required this.progress,
    required this.onTap,
  });

  final ShortVideoCollectionEntry entry;
  final ShortVideoPlaybackProgressEntry? progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      entry.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const ColoredBox(
                          color: Color(0xFFE5E5EA),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.exclamationmark_triangle,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        );
                      },
                    ),
                    ShortVideoListProgressBadge(progress: progress),
                  ],
                ),
              ),
            ),
            ShortVideoListProgressStrip(progress: progress),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              child: Text(
                entry.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Text(
                entry.source ?? '短视频',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
