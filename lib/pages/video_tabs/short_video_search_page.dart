import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_search_result_page.dart';
import 'package:oolaf_flutted/tools/developer_tools_entry.dart';
import 'package:oolaf_flutted/utils/short_video_search_history_persistence.dart';

class ShortVideoSearchPage extends StatefulWidget {
  const ShortVideoSearchPage({
    super.key,
    required this.seedTitle,
    this.seedSource,
  });

  final String seedTitle;
  final String? seedSource;

  @override
  State<ShortVideoSearchPage> createState() => _ShortVideoSearchPageState();
}

class _ShortVideoSearchPageState extends State<ShortVideoSearchPage> {
  static const int _historyInitialVisibleCount = 5;
  static const int _historyExpandStep = 5;
  static const List<String> _baseHotSearches = <String>[
    '热点新闻',
    '搞笑短片',
    '手机摄影',
    'AI剪辑',
    '电影解说',
    '旅行记录',
    '美食探店',
    '体育集锦',
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<String> _history = const <String>[];
  List<_GuessCandidate> _guesses = const <_GuessCandidate>[];
  int _guessRefreshTick = 0;
  int _historyVisibleCount = _historyInitialVisibleCount;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _refreshGuesses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await ShortVideoSearchHistoryPersistence.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _history = history;
      _historyVisibleCount = history.isEmpty
          ? _historyInitialVisibleCount
          : _historyVisibleCount.clamp(
              _historyInitialVisibleCount,
              history.length,
            );
    });
  }

  Future<void> _submitSearch([String? keyword]) async {
    final text = (keyword ?? _searchController.text).trim();
    if (text.isEmpty) {
      return;
    }
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
    _searchController.text = text;
    _searchController.selection = TextSelection.collapsed(offset: text.length);
    final openedDeveloperTools = await DeveloperToolsEntry.maybeOpenFromInput(
      context,
      text,
    );
    if (openedDeveloperTools) {
      return;
    }
    await ShortVideoSearchHistoryPersistence.add(text);
    await _loadHistory();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => ShortVideoSearchResultPage(keyword: text),
      ),
    );
  }

  Future<void> _removeHistory(String keyword) async {
    await ShortVideoSearchHistoryPersistence.remove(keyword);
    await _loadHistory();
  }

  void _expandHistory() {
    if (_history.isEmpty) {
      return;
    }
    setState(() {
      _historyVisibleCount = (_historyVisibleCount + _historyExpandStep).clamp(
        _historyInitialVisibleCount,
        _history.length,
      );
    });
  }

  void _collapseHistory() {
    setState(() {
      _historyVisibleCount = _historyInitialVisibleCount;
    });
  }

  void _refreshGuesses() {
    final seed = '${widget.seedTitle}::${widget.seedSource ?? ''}';
    final random = math.Random(seed.hashCode + _guessRefreshTick * 97);
    final candidates = _buildGuessPool(random)..shuffle(random);
    final selected = <_GuessCandidate>[];
    final used = <String>{};

    for (final item in candidates) {
      if (used.add(item.text)) {
        selected.add(item);
      }
      if (selected.length >= 8) {
        break;
      }
    }

    setState(() {
      _guesses = selected;
      _guessRefreshTick += 1;
    });
  }

  List<String> _buildHotSearches() {
    final source = widget.seedSource?.trim();
    final result = <String>[];
    if (source != null && source.isNotEmpty) {
      result.add('$source 热门视频');
      result.add('$source 最新内容');
    }
    for (final item in _baseHotSearches) {
      if (!result.contains(item)) {
        result.add(item);
      }
    }
    return result.take(8).toList(growable: false);
  }

  List<_GuessCandidate> _buildGuessPool(math.Random random) {
    final source = widget.seedSource?.trim();
    final title = widget.seedTitle.trim();

    final baseTopics = <String>[
      '高能转场',
      '卡点节奏',
      '运镜教学',
      '同款BGM',
      '热门模板',
      '拍摄技巧',
      '剪辑思路',
      '剧情反转',
      '爆款文案',
      '镜头拆解',
      '氛围感大片',
      'AI剪辑',
      '手机摄影',
      '创意短片',
    ];

    final sourceCandidates = source == null || source.isEmpty
        ? const <String>[]
        : <String>[
            '$source 热门视频',
            '$source 同款',
            '$source 爆款剪辑',
            '$source 最新内容',
          ];

    final titleCandidates = <String>[
      title,
      '$title 同款',
      '$title 教程',
      '$title 原声',
      '$title 怎么拍',
      '$title 慢放版',
    ];

    final pool = <_GuessCandidate>[];
    for (final text in titleCandidates) {
      final clamped = text.trim();
      if (clamped.isEmpty) {
        continue;
      }
      pool.add(
        _GuessCandidate(
          text: clamped,
          relevance: 0.85 + random.nextDouble() * 0.15,
        ),
      );
    }

    for (final text in sourceCandidates) {
      pool.add(
        _GuessCandidate(
          text: text,
          relevance: 0.72 + random.nextDouble() * 0.2,
        ),
      );
    }

    for (final topic in baseTopics) {
      final related = random.nextDouble();
      final text = related > 0.55 ? '$topic $title' : topic;
      final relevance = related > 0.7
          ? 0.68 + random.nextDouble() * 0.22
          : 0.35 + random.nextDouble() * 0.35;
      pool.add(_GuessCandidate(text: text, relevance: relevance));
    }

    return pool;
  }

  Color _guessColor(double relevance) {
    if (relevance < 0.62) {
      return const Color(0xFF3A3A3C);
    }
    final t = ((relevance - 0.62) / 0.38).clamp(0.0, 1.0);
    return Color.lerp(const Color(0xFF3A3A3C), const Color(0xFFD70015), t) ??
        const Color(0xFF3A3A3C);
  }

  String _ellipsis8(String text) {
    final runes = text.runes.toList(growable: false);
    if (runes.length <= 8) {
      return text;
    }
    return '${String.fromCharCodes(runes.take(8))}...';
  }

  @override
  Widget build(BuildContext context) {
    final visibleHistoryCount = _historyVisibleCount.clamp(0, _history.length);
    final visibleHistory =
        _history.take(visibleHistoryCount).toList(growable: false);
    final recentHistory = visibleHistory.take(5).toList(growable: false);
    final earlierHistory = visibleHistory.skip(5).toList(growable: false);
    final hasMoreHistory = _history.length > visibleHistoryCount;
    final canCollapseHistory = _history.length > _historyInitialVisibleCount &&
        visibleHistoryCount >= _history.length;
    final hotSearches = _buildHotSearches();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      resizeToAvoidBottomInset: false,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 10, 10),
              child: Row(
                children: [
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    minimumSize: Size.zero,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const AppAssetIcon(
                      assetName: 'arrow-back',
                      size: 22,
                      color: CupertinoColors.black,
                      fallbackIcon: CupertinoIcons.back,
                    ),
                  ),
                  Expanded(
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      placeholder: '搜索你感兴趣的视频',
                      onSubmitted: (_) {
                        _submitSearch();
                      },
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 10, right: 2),
                    minimumSize: Size.zero,
                    onPressed: _submitSearch,
                    child: const Text(
                      '搜索',
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                children: [
                  if (_history.isNotEmpty) ...[
                    _SectionHeader(
                      title: '最近搜索',
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: () async {
                          await ShortVideoSearchHistoryPersistence.clearAll();
                          await _loadHistory();
                        },
                        child: const Text(
                          '清空',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final keyword in recentHistory)
                          _HistoryChip(
                            text: keyword,
                            onTap: () {
                              _submitSearch(keyword);
                            },
                            onDelete: () {
                              _removeHistory(keyword);
                            },
                          ),
                      ],
                    ),
                    if (earlierHistory.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const _SectionHeader(title: '更早搜索'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final keyword in earlierHistory)
                            _HistoryChip(
                              text: keyword,
                              onTap: () {
                                _submitSearch(keyword);
                              },
                              onDelete: () {
                                _removeHistory(keyword);
                              },
                            ),
                        ],
                      ),
                    ],
                    if (hasMoreHistory || canCollapseHistory) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 0,
                          ),
                          minimumSize: Size.zero,
                          onPressed: hasMoreHistory
                              ? _expandHistory
                              : _collapseHistory,
                          child: Text(
                            hasMoreHistory ? '展开更多' : '收起',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  const _SectionHeader(title: '热门搜索'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < hotSearches.length; i += 1)
                        _HotSearchChip(
                          rank: i + 1,
                          text: hotSearches[i],
                          onTap: () {
                            _submitSearch(hotSearches[i]);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(
                    title: '猜你想搜',
                    trailing: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      onPressed: _refreshGuesses,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppAssetIcon(
                            assetName: 'refresh',
                            size: 14,
                            color: Color(0xFF8E8E93),
                            fallbackIcon: CupertinoIcons.refresh,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '换一换',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _guesses.length.clamp(0, 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 4.2,
                    ),
                    itemBuilder: (context, index) {
                      final item = _guesses[index];
                      return _GuessChip(
                        text: _ellipsis8(item.text),
                        textColor: _guessColor(item.relevance),
                        onTap: () {
                          _submitSearch(item.text);
                        },
                      );
                    },
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.trailing,
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.text,
    required this.onTap,
    required this.onDelete,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final maxChipWidth = MediaQuery.of(context).size.width - 72;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8ED)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CupertinoButton(
                padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
                minimumSize: Size.zero,
                onPressed: onTap,
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3A3A3C),
                  ),
                ),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.fromLTRB(2, 4, 8, 4),
              minimumSize: Size.zero,
              onPressed: onDelete,
              child: const AppAssetIcon(
                assetName: 'close-circle',
                size: 14,
                color: Color(0xFFAEAEB2),
                fallbackIcon: CupertinoIcons.clear_circled_solid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotSearchChip extends StatelessWidget {
  const _HotSearchChip({
    required this.rank,
    required this.text,
    required this.onTap,
  });

  final int rank;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hot = rank <= 3;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(16),
      color: CupertinoColors.white,
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$rank',
            style: TextStyle(
              color: hot ? CupertinoColors.systemRed : const Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF3A3A3C),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuessChip extends StatelessWidget {
  const _GuessChip({
    required this.text,
    required this.textColor,
    required this.onTap,
  });

  final String text;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(12),
      color: CupertinoColors.white,
      onPressed: onTap,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GuessCandidate {
  const _GuessCandidate({
    required this.text,
    required this.relevance,
  });

  final String text;
  final double relevance;
}
