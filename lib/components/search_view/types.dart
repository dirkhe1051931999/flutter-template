import 'package:flutter/cupertino.dart';

class SearchSuggestionItem {
  const SearchSuggestionItem({
    required this.id,
    required this.keyword,
    this.badgeText,
    this.isHighlight = false,
  });

  final String id;
  final String keyword;
  final String? badgeText;
  final bool isHighlight;
}

class SearchHistoryItem {
  const SearchHistoryItem({
    required this.keyword,
  });

  final String keyword;
}

class SearchTabItem {
  const SearchTabItem({
    required this.key,
    required this.title,
  });

  final String key;
  final String title;
}

typedef SearchSubmitCallback = Future<void> Function(String keyword);
typedef SearchKeywordCallback = void Function(String keyword);
typedef SearchHistoryDeleteCallback = Future<void> Function(String keyword);
typedef SearchHistoryClearCallback = Future<void> Function();
typedef SearchResultTabBuilder = Widget Function(
  BuildContext context,
  SearchTabItem tab,
);
