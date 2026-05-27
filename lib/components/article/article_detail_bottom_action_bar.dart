import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';

class ArticleDetailBottomActionBar extends StatelessWidget {
  const ArticleDetailBottomActionBar({
    super.key,
    required this.isCommentMode,
    required this.commentCountText,
    required this.isCollected,
    required this.isLiked,
    required this.onTapPlaceholder,
    required this.onTapModeToggle,
    required this.onTapCollect,
    required this.onTapLike,
    required this.onTapShare,
  });

  final bool isCommentMode;
  final String commentCountText;
  final bool isCollected;
  final bool isLiked;
  final VoidCallback onTapPlaceholder;
  final VoidCallback onTapModeToggle;
  final VoidCallback onTapCollect;
  final VoidCallback onTapLike;
  final VoidCallback onTapShare;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset > 0 ? bottomInset : 8),
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDEEF2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapPlaceholder,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '我来说两句',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ActionIconButton(
            onTap: onTapModeToggle,
            icon: isCommentMode ? 'chatbox-outline' : 'newspaper-outline',
            fallbackIcon: isCommentMode
                ? CupertinoIcons.chat_bubble
                : CupertinoIcons.doc_text,
            badgeText: isCommentMode ? commentCountText : null,
          ),
          _ActionIconButton(
            onTap: onTapCollect,
            icon: isCollected ? 'star' : 'star-outline',
            fallbackIcon:
                isCollected ? CupertinoIcons.star_fill : CupertinoIcons.star,
          ),
          _ActionIconButton(
            onTap: onTapLike,
            icon: isLiked ? 'heart' : 'heart-outline',
            fallbackIcon:
                isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          ),
          _ActionIconButton(
            onTap: onTapShare,
            icon: 'share-social-outline',
            fallbackIcon: CupertinoIcons.share,
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.onTap,
    required this.icon,
    required this.fallbackIcon,
    this.badgeText,
  });

  final VoidCallback onTap;
  final String icon;
  final IconData fallbackIcon;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: const Size(28, 28),
        onPressed: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AppAssetIcon(
              assetName: icon,
              size: 24,
              color: const Color(0xFF1C1C1E),
              fallbackIcon: fallbackIcon,
            ),
            if (badgeText != null && badgeText!.isNotEmpty)
              Positioned(
                top: -8,
                left: 10,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
