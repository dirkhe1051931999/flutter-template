import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_refresh_indicator.dart';

const Set<PointerDeviceKind> _nbaScheduleDragDevices = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.trackpad,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown,
};

class HupuNbaSchedulePage extends StatefulWidget {
  const HupuNbaSchedulePage({
    super.key,
    this.initialTabId,
  });

  final String? initialTabId;

  @override
  State<HupuNbaSchedulePage> createState() => _HupuNbaSchedulePageState();
}

class _HupuNbaSchedulePageState extends State<HupuNbaSchedulePage> {
  final ScrollController _scrollController = ScrollController();
  final List<HupuNbaScheduleDay> _days = <HupuNbaScheduleDay>[];
  final Set<String> _dayKeys = <String>{};
  final Map<String, GlobalKey> _dayAnchors = <String, GlobalKey>{};

  List<HupuNbaDataTab> _tabs = const <HupuNbaDataTab>[];
  HupuNbaScheduleStats? _stats;
  bool _isInitialLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingPrev = false;
  bool _isLoadingNext = false;
  bool _hasPrev = true;
  bool _hasNext = true;
  bool _showTodayButton = false;
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

  Future<void> _fetchInitial({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isInitialLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }
    try {
      final results = await Future.wait([
        getHupuNbaDataTabs(),
        getHupuNbaScheduleList(),
      ]);
      final tabs = results[0] as List<HupuNbaDataTab>;
      final schedule = results[1] as HupuNbaScheduleData;
      if (!mounted) {
        return;
      }
      setState(() {
        _dayAnchors.clear();
        _tabs = tabs;
        _stats = schedule.stats;
        _days
          ..clear()
          ..addAll(schedule.days);
        _dayKeys
          ..clear()
          ..addAll(schedule.days.map((item) => item.day));
        _hasPrev = _canLoadPrev;
        _hasNext = _canLoadNext;
        _isInitialLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToToday(animated: false);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isInitialLoading = false;
      });
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || _isInitialLoading || _isRefreshing) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels <= 180) {
      unawaited(_loadPrev());
    }
    if (position.extentAfter <= 360) {
      unawaited(_loadNext());
    }
    final show = _shouldShowTodayButton();
    if (show != _showTodayButton) {
      setState(() {
        _showTodayButton = show;
      });
    }
  }

  Future<void> _loadPrev() async {
    if (_isLoadingPrev || !_hasPrev || _days.isEmpty) {
      return;
    }
    final cursor = _dateOffset(_days.first.day, -1);
    if (cursor.isEmpty) {
      return;
    }
    setState(() {
      _isLoadingPrev = true;
    });
    final oldMaxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    try {
      final response = await getHupuNbaScheduleList(
        cursor: cursor,
        direction: HupuNbaScheduleDirection.prev,
      );
      final incoming = response.days
          .where((item) => !_dayKeys.contains(item.day))
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _days.insertAll(0, incoming);
        _dayKeys.addAll(incoming.map((item) => item.day));
        _hasPrev = incoming.isNotEmpty && _canLoadPrev;
        _isLoadingPrev = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) {
          return;
        }
        final delta = _scrollController.position.maxScrollExtent - oldMaxExtent;
        _scrollController.jumpTo(_scrollController.offset + delta);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoadingPrev = false;
      });
    }
  }

  Future<void> _loadNext() async {
    if (_isLoadingNext || !_hasNext || _days.isEmpty) {
      return;
    }
    final cursor = _dateOffset(_days.last.day, 1);
    if (cursor.isEmpty) {
      return;
    }
    setState(() {
      _isLoadingNext = true;
    });
    try {
      final response = await getHupuNbaScheduleList(
        cursor: cursor,
        direction: HupuNbaScheduleDirection.next,
      );
      final incoming = response.days
          .where((item) => !_dayKeys.contains(item.day))
          .toList(growable: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _days.addAll(incoming);
        _dayKeys.addAll(incoming.map((item) => item.day));
        _hasNext = incoming.isNotEmpty && _canLoadNext;
        _isLoadingNext = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isLoadingNext = false;
      });
    }
  }

  bool get _canLoadPrev {
    final stats = _stats;
    if (stats == null || _days.isEmpty || stats.earliestDate.isEmpty) {
      return true;
    }
    return _days.first.day.compareTo(stats.earliestDate) > 0;
  }

  bool get _canLoadNext {
    final stats = _stats;
    if (stats == null || _days.isEmpty || stats.latestDate.isEmpty) {
      return true;
    }
    return _days.last.day.compareTo(stats.latestDate) < 0;
  }

  bool _shouldShowTodayButton() {
    final currentDate = _stats?.currentDate ?? '';
    if (currentDate.isEmpty || !_dayKeys.contains(currentDate)) {
      return false;
    }
    final anchorContext = _dayAnchors[currentDate]?.currentContext;
    if (anchorContext == null) {
      return true;
    }
    final box = anchorContext.findRenderObject();
    if (box is! RenderBox) {
      return true;
    }
    final offset = box.localToGlobal(Offset.zero).dy;
    return offset < 106 || offset > MediaQuery.of(context).size.height - 260;
  }

  void _scrollToToday({bool animated = true}) {
    final currentDate = _stats?.currentDate ?? '';
    final offset = _scrollOffsetForDay(currentDate);
    if (offset == null || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final target =
        offset.clamp(position.minScrollExtent, position.maxScrollExtent);
    if (!animated) {
      _scrollController.jumpTo(target);
      return;
    }
    unawaited(
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      ),
    );
    if (_showTodayButton) {
      setState(() {
        _showTodayButton = false;
      });
    }
  }

  double? _scrollOffsetForDay(String day) {
    if (day.isEmpty) {
      return null;
    }
    var offset = 0.0;
    for (final item in _days) {
      if (item.day == day) {
        return offset;
      }
      offset += 42 + (item.matches.length * 98);
    }
    return null;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    try {
      await _fetchInitial(showLoading: false);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      } else {
        _isRefreshing = false;
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

  List<LinkedTabItem> _buildLinkedTabs() {
    final sourceTabs = _tabs.isEmpty ? _fallbackTabs : _tabs;
    return sourceTabs.map((tab) {
      switch (tab.id) {
        case 'games':
          return LinkedTabItem(
            id: tab.id,
            label: tab.name,
            child: _ScheduleGamesTab(
              isInitialLoading: _isInitialLoading,
              days: _days,
              errorMessage: _errorMessage,
              isLoadingPrev: _isLoadingPrev,
              hasPrev: _hasPrev,
              isLoadingNext: _isLoadingNext,
              hasNext: _hasNext,
              showTodayButton: _showTodayButton,
              scrollController: _scrollController,
              anchorForDay: _anchorForDay,
              onRefresh: _onRefresh,
              refreshIndicatorBuilder: _buildRefreshIndicator,
              onScrollToToday: _scrollToToday,
            ),
          );
        case 'against_playoff':
          return LinkedTabItem(
            id: tab.id,
            label: tab.name,
            child: const _PlayoffBracketView(),
          );
        case 'playersrank':
          return LinkedTabItem(
            id: tab.id,
            label: tab.name,
            child: const _PlayerRankView(),
          );
        case 'teamsrank':
          return LinkedTabItem(
            id: tab.id,
            label: tab.name,
            child: const _TeamRankView(),
          );
        default:
          return LinkedTabItem(
            id: tab.id,
            label: tab.name,
            child: _ScheduleLinkedPlaceholderTab(title: tab.name),
          );
      }
    }).toList(growable: false);
  }

  int _initialLinkedTabIndex() {
    final sourceTabs = _tabs.isEmpty ? _fallbackTabs : _tabs;
    final initialTabId = widget.initialTabId;
    if (initialTabId != null && initialTabId.isNotEmpty) {
      final configuredIndex = sourceTabs.indexWhere(
        (tab) => tab.id == initialTabId,
      );
      if (configuredIndex >= 0) {
        return configuredIndex;
      }
    }
    final index = sourceTabs.indexWhere((tab) => tab.id == 'games');
    return index < 0 ? 0 : index;
  }

  static const List<HupuNbaDataTab> _fallbackTabs = <HupuNbaDataTab>[
    HupuNbaDataTab(
      id: 'games',
      name: '赛程',
      type: 'native',
      url: '',
    ),
    HupuNbaDataTab(
      id: 'against_playoff',
      name: '季后赛',
      type: 'native',
      url: '',
    ),
    HupuNbaDataTab(
      id: 'playersrank',
      name: '球员榜',
      type: 'native',
      url: '',
    ),
    HupuNbaDataTab(
      id: 'teamsrank',
      name: '球队榜',
      type: 'native',
      url: '',
    ),
    HupuNbaDataTab(
      id: 'dailyrank',
      name: '日榜',
      type: 'native',
      url: '',
    ),
  ];

  GlobalKey _anchorForDay(String day) {
    return _dayAnchors.putIfAbsent(day, GlobalKey.new);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    return ScrollConfiguration(
      behavior: const CupertinoScrollBehavior().copyWith(
        dragDevices: _nbaScheduleDragDevices,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  RoutePageHeader(
                    title: 'NBA',
                    onBack: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: LinkedTabView(
                      items: _buildLinkedTabs(),
                      initialIndex: _initialLinkedTabIndex(),
                      tabBarHeight: isCompact ? 46 : 52,
                      tabBarPadding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 12 : 20,
                      ),
                      tabSpacing: isCompact ? 18 : 32,
                      activeTabColor: const Color(0xFF202127),
                      inactiveTabColor: const Color(0xFF8F96A3),
                      activeIndicatorColor: const Color(0xFFE91B2A),
                      activeFontSize: isCompact ? 16 : 20,
                      inactiveFontSize: isCompact ? 16 : 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  const _ScheduleDaySection({
    required this.day,
    super.key,
  });

  final HupuNbaScheduleDay day;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 42,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          color: const Color(0xFFF0F1F5),
          child: Text(
            day.dayBlock,
            style: const TextStyle(
              color: Color(0xFF6E7582),
              fontSize: 14,
            ),
          ),
        ),
        ...day.matches.map((match) => _ScheduleMatchTile(match: match)),
      ],
    );
  }
}

class _ScheduleMatchTile extends StatelessWidget {
  const _ScheduleMatchTile({required this.match});

  final HupuNbaScheduleMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 0.7),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.timeText,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    match.stageText,
                    style: const TextStyle(
                      color: Color(0xFF9AA1AE),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TeamLine(
                  logoUrl: match.awayTeamLogo,
                  name: match.awayTeamName,
                  bigScore: match.awayBigScore,
                ),
                const SizedBox(height: 8),
                _TeamLine(
                  logoUrl: match.homeTeamLogo,
                  name: match.homeTeamName,
                  bigScore: match.homeBigScore,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 38,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _scoreText(match.awayScore),
                  style: TextStyle(
                    color: match.isCompleted
                        ? const Color(0xFF9AA1AE)
                        : const Color(0xFF202127),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _scoreText(match.homeScore),
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFFEDEEF2),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SizedBox(
              width: 52,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    match.rightTitle,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (match.scoreText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      match.scoreText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9AA1AE),
                        fontSize: 10,
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

  String _scoreText(int? score) => score == null ? '-' : '$score';
}

class _ScheduleGamesTab extends StatelessWidget {
  const _ScheduleGamesTab({
    required this.isInitialLoading,
    required this.days,
    required this.errorMessage,
    required this.isLoadingPrev,
    required this.hasPrev,
    required this.isLoadingNext,
    required this.hasNext,
    required this.showTodayButton,
    required this.scrollController,
    required this.anchorForDay,
    required this.onRefresh,
    required this.refreshIndicatorBuilder,
    required this.onScrollToToday,
  });

  final bool isInitialLoading;
  final List<HupuNbaScheduleDay> days;
  final String? errorMessage;
  final bool isLoadingPrev;
  final bool hasPrev;
  final bool isLoadingNext;
  final bool hasNext;
  final bool showTodayButton;
  final ScrollController scrollController;
  final GlobalKey Function(String day) anchorForDay;
  final Future<void> Function() onRefresh;
  final LinkedTabRefreshIndicatorBuilder refreshIndicatorBuilder;
  final VoidCallback onScrollToToday;

  @override
  Widget build(BuildContext context) {
    if (isInitialLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (days.isEmpty) {
      return _ScheduleEmptyState(detail: errorMessage);
    }
    return Stack(
      children: [
        LinkedTabPageRefresh(
          onRefresh: onRefresh,
          indicatorBuilder: refreshIndicatorBuilder,
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: _TopLoadingIndicator(
                  isLoading: isLoadingPrev,
                  hasMore: hasPrev,
                ),
              ),
              SliverList.builder(
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  return _ScheduleDaySection(
                    key: anchorForDay(day.day),
                    day: day,
                  );
                },
              ),
              SliverToBoxAdapter(
                child: _BottomLoadingIndicator(
                  isLoading: isLoadingNext,
                  hasMore: hasNext,
                ),
              ),
            ],
          ),
        ),
        if (showTodayButton)
          Positioned(
            left: 0,
            right: 0,
            bottom: 78,
            child: Center(
              child: _TodayFloatingButton(onTap: onScrollToToday),
            ),
          ),
      ],
    );
  }
}

class _ScheduleLinkedPlaceholderTab extends StatelessWidget {
  const _ScheduleLinkedPlaceholderTab({required this.title});

  final String title;

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildRefreshIndicator(
    BuildContext context,
    LinkedTabRefreshState state,
    double progress,
  ) {
    final isArmed = state == LinkedTabRefreshState.armed ||
        state == LinkedTabRefreshState.refreshing;
    final isRefreshing = state == LinkedTabRefreshState.refreshing ||
        state == LinkedTabRefreshState.complete;
    return HupuRefreshIndicator(
      progress: progress,
      isArmed: isArmed,
      isRefreshing: isRefreshing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LinkedTabPageRefresh(
      onRefresh: _onRefresh,
      indicatorBuilder: _buildRefreshIndicator,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D101828),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$title页先占位，后续再接实际内容。',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
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

class _TeamLine extends StatelessWidget {
  const _TeamLine({
    required this.logoUrl,
    required this.name,
    required this.bigScore,
  });

  final String logoUrl;
  final String name;
  final int? bigScore;

  @override
  Widget build(BuildContext context) {
    final suffix = bigScore == null ? '' : '($bigScore)';
    return Row(
      children: [
        CustomNetworkImage(
          logoUrl,
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$name$suffix',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _TodayFloatingButton extends StatelessWidget {
  const _TodayFloatingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: const Color(0xCC4A4F52),
      borderRadius: BorderRadius.circular(5),
      onPressed: onTap,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '回到今日',
            style: TextStyle(color: CupertinoColors.white, fontSize: 15),
          ),
          SizedBox(width: 4),
          Icon(
            CupertinoIcons.chevron_down,
            color: CupertinoColors.white,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _TopLoadingIndicator extends StatelessWidget {
  const _TopLoadingIndicator({
    required this.isLoading,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return const SizedBox.shrink();
    }
    return const SizedBox(
      height: 42,
      child: Center(child: CupertinoActivityIndicator(radius: 10)),
    );
  }
}

class _BottomLoadingIndicator extends StatelessWidget {
  const _BottomLoadingIndicator({
    required this.isLoading,
    required this.hasMore,
  });

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 52,
        child: Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }
    return SizedBox(
      height: 52,
      child: Center(
        child: Text(
          hasMore ? '' : '没有更多了',
          style: const TextStyle(color: Color(0xFF9AA1AE), fontSize: 13),
        ),
      ),
    );
  }
}

class _PlayoffBracketView extends StatefulWidget {
  const _PlayoffBracketView();

  @override
  State<_PlayoffBracketView> createState() => _PlayoffBracketViewState();
}

class _PlayoffBracketViewState extends State<_PlayoffBracketView> {
  late final Future<HupuNbaPlayoffBracketData> _future;

  @override
  void initState() {
    super.initState();
    _future = getHupuNbaPlayoffBracket();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HupuNbaPlayoffBracketData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator(radius: 14));
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return _ScheduleEmptyState(detail: snapshot.error?.toString());
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 0, 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final scale = width / _BracketCanvas.canvasSize.width;
                final height = _BracketCanvas.canvasSize.height * scale;
                return SizedBox(
                  width: width,
                  height: height,
                  child: FittedBox(
                    alignment: Alignment.topCenter,
                    fit: BoxFit.contain,
                    child: _BracketCanvas(data: snapshot.data!),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _BracketCanvas extends StatelessWidget {
  const _BracketCanvas({required this.data});

  final HupuNbaPlayoffBracketData data;

  static const Size canvasSize = Size(390, 1050);

  @override
  Widget build(BuildContext context) {
    final byNumber = <String, HupuNbaPlayoffMatchup>{
      for (final item in data.items) item.planChartNumber: item,
    };
    return SizedBox(
      width: canvasSize.width,
      height: canvasSize.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _BracketLinePainter(matchups: byNumber),
            ),
          ),
          const Positioned(
            left: 18,
            top: 22,
            child: _BracketWatermark(text: 'EAST'),
          ),
          const Positioned(
            left: 18,
            top: 610,
            child: _BracketWatermark(text: 'WEST'),
          ),
          ..._bracketPositions.entries.map((entry) {
            final matchup = byNumber[entry.key];
            if (matchup == null) {
              return const SizedBox.shrink();
            }
            return Positioned(
              left: entry.value.dx,
              top: entry.value.dy,
              child: _BracketMatchupCardV2(
                matchup: matchup,
                isFinal: entry.key == '3-0',
                onTap: matchup.canOpenSeries
                    ? () => _showSeriesMatches(context, data.season, matchup)
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BracketLinePainter extends CustomPainter {
  const _BracketLinePainter({required this.matchups});

  final Map<String, HupuNbaPlayoffMatchup> matchups;

  @override
  void paint(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = const Color(0xFFE91B2A)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final greyPaint = Paint()
      ..color = const Color(0xFFE0E1E5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final line in _bracketLines) {
      final from = matchups[line.from];
      if (from == null) {
        _drawPath(canvas, greyPaint, line.start, line.mid, line.end);
        continue;
      }
      final sourceY = (_bracketPositions[line.from]?.dy ?? line.start.dy) + 72;
      if (from.winnerTeamId.isEmpty) {
        final start = Offset(_teamAnchorX(line.from, null), sourceY);
        _drawPath(canvas, greyPaint, start, line.mid, line.end);
        continue;
      }
      final winnerIsLeft = from.winnerTeamId == from.teamId;
      final winnerStart =
          Offset(_teamAnchorX(line.from, winnerIsLeft), sourceY);
      final loserStart =
          Offset(_teamAnchorX(line.from, !winnerIsLeft), sourceY);
      final loserMid = Offset(loserStart.dx, line.mid.dy);
      _drawPath(canvas, greyPaint, loserStart, loserMid, line.mid);
      _drawPath(canvas, redPaint, winnerStart, line.mid, line.end);
    }
  }

  void _drawPath(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset mid,
    Offset end,
  ) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, mid.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  double _teamAnchorX(String key, bool? leftTeam) {
    final origin = _bracketPositions[key] ?? Offset.zero;
    if (leftTeam == null) {
      return origin.dx + 45;
    }
    return origin.dx + (leftTeam ? 14 : 76);
  }

  @override
  bool shouldRepaint(covariant _BracketLinePainter oldDelegate) {
    return oldDelegate.matchups != matchups;
  }
}

void _showSeriesMatches(
  BuildContext context,
  String season,
  HupuNbaPlayoffMatchup matchup,
) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return _SeriesMatchPopupV2(
        future: getHupuNbaPlayoffSeriesMatches(
          teamIds: matchup.teamIds,
          season: season,
        ),
      );
    },
  );
}

// ignore: unused_element
class _BracketMatchupCard extends StatelessWidget {
  const _BracketMatchupCard({
    required this.matchup,
    required this.onTap,
  });

  final HupuNbaPlayoffMatchup matchup;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leftWinner = matchup.winnerTeamId.isNotEmpty &&
        matchup.winnerTeamId == matchup.teamId;
    final rightWinner = matchup.winnerTeamId.isNotEmpty &&
        matchup.winnerTeamId == matchup.oppoTeamId;
    final card = SizedBox(
      width: 160,
      height: 76,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BracketTeamBadge(
                logoUrl: matchup.teamLogo,
                rank: matchup.rank,
                name: matchup.teamName,
                isWinner: leftWinner,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${matchup.score}-${matchup.oppoScore}',
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _BracketTeamBadge(
                logoUrl: matchup.oppoTeamLogo,
                rank: matchup.oppoRank,
                name: matchup.oppoTeamName,
                isWinner: rightWinner,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  matchup.teamName.isEmpty ? '待定' : matchup.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: leftWinner || matchup.winnerTeamId.isEmpty
                        ? const Color(0xFF202127)
                        : const Color(0xFFB8BDC7),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  matchup.oppoTeamName.isEmpty ? '待定' : matchup.oppoTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: rightWinner || matchup.winnerTeamId.isEmpty
                        ? const Color(0xFF202127)
                        : const Color(0xFFB8BDC7),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.72 : 1,
        child: card,
      ),
    );
  }
}

class _BracketMatchupCardV2 extends StatelessWidget {
  const _BracketMatchupCardV2({
    required this.matchup,
    required this.isFinal,
    required this.onTap,
  });

  final HupuNbaPlayoffMatchup matchup;
  final bool isFinal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leftWinner = matchup.winnerTeamId.isNotEmpty &&
        matchup.winnerTeamId == matchup.teamId;
    final rightWinner = matchup.winnerTeamId.isNotEmpty &&
        matchup.winnerTeamId == matchup.oppoTeamId;
    final child = isFinal
        ? _buildFinal(leftWinner, rightWinner)
        : _buildNormal(leftWinner, rightWinner);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(opacity: onTap == null ? 0.74 : 1, child: child),
    );
  }

  Widget _buildNormal(bool leftWinner, bool rightWinner) {
    return SizedBox(
      width: 90,
      height: 72,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                child: Center(
                  child: _BracketTeamBadgeV2(
                    logoUrl: matchup.teamLogo,
                    rank: matchup.rank,
                    isWinner: leftWinner,
                  ),
                ),
              ),
              SizedBox(
                width: 34,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${matchup.score}-${matchup.oppoScore}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                child: Center(
                  child: _BracketTeamBadgeV2(
                    logoUrl: matchup.oppoTeamLogo,
                    rank: matchup.oppoRank,
                    isWinner: rightWinner,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: _BracketTeamName(
                  name: matchup.teamName,
                  isWinner: leftWinner,
                  winnerKnown: matchup.winnerTeamId.isNotEmpty,
                ),
              ),
              Expanded(
                child: _BracketTeamName(
                  name: matchup.oppoTeamName,
                  isWinner: rightWinner,
                  winnerKnown: matchup.winnerTeamId.isNotEmpty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinal(bool leftWinner, bool rightWinner) {
    return Container(
      width: 330,
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF4A800), width: 2.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BracketFinalTeam(
              logoUrl: matchup.teamLogo,
              name: matchup.teamName,
              rank: matchup.rank,
              isWinner: leftWinner,
            ),
          ),
          Text(
            '${matchup.score}总决赛${matchup.oppoScore}',
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: _BracketFinalTeam(
              logoUrl: matchup.oppoTeamLogo,
              name: matchup.oppoTeamName,
              rank: matchup.oppoRank,
              isWinner: rightWinner,
              alignRight: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketTeamName extends StatelessWidget {
  const _BracketTeamName({
    required this.name,
    required this.isWinner,
    required this.winnerKnown,
  });

  final String name;
  final bool isWinner;
  final bool winnerKnown;

  @override
  Widget build(BuildContext context) {
    return Text(
      name.isEmpty ? '待定' : name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: !winnerKnown || isWinner
            ? const Color(0xFF202127)
            : const Color(0xFFB8BDC7),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _BracketTeamBadgeV2 extends StatelessWidget {
  const _BracketTeamBadgeV2({
    required this.logoUrl,
    required this.rank,
    required this.isWinner,
  });

  final String logoUrl;
  final int rank;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: logoUrl.isEmpty
                ? const Color(0xFFE0E0E0)
                : CupertinoColors.white,
            border: Border.all(color: const Color(0xFFE6E8EE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: logoUrl.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(2),
                  child: CustomNetworkImage(logoUrl, fit: BoxFit.contain),
                ),
        ),
        if (rank > 0)
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xAA858B95),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BracketFinalTeam extends StatelessWidget {
  const _BracketFinalTeam({
    required this.logoUrl,
    required this.name,
    required this.rank,
    required this.isWinner,
    this.alignRight = false,
  });

  final String logoUrl;
  final String name;
  final int rank;
  final bool isWinner;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final badge = _BracketTeamBadgeV2(
      logoUrl: logoUrl,
      rank: rank,
      isWinner: isWinner,
    );
    final label = Flexible(
      child: Text(
        name.isEmpty ? '待定' : name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(
          color: isWinner || name.isEmpty
              ? const Color(0xFF202127)
              : const Color(0xFFB8BDC7),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    return Row(
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignRight
          ? <Widget>[label, const SizedBox(width: 8), badge]
          : <Widget>[badge, const SizedBox(width: 8), label],
    );
  }
}

class _BracketTeamBadge extends StatelessWidget {
  const _BracketTeamBadge({
    required this.logoUrl,
    required this.rank,
    required this.name,
    required this.isWinner,
  });

  final String logoUrl;
  final int rank;
  final String name;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: logoUrl.isEmpty
                ? const Color(0xFFE0E0E0)
                : CupertinoColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 4,
              ),
            ],
          ),
          child: logoUrl.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.all(3),
                  child: CustomNetworkImage(logoUrl, fit: BoxFit.contain),
                ),
        ),
        if (rank > 0)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xAA5E6268),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BracketWatermark extends StatelessWidget {
  const _BracketWatermark({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0x07000000),
        fontSize: 132,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
  }
}

// ignore: unused_element
class _SeriesMatchPopup extends StatelessWidget {
  const _SeriesMatchPopup({required this.future});

  final Future<List<HupuNbaPlayoffSeriesMatch>> future;

  @override
  Widget build(BuildContext context) {
    return CupertinoPopupSurface(
      isSurfacePainted: false,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.86,
        constraints: const BoxConstraints(maxHeight: 620),
        margin: const EdgeInsets.only(bottom: 54),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: FutureBuilder<List<HupuNbaPlayoffSeriesMatch>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 260,
                child: Center(child: CupertinoActivityIndicator(radius: 13)),
              );
            }
            final matches =
                snapshot.data ?? const <HupuNbaPlayoffSeriesMatch>[];
            if (snapshot.hasError || matches.isEmpty) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Text(
                    snapshot.error?.toString() ?? '暂无比赛',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8F96A3),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: matches.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _SeriesMatchTile(match: matches[index]);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(52, 52),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: CupertinoColors.white),
                      color: const Color(0x33FFFFFF),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: CupertinoColors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SeriesMatchPopupV2 extends StatelessWidget {
  const _SeriesMatchPopupV2({required this.future});

  final Future<List<HupuNbaPlayoffSeriesMatch>> future;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final panelWidth = screen.width * 0.78;
    final panelTop = screen.height * 0.18;
    final panelMaxHeight = screen.height * 0.58;
    return SizedBox(
      width: screen.width,
      height: screen.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: panelTop,
            child: Container(
              width: panelWidth,
              constraints: BoxConstraints(maxHeight: panelMaxHeight),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: FutureBuilder<List<HupuNbaPlayoffSeriesMatch>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 260,
                      child: Center(
                        child: CupertinoActivityIndicator(radius: 13),
                      ),
                    );
                  }
                  final matches =
                      snapshot.data ?? const <HupuNbaPlayoffSeriesMatch>[];
                  if (snapshot.hasError || matches.isEmpty) {
                    return SizedBox(
                      height: 220,
                      child: Center(
                        child: Text(
                          snapshot.error?.toString() ?? '暂无比赛',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8F96A3),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: matches.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _SeriesMatchTileV2(match: matches[index]);
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: panelTop + panelMaxHeight + 16,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 52),
              onPressed: () => Navigator.of(context).pop(),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CupertinoColors.white, width: 1.4),
                  color: const Color(0x22FFFFFF),
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  color: CupertinoColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesMatchTile extends StatelessWidget {
  const _SeriesMatchTile({required this.match});

  final HupuNbaPlayoffSeriesMatch match;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              match.homeTeamName,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, color: Color(0xFF202127)),
            ),
          ),
          const SizedBox(width: 10),
          CustomNetworkImage(
            match.homeTeamLogo,
            width: 42,
            height: 42,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${match.homeScore ?? '-'}-${match.awayScore ?? '-'}',
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${match.dateText}${match.displayStatus}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8F96A3),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CustomNetworkImage(
            match.awayTeamLogo,
            width: 42,
            height: 42,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              match.awayTeamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 22, color: Color(0xFF202127)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesMatchTileV2 extends StatelessWidget {
  const _SeriesMatchTileV2({required this.match});

  final HupuNbaPlayoffSeriesMatch match;

  @override
  Widget build(BuildContext context) {
    final homeWon = match.homeWon;
    final awayWon = match.awayWon;
    final homeColor =
        awayWon ? const Color(0xFFB8BDC7) : const Color(0xFF202127);
    final awayColor =
        homeWon ? const Color(0xFFB8BDC7) : const Color(0xFF202127);
    final homeWeight = homeWon ? FontWeight.w700 : FontWeight.w500;
    final awayWeight = awayWon ? FontWeight.w700 : FontWeight.w500;
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 26,
            child: Text(
              match.homeTeamName,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                color: homeColor,
                fontWeight: homeWeight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Opacity(
            opacity: awayWon ? 0.46 : 1,
            child: CustomNetworkImage(
              match.homeTeamLogo,
              width: 38,
              height: 38,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 92,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    maxLines: 1,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1,
                      ),
                      children: [
                        TextSpan(
                          text: '${match.homeScore ?? '-'}',
                          style: TextStyle(
                            color: homeColor,
                            fontWeight:
                                homeWon ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                        const TextSpan(
                          text: '-',
                          style: TextStyle(
                            color: Color(0xFF202127),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '${match.awayScore ?? '-'}',
                          style: TextStyle(
                            color: awayColor,
                            fontWeight:
                                awayWon ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${match.dateText}${match.displayStatus}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8F96A3),
                    fontSize: 16,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Opacity(
            opacity: homeWon ? 0.46 : 1,
            child: CustomNetworkImage(
              match.awayTeamLogo,
              width: 38,
              height: 38,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 26,
            child: Text(
              match.awayTeamName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                color: awayColor,
                fontWeight: awayWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRankView extends StatefulWidget {
  const _PlayerRankView();

  @override
  State<_PlayerRankView> createState() => _PlayerRankViewState();
}

class _PlayerRankViewState extends State<_PlayerRankView> {
  final ScrollController _rankScrollController = ScrollController();
  final ScrollController _metricScrollController = ScrollController();
  final List<GlobalKey> _rankSectionKeys = <GlobalKey>[];
  HupuNbaRankSeason? _selectedSeason;
  List<HupuNbaRankSeason> _seasons = const <HupuNbaRankSeason>[];
  HupuNbaPlayerRankData? _rankData;
  int _activeDimensionIndex = 0;
  int _activeItemIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _rankScrollController.addListener(_handleRankScroll);
    unawaited(_fetchInitial());
  }

  @override
  void dispose() {
    _rankScrollController
      ..removeListener(_handleRankScroll)
      ..dispose();
    _metricScrollController.dispose();
    super.dispose();
  }

  void _handleRankScroll() {
    final dimensions = _rankData?.dimensions ?? const <HupuNbaRankDimension>[];
    if (dimensions.isEmpty || _activeDimensionIndex >= dimensions.length) {
      return;
    }
    final itemCount = dimensions[_activeDimensionIndex].items.length;
    var nextIndex = _activeItemIndex;
    for (var index = 0; index < itemCount; index += 1) {
      final context = _rankSectionKeys[index].currentContext;
      if (context == null) {
        continue;
      }
      final box = context.findRenderObject();
      if (box is! RenderBox) {
        continue;
      }
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= 180) {
        nextIndex = index;
      }
    }
    if (nextIndex != _activeItemIndex && mounted) {
      setState(() {
        _activeItemIndex = nextIndex;
      });
      _scrollMetricIntoView(nextIndex);
    }
  }

  void _ensureRankKeys(int count) {
    if (_rankSectionKeys.length == count) {
      return;
    }
    _rankSectionKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(count, (_) => GlobalKey()));
  }

  void _scrollMetricIntoView(int index) {
    if (!_metricScrollController.hasClients) {
      return;
    }
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    final itemExtent = isCompact ? 70.0 : 82.0;
    final leadingOffset = isCompact ? 96.0 : 120.0;
    final target = (index * itemExtent - leadingOffset).clamp(
      _metricScrollController.position.minScrollExtent,
      _metricScrollController.position.maxScrollExtent,
    );
    unawaited(
      _metricScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _jumpToRankItem(int index) {
    if (index < 0 || index >= _rankSectionKeys.length) {
      return;
    }
    final context = _rankSectionKeys[index].currentContext;
    if (context == null) {
      return;
    }
    setState(() {
      _activeItemIndex = index;
    });
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final seasons = await getHupuNbaRankSeasons();
      final selected = seasons.seasons.isEmpty ? null : seasons.selected;
      final rankData = selected == null
          ? const HupuNbaPlayerRankData(dimensions: <HupuNbaRankDimension>[])
          : await getHupuNbaPlayerRank(
              season: selected.season,
              competitionStageType: selected.seasonType,
            );
      if (!mounted) {
        return;
      }
      setState(() {
        _seasons = seasons.seasons;
        _selectedSeason = selected;
        _rankData = rankData;
        _isLoading = false;
      });
      _ensureRankKeys(rankData.dimensions.isEmpty
          ? 0
          : rankData.dimensions.first.items.length);
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

  Future<void> _selectSeason(HupuNbaRankSeason season) async {
    Navigator.of(context).pop();
    setState(() {
      _selectedSeason = season;
      _isLoading = true;
      _activeDimensionIndex = 0;
      _activeItemIndex = 0;
    });
    try {
      final rankData = await getHupuNbaPlayerRank(
        season: season.season,
        competitionStageType: season.seasonType,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _rankData = rankData;
        _isLoading = false;
      });
      _ensureRankKeys(rankData.dimensions.isEmpty
          ? 0
          : rankData.dimensions.first.items.length);
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

  void _showSeasonPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 360,
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Color(0xFF8F96A3)),
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Color(0xFFE91B2A)),
                      ),
                    ),
                  ],
                ),
              ),
              const DividerLine(),
              Expanded(
                child: ListView.builder(
                  itemCount: _seasons.length,
                  itemBuilder: (context, index) {
                    final season = _seasons[index];
                    final isSelected =
                        season.season == _selectedSeason?.season &&
                            season.seasonType == _selectedSeason?.seasonType;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectSeason(season),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        color: isSelected
                            ? const Color(0xFFF3F5FA)
                            : CupertinoColors.white,
                        child: Text(
                          season.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: isSelected ? 24 : 21,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_errorMessage != null) {
      return _ScheduleEmptyState(detail: _errorMessage);
    }
    final dimensions = _rankData?.dimensions ?? const <HupuNbaRankDimension>[];
    if (dimensions.isEmpty) {
      return const _ScheduleEmptyState();
    }
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    final topBarHeight = isCompact ? 68.0 : 82.0;
    final sideColumnWidth = isCompact ? 92.0 : 118.0;
    final sideItemHeight = isCompact ? 70.0 : 82.0;
    final dimension = dimensions[_activeDimensionIndex];
    _ensureRankKeys(dimension.items.length);
    return Column(
      children: [
        Container(
          height: topBarHeight,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 18),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CupertinoButton(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 18,
                    vertical: isCompact ? 8 : 10,
                  ),
                  color: const Color(0xFFF3F5FA),
                  borderRadius: BorderRadius.circular(4),
                  onPressed: _showSeasonPicker,
                  child: Text(
                    '${_selectedSeason?.displayName ?? '选择赛季'} ▾',
                    style: TextStyle(
                      color: const Color(0xFF202127),
                      fontSize: isCompact ? 16 : 20,
                    ),
                  ),
                ),
                SizedBox(width: isCompact ? 10 : 16),
                ...List.generate(dimensions.length, (index) {
                  final item = dimensions[index];
                  final isActive = index == _activeDimensionIndex;
                  return Padding(
                    padding: EdgeInsets.only(right: isCompact ? 8 : 12),
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 14 : 24,
                        vertical: isCompact ? 8 : 10,
                      ),
                      color: const Color(0xFFF3F5FA),
                      borderRadius: BorderRadius.circular(4),
                      onPressed: () {
                        setState(() {
                          _activeDimensionIndex = index;
                          _activeItemIndex = 0;
                        });
                        _ensureRankKeys(item.items.length);
                        if (_rankScrollController.hasClients) {
                          _rankScrollController.jumpTo(0);
                        }
                      },
                      child: Text(
                        item.chineseName,
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF202127)
                              : const Color(0xFF8F96A3),
                          fontSize: isCompact ? 16 : 20,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: sideColumnWidth,
                color: const Color(0xFFF3F5FA),
                child: ListView.builder(
                  controller: _metricScrollController,
                  itemCount: dimension.items.length,
                  itemBuilder: (context, index) {
                    final item = dimension.items[index];
                    final isActive = index == _activeItemIndex;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _jumpToRankItem(index),
                      child: Container(
                        height: sideItemHeight,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                          left: isCompact ? 12 : 22,
                          right: isCompact ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? CupertinoColors.white
                              : const Color(0xFFF3F5FA),
                          border: isActive
                              ? Border(
                                  left: BorderSide(
                                    color: const Color(0xFFE91B2A),
                                    width: isCompact ? 3 : 4,
                                  ),
                                )
                              : null,
                        ),
                        child: Text(
                          item.chineseName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: isCompact ? 15 : 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: dimension.items.isEmpty
                    ? const _ScheduleEmptyState()
                    : ListView.builder(
                        controller: _rankScrollController,
                        padding: EdgeInsets.zero,
                        itemCount: dimension.items.length,
                        itemBuilder: (context, index) {
                          return _RankItemContentV2(
                            key: _rankSectionKeys[index],
                            item: dimension.items[index],
                            selectedSeason: _selectedSeason,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: unused_element
class _LegacyRankItemContent extends StatelessWidget {
  const _LegacyRankItemContent({required this.item});

  final HupuNbaRankItem item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _RankHeader(title: '${item.chineseName}榜'),
        ...item.players.map((player) => _RankPlayerTile(player: player)),
        if (item.hasMore)
          const SizedBox(
            height: 58,
            child: Center(
              child: Text(
                '查看全部 〉',
                style: TextStyle(color: Color(0xFF9AA1AE), fontSize: 17),
              ),
            ),
          ),
      ],
    );
  }
}

class _RankItemContentV2 extends StatelessWidget {
  const _RankItemContentV2({
    required this.item,
    required this.selectedSeason,
    super.key,
  });

  final HupuNbaRankItem item;
  final HupuNbaRankSeason? selectedSeason;

  bool get _canOpenAll => item.engName == 'basic.ptsAvg';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RankHeader(title: '${item.chineseName}榜'),
        ...item.players.map((player) => _RankPlayerTile(player: player)),
        if (item.hasMore)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _canOpenAll && selectedSeason != null
                ? () {
                    Navigator.of(context).push<void>(
                      CupertinoPageRoute<void>(
                        builder: (_) => _PlayerRankAllPage(
                          item: item,
                          season: selectedSeason!,
                        ),
                      ),
                    );
                  }
                : null,
            child: const SizedBox(
              height: 58,
              child: Center(
                child: Text(
                  '查看全部 ›',
                  style: TextStyle(color: Color(0xFF9AA1AE), fontSize: 17),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TeamRankView extends StatefulWidget {
  const _TeamRankView();

  @override
  State<_TeamRankView> createState() => _TeamRankViewState();
}

class _TeamRankViewState extends State<_TeamRankView> {
  final ScrollController _contentScrollController = ScrollController();
  final ScrollController _menuScrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = <GlobalKey>[];

  HupuNbaRankSeason? _selectedSeason;
  List<HupuNbaRankSeason> _seasons = const <HupuNbaRankSeason>[];
  List<_TeamRankSection> _sections = const <_TeamRankSection>[];
  int _activeSectionIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _contentScrollController.addListener(_handleContentScroll);
    unawaited(_fetchInitial());
  }

  @override
  void dispose() {
    _contentScrollController
      ..removeListener(_handleContentScroll)
      ..dispose();
    _menuScrollController.dispose();
    super.dispose();
  }

  void _ensureSectionKeys(int count) {
    if (_sectionKeys.length == count) {
      return;
    }
    _sectionKeys
      ..clear()
      ..addAll(List<GlobalKey>.generate(count, (_) => GlobalKey()));
  }

  void _handleContentScroll() {
    if (_sections.isEmpty) {
      return;
    }
    var nextIndex = _activeSectionIndex;
    for (var index = 0; index < _sections.length; index += 1) {
      final context = _sectionKeys[index].currentContext;
      if (context == null) {
        continue;
      }
      final box = context.findRenderObject();
      if (box is! RenderBox) {
        continue;
      }
      final top = box.localToGlobal(Offset.zero).dy;
      if (top <= 180) {
        nextIndex = index;
      }
    }
    if (nextIndex != _activeSectionIndex && mounted) {
      setState(() {
        _activeSectionIndex = nextIndex;
      });
      _scrollMenuIntoView(nextIndex);
    }
  }

  void _scrollMenuIntoView(int index) {
    if (!_menuScrollController.hasClients) {
      return;
    }
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    final itemExtent = isCompact ? 68.0 : 78.0;
    final leadingOffset = isCompact ? 88.0 : 118.0;
    final target = (index * itemExtent - leadingOffset).clamp(
      _menuScrollController.position.minScrollExtent,
      _menuScrollController.position.maxScrollExtent,
    );
    unawaited(
      _menuScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _jumpToSection(int index) {
    if (index < 0 || index >= _sectionKeys.length) {
      return;
    }
    final context = _sectionKeys[index].currentContext;
    if (context == null) {
      return;
    }
    setState(() {
      _activeSectionIndex = index;
    });
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  Future<void> _fetchInitial() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final seasons = await getHupuNbaRankSeasons();
      final selected = seasons.seasons.isEmpty ? null : seasons.selected;
      final standingData = selected == null
          ? const HupuNbaTeamStandingData(
              season: '',
              competitionStageType: '',
              eastRows: <HupuNbaTeamStandingRow>[],
              westRows: <HupuNbaTeamStandingRow>[],
              divisionGroups: <HupuNbaTeamStandingDivisionGroup>[],
            )
          : await getHupuNbaTeamStandingList(
              season: selected.season,
              competitionStageType: selected.seasonType,
            );
      final teamRankData = selected == null
          ? const HupuNbaTeamRankData(categories: <HupuNbaTeamRankCategory>[])
          : await getHupuNbaTeamSeasonRank(
              season: selected.season,
              competitionStageType: selected.seasonType,
            );
      if (!mounted) {
        return;
      }
      final sections = _buildTeamRankSections(standingData, teamRankData);
      setState(() {
        _seasons = seasons.seasons;
        _selectedSeason = selected;
        _sections = sections;
        _activeSectionIndex = 0;
        _isLoading = false;
      });
      _ensureSectionKeys(sections.length);
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

  List<_TeamRankSection> _buildTeamRankSections(
    HupuNbaTeamStandingData standingData,
    HupuNbaTeamRankData teamRankData,
  ) {
    final sections = <_TeamRankSection>[];
    if (standingData.eastRows.isNotEmpty) {
      sections.add(
        _TeamRankSection.conference(
          id: 'east',
          title: '东部排行',
          rows: standingData.eastRows,
        ),
      );
    }
    if (standingData.westRows.isNotEmpty) {
      sections.add(
        _TeamRankSection.conference(
          id: 'west',
          title: '西部排行',
          rows: standingData.westRows,
        ),
      );
    }
    if (standingData.divisionGroups.isNotEmpty) {
      sections.add(
        _TeamRankSection.division(
          id: 'division',
          title: '分区排行',
          groups: standingData.divisionGroups,
        ),
      );
    }
    for (final category in teamRankData.categories) {
      sections.add(
        _TeamRankSection.metric(
          id: 'metric-${category.rankType}',
          title: category.name,
          rows: category.rows,
        ),
      );
    }
    return sections;
  }

  Future<void> _selectSeason(HupuNbaRankSeason season) async {
    Navigator.of(context).pop();
    setState(() {
      _selectedSeason = season;
      _isLoading = true;
      _activeSectionIndex = 0;
    });
    try {
      final results = await Future.wait([
        getHupuNbaTeamStandingList(
          season: season.season,
          competitionStageType: season.seasonType,
        ),
        getHupuNbaTeamSeasonRank(
          season: season.season,
          competitionStageType: season.seasonType,
        ),
      ]);
      if (!mounted) {
        return;
      }
      final sections = _buildTeamRankSections(
        results[0] as HupuNbaTeamStandingData,
        results[1] as HupuNbaTeamRankData,
      );
      setState(() {
        _sections = sections;
        _isLoading = false;
      });
      _ensureSectionKeys(sections.length);
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

  void _showSeasonPicker() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        return Container(
          height: 360,
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '取消',
                        style: TextStyle(color: Color(0xFF8F96A3)),
                      ),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '确定',
                        style: TextStyle(color: Color(0xFFE91B2A)),
                      ),
                    ),
                  ],
                ),
              ),
              const DividerLine(),
              Expanded(
                child: ListView.builder(
                  itemCount: _seasons.length,
                  itemBuilder: (context, index) {
                    final season = _seasons[index];
                    final isSelected =
                        season.season == _selectedSeason?.season &&
                            season.seasonType == _selectedSeason?.seasonType;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _selectSeason(season),
                      child: Container(
                        height: 52,
                        alignment: Alignment.center,
                        color: isSelected
                            ? const Color(0xFFF3F5FA)
                            : CupertinoColors.white,
                        child: Text(
                          season.displayName,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: isSelected ? 24 : 21,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }
    if (_errorMessage != null) {
      return _ScheduleEmptyState(detail: _errorMessage);
    }
    if (_sections.isEmpty) {
      return const _ScheduleEmptyState();
    }
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    final topBarHeight = isCompact ? 68.0 : 82.0;
    final menuWidth = isCompact ? 92.0 : 108.0;
    final menuItemHeight = isCompact ? 68.0 : 78.0;

    _ensureSectionKeys(_sections.length);

    return Column(
      children: [
        Container(
          height: topBarHeight,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 18),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 18,
              vertical: isCompact ? 8 : 10,
            ),
            color: const Color(0xFFF3F5FA),
            borderRadius: BorderRadius.circular(4),
            onPressed: _showSeasonPicker,
            child: Text(
              '${_selectedSeason?.displayName ?? '选择赛季'} ▾',
              style: TextStyle(
                color: const Color(0xFF202127),
                fontSize: isCompact ? 16 : 20,
              ),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Container(
                width: menuWidth,
                color: const Color(0xFFF3F5FA),
                child: ListView.builder(
                  controller: _menuScrollController,
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    final isActive = index == _activeSectionIndex;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _jumpToSection(index),
                      child: Container(
                        height: menuItemHeight,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                          left: isCompact ? 12 : 16,
                          right: isCompact ? 8 : 12,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? CupertinoColors.white
                              : const Color(0xFFF3F5FA),
                          border: isActive
                              ? Border(
                                  left: BorderSide(
                                    color: const Color(0xFFE91B2A),
                                    width: isCompact ? 3 : 4,
                                  ),
                                )
                              : null,
                        ),
                        child: Text(
                          section.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isActive
                                ? const Color(0xFF202127)
                                : const Color(0xFF8F96A3),
                            fontSize: isCompact ? 15 : 17,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _contentScrollController,
                  padding: EdgeInsets.zero,
                  itemCount: _sections.length,
                  itemBuilder: (context, index) {
                    final section = _sections[index];
                    return Container(
                      key: _sectionKeys[index],
                      child: _TeamRankSectionBlock(
                        section: section,
                        isCompact: isCompact,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamRankSection {
  const _TeamRankSection._({
    required this.id,
    required this.title,
    required this.kind,
    this.conferenceRows = const <HupuNbaTeamStandingRow>[],
    this.divisionGroups = const <HupuNbaTeamStandingDivisionGroup>[],
    this.metricRows = const <HupuNbaTeamRankRow>[],
  });

  factory _TeamRankSection.conference({
    required String id,
    required String title,
    required List<HupuNbaTeamStandingRow> rows,
  }) {
    return _TeamRankSection._(
      id: id,
      title: title,
      kind: _TeamRankSectionKind.conference,
      conferenceRows: rows,
    );
  }

  factory _TeamRankSection.division({
    required String id,
    required String title,
    required List<HupuNbaTeamStandingDivisionGroup> groups,
  }) {
    return _TeamRankSection._(
      id: id,
      title: title,
      kind: _TeamRankSectionKind.division,
      divisionGroups: groups,
    );
  }

  factory _TeamRankSection.metric({
    required String id,
    required String title,
    required List<HupuNbaTeamRankRow> rows,
  }) {
    return _TeamRankSection._(
      id: id,
      title: title,
      kind: _TeamRankSectionKind.metric,
      metricRows: rows,
    );
  }

  final String id;
  final String title;
  final _TeamRankSectionKind kind;
  final List<HupuNbaTeamStandingRow> conferenceRows;
  final List<HupuNbaTeamStandingDivisionGroup> divisionGroups;
  final List<HupuNbaTeamRankRow> metricRows;
}

enum _TeamRankSectionKind {
  conference,
  division,
  metric,
}

class _TeamRankSectionBlock extends StatelessWidget {
  const _TeamRankSectionBlock({
    required this.section,
    required this.isCompact,
  });

  final _TeamRankSection section;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    switch (section.kind) {
      case _TeamRankSectionKind.conference:
        return _ConferenceSection(
          title: section.title,
          rows: section.conferenceRows,
          isCompact: isCompact,
        );
      case _TeamRankSectionKind.division:
        return _DivisionSection(
          title: section.title,
          groups: section.divisionGroups,
          isCompact: isCompact,
        );
      case _TeamRankSectionKind.metric:
        return _MetricSection(
          title: section.title,
          rows: section.metricRows,
          isCompact: isCompact,
        );
    }
  }
}

class _ConferenceSection extends StatelessWidget {
  const _ConferenceSection({
    required this.title,
    required this.rows,
    required this.isCompact,
  });

  final String title;
  final List<HupuNbaTeamStandingRow> rows;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeamSectionTitle(title: title, isCompact: isCompact),
        _ConferenceHeader(isCompact: isCompact),
        ...rows.map(
          (row) => _ConferenceRow(row: row, isCompact: isCompact),
        ),
      ],
    );
  }
}

class _DivisionSection extends StatelessWidget {
  const _DivisionSection({
    required this.title,
    required this.groups,
    required this.isCompact,
  });

  final String title;
  final List<HupuNbaTeamStandingDivisionGroup> groups;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeamSectionTitle(title: title, isCompact: isCompact),
        ...groups.map(
          (group) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: isCompact ? 34 : 40,
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
                alignment: Alignment.centerLeft,
                color: const Color(0xFFF7F8FB),
                child: Text(
                  group.title,
                  style: TextStyle(
                    color: const Color(0xFF6E7582),
                    fontSize: isCompact ? 13 : 15,
                  ),
                ),
              ),
              _DivisionHeader(isCompact: isCompact),
              ...group.rows.map(
                (row) => _DivisionRow(row: row, isCompact: isCompact),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricSection extends StatelessWidget {
  const _MetricSection({
    required this.title,
    required this.rows,
    required this.isCompact,
  });

  final String title;
  final List<HupuNbaTeamRankRow> rows;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TeamSectionTitle(title: title, isCompact: isCompact),
        _MetricHeader(isCompact: isCompact),
        ...rows.map((row) => _MetricRow(row: row, isCompact: isCompact)),
      ],
    );
  }
}

class _TeamSectionTitle extends StatelessWidget {
  const _TeamSectionTitle({required this.title, required this.isCompact});

  final String title;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 34 : 40,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      color: const Color(0xFFF0F1F5),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF6E7582),
          fontSize: isCompact ? 13 : 15,
        ),
      ),
    );
  }
}

class _ConferenceHeader extends StatelessWidget {
  const _ConferenceHeader({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 12.0 : 14.0;
    return Container(
      height: isCompact ? 36 : 42,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: Text('球队', style: TextStyle(fontSize: fontSize)),
          ),
          Expanded(
            flex: 18,
            child: Text(
              '胜-负',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 24,
            child: Text(
              '胜率/胜场差',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              '近况',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConferenceRow extends StatelessWidget {
  const _ConferenceRow({required this.row, required this.isCompact});

  final HupuNbaTeamStandingRow row;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 12.0 : 14.0;
    return Container(
      height: isCompact ? 52 : 60,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 40,
            child: Row(
              children: [
                SizedBox(
                  width: isCompact ? 16 : 20,
                  child: Text(
                    '${row.rank}',
                    style: TextStyle(
                      color: row.rank == 1
                          ? const Color(0xFFE91B2A)
                          : const Color(0xFF202127),
                      fontSize: fontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CustomNetworkImage(
                  row.logoLink,
                  width: isCompact ? 22 : 26,
                  height: isCompact ? 22 : 26,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    row.teamShortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              row.wl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 24,
            child: Text(
              '${row.winRate}/${row.gb}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF6E7582),
              ),
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              row.streakText,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                color: const Color(0xFF6E7582),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionHeader extends StatelessWidget {
  const _DivisionHeader({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 11.0 : 13.0;
    return Container(
      height: isCompact ? 34 : 40,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 36,
            child: Text('球队', style: TextStyle(fontSize: fontSize)),
          ),
          Expanded(
            flex: 16,
            child: Text(
              '胜-负',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              '胜差',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              '联盟胜-负',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(
              '分区胜-负',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _DivisionRow extends StatelessWidget {
  const _DivisionRow({required this.row, required this.isCompact});

  final HupuNbaTeamStandingRow row;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 11.0 : 13.0;
    return Container(
      height: isCompact ? 50 : 58,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 36,
            child: Row(
              children: [
                SizedBox(
                  width: isCompact ? 16 : 20,
                  child: Text(
                    '${row.rank}',
                    style: TextStyle(
                      color: row.rank == 1
                          ? const Color(0xFFE91B2A)
                          : const Color(0xFF202127),
                      fontSize: fontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CustomNetworkImage(
                  row.logoLink,
                  width: isCompact ? 22 : 26,
                  height: isCompact ? 22 : 26,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    row.teamShortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(
              row.wl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              row.gb,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 20,
            child: Text(
              row.confWl,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(
              row.divWl,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricHeader extends StatelessWidget {
  const _MetricHeader({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 12.0 : 14.0;
    return Container(
      height: isCompact ? 36 : 42,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 76,
            child: Text('球队', style: TextStyle(fontSize: fontSize)),
          ),
          Expanded(
            flex: 24,
            child: Text(
              '数据',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.row, required this.isCompact});

  final HupuNbaTeamRankRow row;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final fontSize = isCompact ? 12.0 : 14.0;
    return Container(
      height: isCompact ? 52 : 60,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 76,
            child: Row(
              children: [
                SizedBox(
                  width: isCompact ? 16 : 20,
                  child: Text(
                    '${row.rank}',
                    style: TextStyle(
                      color: row.rank == 1
                          ? const Color(0xFFE91B2A)
                          : const Color(0xFF202127),
                      fontSize: fontSize,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CustomNetworkImage(
                  row.logoUrl,
                  width: isCompact ? 22 : 26,
                  height: isCompact ? 22 : 26,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    row.teamShortName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 24,
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF202127),
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankHeader extends StatelessWidget {
  const _RankHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    return Container(
      height: isCompact ? 42 : 48,
      padding: EdgeInsets.only(
        left: isCompact ? 12 : 18,
        right: isCompact ? 14 : 22,
      ),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isCompact ? 15 : 18,
                color: const Color(0xFF202127),
              ),
            ),
          ),
          Text(
            '球队',
            style: TextStyle(
              fontSize: isCompact ? 15 : 18,
              color: const Color(0xFF202127),
            ),
          ),
          SizedBox(width: isCompact ? 26 : 40),
          Text(
            '数据',
            style: TextStyle(
              fontSize: isCompact ? 15 : 18,
              color: const Color(0xFF202127),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankPlayerTile extends StatelessWidget {
  const _RankPlayerTile({required this.player});

  final HupuNbaRankPlayer player;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width <= 450;
    return Container(
      height: isCompact ? 72 : 82,
      padding: EdgeInsets.only(
        left: isCompact ? 12 : 18,
        right: isCompact ? 14 : 22,
      ),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isCompact ? 24 : 30,
            child: Text(
              '${player.rank}',
              style: TextStyle(
                color: player.rank == 1
                    ? const Color(0xFFE91B2A)
                    : const Color(0xFF202127),
                fontSize: isCompact ? 15 : 18,
              ),
            ),
          ),
          CustomNetworkImage(
            player.photo,
            width: isCompact ? 44 : 52,
            height: isCompact ? 44 : 52,
            fit: BoxFit.cover,
          ),
          SizedBox(width: isCompact ? 8 : 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF202127),
                    fontSize: isCompact ? 16 : 19,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  player.statSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF8F96A3),
                    fontSize: isCompact ? 13 : 15,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: isCompact ? 56 : 68,
            child: Text(
              player.teamShortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF202127),
                fontSize: isCompact ? 15 : 18,
              ),
            ),
          ),
          SizedBox(
            width: isCompact ? 48 : 58,
            child: Text(
              player.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF202127),
                fontSize: isCompact ? 16 : 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRankAllPage extends StatefulWidget {
  const _PlayerRankAllPage({
    required this.item,
    required this.season,
  });

  final HupuNbaRankItem item;
  final HupuNbaRankSeason season;

  @override
  State<_PlayerRankAllPage> createState() => _PlayerRankAllPageState();
}

class _PlayerRankAllPageState extends State<_PlayerRankAllPage> {
  late Future<HupuNbaRankItem> _future;

  @override
  void initState() {
    super.initState();
    _future = getHupuNbaSingleDimensionPlayerRank(
      rankType: widget.item.engName,
      season: widget.season.season,
      competitionStageType: widget.season.seasonType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.item.chineseName}榜'),
        previousPageTitle: '',
        border: null,
      ),
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<HupuNbaRankItem>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CupertinoActivityIndicator(radius: 14));
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _ScheduleEmptyState(detail: snapshot.error?.toString());
            }
            final item = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: item.players.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _RankHeader(title: '${item.chineseName}榜');
                }
                return _RankPlayerTile(player: item.players[index - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFEDEEF2));
  }
}

class _ScheduleEmptyState extends StatelessWidget {
  const _ScheduleEmptyState({this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          detail == null ? '暂无赛程' : '加载失败\n$detail',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

String _dateOffset(String compactDate, int days) {
  if (compactDate.length != 8) {
    return '';
  }
  final year = int.tryParse(compactDate.substring(0, 4));
  final month = int.tryParse(compactDate.substring(4, 6));
  final day = int.tryParse(compactDate.substring(6, 8));
  if (year == null || month == null || day == null) {
    return '';
  }
  final date = DateTime(year, month, day).add(Duration(days: days));
  final nextMonth = date.month.toString().padLeft(2, '0');
  final nextDay = date.day.toString().padLeft(2, '0');
  return '${date.year}$nextMonth$nextDay';
}

const Map<String, Offset> _bracketPositions = <String, Offset>{
  '0-0': Offset(2, 54),
  '0-1': Offset(100, 54),
  '0-2': Offset(198, 54),
  '0-3': Offset(296, 54),
  '1-0': Offset(52, 188),
  '1-1': Offset(248, 188),
  '2-0': Offset(150, 326),
  '3-0': Offset(30, 470),
  '4-0': Offset(150, 632),
  '5-0': Offset(52, 770),
  '5-1': Offset(248, 770),
  '6-0': Offset(2, 900),
  '6-1': Offset(100, 900),
  '6-2': Offset(198, 900),
  '6-3': Offset(296, 900),
};

const List<_BracketLine> _bracketLines = <_BracketLine>[
  _BracketLine('0-0', '1-0', Offset.zero, Offset(52, 142), Offset(97, 142)),
  _BracketLine('0-1', '1-0', Offset.zero, Offset(145, 142), Offset(97, 142)),
  _BracketLine('0-2', '1-1', Offset.zero, Offset(250, 142), Offset(293, 142)),
  _BracketLine('0-3', '1-1', Offset.zero, Offset(343, 142), Offset(293, 142)),
  _BracketLine('1-0', '2-0', Offset.zero, Offset(97, 282), Offset(195, 282)),
  _BracketLine('1-1', '2-0', Offset.zero, Offset(293, 282), Offset(195, 282)),
  _BracketLine('2-0', '3-0', Offset.zero, Offset(195, 438), Offset(195, 438)),
  _BracketLine('3-0', '4-0', Offset.zero, Offset(195, 604), Offset(195, 604)),
  _BracketLine('4-0', '3-0', Offset.zero, Offset(195, 604), Offset(195, 604)),
  _BracketLine('5-0', '4-0', Offset.zero, Offset(97, 724), Offset(195, 724)),
  _BracketLine('5-1', '4-0', Offset.zero, Offset(293, 724), Offset(195, 724)),
  _BracketLine('6-0', '5-0', Offset.zero, Offset(52, 872), Offset(97, 872)),
  _BracketLine('6-1', '5-0', Offset.zero, Offset(145, 872), Offset(97, 872)),
  _BracketLine('6-2', '5-1', Offset.zero, Offset(250, 872), Offset(293, 872)),
  _BracketLine('6-3', '5-1', Offset.zero, Offset(343, 872), Offset(293, 872)),
];

class _BracketLine {
  const _BracketLine(this.from, this.to, this.start, this.mid, this.end);

  final String from;
  final String to;
  final Offset start;
  final Offset mid;
  final Offset end;
}
