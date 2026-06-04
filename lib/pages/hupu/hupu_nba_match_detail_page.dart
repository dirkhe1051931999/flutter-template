import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';
import 'package:oolaf_flutted/components/app_tab/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_nba_match_score_detail_page.dart';

class HupuNbaMatchDetailPage extends StatefulWidget {
  const HupuNbaMatchDetailPage({
    required this.matchId,
    super.key,
    this.scoreBizId = '',
  });

  final String matchId;
  final String scoreBizId;

  @override
  State<HupuNbaMatchDetailPage> createState() => _HupuNbaMatchDetailPageState();
}

class _HupuNbaMatchDetailPageState extends State<HupuNbaMatchDetailPage> {
  int _selectedTabIndex = 0;
  HupuNbaMatchDetail? _matchDetail;
  HupuNbaMatchLiveData? _liveData;
  HupuNbaMatchScoreData? _scoreData;
  HupuNbaMatchStatsData? _statsData;
  bool _isLoading = true;
  bool _isLiveLoading = false;
  bool _isScoreLoading = false;
  bool _isStatsLoading = false;
  bool _isBannerCollapsed = false;
  String? _errorMessage;
  String? _liveErrorMessage;
  String? _scoreErrorMessage;
  String? _statsErrorMessage;

  @override
  void initState() {
    super.initState();
    unawaited(_fetchDetail());
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _liveData = null;
      _scoreData = null;
      _statsData = null;
      _liveErrorMessage = null;
      _scoreErrorMessage = null;
      _statsErrorMessage = null;
    });
    try {
      final detail = await getHupuNbaMatchDetail(matchId: widget.matchId);
      if (!mounted) {
        return;
      }
      setState(() {
        _matchDetail = detail;
        _isLoading = false;
      });
      unawaited(_fetchLiveData());
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

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical || _matchDetail == null) {
      return false;
    }
    final shouldCollapse = notification.metrics.pixels > 8;
    if (shouldCollapse != _isBannerCollapsed) {
      setState(() {
        _isBannerCollapsed = shouldCollapse;
      });
    }
    return false;
  }

  Future<void> _fetchLiveData() async {
    final detail = _matchDetail;
    if (detail == null || _isLiveLoading || _liveData != null) {
      return;
    }
    setState(() {
      _isLiveLoading = true;
      _liveErrorMessage = null;
    });
    try {
      final data = await getHupuNbaMatchLiveData(matchId: detail.matchId);
      if (!mounted) {
        return;
      }
      setState(() {
        _liveData = data;
        _isLiveLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _liveErrorMessage = error.toString();
        _isLiveLoading = false;
      });
    }
  }

  Future<void> _fetchScoreData() async {
    final detail = _matchDetail;
    if (detail == null || _isScoreLoading || _scoreData != null) {
      return;
    }
    setState(() {
      _isScoreLoading = true;
      _scoreErrorMessage = null;
    });
    try {
      final data = await getHupuNbaMatchScoreData(
        matchId: detail.matchId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _scoreData = data;
        _isScoreLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _scoreErrorMessage = error.toString();
        _isScoreLoading = false;
      });
    }
  }

  Future<void> _fetchStatsData() async {
    final detail = _matchDetail;
    if (detail == null || _isStatsLoading || _statsData != null) {
      return;
    }
    setState(() {
      _isStatsLoading = true;
      _statsErrorMessage = null;
    });
    try {
      final data = await getHupuNbaMatchStatsData(matchId: detail.matchId);
      if (!mounted) {
        return;
      }
      setState(() {
        _statsData = data;
        _isStatsLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statsErrorMessage = error.toString();
        _isStatsLoading = false;
      });
    }
  }

  void _handleTabChanged(int index) {
    if (index == 0) {
      unawaited(_fetchLiveData());
    }
    if (index == 1) {
      unawaited(_fetchScoreData());
    }
    if (index == 2) {
      unawaited(_fetchStatsData());
    }
  }

  List<AppTabItemData> _buildTabs(HupuNbaMatchDetail match) {
    return <AppTabItemData>[
      AppTabItemData(
        title: '直播',
        child: _LiveTabView(
          data: _liveData,
          isLoading: _isLiveLoading,
          errorMessage: _liveErrorMessage,
          onRetry: _fetchLiveData,
        ),
      ),
      AppTabItemData(
        title: '评分',
        child: _ScoreTabView(
          match: match,
          data: _scoreData,
          isLoading: _isScoreLoading,
          errorMessage: _scoreErrorMessage,
          onRetry: _fetchScoreData,
        ),
      ),
      AppTabItemData(
        title: '统计',
        child: _StatsTabView(
          data: _statsData,
          isLoading: _isStatsLoading,
          errorMessage: _statsErrorMessage,
          onRetry: _fetchStatsData,
        ),
      ),
      const AppTabItemData(
        title: '热线',
        child: _PlaceholderTabView(title: '暂无热线'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      child: SafeArea(
        bottom: false,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 14,
          color: CupertinoColors.white,
        ),
      );
    }

    if (_matchDetail == null) {
      return Center(
        child: CupertinoButton(
          onPressed: _fetchDetail,
          child: Text(
            _errorMessage ?? '加载失败，点此重试',
            style: const TextStyle(color: CupertinoColors.white),
          ),
        ),
      );
    }

    return Column(
      children: [
        RoutePageHeader(
          title: _matchDetail!.competitionStageDesc.isNotEmpty
              ? _matchDetail!.competitionStageDesc
              : 'NBA',
          onBack: () => Navigator.of(context).maybePop(),
          trailing: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavAction(icon: CupertinoIcons.videocam_fill, label: '直播'),
                SizedBox(width: 14),
                _NavAction(
                    icon: CupertinoIcons.chart_bar_alt_fill, label: '排行'),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _isBannerCollapsed
              ? _CollapsedMatchBanner(
                  key: const ValueKey<String>('collapsed-banner'),
                  match: _matchDetail!,
                )
              : _MatchDetailBanner(
                  key: const ValueKey<String>('expanded-banner'),
                  match: _matchDetail!,
                ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: AppTabs(
              activeKey: _selectedTabIndex,
              onChange: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
                _handleTabChanged(index);
              },
              backgroundColor: CupertinoColors.white,
              border: true,
              color: const Color(0xFFE51E2A),
              titleActiveColor: const Color(0xFF202127),
              titleInactiveColor: const Color(0xFF9AA1AE),
              headerHeight: 52,
              lineWidth: 28,
              lineHeight: 3,
              swipeable: true,
              lazyRender: false,
              items: _buildTabs(_matchDetail!),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavAction extends StatelessWidget {
  const _NavAction({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF202127), size: 16),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MatchDetailBanner extends StatelessWidget {
  const _MatchDetailBanner({
    required this.match,
    super.key,
  });

  final HupuNbaMatchDetail match;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width <= 390;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, isCompact ? 7 : 9, 18, 11),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF252933),
            Color(0xFF151922),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '260万热度',
            style: TextStyle(
              color: Color(0xFFE8EBF2),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _DetailTeamColumn(
                  logoUrl: match.awayTeamLogo,
                  score: match.awayScore,
                  name: match.awayTeamName,
                  rankText: match.awayRankText,
                  sideText: '客',
                  alignRight: true,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 12),
              _DetailMatchCenter(match: match),
              SizedBox(width: isCompact ? 8 : 12),
              Expanded(
                child: _DetailTeamColumn(
                  logoUrl: match.homeTeamLogo,
                  score: match.homeScore,
                  name: match.homeTeamName,
                  rankText: match.homeRankText,
                  sideText: '主',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _DetailMiddleStats(match: match),
          const SizedBox(height: 9),
          const _SupportBar(),
        ],
      ),
    );
  }
}

class _CollapsedMatchBanner extends StatelessWidget {
  const _CollapsedMatchBanner({
    required this.match,
    super.key,
  });

  final HupuNbaMatchDetail match;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF20242C),
            Color(0xFF161A22),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    match.awayTeamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CustomNetworkImage(
                  match.awayTeamLogo,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${match.awayScore ?? 0} - ${match.homeScore ?? 0}',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${match.displayQuarterText} ${match.displayClockText}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFB6BECC),
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                CustomNetworkImage(
                  match.homeTeamLogo,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    match.homeTeamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTeamColumn extends StatelessWidget {
  const _DetailTeamColumn({
    required this.logoUrl,
    required this.score,
    required this.name,
    required this.rankText,
    required this.sideText,
    this.alignRight = false,
  });

  final String logoUrl;
  final int? score;
  final String name;
  final String rankText;
  final String sideText;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final textAlign = alignRight ? TextAlign.right : TextAlign.left;
    final crossAxisAlignment =
        alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final isCompact = MediaQuery.sizeOf(context).width <= 390;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        SizedBox(
          width: double.infinity,
          height: isCompact ? 50 : 54,
          child: Stack(
            alignment:
                alignRight ? Alignment.centerRight : Alignment.centerLeft,
            children: [
              Positioned(
                left: alignRight ? null : 0,
                right: alignRight ? 0 : null,
                child: CustomNetworkImage(
                  logoUrl,
                  width: isCompact ? 44 : 50,
                  height: isCompact ? 44 : 50,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: alignRight
                    ? 0
                    : isCompact
                        ? 38
                        : 43,
                right: alignRight
                    ? isCompact
                        ? 38
                        : 43
                    : 0,
                child: Text(
                  '${score ?? 0}',
                  textAlign: alignRight ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: isCompact ? 24 : 27,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$name$rankText',
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sideText,
          textAlign: textAlign,
          style: const TextStyle(
            color: Color(0xFF9AA3B2),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DetailMatchCenter extends StatelessWidget {
  const _DetailMatchCenter({required this.match});

  final HupuNbaMatchDetail match;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          match.bigScoreText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD9DEE8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          match.displayQuarterText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD9DEE8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          match.displayClockText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFB5BDCA),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DetailMiddleStats extends StatelessWidget {
  const _DetailMiddleStats({required this.match});

  final HupuNbaMatchDetail match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xD90A0D13),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: Column(
        children: [
          _StatLine(
            leftText: '${match.awaySurplusPause ?? 0}',
            centerText: '剩余暂停',
            rightText: '${match.homeSurplusPause ?? 0}',
          ),
          const SizedBox(height: 4),
          _StatLine(
            leftText: '${match.awayFouls ?? 0}',
            centerText: '本节犯规',
            rightText: '${match.homeFouls ?? 0}',
          ),
        ],
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.leftText,
    required this.centerText,
    required this.rightText,
  });

  final String leftText;
  final String centerText;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          leftText,
          style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
        ),
        const SizedBox(width: 6),
        Text(
          centerText,
          style: const TextStyle(color: Color(0xFF9AA3B2), fontSize: 12),
        ),
        const SizedBox(width: 6),
        Text(
          rightText,
          style: const TextStyle(color: CupertinoColors.white, fontSize: 13),
        ),
      ],
    );
  }
}

class _SupportBar extends StatelessWidget {
  const _SupportBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SupportChip(
          icon: CupertinoIcons.hand_thumbsup_fill,
          text: '45291(34%)',
          alignStart: true,
        ),
        Expanded(
          child: Container(
            height: 2.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: const LinearGradient(
                colors: <Color>[
                  Color(0xFFF47C32),
                  Color(0xFFF47C32),
                  Color(0xFF48BCEB),
                ],
                stops: <double>[0, 0.34, 0.34],
              ),
            ),
          ),
        ),
        const _SupportChip(
          icon: CupertinoIcons.hand_thumbsdown_fill,
          text: '87514(66%)',
          alignStart: false,
        ),
      ],
    );
  }
}

class _LiveTabView extends StatelessWidget {
  const _LiveTabView({
    required this.data,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final HupuNbaMatchLiveData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: const Color(0xFFE51E2A),
            borderRadius: BorderRadius.circular(18),
            onPressed: onRetry,
            child: const Text('直播加载失败，点此重试'),
          ),
        ),
      );
    }
    final liveData = data;
    if (liveData == null || liveData.events.isEmpty) {
      return const _PlaceholderTabView(title: '暂无直播内容');
    }
    final entries = liveData.entries;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.isTime) {
          return _LiveTimeDivider(label: entry.timeLabel);
        }
        return _LiveEventTile(event: entry.event!);
      },
    );
  }
}

class _LiveTimeDivider extends StatelessWidget {
  const _LiveTimeDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4FA),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9AA1AE),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveEventTile extends StatelessWidget {
  const _LiveEventTile({required this.event});

  final HupuNbaMatchLiveEvent event;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  const _LiveAvatar(),
                  Expanded(
                    child: Container(
                      width: 1,
                      color: const Color(0xFFE4E8F0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F5FA),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        event.event,
                        style: const TextStyle(
                          color: Color(0xFF3A3F48),
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F8FF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '得分  ${event.scoreText}',
                        style: const TextStyle(
                          color: Color(0xFF0497B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveAvatar extends StatelessWidget {
  const _LiveAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD7B66C),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF8D6C27), width: 1),
      ),
      child: const Text(
        '虎',
        style: TextStyle(
          color: Color(0xFF5C4212),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScoreTabView extends StatelessWidget {
  const _ScoreTabView({
    required this.match,
    required this.data,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final HupuNbaMatchDetail match;
  final HupuNbaMatchScoreData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: const Color(0xFFE51E2A),
            borderRadius: BorderRadius.circular(18),
            onPressed: onRetry,
            child: const Text('评分加载失败，点此重试'),
          ),
        ),
      );
    }
    final scoreData = data;
    if (scoreData == null || !scoreData.hasItems) {
      return const _PlaceholderTabView(title: '暂无评分');
    }
    return _ScoreTeamSwitcher(data: scoreData);
  }
}

class _ScoreTeamSwitcher extends StatefulWidget {
  const _ScoreTeamSwitcher({required this.data});

  final HupuNbaMatchScoreData data;

  @override
  State<_ScoreTeamSwitcher> createState() => _ScoreTeamSwitcherState();
}

class _ScoreTeamSwitcherState extends State<_ScoreTeamSwitcher> {
  int _selectedTeamIndex = 0;

  @override
  Widget build(BuildContext context) {
    final teams =
        widget.data.teams.where((team) => team.players.isNotEmpty).toList();
    if (teams.isEmpty) {
      return const _PlaceholderTabView(title: '暂无评分');
    }
    final selectedIndex = _selectedTeamIndex.clamp(0, teams.length - 1);
    final selectedTeam = teams[selectedIndex];
    return Column(
      children: [
        _ScoreTeamTabs(
          teams: teams,
          selectedIndex: selectedIndex,
          onChanged: (index) {
            setState(() {
              _selectedTeamIndex = index;
            });
          },
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            physics: const BouncingScrollPhysics(),
            itemCount: selectedTeam.players.length,
            itemBuilder: (context, index) {
              return _ScorePlayerCard(player: selectedTeam.players[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _ScoreTeamTabs extends StatelessWidget {
  const _ScoreTeamTabs({
    required this.teams,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<HupuNbaMatchScoreTeam> teams;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: CupertinoColors.white,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E8EE), width: 0.7),
        ),
        child: Row(
          children: List.generate(teams.length, (index) {
            final team = teams[index];
            final isActive = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? CupertinoColors.white
                        : CupertinoColors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: isActive
                        ? const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomNetworkImage(
                        team.teamLogo,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          team.teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StatsTeamTabs extends StatelessWidget {
  const _StatsTeamTabs({
    required this.teams,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<HupuNbaMatchStatsTeam> teams;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: CupertinoColors.white,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6E8EE), width: 0.7),
        ),
        child: Row(
          children: List.generate(teams.length, (index) {
            final team = teams[index];
            final isActive = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isActive
                        ? CupertinoColors.white
                        : CupertinoColors.white.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFE7EAF1)
                          : CupertinoColors.transparent,
                    ),
                    boxShadow: isActive
                        ? const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomNetworkImage(
                        team.teamLogo,
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          team.teamName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: 14,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ScorePlayerCard extends StatelessWidget {
  const _ScorePlayerCard({required this.player});

  final HupuNbaMatchScorePlayer player;

  @override
  Widget build(BuildContext context) {
    final hotComment = player.hotComment;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: player.scoreBizId.isEmpty
          ? null
          : () {
              Navigator.of(context).push<void>(
                CupertinoPageRoute<void>(
                  builder: (_) => HupuNbaMatchScoreDetailPage(
                    scoreBizId: player.scoreBizId,
                  ),
                ),
              );
            },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFEDEEF2)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomNetworkImage(
                  player.photo,
                  width: 58,
                  height: 76,
                  fit: BoxFit.cover,
                  skeletonBorderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        player.statSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8F96A3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const _ScoreStars(),
                    const SizedBox(height: 8),
                    Text(
                      player.displayScore,
                      style: const TextStyle(
                        color: Color(0xFF249AF5),
                        fontSize: 25,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      player.scoreCountText,
                      style: const TextStyle(
                        color: Color(0xFF9AA1AE),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!player.didNotPlay) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      hotComment.isNotEmpty
                          ? '"$hotComment"'
                          : '"${player.displayName}本场表现"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFF6A3A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.arrow_up_right_square,
                    color: Color(0xFF8F96A3),
                    size: 16,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoreStars extends StatelessWidget {
  const _ScoreStars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(left: 1),
          child: Icon(
            CupertinoIcons.star_fill,
            color: Color(0xFFC9CED8),
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _StatsTabView extends StatelessWidget {
  const _StatsTabView({
    required this.data,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final HupuNbaMatchStatsData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: const Color(0xFFE51E2A),
            borderRadius: BorderRadius.circular(18),
            onPressed: onRetry,
            child: const Text('统计加载失败，点此重试'),
          ),
        ),
      );
    }
    final statsData = data;
    if (statsData == null || !statsData.hasItems) {
      return const _PlaceholderTabView(title: '暂无统计');
    }
    return _StatsTeamSwitcher(data: statsData);
  }
}

class _StatsTeamSwitcher extends StatefulWidget {
  const _StatsTeamSwitcher({required this.data});

  final HupuNbaMatchStatsData data;

  @override
  State<_StatsTeamSwitcher> createState() => _StatsTeamSwitcherState();
}

class _StatsTeamSwitcherState extends State<_StatsTeamSwitcher> {
  int _selectedTeamIndex = 0;
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _headerScrollController.addListener(_syncHeaderToBody);
    _bodyScrollController.addListener(_syncBodyToHeader);
  }

  @override
  void dispose() {
    _headerScrollController
      ..removeListener(_syncHeaderToBody)
      ..dispose();
    _bodyScrollController
      ..removeListener(_syncBodyToHeader)
      ..dispose();
    super.dispose();
  }

  void _syncHeaderToBody() {
    if (!_bodyScrollController.hasClients ||
        !_headerScrollController.hasClients) {
      return;
    }
    if ((_bodyScrollController.offset - _headerScrollController.offset).abs() >
        0.5) {
      _bodyScrollController.jumpTo(_headerScrollController.offset);
    }
  }

  void _syncBodyToHeader() {
    if (!_bodyScrollController.hasClients ||
        !_headerScrollController.hasClients) {
      return;
    }
    if ((_headerScrollController.offset - _bodyScrollController.offset).abs() >
        0.5) {
      _headerScrollController.jumpTo(_bodyScrollController.offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teams =
        widget.data.teams.where((team) => team.players.isNotEmpty).toList();
    if (teams.isEmpty) {
      return const _PlaceholderTabView(title: '暂无统计');
    }
    final selectedIndex = _selectedTeamIndex.clamp(0, teams.length - 1);
    final selectedTeam = teams[selectedIndex];
    return Column(
      children: [
        _StatsTeamTabs(
          teams: teams,
          selectedIndex: selectedIndex,
          onChanged: (index) {
            setState(() {
              _selectedTeamIndex = index;
            });
          },
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _MatchStatsTable(
                players: selectedTeam.players,
                columns: _matchStatsColumns,
                headerScrollController: _headerScrollController,
                bodyScrollController: _bodyScrollController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchStatsTable extends StatelessWidget {
  const _MatchStatsTable({
    required this.players,
    required this.columns,
    required this.headerScrollController,
    required this.bodyScrollController,
  });

  final List<HupuNbaMatchStatsPlayer> players;
  final List<_MatchStatsColumn> columns;
  final ScrollController headerScrollController;
  final ScrollController bodyScrollController;

  static const double leftColumnWidth = 154;
  static const double dataColumnWidth = 58;
  static const double headerHeight = 38;
  static const double rowHeight = 58;

  @override
  Widget build(BuildContext context) {
    final tableWidth = columns.length * dataColumnWidth;
    return Container(
      color: CupertinoColors.white,
      child: Column(
        children: [
          Row(
            children: [
              const _MatchStatsHeaderCell(
                title: '球员',
                width: leftColumnWidth,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: headerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Row(
                      children: columns
                          .map(
                            (column) => _MatchStatsHeaderCell(
                              title: column.label,
                              width: dataColumnWidth,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: leftColumnWidth,
                child: Column(
                  children: players
                      .map(
                        (player) => _MatchStatsPlayerCell(
                          player: player,
                          height: rowHeight,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: bodyScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: players
                          .map(
                            (player) => _MatchStatsRow(
                              player: player,
                              columns: columns,
                              columnWidth: dataColumnWidth,
                              height: rowHeight,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchStatsPlayerCell extends StatelessWidget {
  const _MatchStatsPlayerCell({
    required this.player,
    required this.height,
  });

  final HupuNbaMatchStatsPlayer player;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE8EBF0), width: 0.7),
          bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: CustomNetworkImage(
              player.photo,
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              skeletonBorderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${player.numberText}号 · ${player.positionText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8F96A3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchStatsRow extends StatelessWidget {
  const _MatchStatsRow({
    required this.player,
    required this.columns,
    required this.columnWidth,
    required this.height,
  });

  final HupuNbaMatchStatsPlayer player;
  final List<_MatchStatsColumn> columns;
  final double columnWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F1F4), width: 0.7),
        ),
      ),
      child: Row(
        children: columns
            .map(
              (column) => Container(
                width: columnWidth,
                height: height,
                alignment: Alignment.center,
                child: Text(
                  player.statValue(column.key),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: column.key == 'plusMinus' &&
                            player.statValue(column.key).startsWith('+')
                        ? const Color(0xFFE5484D)
                        : const Color(0xFF202127),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _MatchStatsHeaderCell extends StatelessWidget {
  const _MatchStatsHeaderCell({
    required this.title,
    required this.width,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
  });

  final String title;
  final double width;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _MatchStatsTable.headerHeight,
      alignment: alignment,
      padding: padding,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F6F8),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8EBF0), width: 0.7),
        ),
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF202127),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MatchStatsColumn {
  const _MatchStatsColumn({
    required this.key,
    required this.label,
  });

  final String key;
  final String label;
}

const List<_MatchStatsColumn> _matchStatsColumns = <_MatchStatsColumn>[
  _MatchStatsColumn(key: 'mins', label: '时间'),
  _MatchStatsColumn(key: 'pts', label: '得分'),
  _MatchStatsColumn(key: 'reb', label: '篮板'),
  _MatchStatsColumn(key: 'asts', label: '助攻'),
  _MatchStatsColumn(key: 'twoPoints', label: '投篮'),
  _MatchStatsColumn(key: 'threePoints', label: '三分'),
  _MatchStatsColumn(key: 'ft', label: '罚球'),
  _MatchStatsColumn(key: 'efgp', label: 'eFG%'),
  _MatchStatsColumn(key: 'tsp', label: 'TS%'),
  _MatchStatsColumn(key: 'stl', label: '抢断'),
  _MatchStatsColumn(key: 'to', label: '失误'),
  _MatchStatsColumn(key: 'blk', label: '盖帽'),
  _MatchStatsColumn(key: 'blkr', label: '被盖'),
  _MatchStatsColumn(key: 'oreb', label: '前板'),
  _MatchStatsColumn(key: 'dreb', label: '后板'),
  _MatchStatsColumn(key: 'foulr', label: '被犯'),
  _MatchStatsColumn(key: 'pf', label: '犯规'),
  _MatchStatsColumn(key: 'plusMinus', label: '+/-'),
];

class _PlaceholderTabView extends StatelessWidget {
  const _PlaceholderTabView({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      color: CupertinoColors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8F96A3),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({
    required this.icon,
    required this.text,
    required this.alignStart,
  });

  final IconData icon;
  final String text;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: alignStart
            ? <Widget>[
                _SupportCircle(icon: icon),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF8E96A3),
                    fontSize: 12,
                  ),
                ),
              ]
            : <Widget>[
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF8E96A3),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 6),
                _SupportCircle(icon: icon),
              ],
      ),
    );
  }
}

class _SupportCircle extends StatelessWidget {
  const _SupportCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF444B56)),
      ),
      child: Icon(icon, color: CupertinoColors.white, size: 16),
    );
  }
}
