import 'package:flutter/cupertino.dart';

class ShortVideoInteractionOverlay extends StatelessWidget {
  const ShortVideoInteractionOverlay({
    super.key,
    required this.source,
    required this.title,
    required this.onTapComment,
  });

  final String source;
  final String title;
  final VoidCallback onTapComment;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 220,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x4D000000),
                            Color(0xB3000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 24,
                right: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      source,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconButton(
                      icon: CupertinoIcons.heart_fill,
                      label: '1.2k',
                      onTap: () {},
                    ),
                    const SizedBox(height: 18),
                    _IconButton(
                      icon: CupertinoIcons.chat_bubble_text_fill,
                      label: '评论',
                      onTap: onTapComment,
                    ),
                    const SizedBox(height: 18),
                    _IconButton(
                      icon: CupertinoIcons.share_solid,
                      label: '分享',
                      onTap: () {},
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.music_note,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, color: CupertinoColors.white, size: 34),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
