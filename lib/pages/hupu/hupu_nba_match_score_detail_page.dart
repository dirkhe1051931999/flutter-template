import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';
import 'package:oolaf_flutted/components/app_tab/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_helper.dart';

enum _ScoreCommentSort {
  hot,
  latest,
  earliest,
}

enum _ScoreCommentType {
  hottest,
  all,
}

class HupuNbaMatchScoreDetailPage extends StatefulWidget {
  const HupuNbaMatchScoreDetailPage({
    required this.scoreBizId,
    super.key,
  });

  final String scoreBizId;

  @override
  State<HupuNbaMatchScoreDetailPage> createState() =>
      _HupuNbaMatchScoreDetailPageState();
}

class _HupuNbaMatchScoreDetailPageState
    extends State<HupuNbaMatchScoreDetailPage> {
  final ScrollController _scrollController = ScrollController();

  HupuNbaMatchScoreDetail? _detail;
  List<HupuNbaMatchScoreComment> _comments = const <HupuNbaMatchScoreComment>[];
  _ScoreCommentType _commentType = _ScoreCommentType.hottest;
  _ScoreCommentSort _sort = _ScoreCommentSort.hot;

  bool _isLoading = true;
  bool _isCommentLoading = false;
  bool _isCommentLoadingMore = false;
  bool _isCollapsed = false;
  bool _hasMoreComments = false;

  int _hotCommentCount = 0;
  int _allCommentCount = 0;
  int _commentRequestVersion = 0;
  String _commentCursorPublishTime = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    unawaited(_fetchInitial());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final shouldCollapse = _scrollController.offset > 120;
    if (shouldCollapse != _isCollapsed) {
      setState(() {
        _isCollapsed = shouldCollapse;
      });
    }

    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels < 280) {
      unawaited(_loadMoreComments());
    }
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<Object>([
        getHupuNbaMatchScoreDetail(scoreBizId: widget.scoreBizId),
        getHupuNbaMatchScoreHotComments(scoreBizId: widget.scoreBizId),
      ]);
      if (!mounted) {
        return;
      }
      final detail = results[0] as HupuNbaMatchScoreDetail;
      final hotComments = results[1] as HupuNbaMatchScoreCommentPage;
      setState(() {
        _detail = detail;
        _comments = hotComments.comments;
        _commentType = _ScoreCommentType.hottest;
        _sort = _ScoreCommentSort.hot;
        _hotCommentCount = hotComments.comments.length;
        _allCommentCount = detail.commentCount > 0
            ? detail.commentCount
            : hotComments.commentCount;
        _commentCursorPublishTime = hotComments.cursorPublishTime;
        _hasMoreComments = false;
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

  Future<void> _changeCommentType(_ScoreCommentType type) async {
    if (_commentType == type || _isCommentLoading || _isCommentLoadingMore) {
      return;
    }
    final nextSort = type == _ScoreCommentType.hottest
        ? _ScoreCommentSort.hot
        : _ScoreCommentSort.latest;
    await _reloadComments(type: type, sort: nextSort);
  }

  Future<void> _changeSort(_ScoreCommentSort sort) async {
    if (_sort == sort || _isCommentLoading || _isCommentLoadingMore) {
      return;
    }
    if (_commentType == _ScoreCommentType.hottest &&
        sort != _ScoreCommentSort.hot) {
      return;
    }
    if (_commentType == _ScoreCommentType.all &&
        sort == _ScoreCommentSort.hot) {
      return;
    }
    await _reloadComments(type: _commentType, sort: sort);
  }

  Future<void> _reloadComments({
    required _ScoreCommentType type,
    required _ScoreCommentSort sort,
  }) async {
    final requestVersion = ++_commentRequestVersion;
    setState(() {
      _commentType = type;
      _sort = sort;
      _comments = const <HupuNbaMatchScoreComment>[];
      _commentCursorPublishTime = '';
      _hasMoreComments = false;
      _isCommentLoading = true;
      _isCommentLoadingMore = false;
    });
    try {
      final page = await _fetchCommentPage(
        type: type,
        sort: sort,
        publishTime: '',
      );
      if (!mounted || requestVersion != _commentRequestVersion) {
        return;
      }
      setState(() {
        _comments = page.comments;
        _commentCursorPublishTime = page.cursorPublishTime;
        _hasMoreComments = type == _ScoreCommentType.all && page.hasMore;
        _isCommentLoading = false;
        if (type == _ScoreCommentType.hottest) {
          _hotCommentCount = page.comments.length;
        } else {
          _allCommentCount = page.commentCount;
        }
      });
    } catch (_) {
      if (!mounted || requestVersion != _commentRequestVersion) {
        return;
      }
      setState(() {
        _isCommentLoading = false;
      });
    }
  }

  Future<void> _loadMoreComments() async {
    if (_commentType != _ScoreCommentType.all ||
        _isCommentLoading ||
        _isCommentLoadingMore ||
        !_hasMoreComments ||
        _commentCursorPublishTime.isEmpty) {
      return;
    }
    final requestVersion = _commentRequestVersion;
    setState(() {
      _isCommentLoadingMore = true;
    });
    try {
      final page = await _fetchCommentPage(
        type: _commentType,
        sort: _sort,
        publishTime: _commentCursorPublishTime,
      );
      if (!mounted || requestVersion != _commentRequestVersion) {
        return;
      }
      setState(() {
        _comments = <HupuNbaMatchScoreComment>[
          ..._comments,
          ...page.comments,
        ];
        _commentCursorPublishTime = page.cursorPublishTime;
        _hasMoreComments = page.hasMore;
        _allCommentCount = page.commentCount;
        _isCommentLoadingMore = false;
      });
    } catch (_) {
      if (!mounted || requestVersion != _commentRequestVersion) {
        return;
      }
      setState(() {
        _isCommentLoadingMore = false;
      });
    }
  }

  Future<HupuNbaMatchScoreCommentPage> _fetchCommentPage({
    required _ScoreCommentType type,
    required _ScoreCommentSort sort,
    required String publishTime,
  }) {
    if (type == _ScoreCommentType.hottest) {
      return getHupuNbaMatchScoreHotComments(scoreBizId: widget.scoreBizId);
    }
    final order = sort == _ScoreCommentSort.earliest ? 'asc' : 'desc';
    return getHupuNbaMatchScoreLatestComments(
      scoreBizId: widget.scoreBizId,
      publishTime: publishTime,
      order: order,
    );
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
    final detail = _detail;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            RoutePageHeader(
              title: _isCollapsed && detail != null ? detail.name : '',
              subtitle: _isCollapsed && detail != null
                  ? '${detail.scoreText}  ${detail.scoreCountText}'
                  : null,
              avatarUrl: _isCollapsed ? detail?.logoUrl : null,
              centerTitle: !_isCollapsed,
              onBack: () => Navigator.of(context).maybePop(),
              trailing: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: _PosterButton(),
              ),
            ),
            if (_isCollapsed && detail != null)
              _CollapsedScoreInfo(detail: detail),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_detail == null) {
      return Center(
        child: CupertinoButton(
          onPressed: _fetchInitial,
          child: Text(_errorMessage ?? '加载失败，点此重试'),
        ),
      );
    }

    final detail = _detail!;
    return ListView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        _ScoreDetailHero(detail: detail),
        _ScoreDistributionPanel(detail: detail),
        const SizedBox(height: 10),
        _CommentHeader(
          hotCount: _hotCommentCount,
          allCount:
              _allCommentCount > 0 ? _allCommentCount : detail.commentCount,
          type: _commentType,
          sort: _sort,
          isLoading: _isCommentLoading || _isCommentLoadingMore,
          onTypeChanged: _changeCommentType,
          onSortChanged: _changeSort,
        ),
        if (_isCommentLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CupertinoActivityIndicator(radius: 12)),
          )
        else
          ..._comments
              .where((comment) => comment.hasContent)
              .map(
                (comment) => _ScoreCommentTile(
                  comment: comment,
                  onTapUser: comment.puid.isEmpty
                      ? null
                      : () => _openUserDetail(
                            puid: comment.puid,
                            nickname: comment.userName,
                            avatar: comment.avatarUrl,
                          ),
                  onTapSubCommentUser: (reply) => reply.puid.isEmpty
                      ? null
                      : () => _openUserDetail(
                            puid: reply.puid,
                            nickname: reply.userName,
                            avatar: reply.avatarUrl,
                          ),
                ),
              ),
        if (_isCommentLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CupertinoActivityIndicator(radius: 10)),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PosterButton extends StatelessWidget {
  const _PosterButton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.arrow_up_right_square,
          color: Color(0xFF202127),
          size: 17,
        ),
        SizedBox(height: 2),
        Text('海报', style: TextStyle(fontSize: 11, color: Color(0xFF202127))),
      ],
    );
  }
}

class _CollapsedScoreInfo extends StatelessWidget {
  const _CollapsedScoreInfo({required this.detail});

  final HupuNbaMatchScoreDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFFF7A3D),
      child: Row(
        children: [
          Text(
            detail.matchName,
            style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
          ),
          const Spacer(),
          Text(
            '${detail.minutes}  ${detail.points}分  ${detail.scoreText}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreDetailHero extends StatelessWidget {
  const _ScoreDetailHero({required this.detail});

  final HupuNbaMatchScoreDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                detail.logoUrl,
                width: 92,
                height: 112,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (detail.teamLogo.isNotEmpty)
                          CustomNetworkImage(
                            detail.teamLogo,
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            detail.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 18,
                          color: Color(0xFF202127),
                        ),
                      ],
                    ),
                    if (detail.labelText.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDEE),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          detail.labelText,
                          style: const TextStyle(
                            color: Color(0xFFEA0E20),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      detail.matchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8F96A3),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(value: detail.minutes, label: '时间'),
              _StatItem(value: '${detail.points}', label: '得分'),
              _StatItem(value: '${detail.rebounds}', label: '篮板'),
              _StatItem(value: '${detail.assists}', label: '助攻'),
              _StatItem(value: '${detail.steals}', label: '抢断'),
              _StatItem(value: '${detail.blocks}', label: '盖帽'),
              _StatItem(value: detail.plusMinus, label: '+/-'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.isEmpty ? '--' : value,
          style: const TextStyle(color: Color(0xFF202127), fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF606773), fontSize: 12),
        ),
      ],
    );
  }
}

class _ScoreDistributionPanel extends StatelessWidget {
  const _ScoreDistributionPanel({required this.detail});

  final HupuNbaMatchScoreDetail detail;

  @override
  Widget build(BuildContext context) {
    final maxCount = detail.scoreDistribution.values.fold<int>(
      1,
      (previous, item) => item > previous ? item : previous,
    );
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FAFF),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '虎扑评分',
                  style: TextStyle(
                    color: Color(0xFF28A4ED),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.scoreText,
                  style: const TextStyle(
                    color: Color(0xFF28A4ED),
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail.scoreCountText,
                  style:
                      const TextStyle(color: Color(0xFF8F96A3), fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [10, 8, 6, 4, 2].map((score) {
                final count = detail.scoreDistribution[score] ?? 0;
                final percent = detail.scorePersonCount <= 0
                    ? 0.0
                    : count / detail.scorePersonCount;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '★' * (score ~/ 2),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            color: Color(0xFFB7DFF8),
                            fontSize: 7,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 3,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5EFFD),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: count / maxCount,
                              heightFactor: 1,
                              child: const ColoredBox(
                                color: Color(0xFF28A4ED),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 42,
                        child: Text(
                          '${(percent * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Color(0xFF8F96A3),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentHeader extends StatelessWidget {
  const _CommentHeader({
    required this.hotCount,
    required this.allCount,
    required this.type,
    required this.sort,
    required this.isLoading,
    required this.onTypeChanged,
    required this.onSortChanged,
  });

  final int hotCount;
  final int allCount;
  final _ScoreCommentType type;
  final _ScoreCommentSort sort;
  final bool isLoading;
  final ValueChanged<_ScoreCommentType> onTypeChanged;
  final ValueChanged<_ScoreCommentSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: AppTabs(
              activeKey: type.index,
              onChange: (index) {
                onTypeChanged(_ScoreCommentType.values[index]);
              },
              backgroundColor: CupertinoColors.white,
              border: true,
              color: const Color(0xFFE51E2A),
              titleActiveColor: const Color(0xFF202127),
              titleInactiveColor: const Color(0xFF8F96A3),
              headerHeight: 48,
              lineWidth: 28,
              lineHeight: 3,
              items: <AppTabItemData>[
                AppTabItemData(
                  title: '亮回复 /${_countText(hotCount)}',
                  child: const SizedBox.shrink(),
                ),
                AppTabItemData(
                  title: '全部回复 /${_countText(allCount)}',
                  child: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                const Spacer(),
                if (type == _ScoreCommentType.hottest)
                  const _SingleSortBadge(label: '最亮')
                else
                  CupertinoSlidingSegmentedControl<_ScoreCommentSort>(
                    groupValue: sort,
                    padding: const EdgeInsets.all(2),
                    thumbColor: CupertinoColors.white,
                    backgroundColor: const Color(0xFFF3F4F6),
                    children: const {
                      _ScoreCommentSort.latest: _SortText('最晚'),
                      _ScoreCommentSort.earliest: _SortText('最早'),
                    },
                    onValueChanged: (value) {
                      if (isLoading || value == null) {
                        return;
                      }
                      onSortChanged(value);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortText extends StatelessWidget {
  const _SortText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF606773)),
      ),
    );
  }
}

class _SingleSortBadge extends StatelessWidget {
  const _SingleSortBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF606773),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ScoreCommentTile extends StatelessWidget {
  const _ScoreCommentTile({
    required this.comment,
    this.onTapUser,
    this.onTapSubCommentUser,
  });

  final HupuNbaMatchScoreComment comment;
  final VoidCallback? onTapUser;
  final VoidCallback? Function(HupuNbaMatchScoreSubComment reply)?
      onTapSubCommentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDEEF2), width: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapUser,
            child: ClipOval(
              child: CustomNetworkImage(
                comment.avatarUrl,
                width: 34,
                height: 34,
                skeletonBorderRadius: BorderRadius.circular(17),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapUser,
                        child: Text(
                          comment.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6A7180),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    if (comment.score > 0) _MiniStars(score: comment.score),
                  ],
                ),
                const SizedBox(height: 8),
                if (comment.content.isNotEmpty)
                  Text(
                    comment.content,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                if (comment.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  CustomNetworkImage(
                    comment.imageUrls.first,
                    width: 104,
                    height: 104,
                    skeletonBorderRadius: BorderRadius.circular(4),
                  ),
                ],
                if (comment.subComments.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: comment.subComments
                          .take(2)
                          .map(
                            (reply) => _SubCommentPreview(
                              reply: reply,
                              onTapUser: onTapSubCommentUser?.call(reply),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      comment.dateText,
                      style: const TextStyle(
                        color: Color(0xFF9AA1AE),
                        fontSize: 12,
                      ),
                    ),
                    if (comment.ipLocation.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        comment.ipLocation,
                        style: const TextStyle(
                          color: Color(0xFF9AA1AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (comment.replyCount > 0)
                      Text(
                        '${comment.replyCount}回复',
                        style: const TextStyle(
                          color: Color(0xFF9AA1AE),
                          fontSize: 12,
                        ),
                      ),
                    if (comment.lightCount > 0) ...[
                      const SizedBox(width: 12),
                      Text(
                        '亮了 ${comment.lightCount}',
                        style: const TextStyle(
                          color: Color(0xFF9AA1AE),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubCommentPreview extends StatelessWidget {
  const _SubCommentPreview({
    required this.reply,
    this.onTapUser,
  });

  final HupuNbaMatchScoreSubComment reply;
  final VoidCallback? onTapUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  if (onTapUser != null)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTapUser,
                        child: Text(
                          '${reply.userName}: ',
                          style: const TextStyle(
                            color: Color(0xFF1C63B7),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    TextSpan(
                      text: '${reply.userName}: ',
                      style: const TextStyle(
                        color: Color(0xFF6A7180),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  TextSpan(
                    text: reply.content,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (reply.lightCount > 0) ...[
            const SizedBox(width: 10),
            Text(
              '亮 ${reply.lightCount}',
              style: const TextStyle(
                color: Color(0xFF9AA1AE),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStars extends StatelessWidget {
  const _MiniStars({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final count = (score / 2).round().clamp(0, 5);
    return Text(
      '★★★★★'.substring(0, count),
      style: const TextStyle(color: Color(0xFF28A4ED), fontSize: 12),
    );
  }
}

String _countText(int count) {
  if (count >= 10000) {
    final value = count / 10000;
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)}万';
  }
  return '$count';
}
