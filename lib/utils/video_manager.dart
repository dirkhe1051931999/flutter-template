import 'dart:collection';
import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:oolaf_flutted/utils/oolaf_media_kit_controller.dart';
import 'package:oolaf_flutted/utils/oolaf_video_controller.dart';

class VideoManager with WidgetsBindingObserver {
  VideoManager._() {
    WidgetsBinding.instance.addObserver(this);
  }

  static final VideoManager instance = VideoManager._();

  final Map<String, OolafVideoController> _controllerCache =
      <String, OolafVideoController>{};
  final ListQueue<String> _accessOrder = ListQueue<String>();

  int keepWindow = 1;

  Duration backgroundDisposeDelay = const Duration(seconds: 60);
  Timer? _backgroundDisposeTimer;

  final Map<String, int> _scopeRefCount = <String, int>{};

  List<({String id, String url})> _sources = const [];
  int _activeIndex = 0;

  int get activeIndex => _activeIndex;
  List<({String id, String url})> get sources => _sources;

  void setSources(List<({String id, String url})> sources) {
    _sources = List.unmodifiable(sources);
  }

  void acquire(String scope) {
    _scopeRefCount[scope] = (_scopeRefCount[scope] ?? 0) + 1;
  }

  Future<void> release(String scope) async {
    final current = _scopeRefCount[scope] ?? 0;
    if (current <= 1) {
      _scopeRefCount.remove(scope);
    } else {
      _scopeRefCount[scope] = current - 1;
    }

    if (_scopeRefCount.isEmpty) {
      await disposeAll();
    }
  }

  OolafVideoController? getById(String id) {
    final c = _controllerCache[id];
    if (c != null) {
      _touch(id);
    }
    return c;
  }

  Future<void> setActiveIndex(int index) async {
    _activeIndex = index;
    if (_sources.isEmpty) return;

    final keepIds = <String>{};
    for (var i = index - keepWindow; i <= index + keepWindow; i++) {
      if (i < 0 || i >= _sources.length) continue;
      keepIds.add(_sources[i].id);
    }

    for (final source in _sources) {
      if (!keepIds.contains(source.id)) continue;
      await getOrCreate(id: source.id, url: source.url);
    }

    await _disposeNotIn(keepIds);
  }

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

  Future<void> pauseAll() async {
    for (final entry in _controllerCache.entries) {
      try {
        await entry.value.pause();
      } catch (_) {}
    }
  }

  Future<void> playActive() async {
    if (_sources.isEmpty) return;
    if (_activeIndex < 0 || _activeIndex >= _sources.length) return;

    final source = _sources[_activeIndex];
    final id = source.id;
    var c = getById(id);
    c ??= await getOrCreate(id: id, url: source.url);
    await pauseAll();
    if (c == null) {
      debugPrint('playActive failed: controller is null (id=$id)');
      return;
    }
    await c.play();
  }

  Future<void> disposeAll() async {
    _backgroundDisposeTimer?.cancel();
    _backgroundDisposeTimer = null;

    final ids = _controllerCache.keys.toList(growable: false);
    for (final id in ids) {
      final c = _controllerCache.remove(id);
      try {
        await c?.dispose();
      } catch (_) {}
    }
    _accessOrder.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      pauseAll();
      _backgroundDisposeTimer?.cancel();
      _backgroundDisposeTimer = Timer(backgroundDisposeDelay, () {
        disposeAll();
      });
      return;
    }

    if (state == AppLifecycleState.resumed) {
      _backgroundDisposeTimer?.cancel();
      _backgroundDisposeTimer = null;
    }
  }

  void _touch(String id) {
    _accessOrder.remove(id);
    _accessOrder.addLast(id);
  }

  Future<void> _disposeNotIn(Set<String> keepIds) async {
    final toDispose = _controllerCache.keys
        .where((id) => !keepIds.contains(id))
        .toList(growable: false);

    for (final id in toDispose) {
      final c = _controllerCache.remove(id);
      _accessOrder.remove(id);
      try {
        await c?.dispose();
      } catch (_) {}
    }
  }
}
