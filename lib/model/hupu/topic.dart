class HupuTopicCategoryResponse {
  const HupuTopicCategoryResponse({
    required this.categories,
    required this.adPageId,
  });

  final List<HupuTopicCategory> categories;
  final String adPageId;

  factory HupuTopicCategoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu topics payload');
    }

    final list = data['list'];
    return HupuTopicCategoryResponse(
      categories: list is List
          ? list
              .whereType<Map>()
              .map(
                (item) => HupuTopicCategory.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <HupuTopicCategory>[],
      adPageId: data['ad_page_id']?.toString() ?? '',
    );
  }
}

class HupuTopicCategory {
  const HupuTopicCategory({
    required this.categoryId,
    required this.name,
    required this.topics,
  });

  final int categoryId;
  final String name;
  final List<HupuTopicItem> topics;

  factory HupuTopicCategory.fromJson(Map<String, dynamic> json) {
    final topics = json['topics'];
    return HupuTopicCategory(
      categoryId: _parseInt(json['cate_id']),
      name: json['name']?.toString() ?? '',
      topics: topics is List
          ? topics
              .whereType<Map>()
              .map(
                (item) => HupuTopicItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
          : const <HupuTopicItem>[],
    );
  }
}

class HupuTopicItem {
  const HupuTopicItem({
    required this.topicId,
    required this.name,
    required this.logo,
    required this.countText,
    required this.form,
    required this.type,
  });

  final int topicId;
  final String name;
  final String logo;
  final String countText;
  final int form;
  final int type;

  factory HupuTopicItem.fromJson(Map<String, dynamic> json) {
    return HupuTopicItem(
      topicId: _parseInt(json['topic_id']),
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
      countText: json['count']?.toString() ?? '',
      form: _parseInt(json['form']),
      type: _parseInt(json['type']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
