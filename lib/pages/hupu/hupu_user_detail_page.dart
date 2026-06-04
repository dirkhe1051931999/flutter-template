import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';
import 'package:oolaf_flutted/components/app_tab/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_status_view.dart';

class HupuUserDetailPage extends StatefulWidget {
  const HupuUserDetailPage({
    required this.puid,
    this.initialNickname = '',
    this.initialAvatar = '',
    super.key,
  });

  final String puid;
  final String initialNickname;
  final String initialAvatar;

  @override
  State<HupuUserDetailPage> createState() => _HupuUserDetailPageState();
}

class _HupuUserDetailPageState extends State<HupuUserDetailPage> {
  static const int _replyTabIndex = 1;
  static const int _recommendTabIndex = 2;

  HupuUserProfile? _profile;
  int _activeTabIndex = 0;
  bool _isLoadingProfile = true;
  String? _profileErrorMessage;
  double _bannerCollapseProgress = 0;

  List<HupuUserThreadRecord> _postItems = const <HupuUserThreadRecord>[];
  int _postPage = 1;
  bool _hasMorePosts = false;
  bool _isLoadingPosts = false;
  bool _isLoadingMorePosts = false;
  String? _postErrorMessage;

  List<HupuUserReplyRecord> _replyItems = const <HupuUserReplyRecord>[];
  int _replyMaxTime = 0;
  bool _hasMoreReplies = false;
  bool _isLoadingReplies = false;
  bool _isLoadingMoreReplies = false;
  String? _replyErrorMessage;

  List<HupuUserThreadRecord> _recommendItems = const <HupuUserThreadRecord>[];
  int _recommendPage = 1;
  bool _hasMoreRecommendations = false;
  bool _isLoadingRecommendations = false;
  bool _isLoadingMoreRecommendations = false;
  String? _recommendErrorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_loadInitial());
  }

  Future<void> _loadInitial() async {
    await _loadProfile();
    unawaited(_loadPosts(reset: true));
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoadingProfile = true;
      _profileErrorMessage = null;
    });

    try {
      final profile = await getHupuUserProfile(puid: widget.puid);
      if (!mounted) {
        return;
      }
      setState(() {
        _profile = profile;
        _isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _profileErrorMessage = error.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadPosts({required bool reset}) async {
    if (_isLoadingPosts || _isLoadingMorePosts) {
      return;
    }
    if (!reset && !_hasMorePosts) {
      return;
    }

    setState(() {
      if (reset) {
        _isLoadingPosts = true;
        _postErrorMessage = null;
      } else {
        _isLoadingMorePosts = true;
      }
    });

    try {
      final nextPage = reset ? 1 : _postPage + 1;
      final response = await getHupuUserThreads(
        puid: widget.puid,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _postItems = reset
            ? response.items
            : _mergeThreadRecords(_postItems, response.items);
        _postPage = nextPage;
        _hasMorePosts = response.hasNextPage && response.items.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _postErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
          _isLoadingMorePosts = false;
        });
      }
    }
  }

  Future<void> _loadReplies({required bool reset}) async {
    if (_isLoadingReplies || _isLoadingMoreReplies) {
      return;
    }
    if (!reset && !_hasMoreReplies) {
      return;
    }

    setState(() {
      if (reset) {
        _isLoadingReplies = true;
        _replyErrorMessage = null;
      } else {
        _isLoadingMoreReplies = true;
      }
    });

    try {
      final response = await getHupuUserReplies(
        puid: widget.puid,
        maxTime: reset ? 0 : _replyMaxTime,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _replyItems = reset
            ? response.items
            : _mergeReplyRecords(_replyItems, response.items);
        _replyMaxTime = response.nextMaxTime;
        _hasMoreReplies = response.hasNextPage && response.items.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _replyErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReplies = false;
          _isLoadingMoreReplies = false;
        });
      }
    }
  }

  Future<void> _loadRecommendations({required bool reset}) async {
    if (_isLoadingRecommendations || _isLoadingMoreRecommendations) {
      return;
    }
    if (!reset && !_hasMoreRecommendations) {
      return;
    }

    setState(() {
      if (reset) {
        _isLoadingRecommendations = true;
        _recommendErrorMessage = null;
      } else {
        _isLoadingMoreRecommendations = true;
      }
    });

    try {
      final nextPage = reset ? 1 : _recommendPage + 1;
      final response = await getHupuUserRecommendations(
        puid: widget.puid,
        page: nextPage,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _recommendItems = reset
            ? response.items
            : _mergeThreadRecords(_recommendItems, response.items);
        _recommendPage = nextPage;
        _hasMoreRecommendations =
            response.hasNextPage && response.items.isNotEmpty;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _recommendErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
          _isLoadingMoreRecommendations = false;
        });
      }
    }
  }

  void _handleTabChanged(int index) {
    if (_activeTabIndex == index) {
      return;
    }
    setState(() {
      _activeTabIndex = index;
    });

    if (index == _replyTabIndex && _replyItems.isEmpty && !_isLoadingReplies) {
      unawaited(_loadReplies(reset: true));
    }
    if (index == _recommendTabIndex &&
        _recommendItems.isEmpty &&
        !_isLoadingRecommendations) {
      unawaited(_loadRecommendations(reset: true));
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final progress = (notification.metrics.pixels / 132).clamp(0.0, 1.0);
    if ((progress - _bannerCollapseProgress).abs() < 0.01) {
      return false;
    }
    setState(() {
      _bannerCollapseProgress = progress;
    });
    return false;
  }

  Future<void> _openPostDetail({
    required String tid,
    required String fid,
    required int topicId,
    required String title,
  }) async {
    if (tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: tid,
          fid: fid,
          topicId: topicId,
          initialTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      child: SafeArea(
        bottom: false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoadingProfile && _profile == null) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (_profile == null) {
      return HupuStatusView(
        message: '用户详情加载失败',
        detail: _profileErrorMessage,
        onRetry: _loadInitial,
      );
    }

    final profile = _profile!;
    return Column(
      children: [
        _UserDetailBanner(
          profile: profile,
          collapseProgress: _bannerCollapseProgress,
          fallbackAvatar: widget.initialAvatar,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: AppTabs(
              activeKey: _activeTabIndex,
              onChange: _handleTabChanged,
              backgroundColor: CupertinoColors.white,
              color: const Color(0xFFFF1E2D),
              titleActiveColor: const Color(0xFF202127),
              titleInactiveColor: const Color(0xFF9AA1AE),
              headerHeight: 50,
              lineWidth: 26,
              lineHeight: 3,
              swipeable: true,
              lazyRender: false,
              items: <AppTabItemData>[
                AppTabItemData(
                  title: '发帖 ${profile.postCount}',
                  child: _UserThreadTabView(
                    items: _postItems,
                    isLoading: _isLoadingPosts,
                    isLoadingMore: _isLoadingMorePosts,
                    errorMessage: _postErrorMessage,
                    hasMore: _hasMorePosts,
                    emptyTitle: '暂无发帖',
                    onRetry: () => _loadPosts(reset: true),
                    onLoadMore: () => _loadPosts(reset: false),
                    onTapItem: (item) => _openPostDetail(
                      tid: item.tid,
                      fid: item.fid,
                      topicId: item.topicId,
                      title: item.title,
                    ),
                  ),
                ),
                AppTabItemData(
                  title: '回帖 ${profile.replyCount}',
                  child: _UserReplyTabView(
                    items: _replyItems,
                    isLoading: _isLoadingReplies,
                    isLoadingMore: _isLoadingMoreReplies,
                    errorMessage: _replyErrorMessage,
                    hasMore: _hasMoreReplies,
                    onRetry: () => _loadReplies(reset: true),
                    onLoadMore: () => _loadReplies(reset: false),
                    onTapItem: (item) => _openPostDetail(
                      tid: item.tid,
                      fid: '',
                      topicId: 0,
                      title: item.title,
                    ),
                  ),
                ),
                AppTabItemData(
                  title: '推荐 ${profile.recommendCount}',
                  child: _UserThreadTabView(
                    items: _recommendItems,
                    isLoading: _isLoadingRecommendations,
                    isLoadingMore: _isLoadingMoreRecommendations,
                    errorMessage: _recommendErrorMessage,
                    hasMore: _hasMoreRecommendations,
                    emptyTitle: '暂无推荐',
                    onRetry: () => _loadRecommendations(reset: true),
                    onLoadMore: () => _loadRecommendations(reset: false),
                    onTapItem: (item) => _openPostDetail(
                      tid: item.tid,
                      fid: item.fid,
                      topicId: item.topicId,
                      title: item.title,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _UserDetailBanner extends StatelessWidget {
  const _UserDetailBanner({
    required this.profile,
    required this.collapseProgress,
    required this.fallbackAvatar,
    required this.onBack,
  });

  final HupuUserProfile profile;
  final double collapseProgress;
  final String fallbackAvatar;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topHeight = lerpDouble(146, 88, collapseProgress)!;
    final cardPaddingTop = lerpDouble(26, 10, collapseProgress)!;
    final statOpacity = (1 - collapseProgress * 1.8).clamp(0.0, 1.0);
    final avatarSize = lerpDouble(58, 42, collapseProgress)!;
    final nameFontSize = lerpDouble(18, 16, collapseProgress)!;
    final showMeta = collapseProgress < 0.92;

    return ColoredBox(
      color: const Color(0xFFF4F5F7),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: topHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2C2F36),
                  const Color(0xFF191B21),
                  const Color(0xFF121419).withValues(alpha: 0.96),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(32, 32),
                    onPressed: onBack,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: CupertinoColors.white,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    CupertinoIcons.ellipsis,
                    color: CupertinoColors.white,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, lerpDouble(-26, -10, collapseProgress)!),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: EdgeInsets.fromLTRB(16, cardPaddingTop, 16, 12),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset:
                            Offset(0, lerpDouble(-18, -4, collapseProgress)!),
                        child: ClipOval(
                          child: CustomNetworkImage(
                            profile.header.isNotEmpty
                                ? profile.header
                                : fallbackAvatar,
                            width: avatarSize,
                            height: avatarSize,
                            skeletonBorderRadius:
                                BorderRadius.circular(avatarSize / 2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    profile.nickname.isEmpty
                                        ? '虎扑用户'
                                        : profile.nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: const Color(0xFF202127),
                                      fontSize: nameFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (profile.gender == 1)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(
                                      '♂',
                                      style: TextStyle(
                                        color: Color(0xFF4D8EFF),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else if (profile.gender == 2)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text(
                                      '♀',
                                      style: TextStyle(
                                        color: Color(0xFFFF6B96),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (showMeta) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                runSpacing: 6,
                                children: [
                                  if (_resolveLocationText(profile).isNotEmpty)
                                    _MetaChip(
                                        text: _resolveLocationText(profile)),
                                  if (profile.regTimeText.isNotEmpty)
                                    _MetaChip(text: profile.regTimeText),
                                  if (profile.reputationValue > 0)
                                    _MetaChip(
                                        text: '${profile.reputationValue}声望'),
                                  if (profile.levelText.isNotEmpty)
                                    _MetaChip(text: profile.levelText),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            color: const Color(0xFFFF1E2D),
                            child: Text(
                              _followButtonLabel(profile.followStatus),
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (collapseProgress < 0.72) ...[
                            const SizedBox(height: 10),
                            Container(
                              width: 42,
                              height: 34,
                              alignment: Alignment.center,
                              color: const Color(0xFFF3F5FA),
                              child: const Icon(
                                CupertinoIcons.mail,
                                color: Color(0xFF6A7180),
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (statOpacity > 0) ...[
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: statOpacity,
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProfileStat(
                              value: _formatCount(profile.beLightCount),
                              label: '被点亮',
                            ),
                          ),
                          Expanded(
                            child: _ProfileStat(
                              value: _formatCount(profile.beRecommendCount),
                              label: '被推荐',
                            ),
                          ),
                          Expanded(
                            child: _ProfileStat(
                              value: _formatCount(profile.followCount),
                              label: '关注',
                            ),
                          ),
                          Expanded(
                            child: _ProfileStat(
                              value: _formatCount(profile.fansCount),
                              label: '粉丝',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: const Color(0xFFF5F6F8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6A7180),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F96A3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _UserThreadTabView extends StatelessWidget {
  const _UserThreadTabView({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.hasMore,
    required this.emptyTitle,
    required this.onRetry,
    required this.onLoadMore,
    required this.onTapItem,
  });

  final List<HupuUserThreadRecord> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final String emptyTitle;
  final Future<void> Function() onRetry;
  final Future<void> Function() onLoadMore;
  final ValueChanged<HupuUserThreadRecord> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return HupuStatusView(
        message: '内容加载失败',
        detail: errorMessage,
        onRetry: onRetry,
      );
    }

    if (items.isEmpty) {
      return _EmptyTabView(title: emptyTitle);
    }

    return _LoadMoreListView(
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      onLoadMore: onLoadMore,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            );
          }
          final item = items[index];
          return _UserThreadTile(
            item: item,
            onTap: () => onTapItem(item),
          );
        },
      ),
    );
  }
}

class _UserReplyTabView extends StatelessWidget {
  const _UserReplyTabView({
    required this.items,
    required this.isLoading,
    required this.isLoadingMore,
    required this.errorMessage,
    required this.hasMore,
    required this.onRetry,
    required this.onLoadMore,
    required this.onTapItem,
  });

  final List<HupuUserReplyRecord> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasMore;
  final Future<void> Function() onRetry;
  final Future<void> Function() onLoadMore;
  final ValueChanged<HupuUserReplyRecord> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (isLoading && items.isEmpty) {
      return const Center(
        child: CupertinoActivityIndicator(radius: 14),
      );
    }

    if (errorMessage != null && items.isEmpty) {
      return HupuStatusView(
        message: '回帖加载失败',
        detail: errorMessage,
        onRetry: onRetry,
      );
    }

    if (items.isEmpty) {
      return const _EmptyTabView(title: '暂无回帖');
    }

    return _LoadMoreListView(
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      onLoadMore: onLoadMore,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 18),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: items.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            );
          }
          final item = items[index];
          return _UserReplyTile(
            item: item,
            onTap: () => onTapItem(item),
          );
        },
      ),
    );
  }
}

class _UserThreadTile extends StatelessWidget {
  const _UserThreadTile({
    required this.item,
    required this.onTap,
  });

  final HupuUserThreadRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover =
        item.pics.isNotEmpty ? item.pics.first.url : item.video?.cover ?? '';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: CustomNetworkImage(
                    item.header,
                    width: 36,
                    height: 36,
                    skeletonBorderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nickname.isEmpty ? '虎扑用户' : item.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatThreadDate(
                          item.lastPostTime > 0
                              ? item.lastPostTime
                              : item.createTime,
                        ),
                        style: const TextStyle(
                          color: Color(0xFF9AA1AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                height: 1.45,
              ),
            ),
            if (item.summary.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF606773),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
            if (cover.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CustomNetworkImage(
                  cover,
                  width: 180,
                  height: 132,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.forumName.isEmpty ? item.topicName : item.forumName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8F96A3),
                      fontSize: 13,
                    ),
                  ),
                ),
                _StatText(
                  icon: CupertinoIcons.hand_thumbsup,
                  text: _formatCount(item.recommendCount),
                ),
                const SizedBox(width: 14),
                _StatText(
                  icon: CupertinoIcons.chat_bubble,
                  text: _formatCount(item.replies),
                ),
                const SizedBox(width: 14),
                _StatText(
                  icon: CupertinoIcons.share,
                  text: _formatCount(item.shareCount),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 0.7,
              color: const Color(0xFFF0F1F4),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserReplyTile extends StatelessWidget {
  const _UserReplyTile({
    required this.item,
    required this.onTap,
  });

  final HupuUserReplyRecord item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final replyImage = item.picInfos.isNotEmpty ? item.picInfos.first.url : '';
    final quote = item.quoteInfo;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: CustomNetworkImage(
                    item.header,
                    width: 34,
                    height: 34,
                    skeletonBorderRadius: BorderRadius.circular(17),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.username.isEmpty ? '虎扑用户' : item.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.formatTime,
                        style: const TextStyle(
                          color: Color(0xFF9AA1AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatText(
                  icon: CupertinoIcons.hand_thumbsup,
                  text: '亮了(${item.lightCount})',
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (item.title.trim().isNotEmpty)
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF202127),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (item.content.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.content,
                style: const TextStyle(
                  color: Color(0xFF202127),
                  fontSize: 16,
                  height: 1.45,
                ),
              ),
            ],
            if (replyImage.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CustomNetworkImage(
                  replyImage,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
            if (quote != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                color: const Color(0xFFF3F5FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '主帖: ${quote.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7C8594),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (quote.content.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        quote.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8F96A3),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              height: 0.7,
              color: const Color(0xFFF0F1F4),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatText extends StatelessWidget {
  const _StatText({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF8F96A3),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF8F96A3),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LoadMoreListView extends StatefulWidget {
  const _LoadMoreListView({
    required this.child,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
  });

  final Widget child;
  final bool hasMore;
  final bool isLoadingMore;
  final Future<void> Function() onLoadMore;

  @override
  State<_LoadMoreListView> createState() => _LoadMoreListViewState();
}

class _LoadMoreListViewState extends State<_LoadMoreListView> {
  bool _handleScroll(ScrollNotification notification) {
    if (!widget.hasMore || widget.isLoadingMore) {
      return false;
    }
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification.metrics.extentAfter > 280) {
      return false;
    }
    unawaited(widget.onLoadMore());
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScroll,
      child: widget.child,
    );
  }
}

class _EmptyTabView extends StatelessWidget {
  const _EmptyTabView({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8F96A3),
          fontSize: 14,
        ),
      ),
    );
  }
}

List<HupuUserThreadRecord> _mergeThreadRecords(
  List<HupuUserThreadRecord> current,
  List<HupuUserThreadRecord> incoming,
) {
  final merged = List<HupuUserThreadRecord>.from(current);
  final ids = current.map((item) => item.tid).toSet();
  for (final item in incoming) {
    if (item.tid.isEmpty || ids.contains(item.tid)) {
      continue;
    }
    ids.add(item.tid);
    merged.add(item);
  }
  return merged;
}

List<HupuUserReplyRecord> _mergeReplyRecords(
  List<HupuUserReplyRecord> current,
  List<HupuUserReplyRecord> incoming,
) {
  final merged = List<HupuUserReplyRecord>.from(current);
  final ids = current.map((item) => item.pid).toSet();
  for (final item in incoming) {
    if (item.pid.isEmpty || ids.contains(item.pid)) {
      continue;
    }
    ids.add(item.pid);
    merged.add(item);
  }
  return merged;
}

String _resolveLocationText(HupuUserProfile profile) {
  final location = profile.locationText.trim().isNotEmpty
      ? profile.locationText.trim()
      : profile.location.trim();
  if (location.isEmpty) {
    return '';
  }
  return 'IP属地:$location';
}

String _followButtonLabel(int followStatus) {
  if (followStatus == 1) {
    return '已关注';
  }
  return '+ 关注';
}

String _formatCount(int value) {
  if (value >= 10000) {
    return '${(value / 10000).toStringAsFixed(value >= 100000 ? 0 : 1)}万+';
  }
  return '$value';
}

String _formatThreadDate(int seconds) {
  if (seconds <= 0) {
    return '';
  }
  final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  final month = time.month.toString().padLeft(2, '0');
  final day = time.day.toString().padLeft(2, '0');
  return '$month-$day';
}

double? lerpDouble(num? a, num? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  a ??= 0.0;
  b ??= 0.0;
  return a + (b - a) * t;
}
