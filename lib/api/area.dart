import 'package:flutter_template_start/utils/helper.dart';
import 'package:flutter_template_start/utils/request.dart';

var client = DioClient(baseUrl: 'https://api.help.bj.cn/');
void commonGetRequest() async {
  try {
    var response =
        await client.get('/apis/CityC2ode/', queryParameters: {'code': 14});
    customLogger.log(response.data);
  } catch (e) {
    customLogger.log('Error: $e');
  }
}

dynamic commonPostRequest() async {
  try {
    var response = await client.post('/apis/CityCode/', data: {'code': 15});
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    } else {
      customLogger.log('Failed to load data from the server');
    }
  } catch (e) {
    customLogger.log('Error: $e');
  }
}
