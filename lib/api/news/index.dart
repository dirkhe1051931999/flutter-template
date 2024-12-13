import 'package:dio/dio.dart';
import 'package:flutter_template_start/model/news/index.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

var client = DioClient(baseUrl: 'https://www.oolaf.top');

Future<TabsModel?> getNewsColumnAdd() async {
  try {
    Response response = await client.get('/flutter-mock/news/tabs.json', queryParameters: {});
    if (response.statusCode == 200 && response.data != null) {
      return TabsModel.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return null;
}

Future<ListModel?> getNewsListAd(Map<String, dynamic> data) async {
  try {
    Response response = await client.get('/flutter-mock/news/list.json', queryParameters: data);
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
    Response response = await client.get('/flutter-mock/news/detail.json', queryParameters: data);
    if (response.statusCode == 200 && response.data != null) {
      return DetailModel.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return null;
}
