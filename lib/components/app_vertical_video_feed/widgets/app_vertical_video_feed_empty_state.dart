import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';

class AppVerticalVideoFeedEmptyState extends StatelessWidget {
  const AppVerticalVideoFeedEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: AppAssetIcon(
                    assetName: 'play',
                    color: CupertinoColors.white,
                    size: 30,
                    fallbackIcon: CupertinoIcons.play_rectangle_fill,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              CupertinoButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(18),
                onPressed: onActionPressed,
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
