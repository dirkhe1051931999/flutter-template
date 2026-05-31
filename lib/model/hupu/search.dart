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
    required this.posts,
    required this.users,
    required this.postTotalPage,
    required this.userTotalPage,
    required this.hasMorePosts,
    required this.hasMoreUsers,
  });

  final List<HupuSearchNavItem> navItems;
  final List<HupuSearchPostItem> posts;
  final List<HupuSearchUserItem> users;
  final int postTotalPage;
  final int userTotalPage;
  final bool hasMorePosts;
  final bool hasMoreUsers;

  factory HupuSearchResponse.fromJson(Map<String, dynamic> json) {
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu search payload');
    }

    final sections = result['result'];
    final sectionList = sections is List ? sections : const <dynamic>[];
    Map<String, dynamic>? postsSection;
    Map<String, dynamic>? usersSection;

    for (final section in sectionList) {
      if (section is! Map) {
        continue;
      }
      final typedSection = Map<String, dynamic>.from(section);
      final type = typedSection['type']?.toString() ?? '';
      if (type == 'posts') {
        postsSection = typedSection;
      } else if (type == 'users') {
        usersSection = typedSection;
      }
    }

    return HupuSearchResponse(
      navItems: _parseSearchNavItems(result['search_nav_list']),
      posts: _parseSearchPostItems(postsSection?['data']),
      users: _parseSearchUserItems(usersSection?['data']),
      postTotalPage: _parseInt(postsSection?['totalPage']),
      userTotalPage: _parseInt(usersSection?['totalPage']),
      hasMorePosts: _parseInt(postsSection?['hasNextPage']) == 1,
      hasMoreUsers: _parseInt(usersSection?['hasNextPage']) == 1,
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
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu post search payload');
    }

    final section = _findSearchSection(result, 'posts');
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
    final result = json['result'];
    if (result is! Map<String, dynamic>) {
      throw StateError('Unexpected Hupu user search payload');
    }

    final section = _findSearchSection(result, 'users');
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

Map<String, dynamic>? _findSearchSection(
  Map<String, dynamic> result,
  String type,
) {
  final sections = result['result'];
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

List<HupuSearchHotKeyword> parseHupuSearchHotKeywords(dynamic rawItems) {
  if (rawItems is! List) {
    return const <HupuSearchHotKeyword>[];
  }

  return rawItems
      .whereType<Map>()
      .map(
        (item) => HupuSearchHotKeyword.fromJson(Map<String, dynamic>.from(item)),
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
