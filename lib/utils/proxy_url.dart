import 'package:oolaf_flutted/app.config.dart';

const Set<String> _proxyBypassImageExtensions = <String>{
  '.apng',
  '.avif',
  '.bmp',
  '.gif',
  '.ico',
  '.jpeg',
  '.jpg',
  '.png',
  '.svg',
  '.webp',
};

bool shouldProxyUrl(String targetUrl) {
  if (!AppConfig.shouldUseProxy) {
    return false;
  }
  return !shouldBypassProxyUrl(targetUrl);
}

bool shouldBypassProxyUrl(String targetUrl) {
  final targetUri = Uri.tryParse(targetUrl.trim());
  if (targetUri == null || !targetUri.hasScheme || targetUri.host.isEmpty) {
    return false;
  }

  if (_isImageUrl(targetUri)) {
    return true;
  }

  final musicCdnUri = Uri.tryParse(AppConfig.oolafMusicCdnBaseUrl.trim());
  if (musicCdnUri == null || musicCdnUri.host.isEmpty) {
    return false;
  }

  return targetUri.host.toLowerCase() == musicCdnUri.host.toLowerCase();
}

bool _isImageUrl(Uri uri) {
  final path = uri.path.toLowerCase();
  return _proxyBypassImageExtensions.any(path.endsWith);
}

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
