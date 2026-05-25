import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_detail_page.dart';
import 'package:oolaf_flutted/utils/short_video_article_history_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoArticleHistoryPage extends StatefulWidget {
  const ShortVideoArticleHistoryPage({super.key});

  @override
  State<ShortVideoArticleHistoryPage> createState() =>
      _ShortVideoArticleHistoryPageState();
}

class _ShortVideoArticleHistoryPageState
    extends State<ShortVideoArticleHistoryPage> {
  bool _isLoading = true;
  String _searchKeyword = '';
  List<_ShortVideoArticleHistorySection> _sections =
      const <_ShortVideoArticleHistorySection>[];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final entries = await ShortVideoArticleHistoryPersistence.loadAll();
    final sections = _buildSections(entries);
    if (!mounted) {
      return;
    }
    setState(() {
      _sections = sections;
      _isLoading = false;
    });
  }

  List<_ShortVideoArticleHistorySection> _buildSections(
    List<ShortVideoArticleHistoryEntry> entries,
  ) {
    final sectionMap = <String, List<ShortVideoArticleHistoryEntry>>{};
    for (final entry in entries) {
      final dateLabel = _formatDate(entry.viewedAt);
      final items = sectionMap.putIfAbsent(
        dateLabel,
        () => <ShortVideoArticleHistoryEntry>[],
      );
      items.add(entry);
    }

    return sectionMap.entries
        .map(
          (entry) => _ShortVideoArticleHistorySection(
            dateLabel: entry.key,
            entries: List<ShortVideoArticleHistoryEntry>.unmodifiable(
              entry.value,
            ),
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
    await ShortVideoArticleHistoryPersistence.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _sections = const <_ShortVideoArticleHistorySection>[];
    });
  }

  Future<void> _deleteSingle(String docId) async {
    await ShortVideoArticleHistoryPersistence.remove(docId);
    await _loadHistory();
  }

  Future<void> _openDetail(ShortVideoArticleHistoryEntry entry) async {
    final detail = await getShortVideoNewsDocDetail(detailUrl: entry.detailUrl);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: const Text('加载失败'),
            content: const Text('文章详情暂时不可用，请稍后重试。'),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('知道了'),
              ),
            ],
          );
        },
      );
      return;
    }

    await openShortVideoArticleDetailPage(
      context,
      detail: detail,
      coverUrl: entry.coverUrl,
    );
  }

  List<_ShortVideoArticleHistorySection> _visibleSections() {
    final keyword = _searchKeyword.trim();
    if (keyword.isEmpty) {
      return _sections;
    }
    return _sections
        .map((section) {
          final entries = section.entries.where((entry) {
            return entry.title.contains(keyword) ||
                entry.source.contains(keyword);
          }).toList(growable: false);
          return _ShortVideoArticleHistorySection(
            dateLabel: section.dateLabel,
            entries: entries,
          );
        })
        .where((section) => section.entries.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visibleSections = _visibleSections();
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('文章查看历史'),
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
                      placeholder: '搜索历史文章',
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
                              _searchKeyword.trim().isEmpty
                                  ? '暂无文章查看历史'
                                  : '没有匹配结果',
                              style: const TextStyle(
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 18),
                            itemCount: visibleSections.length,
                            itemBuilder: (context, index) {
                              final section = visibleSections[index];
                              return _ArticleHistorySectionWidget(
                                section: section,
                                onTapEntry: _openDetail,
                                onDeleteEntry: _deleteSingle,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ArticleHistorySectionWidget extends StatelessWidget {
  const _ArticleHistorySectionWidget({
    required this.section,
    required this.onTapEntry,
    required this.onDeleteEntry,
  });

  final _ShortVideoArticleHistorySection section;
  final ValueChanged<ShortVideoArticleHistoryEntry> onTapEntry;
  final ValueChanged<String> onDeleteEntry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
          child: Text(
            section.dateLabel,
            style: const TextStyle(
              color: Color(0xFF6D6D72),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...section.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                onTapEntry(entry);
              },
              onLongPress: () {
                onDeleteEntry(entry.docId);
              },
              onSecondaryTap: () {
                onDeleteEntry(entry.docId);
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CustomNetworkImage(
                          entry.coverUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const SizedBox(
                              width: 72,
                              height: 72,
                              child: ColoredBox(color: Color(0xFFE5E5EA)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF1C1C1E),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.updateTime,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFAEAEB2),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: Color(0xFFAEAEB2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShortVideoArticleHistorySection {
  const _ShortVideoArticleHistorySection({
    required this.dateLabel,
    required this.entries,
  });

  final String dateLabel;
  final List<ShortVideoArticleHistoryEntry> entries;
}
