import 'package:flutter/cupertino.dart';

import 'package:oolaf_flutted/pages/home/widgets/home_entry.dart';

class HomeListTile extends StatelessWidget {
  const HomeListTile({
    required this.item,
    required this.onTap,
    super.key,
  });

  final HomeEntry item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xF6FFFFFF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x0D000000)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFF616A78),
                    size: 19,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8A92A0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: Color(0xFFB1B7C2),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
