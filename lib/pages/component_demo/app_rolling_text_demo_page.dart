import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_rolling_text/app_rolling_text_types.dart';
import 'package:oolaf_flutted/components/app_rolling_text/index.dart';

class AppRollingTextDemoPage extends StatelessWidget {
  const AppRollingTextDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant RollingText，补了数字滚动和文本轮播两种常用模式。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '数字翻牌',
          subtitle: '适合金额、销量、计数器和战报分数等场景。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppRollingText(
                mode: AppRollingTextMode.number,
                startNum: 1200,
                targetNum: 3489,
              ),
              SizedBox(height: 12),
              AppRollingText(
                mode: AppRollingTextMode.number,
                startNum: 80990,
                targetNum: 128560,
                stopOrder: [4, 3, 2, 1, 0, 5],
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '文本轮播',
          subtitle: '适合热点播报、活动轮播和顶部口号切换。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppRollingText(
                mode: AppRollingTextMode.text,
                texts: [
                  '今日热榜持续更新中',
                  '湖人对勇士今晚 8 点开打',
                  '新版本基础组件数已扩展到 30+',
                ],
                duration: Duration(milliseconds: 1600),
                loop: true,
              ),
              SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(14, 16, 14, 16),
                  child: AppRollingText(
                    mode: AppRollingTextMode.text,
                    texts: [
                      'Morning Drop',
                      'Noon Flash Sale',
                      'Night Live Show',
                    ],
                    duration: Duration(milliseconds: 1400),
                    loop: true,
                    style: TextStyle(
                      color: Color(0xFF7C3AED),
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF8F96A3),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const items = [
      '支持 number / text 两种模式，覆盖翻牌数字和文本轮播。',
      '数字模式支持 startNum、targetNum、duration、stopOrder。',
      '文本模式支持 texts、duration、loop，更适合营销文案和热点播报。',
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
