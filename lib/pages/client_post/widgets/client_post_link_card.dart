import 'package:flutter/cupertino.dart';

class ClientPostLinkCard extends StatelessWidget {
  const ClientPostLinkCard({
    super.key,
    required this.title,
    required this.url,
    required this.onRemove,
  });

  final String title;
  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(CupertinoIcons.link, color: Color(0xFF576B95), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.isEmpty ? url : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, color: Color(0xFF1F1F1F))),
                const SizedBox(height: 3),
                Text(url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF8A8A8A))),
              ],
            ),
          ),
          CupertinoButton(
            minimumSize: const Size(30, 30),
            padding: EdgeInsets.zero,
            onPressed: onRemove,
            child: const Icon(CupertinoIcons.xmark_circle_fill,
                color: Color(0xFFB3B3B3), size: 21),
          ),
        ],
      ),
    );
  }
}
