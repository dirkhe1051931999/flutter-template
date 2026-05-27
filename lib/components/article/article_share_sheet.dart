import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

Future<void> showArticleShareSheet(BuildContext context) {
  return showAppSheet<void>(
    context: context,
    maxHeightFactor: 0.24,
    edgeToEdge: true,
    backgroundColor: CupertinoColors.white,
    builder: (_) {
      return const _ArticleShareSheet();
    },
  );
}

class _ArticleShareSheet extends StatelessWidget {
  const _ArticleShareSheet();

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ShareAction(
                      label: '微信',
                      iconAssetName: 'logo-wechat',
                      fallbackIcon: CupertinoIcons.chat_bubble_2_fill,
                    ),
                  ),
                  Expanded(
                    child: _ShareAction(
                      label: 'QQ',
                      iconAssetName: 'chatbubble-ellipses',
                      fallbackIcon: CupertinoIcons.chat_bubble_2,
                    ),
                  ),
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ShareAction(
                      label: '复制链接',
                      iconAssetName: 'copy-outline',
                      fallbackIcon: CupertinoIcons.link,
                    ),
                  ),
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                  Expanded(
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          height: 6,
          color: const Color(0xFFF4F5F7),
        ),
        CupertinoButton(
          padding: EdgeInsets.fromLTRB(0, 12, 0, safeBottom > 0 ? safeBottom : 12),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Center(
            child: Text(
              '取消',
              style: TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareAction extends StatelessWidget {
  const _ShareAction({
    required this.label,
    required this.iconAssetName,
    required this.fallbackIcon,
  });

  final String label;
  final String iconAssetName;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppAssetIcon(
            assetName: iconAssetName,
            size: 18,
            fallbackIcon: fallbackIcon,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
