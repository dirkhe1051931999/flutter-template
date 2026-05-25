import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectionArea, SelectableText;
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_detail_page.dart';
import 'package:oolaf_flutted/api/short_video/index.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/store/short_video/state.dart';
import 'package:oolaf_flutted/utils/short_video_article_history_persistence.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/short_video_playback_coordinator.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoHeadlinePage extends StatefulWidget {
  const ShortVideoHeadlinePage({super.key});

  @override
  State<ShortVideoHeadlinePage> createState() => _ShortVideoHeadlinePageState();
}

class _ShortVideoHeadlinePageState extends State<ShortVideoHeadlinePage>
    with AutomaticKeepAliveClientMixin {
  final PreloadPageController _pageController = PreloadPageController();
  final VideoManager _videoManager = VideoManager();
  final ShortVideoPlaybackCoordinator _playbackCoordinator =
      ShortVideoPlaybackCoordinator.instance;

  bool _isLoading = true;
  bool _isPaging = false;
  bool _hasMore = true;
  int _nextPullNum = 1;
  int _activeIndex = 0;
  int _requestGeneration = 0;
  bool _docSpeedBoosting = false;
  List<HeadlineFeedItem> _items = const <HeadlineFeedItem>[];

  String get _ownerKey => 'short_video_headline_tab';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videoManager.keepWindow = 2;
    _playbackCoordinator.register(scope: _ownerKey, manager: _videoManager);
    _loadInitial();
  }

  @override
  void dispose() {
    _playbackCoordinator.unregister(_ownerKey);
    _videoManager.disposeManager();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _items = const <HeadlineFeedItem>[];
      _nextPullNum = 1;
      _hasMore = true;
    });
    await _loadMore(reset: true);
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadMore({bool reset = false}) async {
    if (_isPaging || !_hasMore) {
      return;
    }
    _isPaging = true;
    final requestGeneration = ++_requestGeneration;
    final pullNum = reset ? 1 : _nextPullNum;

    try {
      final incoming = await getShortVideoHeadlinePage(
        pullNum: pullNum,
        dailyOpenNum: nextShortVideoDailyOpenNum(),
      );
      if (!mounted || requestGeneration != _requestGeneration) {
        return;
      }
      if (incoming.isEmpty) {
        setState(() {
          _hasMore = false;
        });
        return;
      }

      setState(() {
        final currentIds = _items
            .map((item) => item.type == HeadlineFeedItemType.phvideo
                ? item.video?.id
                : item.doc?.id)
            .whereType<String>()
            .toSet();
        final merged = <HeadlineFeedItem>[..._items];
        for (final item in incoming) {
          final id = item.type == HeadlineFeedItemType.phvideo
              ? item.video?.id
              : item.doc?.id;
          if (id == null || currentIds.contains(id)) {
            continue;
          }
          currentIds.add(id);
          merged.add(item);
        }
        _items = merged;
        _nextPullNum = pullNum + 1;
      });
      await _syncVideoSourcesAndPlay();
    } finally {
      _isPaging = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _controllerIdOf(ShortVideoItem item) {
    return '$_ownerKey:${item.id}';
  }

  Future<void> _syncVideoSourcesAndPlay() async {
    final videos = _items
        .where((item) => item.type == HeadlineFeedItemType.phvideo)
        .map((item) => item.video)
        .whereType<ShortVideoItem>()
        .toList(growable: false);
    final sources = videos
        .map((item) => (id: _controllerIdOf(item), url: item.videoUrl))
        .toList(growable: false);
    _videoManager.setSources(sources);

    final videoIndex = _activeVideoIndexFromPageIndex(_activeIndex);
    if (videoIndex >= 0) {
      await _videoManager.setActiveIndex(videoIndex);
      await _playbackCoordinator.activate(_ownerKey);
      await _videoManager.playActive();
    } else {
      await _playbackCoordinator.pause(_ownerKey);
    }
  }

  int _activeVideoIndexFromPageIndex(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= _items.length) {
      return -1;
    }
    var count = -1;
    for (var i = 0; i <= pageIndex; i += 1) {
      if (_items[i].type == HeadlineFeedItemType.phvideo) {
        count += 1;
      }
    }
    return count;
  }

  OolafVideoController? _controllerOfItem(HeadlineFeedItem item) {
    final video = item.video;
    if (video == null) {
      return null;
    }
    return _videoManager.getById(_controllerIdOf(video));
  }

  Future<void> _onPageChanged(int index) async {
    _activeIndex = index;
    if (_items.length - index <= 4) {
      await _loadMore();
    }
    await _syncVideoSourcesAndPlay();
  }

  void _jumpToPage(int index) {
    if (!_pageController.hasClients || index < 0 || index >= _items.length) {
      return;
    }
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openDocDetail(HeadlineFeedDocPreview preview) async {
    final detail =
        await getShortVideoNewsDocDetail(detailUrl: preview.detailUrl);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('加载失败'),
          content: const Text('图文详情暂时不可用，请稍后重试。'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('知道了'),
            ),
          ],
        ),
      );
      return;
    }
    await ShortVideoArticleHistoryPersistence.record(
      ShortVideoArticleHistoryEntry(
        docId: preview.id,
        title: preview.title,
        source: preview.source,
        updateTime: preview.updateTime,
        coverUrl: preview.coverUrl,
        detailUrl: preview.detailUrl,
        viewedAtMillis: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) {
      return;
    }
    await openShortVideoArticleDetailPage(
      context,
      detail: detail,
      coverUrl: preview.coverUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_items.isEmpty) {
      return const Center(
        child: Text('暂无内容', style: TextStyle(color: Color(0xFF8E8E93))),
      );
    }

    return PreloadPageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      preloadPagesCount: 2,
      itemCount: _items.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final item = _items[index];
        if (item.type == HeadlineFeedItemType.phvideo) {
          final video = item.video!;
          return _HeadlineVideoPageItem(
            item: video,
            controller: _controllerOfItem(item),
            onSwipeUp: () => _jumpToPage(_activeIndex + 1),
            onSwipeDown: () => _jumpToPage(_activeIndex - 1),
            onCopyLink: () async {
              await Clipboard.setData(ClipboardData(text: video.videoUrl));
            },
          );
        }

        final doc = item.doc!;
        return _HeadlineDocPageItem(
          doc: doc,
          speedBoost: _docSpeedBoosting,
          onTapDetail: () => _openDocDetail(doc),
          onSwipeUp: () => _jumpToPage(_activeIndex + 1),
          onSwipeDown: () => _jumpToPage(_activeIndex - 1),
          onLongPressStart: () => setState(() => _docSpeedBoosting = true),
          onLongPressEnd: () => setState(() => _docSpeedBoosting = false),
          onNotInterested: () {
            setState(() {
              _items = _items
                  .where((element) => element.doc?.id != doc.id)
                  .toList(growable: false);
              if (_activeIndex >= _items.length) {
                _activeIndex = _items.isEmpty ? 0 : _items.length - 1;
              }
            });
          },
        );
      },
    );
  }
}

class _HeadlineVideoPageItem extends StatelessWidget {
  const _HeadlineVideoPageItem({
    required this.item,
    required this.controller,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onCopyLink,
  });

  final ShortVideoItem item;
  final OolafVideoController? controller;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final Future<void> Function() onCopyLink;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ShortVideoPlayerWrapper(
          controller: controller,
          onSingleTap: () {},
          onLongPress: () {},
          onDoubleTap: () {},
          onSwipeUp: onSwipeUp,
          onSwipeDown: onSwipeDown,
          onRetry: () async {
            await controller?.initialize();
            await controller?.play();
          },
          onCopyLink: onCopyLink,
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 96,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x66000000),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.source ?? '凤凰视频',
                    style: const TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeadlineDocPageItem extends StatelessWidget {
  const _HeadlineDocPageItem({
    required this.doc,
    required this.speedBoost,
    required this.onTapDetail,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onNotInterested,
  });

  final HeadlineFeedDocPreview doc;
  final bool speedBoost;
  final VoidCallback onTapDetail;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onNotInterested;
  static const String _fallbackCoverBaseUrl = 'https://picsum.photos/1200/500';

  String get _previewText {
    final intro = doc.intro.trim();
    return intro.isEmpty ? '点击查看完整图文内容' : intro;
  }

  Future<void> _copyDocPreview(BuildContext context) async {
    final text = '${doc.title}\n\n$_previewText'.trim();
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('已复制'),
        content: const Text('图文标题和摘要已复制到剪贴板。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallbackCoverUrl = '$_fallbackCoverBaseUrl?seed=${doc.id}';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapDetail,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -260) onSwipeUp();
        if (velocity > 260) onSwipeDown();
      },
      onSecondaryTap: () async {
        final result = await showCupertinoModalPopup<String>(
          context: context,
          builder: (sheetContext) => CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(sheetContext).pop('not'),
                child: const Text('不感兴趣'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: const Text('取消'),
            ),
          ),
        );
        if (result == 'not') {
          onNotInterested();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF050505)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x33121820), Color(0xDD0B1018)],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 68, 18, 108),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x441A222E),
                      border: Border.all(
                          color: const Color(0x66FFFFFF), width: 0.7),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55000000),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 34,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(22),
                              topRight: Radius.circular(22),
                            ),
                            child: _DocCoverImage(
                              primaryUrl: doc.coverUrl,
                              fallbackUrl: fallbackCoverUrl,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 66,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectionArea(
                                  child: SelectableText(
                                    doc.title,
                                    maxLines: 3,
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      height: 1.24,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SelectionArea(
                                    child: SelectableText(
                                      _previewText,
                                      maxLines: 7,
                                      style: const TextStyle(
                                        color: Color(0xD9E6EDF8),
                                        fontSize: 15,
                                        height: 1.55,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        doc.source,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xB3FFFFFF),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (doc.updateTime.trim().isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        doc.updateTime.trim(),
                                        style: const TextStyle(
                                          color: Color(0x99FFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    if (doc.commentsCount
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      Text(
                                        '${doc.commentsCount.trim()} 评论',
                                        style: const TextStyle(
                                          color: Color(0x99FFFFFF),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 10),
                                    Text(
                                      speedBoost ? '2x 阅读' : '点击查看详情',
                                      style: TextStyle(
                                        color: speedBoost
                                            ? const Color(0xFF7CC4FF)
                                            : const Color(0x99FFFFFF),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      onPressed: () {
                                        _copyDocPreview(context);
                                      },
                                      child: const Icon(
                                        CupertinoIcons.doc_on_doc,
                                        color: Color(0xB3FFFFFF),
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocCoverImage extends StatefulWidget {
  const _DocCoverImage({
    required this.primaryUrl,
    required this.fallbackUrl,
  });

  final String primaryUrl;
  final String fallbackUrl;

  @override
  State<_DocCoverImage> createState() => _DocCoverImageState();
}

class _DocCoverImageState extends State<_DocCoverImage> {
  late String _activeUrl;

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.primaryUrl.trim().isNotEmpty
        ? widget.primaryUrl
        : widget.fallbackUrl;
  }

  @override
  void didUpdateWidget(covariant _DocCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.primaryUrl != widget.primaryUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _activeUrl = widget.primaryUrl.trim().isNotEmpty
          ? widget.primaryUrl
          : widget.fallbackUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomNetworkImage(
      _activeUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        if (_activeUrl != widget.fallbackUrl) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            setState(() {
              _activeUrl = widget.fallbackUrl;
            });
          });
        }
        return const ColoredBox(color: Color(0xFF202632));
      },
    );
  }
}
