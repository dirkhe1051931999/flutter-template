import 'dart:ui';

import 'package:flutter/cupertino.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xAAFFFFFF),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '功能入口',
                  style: TextStyle(
                    color: Color(0xFF1E232D),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '把基础示例和业务模块拆开后，首页会更适合快速扫功能结构，也能一屏看到更多入口。',
                  style: TextStyle(
                    color: Color(0xFF697180),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
