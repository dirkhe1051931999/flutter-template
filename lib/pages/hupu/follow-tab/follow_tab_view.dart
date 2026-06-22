// ignore_for_file: file_names

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_user_detail_helper.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

const Set<PointerDeviceKind> _followTabDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.unknown,
};

class HupuFollowTabView extends StatefulWidget {
  const HupuFollowTabView({super.key});

  @override
  State<HupuFollowTabView> createState() => _HupuFollowTabViewState();
}

class _HupuFollowTabViewState extends State<HupuFollowTabView>
    with AutomaticKeepAliveClientMixin<HupuFollowTabView> {
  HupuFollowContent? _content;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  late String _lastViewTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _lastViewTime = DateTime.now().millisecondsSinceEpoch.toString();
    unawaited(_loadContent());
  }

  Future<void> _loadContent({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final content = await getHupuFollowContent(
        pageIndex: 1,
        lastViewTime: _lastViewTime,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _content = content;
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

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
      _lastViewTime = DateTime.now().millisecondsSinceEpoch.toString();
    });
    try {
      await _loadContent(showLoading: false);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    LinkedTabRefreshState state,
    double progress,
  ) {
    final isArmed = state == LinkedTabRefreshState.armed ||
        state == LinkedTabRefreshState.refreshing;
    final isRefreshing = state == LinkedTabRefreshState.refreshing ||
        state == LinkedTabRefreshState.complete ||
        _isRefreshing;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }

  Future<void> _openUserDetail(HupuFollowRecommendUser user) async {
    await openHupuUserDetail(
      context,
      puid: user.puid,
      initialNickname: user.nickname,
      initialAvatar: user.avatar,
    );
  }

  Future<void> _openPostDetail(HupuFollowRecommendThread thread) async {
    if (thread.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: thread.tid,
          initialTitle: thread.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    final content = _content;
    if (content == null && _errorMessage != null) {
      return _FollowErrorView(
        detail: _errorMessage,
        onRetry: () => _loadContent(),
      );
    }

    final recommendedUsers =
        content?.recommendedUsers ?? const <HupuFollowRecommendUser>[];

    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: ScrollConfiguration(
        behavior: const CupertinoScrollBehavior().copyWith(
          dragDevices: _followTabDragDevices,
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: _FollowLoginPrompt(
                onTapLogin: () {
                  Application.router.navigateTo(context, Routes.hupuLogin);
                },
              ),
            ),
            if (recommendedUsers.isNotEmpty)
              const SliverToBoxAdapter(
                child: _FollowSectionTitle(
                  title: '为你推荐',
                  subtitle: '关注感兴趣的 JRs，首页会展示他们的新内容',
                ),
              ),
            if (recommendedUsers.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FollowEmptyView(
                  hasError: _errorMessage != null,
                  onRetry: _onRefresh,
                ),
              )
            else
              SliverList.builder(
                itemCount: recommendedUsers.length,
                itemBuilder: (context, index) {
                  final user = recommendedUsers[index];
                  return _FollowRecommendUserCard(
                    user: user,
                    onTapUser: () => _openUserDetail(user),
                    onTapThread: _openPostDetail,
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _FollowLoginPrompt extends StatelessWidget {
  const _FollowLoginPrompt({required this.onTapLogin});

  final VoidCallback onTapLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(color: const Color(0xFFE7E8EC)),
                ),
                child: const Icon(
                  CupertinoIcons.person_2_fill,
                  color: Color(0xFFE5484D),
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '你还未登录',
                      style: TextStyle(
                        color: Color(0xFF202127),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '登录账号，查看你关注的JRs发布的内容',
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              color: const Color(0xFFE51E2A),
              borderRadius: BorderRadius.circular(21),
              onPressed: onTapLogin,
              child: const Text(
                '立即登录',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowSectionTitle extends StatelessWidget {
  const _FollowSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9A9AA3),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowRecommendUserCard extends StatelessWidget {
  const _FollowRecommendUserCard({
    required this.user,
    required this.onTapUser,
    required this.onTapThread,
  });

  final HupuFollowRecommendUser user;
  final VoidCallback onTapUser;
  final ValueChanged<HupuFollowRecommendThread> onTapThread;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTapUser,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: CustomNetworkImage(
                    user.avatar,
                    width: 42,
                    height: 42,
                    skeletonBorderRadius: BorderRadius.circular(21),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nickname.isEmpty ? '虎扑用户' : user.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (user.reasons.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _FollowReasonBadge(text: user.reasons.first),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF202127),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    '+ 关注',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (user.threads.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(height: 1, color: const Color(0xFFF1F2F5)),
            const SizedBox(height: 4),
            for (final thread in user.threads.take(2))
              _FollowThreadRow(
                thread: thread,
                onTap: () => onTapThread(thread),
              ),
          ],
        ],
      ),
    );
  }
}

class _FollowReasonBadge extends StatelessWidget {
  const _FollowReasonBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FB),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF3198AA),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FollowThreadRow extends StatelessWidget {
  const _FollowThreadRow({
    required this.thread,
    required this.onTap,
  });

  final HupuFollowRecommendThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 9, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.only(top: 8, right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFC5C7CE),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF30323A),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_formatCount(thread.visits)} 阅读 / ${_formatCount(thread.replies)} 回复',
                    style: const TextStyle(
                      color: Color(0xFF9A9AA3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowEmptyView extends StatelessWidget {
  const _FollowEmptyView({
    required this.hasError,
    required this.onRetry,
  });

  final bool hasError;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError
                  ? CupertinoIcons.exclamationmark_circle
                  : CupertinoIcons.person_crop_circle_badge_plus,
              color: const Color(0xFFB0B3BA),
              size: 34,
            ),
            const SizedBox(height: 12),
            Text(
              hasError ? '关注页加载失败' : '暂无推荐关注',
              style: const TextStyle(
                color: Color(0xFF30323A),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              color: const Color(0xFFE51E2A),
              borderRadius: BorderRadius.circular(18),
              onPressed: () => unawaited(onRetry()),
              child: const Text(
                '重新加载',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowErrorView extends StatelessWidget {
  const _FollowErrorView({
    required this.detail,
    required this.onRetry,
  });

  final String? detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Color(0xFFE51E2A),
              size: 34,
            ),
            const SizedBox(height: 12),
            const Text(
              '关注页加载失败',
              style: TextStyle(
                color: Color(0xFF202127),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(
                detail!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 14),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              color: const Color(0xFFE51E2A),
              borderRadius: BorderRadius.circular(18),
              onPressed: onRetry,
              child: const Text(
                '点此重试',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCount(int count) {
  if (count >= 10000) {
    final value = count / 10000;
    final text =
        value >= 10 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '${text.replaceAll(RegExp(r'\.0$'), '')}万';
  }
  return count.toString();
}
