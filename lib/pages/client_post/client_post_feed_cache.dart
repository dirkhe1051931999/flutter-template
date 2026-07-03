import 'package:oolaf_flutted/model/client_post/client_post.dart';

class ClientPostFeedCache {
  static List<ClientPostItem> list = const <ClientPostItem>[];
  static int page = 0;
  static int pageSize = 10;
  static int total = 0;

  static bool get hasData => list.isNotEmpty;
  static bool get hasMore => list.length < total;

  static void replace(ClientPostPageResult result) {
    list = result.list;
    page = result.page;
    pageSize = result.pageSize;
    total = result.total;
  }

  static void append(ClientPostPageResult result) {
    list = <ClientPostItem>[...list, ...result.list];
    page = result.page;
    pageSize = result.pageSize;
    total = result.total;
  }
}
