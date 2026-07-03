class ClientPostPageResult {
  const ClientPostPageResult({required this.list, required this.page, required this.pageSize, required this.total});

  final List<ClientPostItem> list;
  final int page;
  final int pageSize;
  final int total;

  factory ClientPostPageResult.fromJson(Map<String, dynamic> json) {
    final listJson = json['list'];
    return ClientPostPageResult(
      list: listJson is List<dynamic>
          ? listJson.whereType<Map<String, dynamic>>().map(ClientPostItem.fromJson).toList()
          : const <ClientPostItem>[],
      page: json['page'] is int ? json['page'] as int : 1,
      pageSize: json['pageSize'] is int ? json['pageSize'] as int : 10,
      total: json['total'] is int ? json['total'] as int : 0,
    );
  }
}

class ClientPostItem {
  const ClientPostItem({
    required this.id,
    required this.text,
    required this.media,
    required this.link,
    required this.publishedAt,
  });

  final String id;
  final String text;
  final List<ClientPostMediaItem> media;
  final ClientPostLink? link;
  final DateTime? publishedAt;

  List<String> get imageUrls => media.where((item) => item.type == 'image').map((item) => item.url).toList();
  ClientPostMediaItem? get video {
    for (final item in media) {
      if (item.type == 'video') {
        return item;
      }
    }
    return null;
  }

  factory ClientPostItem.fromJson(Map<String, dynamic> json) {
    final mediaJson = json['media'];
    final linkJson = json['link'];
    return ClientPostItem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      media: mediaJson is List<dynamic>
          ? mediaJson.whereType<Map<String, dynamic>>().map(ClientPostMediaItem.fromJson).toList()
          : const <ClientPostMediaItem>[],
      link: linkJson is Map<String, dynamic> ? ClientPostLink.fromJson(linkJson) : null,
      publishedAt: DateTime.tryParse(json['publishedAt']?.toString() ?? ''),
    );
  }
}

class ClientPostMediaItem {
  const ClientPostMediaItem({required this.type, required this.url});

  final String type;
  final String url;

  factory ClientPostMediaItem.fromJson(Map<String, dynamic> json) {
    return ClientPostMediaItem(type: json['type']?.toString() ?? '', url: json['url']?.toString() ?? '');
  }
}

class ClientPostLink {
  const ClientPostLink({required this.title, required this.url});

  final String title;
  final String url;

  factory ClientPostLink.fromJson(Map<String, dynamic> json) {
    return ClientPostLink(title: json['title']?.toString() ?? '', url: json['url']?.toString() ?? '');
  }
}
