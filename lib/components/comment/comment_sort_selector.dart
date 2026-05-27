import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';

Future<void> showCommentSortActionSheet(
  BuildContext context, {
  required ValueChanged<ShortVideoCommentSortBy> onSelected,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              onSelected(ShortVideoCommentSortBy.hot);
            },
            child: const Text('按热度'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(sheetContext).pop();
              onSelected(ShortVideoCommentSortBy.latest);
            },
            child: const Text('按时间'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('取消'),
        ),
      );
    },
  );
}

class CommentSortSelector extends StatelessWidget {
  const CommentSortSelector({
    super.key,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF5C6270),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const AppAssetIcon(
                assetName: 'chevron-down',
                size: 12,
                color: Color(0xFF5C6270),
                fallbackIcon: CupertinoIcons.chevron_down,
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          const AppAssetIcon(
            assetName: 'chevron-down',
            size: 14,
            color: Color(0xFF8E8E93),
            fallbackIcon: CupertinoIcons.chevron_down,
          ),
        ],
      ),
    );
  }
}
