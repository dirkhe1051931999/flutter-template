import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class OolafVideoCache {
  OolafVideoCache({CacheManager? cacheManager})
      : _cacheManager = cacheManager ?? DefaultCacheManager();

  final CacheManager _cacheManager;

  Future<File> getFile(String url) async {
    final cached = await _cacheManager.getFileFromCache(url);
    if (cached?.file != null) {
      return cached!.file;
    }

    return _cacheManager.getSingleFile(url);
  }
}
