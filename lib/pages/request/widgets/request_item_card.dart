import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/model/banner/index.dart';

class RequestItemCard extends StatelessWidget {
  const RequestItemCard({
    required this.item,
    super.key,
  });

  final GuestbookItem item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xF7FFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.person_crop_circle,
                    size: 18,
                    color: Color(0xFF8B93A1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.author ?? '',
                    style: const TextStyle(
                      color: Color(0xFF1F2329),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.content ?? '',
              style: const TextStyle(
                color: Color(0xFF5A6372),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
