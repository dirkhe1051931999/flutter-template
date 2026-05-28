import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/api/short_video/hot_tab.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_detail_page.dart';
import 'package:oolaf_flutted/pages/video_tabs/watch_history_play_page.dart';
import 'package:oolaf_flutted/utils/short_video_article_history_persistence.dart';
import 'package:oolaf_flutted/utils/short_video_watch_history_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoHotTopicDetailPage extends StatefulWidget {
  const ShortVideoHotTopicDetailPage({
    super.key,
    required this.eventName,
  });

  final String eventName;

  @override
  State<ShortVideoHotTopicDetailPage> createState() =>
      _ShortVideoHotTopicDetailPageState();
}

class _ShortVideoHotTopicDetailPageState
    extends State<ShortVideoHotTopicDetailPage> {
  HotTabDetailPageResult? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
    });

    final detail = await getHotTabDetailPage(
      request: HotTabDetailRequest(eventName: widget.eventName),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _detail = detail;
      _isLoading = false;
    });
  }

  List<ShortVideoWatchHistoryEntry> _buildPlayableEntries() {
    final detail = _detail;
    if (detail == null) {
      return const <ShortVideoWatchHistoryEntry>[];
    }

    return detail.items
        .where((item) => item.isVideo && item.videoUrl.isNotEmpty)
        .map(
          (item) => ShortVideoWatchHistoryEntry(
            videoId: item.id,
            title: item.title,
            updateTime: item.updateTime,
            coverUrl: item.primaryCoverUrl,
            videoUrl: item.videoUrl,
            source: item.source,
            commentsUrl: item.commentsUrl,
            commentsCount: item.commentsCount,
            watchedAtMillis: DateTime.now().millisecondsSinceEpoch,
          ),
        )
        .toList(growable: false);
  }

  Future<void> _openNewsDetail(HotTabDetailNewsItem item) async {
    if (item.detailUrl.isEmpty) {
      return;
    }
    final detail = await getShortVideoNewsDocDetail(detailUrl: item.detailUrl);
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

    await ShortVideoArticleHistoryPersistence.record(
      ShortVideoArticleHistoryEntry(
        docId: item.id,
        title: item.title,
        source: item.source,
        updateTime: item.updateTime,
        coverUrl: item.primaryCoverUrl,
        detailUrl: item.detailUrl,
        viewedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) {
      return;
    }

    await openShortVideoArticleDetailPage(
      context,
      detail: detail,
      coverUrl: item.primaryCoverUrl,
      detailUrl: item.detailUrl,
    );
  }

  Future<void> _openVideoPlaylist(HotTabDetailNewsItem item) async {
    final entries = _buildPlayableEntries();
    if (entries.isEmpty) {
      return;
    }

    final initialIndex = entries.indexWhere((entry) => entry.videoId == item.id);
    if (initialIndex < 0) {
      return;
    }

    await ShortVideoWatchHistoryPersistence.record(entries[initialIndex]);
    if (!mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
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

  Future<void> _copyShareLink() async {
    final text = _detail?.shareUrl ?? '';
    if (text.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('已复制'),
          content: const Text('专题链接已复制到剪贴板。'),
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
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : detail == null
                ? Center(
                    child: CupertinoButton(
                      onPressed: _loadDetail,
                      child: const Text('加载失败，点击重试'),
                    ),
                  )
                : wrapWithDesktopFriendlyScrollBehavior(
                    CustomScrollView(
                      slivers: [
                      CupertinoSliverRefreshControl(onRefresh: _loadDetail),
                      CupertinoSliverNavigationBar(
                        largeTitle: Text(detail.title),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(24, 24),
                          onPressed: _copyShareLink,
                          child: const AppAssetIcon(
                            assetName: 'share-social',
                            fallbackIcon: CupertinoIcons.share,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _TopicHeroBanner(detail: detail),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                        sliver: SliverList.separated(
                          itemCount: detail.items.length,
                          itemBuilder: (context, index) {
                            final item = detail.items[index];
                            return _TopicNewsCard(
                              item: item,
                              onTap: () {
                                if (item.isVideo) {
                                  _openVideoPlaylist(item);
                                  return;
                                }
                                _openNewsDetail(item);
                              },
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                        ),
                      ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _TopicHeroBanner extends StatelessWidget {
  const _TopicHeroBanner({required this.detail});

  final HotTabDetailPageResult detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: detail.bannerImageUrl.isEmpty
            ? null
            : DecorationImage(
                image: NetworkImage(detail.bannerImageUrl),
                fit: BoxFit.cover,
              ),
        color: const Color(0xFF23262D),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x22000000), Color(0xBB000000)],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              detail.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              detail.subscribeCountText,
              style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicNewsCard extends StatelessWidget {
  const _TopicNewsCard({
    required this.item,
    required this.onTap,
  });

  final HotTabDetailNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF202124),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.source}  ${item.updateTime}'.trim(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.coverUrls.isNotEmpty) ...[
              const SizedBox(width: 10),
              _TopicCoverGrid(item: item),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopicCoverGrid extends StatelessWidget {
  const _TopicCoverGrid({required this.item});

  final HotTabDetailNewsItem item;

  @override
  Widget build(BuildContext context) {
    final displayUrls = item.coverUrls.take(3).toList(growable: false);
    if (displayUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    if (displayUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 152,
          height: 96,
          child: CustomNetworkImage(
            displayUrls.first,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return SizedBox(
      width: 152,
      height: 96,
      child: Row(
        children: displayUrls
            .map(
              (url) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: url == displayUrls.last ? 0 : 4,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomNetworkImage(
                      url,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
