import 'package:dio/dio.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/request.dart';

Future<Map<String, dynamic>?> getOolafMusicIndexRaw() async {
  try {
    final Response response = await oolafHubClient.get('/music');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
  } catch (error, stackTrace) {
    customLogger.log('getOolafMusicIndexRaw failed: $error');
    customLogger.log(stackTrace);
  }
  return null;
}

Future<OolafMusicIndex?> getOolafMusicIndex() async {
  try {
    final Response response = await oolafHubClient.get('/music');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return OolafMusicIndex.fromJson(response.data as Map<String, dynamic>);
    }
  } catch (error, stackTrace) {
    customLogger.log('getOolafMusicIndex failed: $error');
    customLogger.log(stackTrace);
  }
  return null;
}
