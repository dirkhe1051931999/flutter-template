import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_play_page.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';

class ShortVideoWatchHistoryPage extends StatefulWidget {
  const ShortVideoWatchHistoryPage({super.key});

  @override
  State<ShortVideoWatchHistoryPage> createState() =>
      _ShortVideoWatchHistoryPageState();
}

class _ShortVideoWatchHistoryPageState extends State<ShortVideoWatchHistoryPage> {
  static const int _gridCrossAxisCount = 3;
  static const double _gridGap = 4;

  bool _isLoading = true;
  String _searchKeyword = '';
  List<ShortVideoWatchHistorySection> _sections =
      const <ShortVideoWatchHistorySection>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await ShortVideoWatchHistoryPersistence.loadAll();
    final sections = _buildSections(entries);
    if (!mounted) {
      return;
    }
    setState(() {
      _sections = sections;
      _isLoading = false;
    });
  }

  List<ShortVideoWatchHistoryEntry> _flattenEntries() {
    return _sections
        .expand((section) => section.entries)
        .toList(growable: false);
  }

  void _openHistoryPlayPage(ShortVideoWatchHistoryEntry entry) {
    final entries = _flattenEntries();
    if (entries.isEmpty) {
      return;
    }

    final initialIndex = entries.indexWhere(
      (item) => item.videoId == entry.videoId,
    );
    if (initialIndex < 0) {
      return;
    }

    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) {
          return ShortVideoWatchHistoryPlayPage(
            entries: entries,
            initialIndex: initialIndex,
          );
        },
      ),
    );
  }

  List<ShortVideoWatchHistorySection> _buildSections(
    List<ShortVideoWatchHistoryEntry> entries,
  ) {
    final map = <String, List<ShortVideoWatchHistoryEntry>>{};

    for (final entry in entries) {
      final dateKey = _formatDate(entry.watchedAt);
      final list = map.putIfAbsent(dateKey, () => <ShortVideoWatchHistoryEntry>[]);
      list.add(entry);
    }

    return map.entries
        .map(
          (e) => ShortVideoWatchHistorySection(
            dateLabel: e.key,
            entries: List<ShortVideoWatchHistoryEntry>.unmodifiable(e.value),
          ),
        )
        .toList(growable: false);
  }

  String _formatDate(DateTime time) {
    final year = time.year.toString().padLeft(4, '0');
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> _clearAll() async {
    await ShortVideoWatchHistoryPersistence.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _sections = const <ShortVideoWatchHistorySection>[];
    });
  }

  Future<void> _deleteSingle(String videoId) async {
    await ShortVideoWatchHistoryPersistence.remove(videoId);
    if (!mounted) {
      return;
    }
    await _loadHistory();
  }

  List<ShortVideoWatchHistorySection> _buildFilteredSections() {
    final keyword = _searchKeyword.trim();
    if (keyword.isEmpty) {
      return _sections;
    }

    return _sections
        .map((section) {
          final entries = section.entries
              .where((entry) {
                return entry.title.contains(keyword) ||
                    (entry.source?.contains(keyword) ?? false);
              })
              .toList(growable: false);
          return ShortVideoWatchHistorySection(
            dateLabel: section.dateLabel,
            entries: entries,
          );
        })
        .where((section) => section.entries.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = _buildFilteredSections();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('观看历史'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _sections.isEmpty ? null : _clearAll,
          child: Text(
            '清空',
            style: TextStyle(
              color: _sections.isEmpty
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: CupertinoSearchTextField(
                      placeholder: '搜索历史视频',
                      onChanged: (value) {
                        setState(() {
                          _searchKeyword = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: visibleSections.isEmpty
                        ? Center(
                            child: Text(
                              _searchKeyword.trim().isEmpty ? '暂无观看历史' : '没有匹配结果',
                              style: const TextStyle(color: Color(0xFF8E8E93)),
                            ),
                          )
                        : CustomScrollView(
                            slivers: [
                              for (final section in visibleSections) ...[
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _ShortVideoHistoryHeaderDelegate(
                                    height: 30,
                                    label: section.dateLabel,
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                  sliver: SliverGrid(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final entry = section.entries[index];
                                        return _HistoryGridItem(
                                          entry: entry,
                                          onTap: () {
                                            _openHistoryPlayPage(entry);
                                          },
                                          onLongPress: () {
                                            _deleteSingle(entry.videoId);
                                          },
                                        );
                                      },
                                      childCount: section.entries.length,
                                    ),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _gridCrossAxisCount,
                                      crossAxisSpacing: _gridGap,
                                      mainAxisSpacing: _gridGap,
                                      childAspectRatio: 0.62,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _HistoryGridItem extends StatelessWidget {
  const _HistoryGridItem({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  final ShortVideoWatchHistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      onSecondaryTap: onLongPress,
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                child: Image.network(
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
              ),
            ),
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

class _ShortVideoHistoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _ShortVideoHistoryHeaderDelegate({
    required this.height,
    required this.label,
  });

  final double height;
  final String label;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: overlapsContent ? const Color(0xFFF0F1F3) : const Color(0xFFF4F5F7),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6D6D72),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ShortVideoHistoryHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.label != label;
  }
}

class ShortVideoWatchHistorySection {
  const ShortVideoWatchHistorySection({
    required this.dateLabel,
    required this.entries,
  });

  final String dateLabel;
  final List<ShortVideoWatchHistoryEntry> entries;
}
