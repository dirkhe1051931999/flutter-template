import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

String formatCommentCount(int count) {
  if (count >= 10000) {
    return '1w+';
  }
  return count.toString();
}

class CommentListItemStyle {
  const CommentListItemStyle({
    required this.rootAvatarSize,
    required this.childAvatarSize,
    required this.rootLeftInset,
    required this.childLeftInset,
    required this.rootItemPadding,
    required this.childTopSpacing,
    required this.avatarGap,
    required this.nameRootColor,
    required this.nameChildColor,
    required this.nameRootFontSize,
    required this.nameChildFontSize,
    required this.likeColor,
    required this.likeFontSize,
    required this.likeIconSize,
    required this.replyPrefixStyle,
    required this.contentRootStyle,
    required this.contentChildStyle,
    required this.metaStyle,
    required this.replyActionStyle,
    required this.loadMoreStyle,
    required this.loadMoreTopPadding,
    required this.loadMoreLeftInset,
    required this.showLoadMoreLeadingLine,
    required this.leadingLineColor,
    required this.avatarBackgroundColor,
    required this.avatarFallbackColor,
    required this.avatarFallbackScale,
  });

  final double rootAvatarSize;
  final double childAvatarSize;
  final double rootLeftInset;
  final double childLeftInset;
  final EdgeInsets rootItemPadding;
  final double childTopSpacing;
  final double avatarGap;
  final Color nameRootColor;
  final Color nameChildColor;
  final double nameRootFontSize;
  final double nameChildFontSize;
  final Color likeColor;
  final double likeFontSize;
  final double likeIconSize;
  final TextStyle replyPrefixStyle;
  final TextStyle contentRootStyle;
  final TextStyle contentChildStyle;
  final TextStyle metaStyle;
  final TextStyle replyActionStyle;
  final TextStyle loadMoreStyle;
  final double loadMoreTopPadding;
  final double loadMoreLeftInset;
  final bool showLoadMoreLeadingLine;
  final Color leadingLineColor;
  final Color avatarBackgroundColor;
  final Color avatarFallbackColor;
  final double avatarFallbackScale;

  static const CommentListItemStyle doc = CommentListItemStyle(
    rootAvatarSize: 40,
    childAvatarSize: 30,
    rootLeftInset: 0,
    childLeftInset: 52,
    rootItemPadding: EdgeInsets.zero,
    childTopSpacing: 12,
    avatarGap: 12,
    nameRootColor: Color(0xFF4B5563),
    nameChildColor: Color(0xFF4B5563),
    nameRootFontSize: 15,
    nameChildFontSize: 15,
    likeColor: Color(0xFF6B7280),
    likeFontSize: 14,
    likeIconSize: 18,
    replyPrefixStyle: TextStyle(
      color: Color(0xFF6B7280),
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.55,
    ),
    contentRootStyle: TextStyle(
      color: Color(0xFF111827),
      fontSize: 17,
      height: 1.55,
      fontWeight: FontWeight.w400,
    ),
    contentChildStyle: TextStyle(
      color: Color(0xFF111827),
      fontSize: 17,
      height: 1.55,
      fontWeight: FontWeight.w400,
    ),
    metaStyle: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 13,
    ),
    replyActionStyle: TextStyle(
      color: Color(0xFF4B5563),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    loadMoreStyle: TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
    loadMoreTopPadding: 10,
    loadMoreLeftInset: 52,
    showLoadMoreLeadingLine: false,
    leadingLineColor: Color(0xFFD0D4DB),
    avatarBackgroundColor: Color(0xFFF1F5F9),
    avatarFallbackColor: Color(0xFFB7BCC6),
    avatarFallbackScale: 0.52,
  );

  static const CommentListItemStyle phvideo = CommentListItemStyle(
    rootAvatarSize: 38,
    childAvatarSize: 28,
    rootLeftInset: 16,
    childLeftInset: 50,
    rootItemPadding: EdgeInsets.fromLTRB(16, 10, 16, 10),
    childTopSpacing: 4,
    avatarGap: 10,
    nameRootColor: Color(0xFF717784),
    nameChildColor: Color(0xFF8E8E93),
    nameRootFontSize: 13,
    nameChildFontSize: 12,
    likeColor: Color(0xFFB9BDC7),
    likeFontSize: 12,
    likeIconSize: 16,
    replyPrefixStyle: TextStyle(
      color: Color(0xFF5C6270),
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.35,
    ),
    contentRootStyle: TextStyle(
      color: Color(0xFF141619),
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w500,
    ),
    contentChildStyle: TextStyle(
      color: Color(0xFF141619),
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w400,
    ),
    metaStyle: TextStyle(
      color: Color(0xFFB0B4BE),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    replyActionStyle: TextStyle(
      color: Color(0xFF5C6270),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    loadMoreStyle: TextStyle(
      color: Color(0xFF8B92A0),
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    loadMoreTopPadding: 6,
    loadMoreLeftInset: 48,
    showLoadMoreLeadingLine: true,
    leadingLineColor: Color(0xFFD0D4DB),
    avatarBackgroundColor: Color(0xFFECEEF3),
    avatarFallbackColor: Color(0xFFB7BCC6),
    avatarFallbackScale: 0.55,
  );
}

class CommentListView extends StatelessWidget {
  const CommentListView({
    super.key,
    required this.comments,
    required this.style,
    this.loadingReplyCommentId,
    this.onTapReply,
    this.onTapLoadMoreReplies,
    this.itemSpacing = 0,
  });

  final List<ShortVideoCommentItem> comments;
  final CommentListItemStyle style;
  final String? loadingReplyCommentId;
  final ValueChanged<ShortVideoCommentItem>? onTapReply;
  final ValueChanged<ShortVideoCommentItem>? onTapLoadMoreReplies;
  final double itemSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < comments.length; index++) ...[
          if (index > 0 && itemSpacing > 0) SizedBox(height: itemSpacing),
          _CommentListTile(
            item: comments[index],
            style: style,
            isLoadingReplies: loadingReplyCommentId == comments[index].commentId,
            onTapReply: onTapReply,
            onTapLoadMoreReplies: onTapLoadMoreReplies,
          ),
        ],
      ],
    );
  }
}

class CommentListEmptyState extends StatelessWidget {
  const CommentListEmptyState({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            '暂无评论，来抢沙发吧',
            style: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAssetIcon(
              assetName: 'chatbubbles',
              size: 42,
              color: Color(0xFFCACDD4),
              fallbackIcon: CupertinoIcons.chat_bubble_2_fill,
            ),
            SizedBox(height: 12),
            Text(
              '暂无评论，来抢沙发吧',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentListTile extends StatelessWidget {
  const _CommentListTile({
    required this.item,
    required this.style,
    this.level = 0,
    this.onTapReply,
    this.onTapLoadMoreReplies,
    this.isLoadingReplies = false,
  });

  final ShortVideoCommentItem item;
  final CommentListItemStyle style;
  final int level;
  final ValueChanged<ShortVideoCommentItem>? onTapReply;
  final ValueChanged<ShortVideoCommentItem>? onTapLoadMoreReplies;
  final bool isLoadingReplies;

  @override
  Widget build(BuildContext context) {
    final avatarSize = level == 0 ? style.rootAvatarSize : style.childAvatarSize;
    final leftInset = level == 0 ? style.rootLeftInset : style.childLeftInset;
    final nameColor = level == 0 ? style.nameRootColor : style.nameChildColor;
    final nameFontSize = level == 0 ? style.nameRootFontSize : style.nameChildFontSize;
    final contentStyle = level == 0 ? style.contentRootStyle : style.contentChildStyle;
    final replyPrefix = item.replyToUserName?.trim().isNotEmpty == true
        ? '回复 @${item.replyToUserName}：'
        : '';

    return Padding(
      padding: style.rootItemPadding.add(EdgeInsets.only(left: leftInset)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CommentAvatar(
                avatarUrl: item.user.avatarUrl,
                size: avatarSize,
                backgroundColor: style.avatarBackgroundColor,
                fallbackColor: style.avatarFallbackColor,
                fallbackScale: style.avatarFallbackScale,
              ),
              SizedBox(width: style.avatarGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.user.name,
                            style: TextStyle(
                              color: nameColor,
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        AppAssetIcon(
                          assetName: 'heart-outline',
                          size: style.likeIconSize,
                          color: style.likeColor,
                          fallbackIcon: CupertinoIcons.heart,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatCommentCount(item.likeCount),
                          style: TextStyle(
                            color: style.likeColor,
                            fontSize: style.likeFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        children: [
                          if (replyPrefix.isNotEmpty)
                            TextSpan(
                              text: replyPrefix,
                              style: style.replyPrefixStyle,
                            ),
                          TextSpan(
                            text: item.content,
                            style: contentStyle,
                          ),
                        ],
                      ),
                    ),
                    if (item.localImageBytes != null || item.imageUrls.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _CommentAttachmentPreview(item: item),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          item.publishTimeText.isEmpty ? '刚刚' : item.publishTimeText,
                          style: style.metaStyle,
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onTapReply == null ? null : () => onTapReply!(item),
                          child: Text(
                            '回复',
                            style: style.replyActionStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (item.children.isNotEmpty) ...[
            SizedBox(height: style.childTopSpacing),
            for (final child in item.children)
              Padding(
                padding: EdgeInsets.only(top: style.childTopSpacing),
                child: _CommentListTile(
                  item: child,
                  style: style,
                  level: level + 1,
                  onTapReply: onTapReply,
                ),
              ),
          ],
          if (item.canLoadMoreChildren && onTapLoadMoreReplies != null)
            Padding(
              padding: EdgeInsets.only(
                left: style.loadMoreLeftInset,
                top: style.loadMoreTopPadding,
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onTapLoadMoreReplies!(item),
                child: style.showLoadMoreLeadingLine
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 18,
                            height: 1,
                            color: style.leadingLineColor,
                          ),
                          const SizedBox(width: 8),
                          if (isLoadingReplies)
                            const CupertinoActivityIndicator(radius: 7)
                          else
                            Text(
                              '查看更多回复 (${formatCommentCount(item.replyCount)})',
                              style: style.loadMoreStyle,
                            ),
                        ],
                      )
                    : isLoadingReplies
                        ? const CupertinoActivityIndicator(radius: 7)
                        : Text(
                            '查看更多回复 (${formatCommentCount(item.replyCount)})',
                            style: style.loadMoreStyle,
                          ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CommentAttachmentPreview extends StatelessWidget {
  const _CommentAttachmentPreview({
    required this.item,
  });

  final ShortVideoCommentItem item;

  @override
  Widget build(BuildContext context) {
    final image = item.localImageBytes != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              item.localImageBytes!,
              width: 108,
              height: 108,
              fit: BoxFit.cover,
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomNetworkImage(
              item.imageUrls.first,
              width: 108,
              height: 108,
              fit: BoxFit.cover,
            ),
          );
    return image;
  }
}

class _CommentAvatar extends StatelessWidget {
  const _CommentAvatar({
    required this.avatarUrl,
    required this.size,
    required this.backgroundColor,
    required this.fallbackColor,
    required this.fallbackScale,
  });

  final String avatarUrl;
  final double size;
  final Color backgroundColor;
  final Color fallbackColor;
  final double fallbackScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl.isEmpty
          ? AppAssetIcon(
              assetName: 'person',
              size: size * fallbackScale,
              color: fallbackColor,
              fallbackIcon: CupertinoIcons.person_fill,
            )
          : CustomNetworkImage(
              avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return AppAssetIcon(
                  assetName: 'person',
                  size: size * fallbackScale,
                  color: fallbackColor,
                  fallbackIcon: CupertinoIcons.person_fill,
                );
              },
            ),
    );
  }
}
