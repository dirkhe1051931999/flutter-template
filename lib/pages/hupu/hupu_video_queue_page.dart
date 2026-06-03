import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';
import 'package:oolaf_flutted/utils/video_manager.dart';

const Set<PointerDeviceKind> _hupuVideoQueueDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

String _formatHupuPublishTime(HupuFeedItem item) {
  final seconds = item.lastPostTime > 0 ? item.lastPostTime : item.createTime;
  if (seconds <= 0) {
    return '';
  }
  final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes >= 0 && diff.inMinutes < 60) {
    return '${diff.inMinutes}分钟前';
  }
  if (diff.inHours >= 0 && diff.inHours < 24) {
    return '${diff.inHours}小时前';
  }
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$month-$day $hour:$minute';
}

class HupuVideoQueuePage extends StatefulWidget {
  const HupuVideoQueuePage({
    super.key,
    required this.initialVideoId,
    required this.videoItemsProvider,
    required this.onLoadMore,
    required this.hasMoreProvider,
  });

  final String initialVideoId;
  final List<HupuFeedItem> Function() videoItemsProvider;
  final Future<void> Function() onLoadMore;
  final bool Function() hasMoreProvider;

  @override
  State<HupuVideoQueuePage> createState() => _HupuVideoQueuePageState();
}

class _HupuVideoQueuePageState extends State<HupuVideoQueuePage>
    with WidgetsBindingObserver {
  static const String _scope = 'hupu_video_queue';
  static const int _preloadTriggerRemainingCount = 5;

  final PageController _pageController = PageController();
  final VideoManager _videoManager = VideoManager();

  List<HupuFeedItem> _videoItems = const <HupuFeedItem>[];
  int _activeIndex = 0;
  bool _isAppActive = true;
  bool _isLoadingMore = false;
  int _playerRefreshEpoch = 0;
  bool _detailsExpanded = false;

  HupuFeedItem? get _activeItem {
    if (_videoItems.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _videoItems.length) {
      return null;
    }
    return _videoItems[_activeIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshVideoItems(initialSelectionId: widget.initialVideoId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _videoItems.isEmpty) {
        return;
      }
      _videoManager.acquire(_scope);
      _videoManager.setSources(_buildSources(_videoItems));
      await _videoManager.setActiveIndex(_activeIndex);
      await _videoManager.playActive();
      if (_activeIndex > 0) {
        _pageController.jumpToPage(_activeIndex);
      }
      await _loadMoreIfNeeded(_activeIndex);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    unawaited(_videoManager.release(_scope));
    unawaited(_videoManager.disposeManager());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;
    if (_isAppActive && !wasActive) {
      unawaited(_videoManager.playActive());
      _schedulePlayerRefresh();
    } else if (!_isAppActive && wasActive) {
      unawaited(_videoManager.pauseAll());
    }
  }

  @override
  void didChangeMetrics() {
    if (!mounted) {
      return;
    }
    setState(() {
      _playerRefreshEpoch++;
    });
  }

  void _refreshVideoItems({String? initialSelectionId}) {
    final latest = widget.videoItemsProvider();
    if (latest.isEmpty) {
      if (mounted) {
        setState(() {
          _videoItems = const <HupuFeedItem>[];
          _activeIndex = 0;
        });
      }
      return;
    }

    final selectedId = initialSelectionId ?? _activeItem?.uniqueKey;
    final nextIndex = selectedId == null
        ? _activeIndex.clamp(0, latest.length - 1)
        : latest.indexWhere((item) => item.uniqueKey == selectedId);
    final resolvedIndex = nextIndex < 0 ? 0 : nextIndex;

    if (mounted) {
      setState(() {
        _videoItems = List<HupuFeedItem>.unmodifiable(latest);
        _activeIndex = resolvedIndex;
      });
    } else {
      _videoItems = List<HupuFeedItem>.unmodifiable(latest);
      _activeIndex = resolvedIndex;
    }
  }

  List<({String id, String url})> _buildSources(List<HupuFeedItem> items) {
    return items
        .map(
          (item) => (
            id: 'hupu_video:${item.uniqueKey}',
            url: item.video!.videoUrl,
          ),
        )
        .toList(growable: false);
  }

  OolafVideoController? _controllerOf(HupuFeedItem item) {
    return _videoManager.getById('hupu_video:${item.uniqueKey}');
  }

  Future<void> _handlePageChanged(int index) async {
    _activeIndex = index;
    _videoManager.setSources(_buildSources(_videoItems));
    await _videoManager.setActiveIndex(index);
    await _videoManager.playActive();
    _schedulePlayerRefresh();
    if (mounted) {
      setState(() {});
    }
    await _loadMoreIfNeeded(index);
  }

  void _schedulePlayerRefresh() {
    final refreshToken = _activeIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted || refreshToken != _activeIndex) {
          return;
        }
        setState(() {
          _playerRefreshEpoch++;
        });
      });
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (!mounted || refreshToken != _activeIndex) {
          return;
        }
        setState(() {
          _playerRefreshEpoch++;
        });
      });
    });
  }

  Future<void> _loadMoreIfNeeded(int index) async {
    if (_isLoadingMore || !widget.hasMoreProvider()) {
      return;
    }
    final remainingCount = _videoItems.length - index - 1;
    if (remainingCount > _preloadTriggerRemainingCount) {
      return;
    }
    _isLoadingMore = true;
    try {
      final selectedId = _activeItem?.uniqueKey;
      await widget.onLoadMore();
      if (!mounted) {
        return;
      }
      _refreshVideoItems(initialSelectionId: selectedId);
      _videoManager.setSources(_buildSources(_videoItems));
      await _videoManager.setActiveIndex(_activeIndex);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> _copyLink(HupuFeedItem item) async {
    final video = item.video;
    if (video == null || video.videoUrl.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: video.videoUrl));
  }

  Future<void> _showNextVideo() async {
    final targetIndex = _activeIndex + 1;
    if (targetIndex >= _videoItems.length) {
      await _loadMoreIfNeeded(_activeIndex);
      if (!mounted || targetIndex >= _videoItems.length) {
        return;
      }
    }
    await _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _showPreviousVideo() async {
    final targetIndex = _activeIndex - 1;
    if (targetIndex < 0) {
      return;
    }
    await _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_videoItems.isEmpty) {
      return CupertinoPageScaffold(
        backgroundColor: const Color(0xFF0B0B0F),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: AppAssetIcon(
                        assetName: 'play',
                        color: CupertinoColors.white,
                        size: 30,
                        fallbackIcon: CupertinoIcons.play_rectangle_fill,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '暂无可播放视频',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '当前已加载的虎扑帖子里还没有可播放的视频内容。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: const Color(0x1AFFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text(
                      '返回列表',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF05060A),
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _hupuVideoQueueDragDevices,
        ),
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _videoItems.length,
          onPageChanged: (index) {
            unawaited(_handlePageChanged(index));
          },
          itemBuilder: (context, index) {
            final item = _videoItems[index];
            return _HupuVideoPageItem(
              key: ValueKey<String>(
                  'hupu_video_page_${item.uniqueKey}_$_playerRefreshEpoch'),
              item: item,
              controller: _controllerOf(item),
              isActive: index == _activeIndex,
              isDetailsExpanded: _detailsExpanded,
              onBack: () => Navigator.of(context).maybePop(),
              onCopyLink: () => _copyLink(item),
              onExpandDetails: () {
                if (_detailsExpanded) {
                  return;
                }
                setState(() {
                  _detailsExpanded = true;
                });
              },
              onCollapseDetails: () {
                if (!_detailsExpanded) {
                  return;
                }
                setState(() {
                  _detailsExpanded = false;
                });
              },
              onSwipeUp: _showNextVideo,
              onSwipeDown: _showPreviousVideo,
            );
          },
        ),
      ),
    );
  }
}

class _ExpandHandleButton extends StatelessWidget {
  const _ExpandHandleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(26, 26),
      onPressed: onPressed,
      child: const Icon(
        CupertinoIcons.chevron_up,
        color: CupertinoColors.white,
        size: 18,
      ),
    );
  }
}

class _CollapseHandleButton extends StatelessWidget {
  const _CollapseHandleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0x4DFFFFFF)),
        shape: BoxShape.circle,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(34, 34),
        onPressed: onPressed,
        child: const Icon(
          CupertinoIcons.chevron_down,
          color: CupertinoColors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _CollapsedVideoInfoBar extends StatelessWidget {
  const _CollapsedVideoInfoBar({
    required this.title,
    required this.onExpand,
  });

  final String title;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(999),
          minimumSize: Size.zero,
          onPressed: onExpand,
          child: const Text(
            '展开',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(36, 36),
        onPressed: onPressed,
        child: Icon(
          icon,
          color: CupertinoColors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  const _StatCapsule({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HupuVideoPageItem extends StatelessWidget {
  const _HupuVideoPageItem({
    super.key,
    required this.item,
    required this.controller,
    required this.isActive,
    required this.isDetailsExpanded,
    required this.onBack,
    required this.onCopyLink,
    required this.onExpandDetails,
    required this.onCollapseDetails,
    required this.onSwipeUp,
    required this.onSwipeDown,
  });

  final HupuFeedItem item;
  final OolafVideoController? controller;
  final bool isActive;
  final bool isDetailsExpanded;
  final VoidCallback onBack;
  final Future<void> Function() onCopyLink;
  final VoidCallback onExpandDetails;
  final VoidCallback onCollapseDetails;
  final Future<void> Function() onSwipeUp;
  final Future<void> Function() onSwipeDown;

  @override
  Widget build(BuildContext context) {
    final video = item.video!;
    final coverUrl = video.backgroundImage.isNotEmpty
        ? video.backgroundImage
        : (video.cover.isNotEmpty ? video.cover : item.header);
    final publishTimeText = _formatHupuPublishTime(item);
    final metaText = [video.playCount, video.duration, video.size]
        .where((value) => value.trim().isNotEmpty)
        .join('  ');
    final summaryText = item.summary.trim().isNotEmpty
        ? item.summary.trim()
        : '虎扑热帖视频内容，沉浸式浏览当前已加载的视频帖子。';

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomNetworkImage(
          coverUrl,
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xC0000000),
                Color(0x40000000),
                Color(0xD9000000),
              ],
              stops: [0, 0.35, 1],
            ),
          ),
        ),
        ShortVideoPlayerWrapper(
          controller: controller,
          onSingleTap: () {},
          onLongPress: () {},
          onDoubleTap: () {},
          onSwipeUp: () {
            unawaited(onSwipeUp());
          },
          onSwipeDown: () {
            unawaited(onSwipeDown());
          },
          progressBarBottomOffset: 0,
          enableVerticalSwipeGestures: true,
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSlide(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  offset: isActive ? Offset.zero : const Offset(0, -0.06),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isActive ? 1 : 0.9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: BoxDecoration(
                            color: const Color(0x2411171F),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0x26FFFFFF)),
                          ),
                          child: Row(
                            children: [
                              _TopActionButton(
                                icon: CupertinoIcons.back,
                                onPressed: onBack,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.forumName.isEmpty
                                          ? item.topicName
                                          : item.forumName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '第 ${item.replies} 条讨论热帖视频流',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xB3FFFFFF),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _TopActionButton(
                                icon: CupertinoIcons.link,
                                onPressed: () {
                                  unawaited(onCopyLink());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                AnimatedSlide(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  offset: isActive ? Offset.zero : const Offset(0, 0.04),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isActive ? 1 : 0.92,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x36171A1F),
                                Color(0x1D171A1F),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: const Color(0x30FFFFFF)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x33000000),
                                blurRadius: 24,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (!isDetailsExpanded) ...[
                                    _ExpandHandleButton(
                                        onPressed: onExpandDetails),
                                    const SizedBox(width: 10),
                                  ],
                                  ClipOval(
                                    child: CustomNetworkImage(
                                      item.header,
                                      width: isDetailsExpanded ? 46 : 38,
                                      height: isDetailsExpanded ? 46 : 38,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.nickname.isEmpty
                                              ? '虎扑用户'
                                              : item.nickname,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          publishTimeText.isNotEmpty
                                              ? '$metaText  $publishTimeText'
                                              : metaText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xCCFFFFFF),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0x1FFFFFFF),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      '视频帖',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (isDetailsExpanded) ...[
                                    const SizedBox(width: 10),
                                    _CollapseHandleButton(
                                        onPressed: onCollapseDetails),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 12),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: isDetailsExpanded
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 22,
                                              height: 1.32,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            summaryText,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xCCFFFFFF),
                                              fontSize: 14,
                                              height: 1.55,
                                            ),
                                          ),
                                          const SizedBox(height: 14),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              _InfoChip(
                                                  label: item.topicName.isEmpty
                                                      ? '未分类'
                                                      : item.topicName),
                                              _InfoChip(
                                                  label: '${item.replies}回复'),
                                              _InfoChip(
                                                  label: '${item.lights}亮了'),
                                              if (video.bulletCommentCount
                                                  .isNotEmpty)
                                                _InfoChip(
                                                    label:
                                                        '${video.bulletCommentCount}弹幕'),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _StatCapsule(
                                                  title: '播放热度',
                                                  value: video.playCount.isEmpty
                                                      ? '--'
                                                      : video.playCount,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _StatCapsule(
                                                  title: '视频时长',
                                                  value: video.duration.isEmpty
                                                      ? '--'
                                                      : video.duration,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: _StatCapsule(
                                                  title: '文件大小',
                                                  value: video.size.isEmpty
                                                      ? '--'
                                                      : video.size,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : _CollapsedVideoInfoBar(
                                        title: item.title,
                                        onExpand: onExpandDetails,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: isActive
                      ? Center(
                          child: Container(
                            key: ValueKey<String>(
                                'queue_hint_${item.uniqueKey}'),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '上滑切换下一个视频',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        if (!isActive) const SizedBox.shrink(),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
