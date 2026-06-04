import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart' as html_parser;
import 'dart:async';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/app_text_ellipsis/index.dart';
import 'package:oolaf_flutted/components/comment/comment_panel_scaffold.dart';
import 'package:oolaf_flutted/components/gallery_preview/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_helper.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_article_body_helper.dart';
import 'package:oolaf_flutted/utils/oolaf_video_player_controller.dart';

enum HupuPostCommentSort {
  hot('最热'),
  earliest('最早'),
  latest('最新'),
  author('楼主');

  const HupuPostCommentSort(this.label);

  final String label;
}

class HupuPostDetailPage extends StatefulWidget {
  const HupuPostDetailPage({
    required this.tid,
    this.fid = '',
    this.topicId = 0,
    this.initialTitle = '',
    super.key,
  });

  final String tid;
  final String fid;
  final int topicId;
  final String initialTitle;

  @override
  State<HupuPostDetailPage> createState() => _HupuPostDetailPageState();
}

class _HupuPostDetailPageState extends State<HupuPostDetailPage> {
  final ScrollController _scrollController = ScrollController();

  HupuPostDetail? _detail;
  OolafVideoPlayerController? _videoController;
  List<HupuPostComment> _lightReplies = const <HupuPostComment>[];
  final List<HupuPostComment> _allComments = <HupuPostComment>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 1;
  HupuPostCommentSort _activeSort = HupuPostCommentSort.hot;

  bool get _hasMoreComments => _currentPage < _totalPages;

  List<HupuPostComment> get _displayComments {
    final authorId = _detail?.authorPuid ?? '';
    final comments = _activeSort == HupuPostCommentSort.author
        ? _allComments.where((item) => item.userId == authorId).toList()
        : List<HupuPostComment>.from(_allComments);

    switch (_activeSort) {
      case HupuPostCommentSort.hot:
        comments
            .sort((left, right) => right.lightCount.compareTo(left.lightCount));
      case HupuPostCommentSort.earliest:
        comments
            .sort((left, right) => left.createdAt.compareTo(right.createdAt));
      case HupuPostCommentSort.latest:
        comments
            .sort((left, right) => right.createdAt.compareTo(left.createdAt));
      case HupuPostCommentSort.author:
        comments
            .sort((left, right) => left.createdAt.compareTo(right.createdAt));
    }
    return comments;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    final videoController = _videoController;
    if (videoController != null) {
      unawaited(videoController.dispose());
    }
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoading ||
        _isLoadingMore ||
        !_hasMoreComments) {
      return;
    }
    if (_scrollController.position.extentAfter > 480) {
      return;
    }
    _loadMoreComments();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await getHupuPostDetail(tid: widget.tid);
      final videoController = await _buildVideoController(detail);
      final fid = widget.fid.isNotEmpty ? widget.fid : detail.fid;
      final topicId = widget.topicId > 0 ? widget.topicId : detail.topicId;
      final responses = await Future.wait<dynamic>([
        getHupuPostLightReplies(
          tid: widget.tid,
          fid: fid,
          topicId: topicId,
        ),
        getHupuPostComments(
          tid: widget.tid,
          fid: fid,
          page: 1,
        ),
      ]);

      if (!mounted) {
        return;
      }

      final lightReplies = responses[0] as HupuPostCommentResponse;
      final comments = responses[1] as HupuPostCommentResponse;
      final previousVideoController = _videoController;
      setState(() {
        _detail = detail;
        _videoController = videoController;
        _lightReplies = lightReplies.comments;
        _allComments
          ..clear()
          ..addAll(comments.comments);
        _currentPage = comments.currentPage;
        _totalPages = comments.totalPages;
        _isLoading = false;
      });
      if (previousVideoController != null &&
          !identical(previousVideoController, videoController)) {
        unawaited(previousVideoController.dispose());
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<OolafVideoPlayerController?> _buildVideoController(
    HupuPostDetail detail,
  ) async {
    final videoUrl = detail.videoInfo?.videoUrl.trim() ?? '';
    if (videoUrl.isEmpty) {
      return null;
    }

    final controller = await OolafVideoPlayerController.fromUrl(videoUrl);
    await controller.initialize();
    await controller.setLooping(false);
    await controller.play();
    return controller;
  }

  Future<void> _loadMoreComments() async {
    final detail = _detail;
    if (detail == null || _isLoadingMore || !_hasMoreComments) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await getHupuPostComments(
        tid: detail.tid,
        fid: detail.fid,
        page: _currentPage + 1,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _allComments.addAll(response.comments);
        _currentPage = response.currentPage;
        _totalPages = response.totalPages;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      } else {
        _isLoadingMore = false;
      }
    }
  }

  Future<void> _openUserDetail({
    required String puid,
    required String nickname,
    required String avatar,
  }) {
    return openHupuUserDetail(
      context,
      puid: puid,
      initialNickname: nickname,
      initialAvatar: avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      navigationBar: _buildNavigationBar(),
      child: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 14),
              )
            : _errorMessage != null && _detail == null
                ? _buildErrorView()
                : Column(
                    children: [
                      Expanded(
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: _buildPostBody(),
                            ),
                            if (_lightReplies.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: _buildSectionDivider(),
                              ),
                              SliverToBoxAdapter(
                                child: _buildSectionHeader(
                                  title: '这些回复亮了',
                                  trailing: Text(
                                    '${_lightReplies.length}条',
                                    style: const TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCommentCard(
                                    _lightReplies[index],
                                    emphasizeLightCount: true,
                                  ),
                                  childCount: _lightReplies.length,
                                ),
                              ),
                            ],
                            SliverToBoxAdapter(
                              child: _buildSectionDivider(),
                            ),
                            SliverToBoxAdapter(
                              child: _buildSectionHeader(
                                title: '全部回复',
                                trailing: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: HupuPostCommentSort.values
                                        .map(_buildSortChip)
                                        .toList(growable: false),
                                  ),
                                ),
                              ),
                            ),
                            if (_displayComments.isEmpty)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 56),
                                  child: Center(
                                    child: Text(
                                      _activeSort == HupuPostCommentSort.author
                                          ? '楼主暂时没有参与回复'
                                          : '暂无评论',
                                      style: const TextStyle(
                                        color: Color(0xFF999999),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => _buildCommentCard(
                                    _displayComments[index],
                                  ),
                                  childCount: _displayComments.length,
                                ),
                              ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 12, 16, 24),
                                child: Center(
                                  child: _isLoadingMore
                                      ? const CupertinoActivityIndicator(
                                          radius: 10)
                                      : Text(
                                          _hasMoreComments
                                              ? '继续上拉加载更多'
                                              : '没有更多评论了',
                                          style: const TextStyle(
                                            color: Color(0xFF999999),
                                            fontSize: 12,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildBottomBar(),
                    ],
                  ),
      ),
    );
  }

  ObstructingPreferredSizeWidget _buildNavigationBar() {
    final detail = _detail;

    return RoutePageNavigationBar(
      title:
          detail?.authorName.isNotEmpty == true ? detail!.authorName : '帖子详情',
      subtitle: detail?.authorPublishTime.isNotEmpty == true
          ? detail!.authorPublishTime
          : widget.initialTitle,
      avatarUrl: detail?.authorAvatar ?? '',
      onTapIdentity: detail?.authorPuid.isNotEmpty == true
          ? () => _openUserDetail(
                puid: detail!.authorPuid,
                nickname: detail.authorName,
                avatar: detail.authorAvatar,
              )
          : null,
      onBack: () => Navigator.of(context).pop(),
      showFollowButton: true,
      showMoreButton: true,
      onTapFollow: () {},
      onTapMore: () {},
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '内容加载失败',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onPressed: _loadInitial,
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostBody() {
    final detail = _detail;
    if (detail == null) {
      return const SizedBox.shrink();
    }

    final body = ShortVideoArticleBodyHelper.parse(
      title: detail.title,
      source: detail.forumName,
      updateTime: detail.authorPublishTime,
      htmlText: detail.content,
      coverUrl: '',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (detail.hasVideo) ...[
            _buildVideoHero(detail),
            const SizedBox(height: 16),
          ],
          Text(
            detail.title,
            style: const TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF1C1C1E),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...ShortVideoArticleBodyHelper.buildWidgets(
            context: context,
            nodes: body.nodes,
            galleryImageUrls: body.imageUrls,
          ),
          const SizedBox(height: 14),
          Text(
            '${detail.forumName}  ${detail.viewCount}浏览',
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoHero(HupuPostDetail detail) {
    final videoInfo = detail.videoInfo;
    if (videoInfo == null) {
      return const SizedBox.shrink();
    }

    final controller = _videoController;
    final aspectRatio = videoInfo.aspectRatio ?? 16 / 9;
    final clampedRatio = aspectRatio.clamp(1.1, 2.2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFF000000),
        ),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: clampedRatio,
              child: controller == null
                  ? CustomNetworkImage(
                      videoInfo.coverUrl.isNotEmpty
                          ? videoInfo.coverUrl
                          : videoInfo.posterUrl,
                      fit: BoxFit.cover,
                    )
                  : ShortVideoPlayerWrapper(
                      controller: controller,
                      fit: BoxFit.contain,
                      enableVerticalSwipeGestures: false,
                      onSingleTap: () async {
                        if (controller.isPlaying.value) {
                          await controller.pause();
                        } else {
                          await controller.play();
                        }
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      onLongPress: () {},
                      onDoubleTap: () {},
                      onSwipeUp: () {},
                      onSwipeDown: () {},
                    ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  if (detail.topicName.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        detail.topicName,
                        style: const TextStyle(
                          color: Color(0xFF6E7683),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (videoInfo.playCountText.trim().isNotEmpty)
                    Text(
                      '${videoInfo.playCountText}播放',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
                      ),
                    ),
                  if (videoInfo.durationText.trim().isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Text(
                      '${videoInfo.durationText}s',
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 12,
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

  Widget _buildSectionDivider() {
    return Container(
      height: 8,
      color: const Color(0xFFF5F6F8),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Widget trailing,
  }) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSortChip(HupuPostCommentSort sort) {
    final isActive = _activeSort == sort;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSort = sort;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF2F3F5) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          sort.label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1C1C1E) : const Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildCommentCard(
    HupuPostComment comment, {
    bool emphasizeLightCount = false,
  }) {
    final parsed = _parseCommentHtml(comment.content);
    final quote = comment.quote == null
        ? null
        : _parseCommentHtml(comment.quote!.content);
    final metaParts = <String>[
      comment.timeText,
      if (comment.location.trim().isNotEmpty) comment.location.trim(),
    ];

    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: comment.userId.isEmpty
                    ? null
                    : () => _openUserDetail(
                          puid: comment.userId,
                          nickname: comment.userName,
                          avatar: comment.userAvatar,
                        ),
                child: ClipOval(
                  child: CustomNetworkImage(
                    comment.userAvatar,
                    width: 38,
                    height: 38,
                    skeletonBorderRadius: BorderRadius.circular(19),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: comment.userId.isEmpty
                          ? null
                          : () => _openUserDetail(
                                puid: comment.userId,
                                nickname: comment.userName,
                                avatar: comment.userAvatar,
                              ),
                      child: Text(
                        comment.userName.isEmpty ? '虎扑用户' : comment.userName,
                        style: const TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      metaParts.join(' 路 '),
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextEllipsis(
                      text: parsed.text,
                      rows: 4,
                      textStyle: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 16,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                      ),
                      actionStyle: const TextStyle(
                        color: Color(0xFF1C63B7),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (parsed.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: parsed.imageUrls
                            .map(
                              (url) => GalleryPreviewImage(
                                imageUrl: url,
                                galleryImageUrls: parsed.imageUrls,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                    if (quote != null && quote.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF6E6E73),
                              fontSize: 13,
                              height: 1.45,
                            ),
                            children: [
                              if (comment.quote!.userName.isNotEmpty &&
                                  comment.quote!.userId.isNotEmpty)
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _openUserDetail(
                                      puid: comment.quote!.userId,
                                      nickname: comment.quote!.userName,
                                      avatar: '',
                                    ),
                                    child: Text(
                                      '${comment.quote!.userName}: ',
                                      style: const TextStyle(
                                        color: Color(0xFF1C63B7),
                                        fontSize: 13,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                )
                              else if (comment.quote!.userName.isNotEmpty)
                                TextSpan(text: '${comment.quote!.userName}: '),
                              TextSpan(text: quote.text),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (comment.replyCount > 0) ...[
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _openCheckReplies(comment),
                        child: Text(
                          '查看${comment.replyCount}条回复>',
                          style: const TextStyle(
                            color: Color(0xFF1C63B7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildActionItem(
                          icon: CupertinoIcons.hand_thumbsup,
                          label: emphasizeLightCount
                              ? '亮了(${comment.lightCount})'
                              : '${comment.lightCount}',
                        ),
                        const SizedBox(width: 18),
                        _buildActionItem(
                          icon: CupertinoIcons.gift,
                          label: '礼物',
                        ),
                        const SizedBox(width: 18),
                        _buildActionItem(
                          icon: CupertinoIcons.arrowshape_turn_up_left,
                          label: '回复',
                        ),
                        const Spacer(),
                        const Icon(
                          CupertinoIcons.share_up,
                          size: 18,
                          color: Color(0xFF999999),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 0.5,
            color: const Color(0xFFE9EAEE),
          ),
        ],
      ),
    );
  }

  Future<void> _openCheckReplies(HupuPostComment comment) async {
    final detail = _detail;
    if (detail == null || comment.commentId.isEmpty) {
      return;
    }
    await showAppSheet<void>(
      context: context,
      barrierLabel: '回复详情',
      maxHeightFactor: 0.9,
      backgroundColor: const Color(0xFFFFFFFF),
      edgeToEdge: true,
      showHandle: false,
      builder: (_) {
        return _HupuCheckReplySheet(
          tid: detail.tid,
          fid: detail.fid,
          pid: comment.commentId,
          fallbackPost: comment,
          itemBuilder: _buildCommentCard,
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF999999),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final detail = _detail;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          '我来评论',
                          style: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        CupertinoIcons.smiley,
                        color: Color(0xFF999999),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              _buildBottomStat(
                icon: CupertinoIcons.hand_thumbsup,
                value: '${detail?.recommendCount ?? 0}',
              ),
              const SizedBox(width: 14),
              _buildBottomStat(
                icon: CupertinoIcons.chat_bubble,
                value: '${detail?.replyCount ?? 0}',
              ),
              const SizedBox(width: 14),
              _buildBottomStat(
                icon: CupertinoIcons.share_up,
                value: '${detail?.shareCount ?? 0}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStat({
    required IconData icon,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF333333),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _HupuCheckReplySheet extends StatefulWidget {
  const _HupuCheckReplySheet({
    required this.tid,
    required this.fid,
    required this.pid,
    required this.fallbackPost,
    required this.itemBuilder,
  });

  final String tid;
  final String fid;
  final String pid;
  final HupuPostComment fallbackPost;
  final Widget Function(
    HupuPostComment comment, {
    bool emphasizeLightCount,
  }) itemBuilder;

  @override
  State<_HupuCheckReplySheet> createState() => _HupuCheckReplySheetState();
}

class _HupuCheckReplySheetState extends State<_HupuCheckReplySheet> {
  bool _isLoading = true;
  String? _errorMessage;
  HupuPostComment? _post;
  List<HupuPostComment> _replies = const <HupuPostComment>[];
  HupuPostCommentSort _sort = HupuPostCommentSort.hot;

  List<HupuPostComment> get _displayReplies {
    final list = List<HupuPostComment>.from(_replies);
    switch (_sort) {
      case HupuPostCommentSort.hot:
        list.sort((left, right) => right.lightCount.compareTo(left.lightCount));
      case HupuPostCommentSort.earliest:
        list.sort((left, right) => left.createdAt.compareTo(right.createdAt));
      case HupuPostCommentSort.latest:
      case HupuPostCommentSort.author:
        list.sort((left, right) => right.createdAt.compareTo(left.createdAt));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await getHupuPostCheckReplies(
        tid: widget.tid,
        fid: widget.fid,
        pid: widget.pid,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _post = response.post;
        _replies = response.replies;
        _sort = HupuPostCommentSort.hot;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommentPanelScaffold(
      header: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  CupertinoIcons.clear_thick,
                  size: 18,
                  color: Color(0xFF1C1C1E),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  '查看回复',
                  style: TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ),
      content: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 12))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '加载失败',
                          style: TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          onPressed: _load,
                          child: const Text('重试'),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: widget.itemBuilder(
                        _post ?? widget.fallbackPost,
                        emphasizeLightCount: true,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: const Color(0xFFF6F7FA),
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: [
                            const Text(
                              '全部回复',
                              style: TextStyle(
                                color: Color(0xFF1C1C1E),
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            _buildSortButton(
                              label: '最热',
                              active: _sort == HupuPostCommentSort.hot,
                              onTap: () {
                                setState(() {
                                  _sort = HupuPostCommentSort.hot;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildSortButton(
                              label: '最早',
                              active: _sort == HupuPostCommentSort.earliest,
                              onTap: () {
                                setState(() {
                                  _sort = HupuPostCommentSort.earliest;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 0.5,
                        color: const Color(0xFFE5E5EA),
                      ),
                    ),
                    if (_displayReplies.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              '暂无回复',
                              style: TextStyle(
                                color: Color(0xFF8E8E93),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => widget.itemBuilder(
                            _displayReplies[index],
                            emphasizeLightCount: false,
                          ),
                          childCount: _displayReplies.length,
                        ),
                      ),
                  ],
                ),
        );
  }

  Widget _buildSortButton({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFFFFF) : const Color(0xFFF0F1F4),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? const Color(0xFFE2E3E7) : const Color(0xFFF0F1F4),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5F6368),
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ParsedCommentBody {
  const _ParsedCommentBody({
    required this.text,
    required this.imageUrls,
  });

  final String text;
  final List<String> imageUrls;
}

_ParsedCommentBody _parseCommentHtml(String html) {
  final fragment = html_parser.parseFragment(html);
  final text = (fragment.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  final imageUrls = <String>[];

  void appendUrl(String? url) {
    final normalized = (url ?? '').trim();
    if (normalized.isEmpty || imageUrls.contains(normalized)) {
      return;
    }
    imageUrls.add(normalized);
  }

  for (final image in fragment.querySelectorAll('img')) {
    appendUrl(
      image.attributes['data-origin'] ??
          image.attributes['data-gif'] ??
          image.attributes['data_url'] ??
          image.attributes['data-src'] ??
          image.attributes['src'],
    );
  }

  return _ParsedCommentBody(
    text: text,
    imageUrls: List<String>.unmodifiable(imageUrls),
  );
}
