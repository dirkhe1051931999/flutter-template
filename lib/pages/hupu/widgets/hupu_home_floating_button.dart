import 'package:flutter/cupertino.dart';

class HupuHomeFloatingButton extends StatelessWidget {
  const HupuHomeFloatingButton({
    super.key,
    required this.isEmphasized,
    required this.onTap,
    required this.onPointerDown,
  });

  final bool isEmphasized;
  final VoidCallback onTap;
  final VoidCallback onPointerDown;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPointerDown(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isEmphasized ? 0.96 : 0.36,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: isEmphasized ? 1 : 0.96,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: const Color(0xCC111318),
              borderRadius: BorderRadius.circular(999),
              minimumSize: Size.zero,
              onPressed: onTap,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.house_fill,
                    color: CupertinoColors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '首页',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
