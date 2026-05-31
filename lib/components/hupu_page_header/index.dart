import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class HupuPageNavigationBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const HupuPageNavigationBar({
    this.title,
    this.subtitle,
    this.avatarUrl,
    this.onBack,
    this.onTapFollow,
    this.onTapMore,
    this.trailing,
    this.height = 64,
    this.centerTitle = true,
    this.showFollowButton = false,
    this.showMoreButton = false,
    this.followButtonText = '关注',
    super.key,
  });

  final String? title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onBack;
  final VoidCallback? onTapFollow;
  final VoidCallback? onTapMore;
  final Widget? trailing;
  final double height;
  final bool centerTitle;
  final bool showFollowButton;
  final bool showMoreButton;
  final String followButtonText;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CupertinoColors.white,
      child: SafeArea(
        bottom: false,
        child: HupuPageHeader(
          title: title,
          subtitle: subtitle,
          avatarUrl: avatarUrl,
          onBack: onBack,
          onTapFollow: onTapFollow,
          onTapMore: onTapMore,
          trailing: trailing,
          height: height,
          centerTitle: centerTitle,
          showFollowButton: showFollowButton,
          showMoreButton: showMoreButton,
          followButtonText: followButtonText,
        ),
      ),
    );
  }
}

class HupuPageHeader extends StatelessWidget {
  const HupuPageHeader({
    this.title,
    this.subtitle,
    this.avatarUrl,
    this.onBack,
    this.onTapFollow,
    this.onTapMore,
    this.trailing,
    this.height = 64,
    this.centerTitle = true,
    this.showFollowButton = false,
    this.showMoreButton = false,
    this.followButtonText = '关注',
    super.key,
  });

  final String? title;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onBack;
  final VoidCallback? onTapFollow;
  final VoidCallback? onTapMore;
  final Widget? trailing;
  final double height;
  final bool centerTitle;
  final bool showFollowButton;
  final bool showMoreButton;
  final String followButtonText;

  bool get _hasAvatarHeader => (avatarUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: CupertinoColors.white,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: height,
            child: onBack == null
                ? const SizedBox.shrink()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(56, height),
                    onPressed: onBack,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Color(0xFF202127),
                      size: 28,
                    ),
                  ),
          ),
          Expanded(
            child: centerTitle
                ? Center(child: _buildCenterContent())
                : _buildCenterContent(),
          ),
          _buildTrailingArea(),
        ],
      ),
    );
  }

  Widget _buildCenterContent() {
    if (_hasAvatarHeader) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: CustomNetworkImage(
                avatarUrl!,
                width: 32,
                height: 32,
                skeletonBorderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (title ?? '').trim().isNotEmpty ? title! : '详情',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((subtitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8F96A3),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          (title ?? '').trim().isNotEmpty ? title! : '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        if ((subtitle ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8F96A3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailingArea() {
    if (trailing != null) {
      return SizedBox(
        height: height,
        child: Center(child: trailing),
      );
    }

    if (!showFollowButton && !showMoreButton) {
      return SizedBox(width: 56, height: height);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFollowButton)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTapFollow,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5484D)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.add,
                      size: 13,
                      color: Color(0xFFE5484D),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      followButtonText,
                      style: const TextStyle(
                        color: Color(0xFFE5484D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (showMoreButton)
            CupertinoButton(
              padding: const EdgeInsets.only(left: 10),
              minimumSize: const Size(30, 30),
              onPressed: onTapMore,
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Color(0xFF202127),
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}
