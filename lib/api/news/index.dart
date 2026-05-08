import 'package:dio/dio.dart';
import 'package:flutter_template_start/model/news/index.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

Future<TabsModel?> getNewsColumnAdd() async {
  return TabsModel.fromJson({
    'data': {
      'columnTypeList': [
        {'id': 1, 'name': '最早', 'sort': 'earliest'},
        {'id': 2, 'name': '最晚', 'sort': 'latest'},
        {'id': 3, 'name': '最热', 'sort': 'popular'},
      ],
    },
    'code': 200,
    'success': true,
    'message': 'SUCCESS',
  });
}

Future<ListModel?> getNewsListAd(Map<String, dynamic> data) async {
  try {
    Response response =
        await httpClient.get('/guestbook/list', queryParameters: {
      'page': data['pageNum'] ?? data['page'] ?? 1,
      'pageSize': data['pageSize'] ?? 10,
      'sort': data['sort'] ?? _sortByColumnId(data['column_id']),
    });
    if (response.statusCode == 200 && response.data != null) {
      return ListModel.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return null;
}

Future<DetailModel?> getNewsDetailAd(Map<String, dynamic> data) async {
  try {
    Response response =
        await httpClient.get('/guestbook/list', queryParameters: {
      'page': 1,
      'pageSize': 10,
      'sort': data['sort'] ?? 'earliest',
    });
    if (response.statusCode == 200 && response.data != null) {
      return DetailModel.fromJson(response.data, data['news_id']);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return null;
}

String _sortByColumnId(dynamic columnId) {
  if (columnId == 2) {
    return 'latest';
  }
  if (columnId == 3) {
    return 'popular';
  }
  return 'earliest';
}
