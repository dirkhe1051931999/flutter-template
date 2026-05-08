import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

dynamic commonGetRequest() async {
  try {
    var response = await httpClient.get('/guestbook/list', queryParameters: {
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
    var response = await httpClient.post('/guestbook/list', data: {'code': 15});
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      customLogger.log('Failed to load data from the server');
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
}
