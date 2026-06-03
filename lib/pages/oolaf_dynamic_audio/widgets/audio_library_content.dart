import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/oolaf_music/music_list.dart';

class AudioLibraryContent extends StatelessWidget {
  const AudioLibraryContent({
    super.key,
    required this.isLoading,
    required this.musicListKey,
    required this.favoriteUrls,
    required this.onToggleFavorite,
  });

  final bool isLoading;
  final GlobalKey<OolafMusicListState> musicListKey;
  final Set<String> favoriteUrls;
  final Future<void> Function(String url) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(22),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: CupertinoColors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: isLoading
                ? const Center(
                    child: CupertinoActivityIndicator(
                      radius: 12,
                    ),
                  )
                : OolafMusicList(
                    key: musicListKey,
                    favoriteUrls: favoriteUrls,
                    onToggleFavorite: onToggleFavorite,
                  ),
          ),
        ),
      ),
    );
  }
}
