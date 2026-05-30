import 'package:flutter/cupertino.dart';

class HupuPageHeader extends StatelessWidget {
  const HupuPageHeader({
    required this.title,
    this.subtitle,
    this.onBack,
    this.height = 64,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: CupertinoColors.white,
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: height,
            child: onBack == null
                ? const SizedBox.shrink()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(height, height),
                    onPressed: onBack,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Color(0xFF202127),
                      size: 30,
                    ),
                  ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
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
            ),
          ),
          SizedBox(width: 64, height: height),
        ],
      ),
    );
  }
}
