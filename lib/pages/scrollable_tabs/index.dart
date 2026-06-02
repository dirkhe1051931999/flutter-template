import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:oolaf_flutted/components/linked_tab_view/index.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/mock_models.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/widgets/helpers.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/widgets/refresh_indicator.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/widgets/summary_card.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/widgets/tab_view.dart';

class ScrollableTabsPage extends StatefulWidget {
  const ScrollableTabsPage({super.key});

  @override
  State<ScrollableTabsPage> createState() => _ScrollableTabsPageState();
}

class _ScrollableTabsPageState extends State<ScrollableTabsPage> {
  ScrollableTabsMockData? _mockData;
  Object? _loadError;
  int _activeIndex = 0;
  int _initialIndex = 0;
  LinkedTabChangeSource _lastChangeSource = LinkedTabChangeSource.programmatic;
  final Map<String, int> _refreshCounts = <String, int>{};
  final Map<String, String> _tabSessions = <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    try {
      final raw = await rootBundle.loadString(
        'lib/pages/scrollable_tabs/mock.json',
      );
      final jsonMap = jsonDecode(raw);
      if (jsonMap is! Map<String, dynamic>) {
        throw const FormatException('mock.json root must be an object');
      }
      final mockData = ScrollableTabsMockData.fromJson(jsonMap);
      setState(() {
        _mockData = mockData;
        _loadError = null;
        _activeIndex = 0;
        _initialIndex = 0;
      });
    } catch (error) {
      setState(() {
        _loadError = error;
      });
    }
  }

  Future<void> _refreshTab(String tabId) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final currentData = _mockData;
    if (!mounted || currentData == null) {
      return;
    }
    final nextTabs = currentData.tabs.map((tab) {
      if (tab.id != tabId || tab.cards.length < 2) {
        return tab;
      }
      final nextCards = <ScrollableTabsMockCard>[
        ...tab.cards.skip(1),
        tab.cards.first,
      ];
      return tab.copyWith(cards: nextCards);
    }).toList(growable: false);

    setState(() {
      _mockData = ScrollableTabsMockData(tabs: nextTabs);
      _refreshCounts[tabId] = (_refreshCounts[tabId] ?? 0) + 1;
    });
  }

  void _jumpToTab(int index) {
    final mockData = _mockData;
    if (mockData == null || mockData.tabs.isEmpty) {
      return;
    }
    final nextIndex = index.clamp(0, mockData.tabs.length - 1);
    if (nextIndex == _activeIndex && nextIndex == _initialIndex) {
      return;
    }
    setState(() {
      _initialIndex = nextIndex;
    });
  }

  String _sessionForTab(String tabId) {
    return _tabSessions.putIfAbsent(
      tabId,
      () => DateTime.now().microsecondsSinceEpoch.toString().substring(7),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError != null) {
      return PageScaffold(
        title: 'Scrollable Tabs',
        widget: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'mock 数据加载失败：$_loadError',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5B6270),
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
    }

    final mockData = _mockData;
    if (mockData == null) {
      return const PageScaffold(
        title: 'Scrollable Tabs',
        widget: Center(
          child: CupertinoActivityIndicator(radius: 12),
        ),
      );
    }

    final tabs = mockData.tabs;
    final activeTab = tabs[_activeIndex.clamp(0, tabs.length - 1)];

    return PageScaffold(
      title: 'Scrollable Tabs',
      widget: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: LinkedTabSummaryCard(
              currentTabLabel: activeTab.label,
              currentDescription: activeTab.description,
              refreshCount: _refreshCounts[activeTab.id] ?? 0,
              lastChangeSource: linkedTabSourceText(_lastChangeSource),
              onJumpToFirst: () => _jumpToTab(0),
              onJumpToState: () => _jumpToTab(2),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: LinkedTabView(
                items: tabs
                    .map(
                      (tab) => LinkedTabItem(
                        id: tab.id,
                        label: tab.label,
                        keepAlive: tab.keepAlive,
                        swipeEnabled: tab.swipeEnabled,
                        refreshConfig: LinkedTabRefreshConfig(
                          onRefresh: () => _refreshTab(tab.id),
                          indicatorBuilder: (context, state, progress) {
                            return LinkedRefreshIndicator(
                              label: tab.label,
                              accentColor: parseLinkedTabColor(tab.accentColor),
                              state: state,
                              progress: progress,
                            );
                          },
                        ),
                        child: ScrollableTabsTabView(
                          tab: tab,
                          sessionId: _sessionForTab(tab.id),
                          refreshCount: _refreshCounts[tab.id] ?? 0,
                          accentColor: parseLinkedTabColor(tab.accentColor),
                        ),
                      ),
                    )
                    .toList(growable: false),
                initialIndex: _initialIndex,
                onIndexChanged: (index, source) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _activeIndex = index;
                      _initialIndex = index;
                      _lastChangeSource = source;
                    });
                  });
                },
                tabBarHeight: 52,
                tabBarPadding: const EdgeInsets.symmetric(horizontal: 16),
                tabSpacing: 26,
                pageSpacing: 10,
                tabBarBackgroundColor: CupertinoColors.white,
                tabBarBorderColor: const Color(0xFFF0F1F4),
                activeTabColor: const Color(0xFF1F2329),
                inactiveTabColor: const Color(0xFF9499A5),
                activeIndicatorColor: parseLinkedTabColor(
                  activeTab.accentColor,
                ),
                activeFontSize: 18,
                inactiveFontSize: 15,
                activeFontWeight: FontWeight.w700,
                inactiveFontWeight: FontWeight.w500,
                enablePageSwipe: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
