import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class AudioLibraryHeader extends StatelessWidget {
  const AudioLibraryHeader({
    super.key,
    required this.headerImageUrl,
  });

  final String headerImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(22),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFE7E7),
            Color(0xFFFFF6F6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '你的音乐库',
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .navTitleTextStyle
                      .copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C1C1E),
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  '搜索 / 收藏 / 播放列表都在这里',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(16),
            ),
            child: CustomNetworkImage(
              headerImageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 64,
                  height: 64,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
