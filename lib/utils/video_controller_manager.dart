import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'package:oolaf_flutted/utils/oolaf_media_kit_controller.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class VideoControllerManager {
  VideoControllerManager();

  final Map<String, OolafVideoController> _controllerCache =
      <String, OolafVideoController>{};

  final ListQueue<String> _accessOrder = ListQueue<String>();

  /// Keep (current - 1, current, current + 1) by default.
  final int keepWindow = 1;

  Future<OolafVideoController?> getOrCreate({
    required String id,
    required String url,
  }) async {
    final existing = _controllerCache[id];
    if (existing != null) {
      _touch(id);
      return existing;
    }

    try {
      final controller = await OolafMediaKitController.fromUrl(url);
      await controller.initialize();
      await controller.setLooping(true);

      _controllerCache[id] = controller;
      _touch(id);
      return controller;
    } catch (error) {
      debugPrint('create video controller failed: $error');
      return null;
    }
  }

  OolafVideoController? getById(String id) => _controllerCache[id];

  void _touch(String id) {
    _accessOrder.remove(id);
    _accessOrder.addLast(id);
  }

  Future<void> setActiveIndex({
    required int index,
    required List<({String id, String url})> sources,
  }) async {
    if (sources.isEmpty || index < 0 || index >= sources.length) {
      return;
    }

    final start = (index - keepWindow).clamp(0, sources.length - 1);
    final end = (index + keepWindow).clamp(0, sources.length - 1);

    final keepIds = <String>{
      for (int i = start; i <= end; i++) sources[i].id,
    };

    final idsToDispose = _controllerCache.keys
        .where((id) => !keepIds.contains(id))
        .toList(growable: false);

    for (final id in idsToDispose) {
      await _disposeById(id);
    }

    // Preload current and next first.
    await getOrCreate(id: sources[index].id, url: sources[index].url);
    if (index + 1 < sources.length) {
      await getOrCreate(id: sources[index + 1].id, url: sources[index + 1].url);
    }
    if (index - 1 >= 0) {
      await getOrCreate(id: sources[index - 1].id, url: sources[index - 1].url);
    }
  }

  Future<void> pauseAll() async {
    final controllers = _controllerCache.values.toList(growable: false);
    for (final c in controllers) {
      try {
        await c.pause();
        await c.seekTo(Duration.zero);
      } catch (_) {}
    }
  }

  Future<void> disposeAll() async {
    final ids = _controllerCache.keys.toList(growable: false);
    for (final id in ids) {
      await _disposeById(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  Future<void> _disposeById(String id) async {
    final controller = _controllerCache.remove(id);
    _accessOrder.remove(id);
    if (controller == null) {
      return;
    }

    try {
      await controller.dispose();
    } catch (_) {}
  }
}
