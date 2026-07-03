import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/aphelios_client/client.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/utils/aphelios_client_api_key_storage.dart';
import 'package:oolaf_flutted/utils/helper.dart';

Future<Map<String, dynamic>?> getOolafMusicIndexRaw() async {
  try {
    final apiKey = await ApheliosClientApiKeyStorage.load();
    if (apiKey.isEmpty) {
      return null;
    }
    final Response response = await apheliosClient.get('/api/v1/client/music',
        options: apheliosClientOptions(apiKey: apiKey));
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
    final apiKey = await ApheliosClientApiKeyStorage.load();
    if (apiKey.isEmpty) {
      return null;
    }
    final Response response = await apheliosClient.get('/api/v1/client/music',
        options: apheliosClientOptions(apiKey: apiKey));
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return OolafMusicIndex.fromJson(response.data as Map<String, dynamic>);
    }
  } catch (error, stackTrace) {
    customLogger.log('getOolafMusicIndex failed: $error');
    customLogger.log(stackTrace);
  }
  return null;
}
