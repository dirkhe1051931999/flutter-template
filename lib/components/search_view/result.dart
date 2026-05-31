import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/search_view/home.dart';
import 'package:oolaf_flutted/components/search_view/types.dart';

class SharedSearchResultShell extends StatelessWidget {
  const SharedSearchResultShell({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onSubmit,
    required this.tabs,
    required this.activeTabKey,
    required this.onChangeTab,
    required this.tabBuilder,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final SearchSubmitCallback onSubmit;
  final List<SearchTabItem> tabs;
  final String activeTabKey;
  final ValueChanged<String> onChangeTab;
  final SearchResultTabBuilder tabBuilder;

  @override
  Widget build(BuildContext context) {
    final activeTab = tabs.firstWhere(
      (item) => item.key == activeTabKey,
      orElse: () => tabs.first,
    );

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      resizeToAvoidBottomInset: false,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SharedSearchBar(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              onSubmit: onSubmit,
            ),
            _SearchResultTabs(
              tabs: tabs,
              activeTabKey: activeTabKey,
              onChangeTab: onChangeTab,
            ),
            Expanded(
              child: tabBuilder(context, activeTab),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTabs extends StatelessWidget {
  const _SearchResultTabs({
    required this.tabs,
    required this.activeTabKey,
    required this.onChangeTab,
  });

  final List<SearchTabItem> tabs;
  final String activeTabKey;
  final ValueChanged<String> onChangeTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE9EBEF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: tabs.map((item) {
          final isActive = item.key == activeTabKey;
          return GestureDetector(
            onTap: () => onChangeTab(item.key),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF202127)
                          : const Color(0xFF8E8E93),
                      fontSize: 15,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFE5484D)
                          : CupertinoColors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
