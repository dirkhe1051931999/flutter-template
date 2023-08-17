import 'package:dio/dio.dart';
import 'package:flutter_template_start/model/news/inews_detail_ad.dart';
import 'package:flutter_template_start/model/news/news_column_add.dart';
import 'package:flutter_template_start/model/news/news_list_ad.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

var client = DioClient(baseUrl: 'https://h5news.ttlaosiji.cn:8080');
Future<INewsColumnAdd> getNewsColumnAdd() async {
  try {
    Response response = await client.postFormData('/newsColumnAdd', data: {
      "channelCode": 'tt',
    });
    if (response.statusCode == 200 && response.data != null) {
      return INewsColumnAdd.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return INewsColumnAdd();
}

Future<INewsListAd> getNewsListAd(Map<String, dynamic> data) async {
  try {
    Response response = await client.postFormData('/newsListAd', data: data);
    if (response.statusCode == 200 && response.data != null) {
      return INewsListAd.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return INewsListAd();
}

Future<INewsDetailAd> getNewsDetailAd(Map<String, dynamic> data) async {
  try {
    Response response = await client.postFormData('/newsDetailAd', data: data);
    if (response.statusCode == 200 && response.data != null) {
      return INewsDetailAd.fromJson(response.data);
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
  return INewsDetailAd();
}
