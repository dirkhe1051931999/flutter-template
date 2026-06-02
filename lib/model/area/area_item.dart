class AreaItem {
  const AreaItem({
    required this.code,
    required this.name,
    required this.children,
  });

  final String code;
  final String name;
  final List<AreaItem> children;

  factory AreaItem.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = rawChildren is List
        ? rawChildren
            .whereType<Map<String, dynamic>>()
            .map(AreaItem.fromJson)
            .toList(growable: false)
        : const <AreaItem>[];

    return AreaItem(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      children: children,
    );
  }
}

class AreaSelection {
  const AreaSelection({
    this.province,
    this.city,
    this.county,
    this.town,
  });

  final AreaItem? province;
  final AreaItem? city;
  final AreaItem? county;
  final AreaItem? town;

  static const empty = AreaSelection();

  bool get isEmpty =>
      province == null && city == null && county == null && town == null;

  List<String> namesUpTo(int levelCount) {
    final names = [
      province?.name,
      city?.name,
      county?.name,
      town?.name,
    ]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    final safeLevelCount = levelCount.clamp(1, 4);
    if (names.length <= safeLevelCount) {
      return names;
    }

    return names.sublist(0, safeLevelCount);
  }

  String displayTextUpTo(int levelCount) {
    return namesUpTo(levelCount).join(' / ');
  }

  String get displayText => displayTextUpTo(4);

  String? codeUpTo(int levelCount) {
    final safeLevelCount = levelCount.clamp(1, 4);
    return switch (safeLevelCount) {
      1 => province?.code,
      2 => city?.code ?? province?.code,
      3 => county?.code ?? city?.code ?? province?.code,
      _ => town?.code ?? county?.code ?? city?.code ?? province?.code,
    };
  }

  String? get code => codeUpTo(4);

  AreaSelection copyWith({
    AreaItem? province,
    AreaItem? city,
    AreaItem? county,
    AreaItem? town,
    bool clearProvince = false,
    bool clearCity = false,
    bool clearCounty = false,
    bool clearTown = false,
  }) {
    return AreaSelection(
      province: clearProvince ? null : province ?? this.province,
      city: clearCity ? null : city ?? this.city,
      county: clearCounty ? null : county ?? this.county,
      town: clearTown ? null : town ?? this.town,
    );
  }
}
