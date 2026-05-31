import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/search_view/types.dart';

class SharedSearchHomeView extends StatelessWidget {
  const SharedSearchHomeView({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.histories,
    required this.suggestions,
    required this.onSubmit,
    required this.onTapHistory,
    required this.onDeleteHistory,
    required this.onClearHistory,
    required this.onTapSuggestion,
    this.headerTrailing,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final List<SearchHistoryItem> histories;
  final List<SearchSuggestionItem> suggestions;
  final SearchSubmitCallback onSubmit;
  final SearchKeywordCallback onTapHistory;
  final SearchHistoryDeleteCallback onDeleteHistory;
  final SearchHistoryClearCallback onClearHistory;
  final SearchKeywordCallback onTapSuggestion;
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context) {
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
              trailing: headerTrailing,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                children: [
                  if (histories.isNotEmpty) ...[
                    _SectionHeader(
                      title: '最近搜索',
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        onPressed: onClearHistory,
                        child: const Text(
                          '清空',
                          style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: histories
                          .map(
                            (item) => _SearchHistoryChip(
                              text: item.keyword,
                              onTap: () => onTapHistory(item.keyword),
                              onDelete: () => onDeleteHistory(item.keyword),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const _SectionHeader(title: '热门搜索'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List<Widget>.generate(
                      suggestions.length,
                      (index) {
                        final item = suggestions[index];
                        return _SearchSuggestionChip(
                          rank: index + 1,
                          item: item,
                          onTap: () => onTapSuggestion(item.keyword),
                        );
                      },
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

class SharedSearchBar extends StatelessWidget {
  const SharedSearchBar({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onSubmit,
    this.trailing,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final SearchSubmitCallback onSubmit;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      child: Row(
        children: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: Size.zero,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Icon(
              CupertinoIcons.back,
              size: 22,
              color: Color(0xFF202127),
            ),
          ),
          Expanded(
            child: CupertinoSearchTextField(
              controller: controller,
              focusNode: focusNode,
              placeholder: placeholder,
              onSubmitted: (value) => onSubmit(value),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ] else ...[
            CupertinoButton(
              padding: const EdgeInsets.only(left: 10, right: 4),
              minimumSize: Size.zero,
              onPressed: () => onSubmit(controller.text),
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
        ],
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
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SearchHistoryChip extends StatelessWidget {
  const _SearchHistoryChip({
    required this.text,
    required this.onTap,
    required this.onDelete,
  });

  final String text;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            minimumSize: Size.zero,
            onPressed: onTap,
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF3B3F46),
                fontSize: 13,
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.fromLTRB(0, 6, 10, 6),
            minimumSize: Size.zero,
            onPressed: onDelete,
            child: const Icon(
              CupertinoIcons.clear_circled_solid,
              size: 15,
              color: Color(0xFFB4B8C1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSuggestionChip extends StatelessWidget {
  const _SearchSuggestionChip({
    required this.rank,
    required this.item,
    required this.onTap,
  });

  final int rank;
  final SearchSuggestionItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isHot = rank <= 3 || item.isHighlight;
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(18),
      color: CupertinoColors.white,
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$rank',
            style: TextStyle(
              color: isHot ? const Color(0xFFE5484D) : const Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            item.keyword,
            style: const TextStyle(
              color: Color(0xFF31343B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          if ((item.badgeText ?? '').trim().isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                item.badgeText!,
                style: const TextStyle(
                  color: Color(0xFFE5484D),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
