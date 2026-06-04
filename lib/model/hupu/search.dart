class HupuSearchHotKeyword {
  const HupuSearchHotKeyword({
    required this.name,
    required this.showName,
    required this.isRecommend,
    required this.itemId,
  });

  final String name;
  final String showName;
  final bool isRecommend;
  final String itemId;

  String get displayText => showName.trim().isNotEmpty ? showName : name;

  factory HupuSearchHotKeyword.fromJson(Map<String, dynamic> json) {
    return HupuSearchHotKeyword(
      name: json['name']?.toString() ?? '',
      showName: json['showName']?.toString() ?? '',
      isRecommend: _parseInt(json['is_recommend']) == 1,
      itemId: json['itemid']?.toString() ?? '',
    );
  }
}

class HupuSearchNavItem {
  const HupuSearchNavItem({
    required this.title,
    required this.type,
  });

  final String title;
  final String type;

  factory HupuSearchNavItem.fromJson(Map<String, dynamic> json) {
    return HupuSearchNavItem(
      title: json['search_title']?.toString() ?? '',
      type: json['search_type']?.toString() ?? '',
    );
  }
}

class HupuSearchResponse {
  const HupuSearchResponse({
    required this.navItems,
    required this.postSection,
    required this.userSection,
    required this.topicSection,
    required this.matchSection,
  });

  final List<HupuSearchNavItem> navItems;
  final HupuSearchPostSection postSection;
  final HupuSearchUserSection userSection;
  final HupuSearchTopicSection topicSection;
  final HupuSearchMatchSection matchSection;

  List<HupuSearchPostItem> get posts => postSection.items;
  List<HupuSearchUserItem> get users => userSection.items;
  int get postTotalPage => postSection.totalPage;
  int get userTotalPage => userSection.totalPage;
  bool get hasMorePosts => postSection.hasNextPage;
  bool get hasMoreUsers => userSection.hasNextPage;

  factory HupuSearchResponse.fromJson(Map<String, dynamic> json) {
    final postsSection = _findSearchSection(json, 'posts');
    final usersSection = _findSearchSection(json, 'users');
    final topicsSection = _findSearchSection(json, 'bbsTag');
    final matchSection = _findSearchSection(json, 'match');

    return HupuSearchResponse(
      navItems: _parseSearchNavItems(json['search_nav_list']),
      postSection: HupuSearchPostSection.fromSection(postsSection),
      userSection: HupuSearchUserSection.fromSection(usersSection),
      topicSection: HupuSearchTopicSection.fromSection(topicsSection),
      matchSection: HupuSearchMatchSection.fromSection(matchSection),
    );
  }
}

class HupuSearchPostSection {
  const HupuSearchPostSection({
    required this.title,
    required this.moreTitle,
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final String title;
  final String moreTitle;
  final List<HupuSearchPostItem> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchPostSection.fromSection(Map<String, dynamic>? section) {
    return HupuSearchPostSection(
      title: section?['search_title']?.toString() ?? '帖子',
      moreTitle: section?['moreTitle']?.toString() ?? '查看更多',
      items: _parseSearchPostItems(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchUserSection {
  const HupuSearchUserSection({
    required this.title,
    required this.moreTitle,
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final String title;
  final String moreTitle;
  final List<HupuSearchUserItem> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchUserSection.fromSection(Map<String, dynamic>? section) {
    return HupuSearchUserSection(
      title: section?['search_title']?.toString() ?? '用户',
      moreTitle: section?['moreTitle']?.toString() ?? '查看更多',
      items: _parseSearchUserItems(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchTopicSection {
  const HupuSearchTopicSection({
    required this.title,
    required this.moreTitle,
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final String title;
  final String moreTitle;
  final List<HupuSearchTopicItem> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchTopicSection.fromSection(Map<String, dynamic>? section) {
    return HupuSearchTopicSection(
      title: section?['search_title']?.toString() ?? '话题',
      moreTitle: section?['moreTitle']?.toString() ?? '查看更多',
      items: _parseSearchTopicItems(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchMatchSection {
  const HupuSearchMatchSection({
    required this.title,
    required this.moreTitle,
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final String title;
  final String moreTitle;
  final List<HupuSearchMatchDay> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchMatchSection.fromSection(Map<String, dynamic>? section) {
    return HupuSearchMatchSection(
      title: section?['search_title']?.toString() ?? '赛程',
      moreTitle: section?['moreTitle']?.toString() ?? '查看更多',
      items: _parseSearchMatchDays(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchPostPage {
  const HupuSearchPostPage({
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final List<HupuSearchPostItem> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchPostPage.fromJson(Map<String, dynamic> json) {
    final section = _findSearchSection(json, 'posts');
    return HupuSearchPostPage(
      items: _parseSearchPostItems(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchUserPage {
  const HupuSearchUserPage({
    required this.items,
    required this.totalPage,
    required this.hasNextPage,
  });

  final List<HupuSearchUserItem> items;
  final int totalPage;
  final bool hasNextPage;

  factory HupuSearchUserPage.fromJson(Map<String, dynamic> json) {
    final section = _findSearchSection(json, 'users');
    return HupuSearchUserPage(
      items: _parseSearchUserItems(section?['data']),
      totalPage: _parseInt(section?['totalPage']),
      hasNextPage: _parseInt(section?['hasNextPage']) == 1,
    );
  }
}

class HupuSearchPostItem {
  const HupuSearchPostItem({
    required this.id,
    required this.title,
    required this.content,
    required this.replies,
    required this.lights,
    required this.recNum,
    required this.username,
    required this.header,
    required this.picture,
    required this.isPic,
    required this.img,
    required this.movie,
    required this.fid,
    required this.forumName,
    required this.schema,
    required this.itemId,
    required this.addTimeDisplay,
  });

  final String id;
  final String title;
  final String content;
  final int replies;
  final int lights;
  final int recNum;
  final String username;
  final String header;
  final String picture;
  final bool isPic;
  final String img;
  final bool movie;
  final String fid;
  final String forumName;
  final String schema;
  final String itemId;
  final String addTimeDisplay;

  bool get hasImage => picture.trim().isNotEmpty || img.trim().isNotEmpty;

  String get previewImage => picture.trim().isNotEmpty ? picture : img;

  factory HupuSearchPostItem.fromJson(Map<String, dynamic> json) {
    return HupuSearchPostItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      replies: _parseInt(json['replies']),
      lights: _parseInt(json['lights']),
      recNum: _parseInt(json['recNum']),
      username: json['username']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      picture: json['picture']?.toString() ?? '',
      isPic: json['isPic']?.toString() == '1' || json['pic'] == true,
      img: json['img']?.toString() ?? '',
      movie: json['movie'] == true || json['isMovie']?.toString() == '1',
      fid: json['fid']?.toString() ?? '',
      forumName: json['forum_name']?.toString() ?? '',
      schema: json['schema']?.toString() ?? '',
      itemId: json['itemid']?.toString() ?? '',
      addTimeDisplay: json['addTimeDisplay']?.toString() ?? '',
    );
  }
}

class HupuSearchUserItem {
  const HupuSearchUserItem({
    required this.id,
    required this.username,
    required this.header,
    required this.lights,
    required this.recNum,
    required this.fans,
    required this.relationStatus,
    required this.userInfo,
    required this.url,
    required this.itemId,
  });

  final String id;
  final String username;
  final String header;
  final int lights;
  final int recNum;
  final int fans;
  final int relationStatus;
  final String userInfo;
  final String url;
  final String itemId;

  String get puid {
    final direct = _firstMeaningfulNumeric(<String>[url, itemId, id]);
    return direct;
  }

  factory HupuSearchUserItem.fromJson(Map<String, dynamic> json) {
    return HupuSearchUserItem(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      header: json['header']?.toString() ?? '',
      lights: _parseInt(json['lights']),
      recNum: _parseInt(json['recNum']),
      fans: _parseInt(json['fans']),
      relationStatus: _parseInt(json['relationStatus']),
      userInfo: json['userInfo']?.toString() ?? json['info']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      itemId: json['itemid']?.toString() ?? '',
    );
  }
}

String _firstMeaningfulNumeric(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    final puidFromUrl = _extractPuidFromUrl(trimmed);
    if (puidFromUrl.isNotEmpty) {
      return puidFromUrl;
    }
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return trimmed;
    }
  }
  return '';
}

String _extractPuidFromUrl(String value) {
  final userPathMatch = RegExp(r'/user/(\d+)').firstMatch(value);
  if (userPathMatch != null) {
    return userPathMatch.group(1) ?? '';
  }
  final puidQueryMatch = RegExp(r'[?&]puid=(\d+)').firstMatch(value);
  if (puidQueryMatch != null) {
    return puidQueryMatch.group(1) ?? '';
  }
  return '';
}

class HupuSearchPostSortItem {
  const HupuSearchPostSortItem({
    required this.name,
    required this.postSort,
  });

  final String name;
  final String postSort;

  factory HupuSearchPostSortItem.fromJson(Map<String, dynamic> json) {
    return HupuSearchPostSortItem(
      name: json['name']?.toString() ?? '',
      postSort: json['postSort']?.toString() ?? '',
    );
  }
}

class HupuSearchPostListPage {
  const HupuSearchPostListPage({
    required this.section,
    required this.sortItems,
  });

  final HupuSearchPostSection section;
  final List<HupuSearchPostSortItem> sortItems;

  factory HupuSearchPostListPage.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final section = result is Map<String, dynamic>
        ? HupuSearchPostSection.fromSection(result)
        : result is Map
            ? HupuSearchPostSection.fromSection(
                Map<String, dynamic>.from(result),
              )
            : HupuSearchPostSection.fromSection(null);
    return HupuSearchPostListPage(
      section: section,
      sortItems: _parseSearchPostSortItems(json['postSortList']),
    );
  }
}

class HupuSearchTopicListPage {
  const HupuSearchTopicListPage({
    required this.section,
  });

  final HupuSearchTopicSection section;

  factory HupuSearchTopicListPage.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final section = result is Map<String, dynamic>
        ? HupuSearchTopicSection.fromSection(result)
        : result is Map
            ? HupuSearchTopicSection.fromSection(
                Map<String, dynamic>.from(result),
              )
            : HupuSearchTopicSection.fromSection(null);
    return HupuSearchTopicListPage(section: section);
  }
}

class HupuSearchUserListPage {
  const HupuSearchUserListPage({
    required this.section,
  });

  final HupuSearchUserSection section;

  factory HupuSearchUserListPage.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    final section = result is Map<String, dynamic>
        ? HupuSearchUserSection.fromSection(result)
        : result is Map
            ? HupuSearchUserSection.fromSection(
                Map<String, dynamic>.from(result),
              )
            : HupuSearchUserSection.fromSection(null);
    return HupuSearchUserListPage(section: section);
  }
}

class HupuSearchTopicItem {
  const HupuSearchTopicItem({
    required this.id,
    required this.name,
    required this.info,
    required this.discussNum,
    required this.icon,
    required this.schema,
    required this.itemId,
  });

  final String id;
  final String name;
  final String info;
  final String discussNum;
  final String icon;
  final String schema;
  final String itemId;

  factory HupuSearchTopicItem.fromJson(Map<String, dynamic> json) {
    return HupuSearchTopicItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      info: json['info']?.toString() ?? json['bbsTagInfo']?.toString() ?? '',
      discussNum: json['discussNum']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      schema: json['schema']?.toString() ?? '',
      itemId: json['itemid']?.toString() ?? '',
    );
  }
}

class HupuSearchMatchDay {
  const HupuSearchMatchDay({
    required this.day,
    required this.dayBlock,
    required this.matches,
  });

  final String day;
  final String dayBlock;
  final List<HupuSearchMatchItem> matches;

  factory HupuSearchMatchDay.fromJson(Map<String, dynamic> json) {
    return HupuSearchMatchDay(
      day: json['day']?.toString() ?? '',
      dayBlock: json['dayBlock']?.toString() ?? '',
      matches: _parseSearchMatchItems(json['matchList']),
    );
  }
}

class HupuSearchMatchItem {
  const HupuSearchMatchItem({
    required this.matchId,
    required this.matchTime,
    required this.matchStatusChinese,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.homeScoreString,
    required this.awayTeamName,
    required this.awayTeamLogo,
    required this.awayScoreString,
    required this.pv,
    required this.playerScore,
  });

  final String matchId;
  final String matchTime;
  final String matchStatusChinese;
  final String homeTeamName;
  final String homeTeamLogo;
  final String homeScoreString;
  final String awayTeamName;
  final String awayTeamLogo;
  final String awayScoreString;
  final String pv;
  final HupuSearchMatchPlayerScore? playerScore;

  factory HupuSearchMatchItem.fromJson(Map<String, dynamic> json) {
    final playerScoreJson = json['playerScore'];
    return HupuSearchMatchItem(
      matchId: json['matchId']?.toString() ?? '',
      matchTime: json['matchTime']?.toString() ?? '',
      matchStatusChinese: json['matchStatusChinese']?.toString() ?? '',
      homeTeamName: json['homeTeamName']?.toString() ?? '',
      homeTeamLogo: json['homeTeamLogo']?.toString() ?? '',
      homeScoreString: json['homeScoreString']?.toString() ?? '',
      awayTeamName: json['awayTeamName']?.toString() ?? '',
      awayTeamLogo: json['awayTeamLogo']?.toString() ?? '',
      awayScoreString: json['awayScoreString']?.toString() ?? '',
      pv: json['pv']?.toString() ?? '',
      playerScore: playerScoreJson is Map<String, dynamic>
          ? HupuSearchMatchPlayerScore.fromJson(playerScoreJson)
          : playerScoreJson is Map
              ? HupuSearchMatchPlayerScore.fromJson(
                  Map<String, dynamic>.from(playerScoreJson),
                )
              : null,
    );
  }
}

class HupuSearchMatchPlayerScore {
  const HupuSearchMatchPlayerScore({
    required this.playerName,
    required this.playerLogo,
    required this.playerTeamLogo,
    required this.hotComment,
    required this.playerScoreCount,
    required this.playerScore,
  });

  final String playerName;
  final String playerLogo;
  final String playerTeamLogo;
  final String hotComment;
  final String playerScoreCount;
  final double playerScore;

  factory HupuSearchMatchPlayerScore.fromJson(Map<String, dynamic> json) {
    return HupuSearchMatchPlayerScore(
      playerName: json['playerName']?.toString() ?? '',
      playerLogo: json['playerLogo']?.toString() ?? '',
      playerTeamLogo: json['playerTeamLogo']?.toString() ?? '',
      hotComment: json['hotComment']?.toString() ?? '',
      playerScoreCount: json['playerScoreCount']?.toString() ?? '',
      playerScore: _parseDouble(json['playerScore']),
    );
  }
}

Map<String, dynamic>? _findSearchSection(
  Map<String, dynamic> json,
  String type,
) {
  final sections = json['result'];
  if (sections is! List) {
    return null;
  }

  for (final section in sections) {
    if (section is! Map) {
      continue;
    }
    final typedSection = Map<String, dynamic>.from(section);
    if (typedSection['type']?.toString() == type) {
      return typedSection;
    }
  }
  return null;
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

double _parseDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<HupuSearchHotKeyword> parseHupuSearchHotKeywords(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchHotKeyword>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) =>
            HupuSearchHotKeyword.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchNavItem> _parseSearchNavItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchNavItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchNavItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchPostItem> _parseSearchPostItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchPostItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchPostItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchUserItem> _parseSearchUserItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchUserItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchUserItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchTopicItem> _parseSearchTopicItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchTopicItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchTopicItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchMatchDay> _parseSearchMatchDays(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchMatchDay>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchMatchDay.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchMatchItem> _parseSearchMatchItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchMatchItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchMatchItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}

List<HupuSearchPostSortItem> _parseSearchPostSortItems(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchPostSortItem>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) =>
            HupuSearchPostSortItem.fromJson(Map<String, dynamic>.from(item)),
      )
      .toList(growable: false);
}
