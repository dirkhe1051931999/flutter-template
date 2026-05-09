import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/oolaf_music/action.dart';
import 'package:flutter_template_start/store/oolaf_music/state.dart';
import 'package:flutter_template_start/utils/oolaf_audio_player.dart';
import 'package:flutter_template_start/components/oolaf_player/disc.dart';
import 'package:flutter_template_start/components/oolaf_player/progress_bar.dart';

class OolafPlayerSheet extends StatelessWidget {
  const OolafPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, OolafMusicState>(
      distinct: true,
      converter: (store) => store.state.oolafMusic,
      builder: (context, state) {
        final nowPlaying = state.nowPlaying;
        const themeColor = Color(0xFFD43C33);

        if (nowPlaying == null) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            OolafRotatingDisc(
              isPlaying: state.isPlaying,
              size: 220,
              title: nowPlaying.title,
              showTonearm: true,
            ),
            const SizedBox(height: 28),
            Text(
              nowPlaying.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            StreamBuilder<Duration>(
              stream: oolafAudioPlayer.positionStream,
              builder: (context, posSnap) {
                return StreamBuilder<Duration?>(
                  stream: oolafAudioPlayer.durationStream,
                  builder: (context, durSnap) {
                    final position = posSnap.data ?? Duration.zero;
                    final duration = durSnap.data ?? Duration.zero;
                    return OolafProgressBar(
                      position: position,
                      duration: duration,
                      onSeek: (to) {
                        oolafAudioPlayer.seek(to);
                      },
                      activeColor: themeColor,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final next = switch (state.loopMode) {
                      OolafLoopMode.off => OolafLoopMode.all,
                      OolafLoopMode.all => OolafLoopMode.one,
                      OolafLoopMode.one => OolafLoopMode.off,
                    };

                    StoreProvider.of<AppState>(context)
                        .dispatch(OolafSetLoopModeAction(next));
                  },
                  icon: Icon(
                    switch (state.loopMode) {
                      OolafLoopMode.off => Icons.repeat,
                      OolafLoopMode.all => Icons.repeat,
                      OolafLoopMode.one => Icons.repeat_one,
                    },
                    color: state.loopMode == OolafLoopMode.off
                        ? Colors.black54
                        : themeColor,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () async {
                    final store = StoreProvider.of<AppState>(context);
                    await oolafAudioPlayer.togglePlayPause();
                    store.dispatch(OolafSetPlayingAction(
                      oolafAudioPlayer.isPlaying,
                    ));
                  },
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: themeColor,
                    size: 64,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
