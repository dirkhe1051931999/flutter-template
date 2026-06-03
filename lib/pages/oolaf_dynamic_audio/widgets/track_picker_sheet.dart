import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/model/oolaf_music/index.dart';

class TrackPickerSheet extends StatelessWidget {
  const TrackPickerSheet({
    super.key,
    required this.title,
    required this.emptyText,
    required this.buildTracks,
    required this.showSearchInput,
    required this.enableFavoriteToggle,
    required this.favoriteUrls,
    required this.onLocateTrack,
    required this.onToggleFavorite,
  });

  final String title;
  final String emptyText;
  final List<OolafMusicTrackItem> Function(String keyword) buildTracks;
  final bool showSearchInput;
  final bool enableFavoriteToggle;
  final Set<String> favoriteUrls;
  final Future<void> Function(OolafMusicTrackItem track) onLocateTrack;
  final Future<void> Function(String url) onToggleFavorite;

  static const Color themeColor = Color(0xFFD43C33);

  static void show(
    BuildContext context, {
    required String title,
    required String emptyText,
    required List<OolafMusicTrackItem> Function(String keyword) buildTracks,
    required bool showSearchInput,
    required bool enableFavoriteToggle,
    required Set<String> favoriteUrls,
    required Future<void> Function(OolafMusicTrackItem track) onLocateTrack,
    required Future<void> Function(String url) onToggleFavorite,
  }) {
    showAppSheet<void>(
      context: context,
      barrierLabel: title,
      position: AppSheetPosition.top,
      maxHeightFactor: 0.72,
      builder: (context) {
        return TrackPickerSheet(
          title: title,
          emptyText: emptyText,
          buildTracks: buildTracks,
          showSearchInput: showSearchInput,
          enableFavoriteToggle: enableFavoriteToggle,
          favoriteUrls: favoriteUrls,
          onLocateTrack: onLocateTrack,
          onToggleFavorite: onToggleFavorite,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var keyword = '';
    return StatefulBuilder(
      builder: (context, setSheetState) {
        final tracks = buildTracks(keyword);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .navTitleTextStyle
                        .copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(36, 36),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const AppAssetIcon(
                    assetName: 'close-circle',
                    size: 26,
                    color: Color(0xFF8E8E93),
                    fallbackIcon: CupertinoIcons.xmark_circle_fill,
                  ),
                ),
              ],
            ),
            if (showSearchInput)
              CupertinoSearchTextField(
                autofocus: true,
                placeholder: '搜索歌曲名',
                onChanged: (value) {
                  setSheetState(() {
                    keyword = value;
                  });
                },
              ),
            const SizedBox(height: 12),
            Flexible(
              child: tracks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          emptyText,
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: tracks.length,
                      separatorBuilder: (_, __) {
                        return Container(
                          height: 1,
                          color: const Color(0x1F3C3C43),
                        );
                      },
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        final isFavorite = favoriteUrls.contains(track.cdnUrl);
                        return CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          alignment: Alignment.centerLeft,
                          onPressed: () {
                            onLocateTrack(track);
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: AppAssetIcon(
                                  assetName: 'musical-note',
                                  color: themeColor,
                                  size: 18,
                                  fallbackIcon: CupertinoIcons.music_note,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    HighlightedText(
                                      text: track.title,
                                      keyword: keyword,
                                      highlightColor: themeColor,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      track.parentKey == '__root__'
                                          ? '根目录'
                                          : track.parentKey,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (enableFavoriteToggle)
                                CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(36, 36),
                                  onPressed: () async {
                                    await onToggleFavorite(track.cdnUrl);
                                    setSheetState(() {});
                                  },
                                  child: AppAssetIcon(
                                    assetName: isFavorite
                                        ? 'star'
                                        : 'star-outline',
                                    color: themeColor,
                                    size: 20,
                                    fallbackIcon: isFavorite
                                        ? CupertinoIcons.star_fill
                                        : CupertinoIcons.star,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    required this.keyword,
    required this.highlightColor,
  });

  final String text;
  final String keyword;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    final query = keyword.trim();
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    final end = start + query.length;
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: TextStyle(
              color: highlightColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
