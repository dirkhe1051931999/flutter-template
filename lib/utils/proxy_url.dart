import 'package:oolaf_flutted/app.config.dart';

String buildProxyUrl({
  required String method,
  required String targetUrl,
}) {
  final proxyBaseUri = Uri.parse(_normalizedProxyBaseUrl());
  final proxyOrigin = '${proxyBaseUri.scheme}://${proxyBaseUri.authority}';
  final proxyPath = _joinProxyPath(
    proxyBaseUri.path,
    'proxy/${method.toLowerCase()}/$targetUrl',
  );
  return '$proxyOrigin$proxyPath';
}

Map<String, String> buildProxyHeaders() {
  final proxyToken = AppConfig.proxyToken.trim();
  if (proxyToken.isEmpty) {
    return const <String, String>{};
  }
  return <String, String>{
    'x-proxy-token': proxyToken,
  };
}

String _normalizedProxyBaseUrl() {
  final value = AppConfig.proxyBaseUrl.trim();
  if (value.endsWith('/')) {
    return value.substring(0, value.length - 1);
  }
  return value;
}

String _joinProxyPath(String basePath, String proxyPath) {
  final normalizedBase = basePath.isEmpty || basePath == '/'
      ? ''
      : basePath.replaceFirst(RegExp(r'/+$'), '');
  return '$normalizedBase/$proxyPath';
}
