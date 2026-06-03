import 'package:redux/redux.dart';
import 'package:oolaf_flutted/api/oolaf/music.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/action.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/oolaf_audio_player.dart';
import 'package:oolaf_flutted/utils/oolaf_music_cache.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class OolafAudioPageLoader {
  Future<void> loadIndexFromCacheOrRemote(Store<AppState> store) async {
    final cached = await OolafMusicCache.readRaw();
    if (cached != null) {
      store.dispatch(OolafSetMusicIndexAction(OolafMusicIndex.fromJson(cached)));
      return;
    }
    await refreshIndex(store);
  }

  Future<void> refreshIndex(Store<AppState> store) async {
    await oolafAudioPlayer.stop();
    store.dispatch(const OolafResetPlaybackAction());
    store.dispatch(const OolafSetLoadingAction(true));
    try {
      final raw = await getOolafMusicIndexRaw();
      if (raw == null) {
        throw StateError('empty response');
      }
      await OolafMusicCache.writeRaw(raw);
      store.dispatch(OolafSetMusicIndexAction(OolafMusicIndex.fromJson(raw)));
    } catch (error, stackTrace) {
      customLogger.log('load oolaf music index failed: $error');
      customLogger.log(stackTrace);
      AppToast.showText('加载失败');
    } finally {
      store.dispatch(const OolafSetLoadingAction(false));
    }
  }
}
