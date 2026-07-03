import 'package:dio/dio.dart';
import 'package:oolaf_flutted/app.config.dart';
import 'package:oolaf_flutted/utils/request.dart';

final apheliosClient = DioClient(baseUrl: AppConfig.apheliosClientApiBaseUrl);

Options apheliosClientOptions({required String apiKey, String? contentType}) {
  return Options(
    contentType: contentType,
    headers: {'x-oolaf-client-key': apiKey},
  );
}

Map<String, dynamic> unwrapApheliosData(dynamic responseData) {
  if (responseData is Map<String, dynamic>) {
    final data = responseData['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return responseData;
  }
  return <String, dynamic>{};
}
