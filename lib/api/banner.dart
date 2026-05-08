import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

var client = DioClient(baseUrl: 'https://aphelios-api.oolaf.top');

dynamic commonGetRequest() async {
  try {
    var response = await client.get('/guestbook/list', queryParameters: {
      'page': 1,
      'pageSize': 10,
      'sort': 'earliest',
    });
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      customLogger.log('Failed to load data from the server');
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
}

dynamic commonPostRequest() async {
  try {
    var response = await client.post('/guestbook/list', data: {'code': 15});
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      customLogger.log('Failed to load data from the server');
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
}