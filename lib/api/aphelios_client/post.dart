import 'package:dio/dio.dart';
import 'package:oolaf_flutted/api/aphelios_client/client.dart';
import 'package:oolaf_flutted/model/client_post/client_post.dart';

class ClientUploadedMedia {
  const ClientUploadedMedia({required this.id, required this.url});

  final String id;
  final String url;

  factory ClientUploadedMedia.fromJson(Map<String, dynamic> json) {
    return ClientUploadedMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
    );
  }
}

class ClientPostPayload {
  const ClientPostPayload({
    required this.text,
    required this.visibility,
    required this.imageMediaIds,
    this.videoMediaId,
    this.restrictedOptions,
    this.linkTitle,
    this.linkUrl,
  });

  final String text;
  final String visibility;
  final List<String> imageMediaIds;
  final String? videoMediaId;
  final List<String>? restrictedOptions;
  final String? linkTitle;
  final String? linkUrl;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'visibility': visibility,
      'restrictedOptions': restrictedOptions,
      'imageMediaIds': imageMediaIds,
      'videoMediaId': videoMediaId,
      'linkTitle': linkTitle,
      'linkUrl': linkUrl,
    };
  }
}

Future<ClientUploadedMedia> uploadClientPostMedia(
    String path, String apiKey) async {
  final filename = path.split(RegExp(r'[\\/]')).last;
  final response = await apheliosClient.postFormData(
    '/api/v1/client/media/upload',
    data: {
      'file': await MultipartFile.fromFile(path, filename: filename),
    },
    options: apheliosClientOptions(
        apiKey: apiKey, contentType: Headers.multipartFormDataContentType),
  );
  return ClientUploadedMedia.fromJson(unwrapApheliosData(response.data));
}

Future<Map<String, dynamic>> createClientPost(
    ClientPostPayload payload, String apiKey) async {
  final response = await apheliosClient.post(
    '/api/v1/client/posts',
    data: payload.toJson(),
    options: apheliosClientOptions(apiKey: apiKey),
  );
  return unwrapApheliosData(response.data);
}

Future<ClientPostPageResult> fetchClientPosts(
    {required int page, required int pageSize, required String apiKey}) async {
  final response = await apheliosClient.get(
    '/api/v1/client/posts',
    queryParameters: {'page': page, 'pageSize': pageSize},
    options: apheliosClientOptions(apiKey: apiKey),
  );
  return ClientPostPageResult.fromJson(unwrapApheliosData(response.data));
}
