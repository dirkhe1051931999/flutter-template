import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_light_reply_card.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_media_block.dart';
import 'package:oolaf_flutted/pages/hupu/widgets/hupu_stat.dart';

class HupuFeedCard extends StatelessWidget {
  const HupuFeedCard({
    required this.item,
    this.onTap,
    this.onTapVideo,
    this.onTapMedia,
    this.onTapAuthor,
    this.onTapLightReplyAuthor,
    super.key,
  });

  final HupuFeedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onTapVideo;
  final VoidCallback? onTapMedia;
  final VoidCallback? onTapAuthor;
  final VoidCallback? onTapLightReplyAuthor;

  @override
  Widget build(BuildContext context) {
    final cover = item.pics.isNotEmpty ? item.pics.first : null;
    final lightReply =
        item.lightReplies.isNotEmpty ? item.lightReplies.first : null;
    final video = item.video;
    final mediaImage =
        video?.cover.isNotEmpty == true ? video!.cover : cover?.url ?? '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapAuthor,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomNetworkImage(
                      item.header,
                      width: 40,
                      height: 40,
                      skeletonBorderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTapAuthor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.nickname.isEmpty ? '虎扑用户' : item.nickname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF41414A),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (item.label.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F0),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: Color(0xFFE5484D),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildMetaText(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF9A9AA3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.more_vert,
                  color: Color(0xFFB5B6BE),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (mediaImage.isNotEmpty) ...[
              const SizedBox(height: 12),
              HupuMediaBlock(
                images: item.pics,
                video: video,
                onTap: video?.isPlayable == true ? onTapVideo : onTapMedia,
              ),
            ],
            if (lightReply != null) ...[
              const SizedBox(height: 12),
              HupuLightReplyCard(
                reply: lightReply,
                onTapUser: onTapLightReplyAuthor,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.forumName.isEmpty ? item.topicName : item.forumName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 13,
                    ),
                  ),
                ),
                HupuStat(
                  icon: Icons.thumb_up_alt_outlined,
                  value: item.lights,
                ),
                const SizedBox(width: 18),
                HupuStat(
                  icon: Icons.chat_bubble_outline,
                  value: item.replies,
                ),
                const SizedBox(width: 18),
                HupuStat(
                  icon: Icons.open_in_new,
                  value: item.shareNum,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _buildMetaText(HupuFeedItem item) {
  final dateText = _formatTime(
    item.lastPostTime > 0 ? item.lastPostTime : item.createTime,
  );
  if (item.topicName.isEmpty) {
    return dateText;
  }
  return '${item.topicName}  $dateText';
}

String _formatTime(int seconds) {
  if (seconds <= 0) {
    return '';
  }

  final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true)
      .toLocal();
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inMinutes >= 0 && diff.inMinutes < 60) {
    return '${diff.inMinutes}分钟前';
  }
  if (diff.inHours >= 0 && diff.inHours < 24) {
    return '${diff.inHours}小时前';
  }
  return DateFormat('MM-dd').format(time);
}
