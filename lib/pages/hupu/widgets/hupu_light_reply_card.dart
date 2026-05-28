import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class HupuLightReplyCard extends StatelessWidget {
  const HupuLightReplyCard({
    required this.reply,
    super.key,
  });

  final HupuLightReply reply;

  @override
  Widget build(BuildContext context) {
    final replyImage = reply.pics.isNotEmpty ? reply.pics.first.url : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${reply.nickname}:',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF666977),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (reply.lightCount > 0)
                Text(
                  '亮了[${reply.lightCount}]',
                  style: const TextStyle(
                    color: Color(0xFF7A7D88),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if (reply.quoteContent.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reply.quoteNickname.isEmpty
                  ? reply.quoteContent
                  : '| @${reply.quoteNickname}: ${reply.quoteContent}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF9A9AA3),
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            reply.content,
            style: const TextStyle(
              color: Color(0xFF3C3F47),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          if (replyImage.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomNetworkImage(
                replyImage,
                width: 92,
                height: 92,
                fit: BoxFit.cover,
                skeletonBorderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
