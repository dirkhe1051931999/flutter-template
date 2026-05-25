import 'package:oolaf_flutted/utils/video_manager.dart';

class ShortVideoPlaybackCoordinator {
  ShortVideoPlaybackCoordinator._();

  static final ShortVideoPlaybackCoordinator instance =
      ShortVideoPlaybackCoordinator._();

  final Map<String, VideoManager> _managersByScope = <String, VideoManager>{};
  String? _activeScope;

  String? get activeScope => _activeScope;

  void register({
    required String scope,
    required VideoManager manager,
  }) {
    _managersByScope[scope] = manager;
  }

  void unregister(String scope) {
    _managersByScope.remove(scope);
    if (_activeScope == scope) {
      _activeScope = null;
    }
  }

  bool isActive(String scope) {
    return _activeScope == scope;
  }

  Future<void> activate(String scope) async {
    final manager = _managersByScope[scope];
    if (manager == null) {
      _activeScope = scope;
      return;
    }

    final pausedManagers = <VideoManager>{};
    for (final entry in _managersByScope.entries) {
      if (entry.key == scope || identical(entry.value, manager)) {
        continue;
      }
      if (pausedManagers.add(entry.value)) {
        await entry.value.pauseAll();
      }
    }

    _activeScope = scope;
  }

  Future<void> pause(String scope) async {
    final manager = _managersByScope[scope];
    if (manager != null) {
      await manager.pauseAll();
    }
    if (_activeScope == scope) {
      _activeScope = null;
    }
  }

  Future<void> pauseAll() async {
    final pausedManagers = <VideoManager>{};
    for (final manager in _managersByScope.values) {
      if (pausedManagers.add(manager)) {
        await manager.pauseAll();
      }
    }
    _activeScope = null;
  }
}
