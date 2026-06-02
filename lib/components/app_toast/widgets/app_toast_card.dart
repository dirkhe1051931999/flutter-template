import 'package:flutter/cupertino.dart';

class AppToastCard extends StatelessWidget {
  const AppToastCard({
    super.key,
    required this.message,
    this.icon,
    this.showLoading = false,
    this.maxWidth = 220,
  });

  final String message;
  final IconData? icon;
  final bool showLoading;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE6111827),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x14FFFFFF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 120,
          maxWidth: maxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLoading) ...[
                const CupertinoActivityIndicator(
                  radius: 14,
                  color: Color(0xFFFFFFFF),
                ),
                const SizedBox(height: 12),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  color: const Color(0xFFFFFFFF),
                  size: 28,
                ),
                const SizedBox(height: 12),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
