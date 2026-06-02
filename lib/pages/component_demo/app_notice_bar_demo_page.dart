import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_notice_bar/app_notice_bar_types.dart';
import 'package:oolaf_flutted/components/app_notice_bar/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppNoticeBarDemoPage extends StatelessWidget {
  const AppNoticeBarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant NoticeBar，补齐横向滚动、垂直滚动、滚动播放和可关闭模式。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '支持横向 marquee、关闭按钮和 link 模式。',
          child: Column(
            children: [
              AppNoticeBar(
                text: '今日版本更新：新增 Button、ActionSheet、Dialog、DropdownMenu、SwipeCell 等多个基础组件。',
                mode: AppNoticeBarMode.link,
                onTap: () => AppToast.showText('点击了公告栏'),
              ),
              const SizedBox(height: 12),
              AppNoticeBar(
                text: '活动提醒：本周五晚 8 点开始限时直播，记得提前预约。',
                mode: AppNoticeBarMode.closeable,
                onClose: () => AppToast.showText('公告栏已关闭'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _DemoSection(
          title: '垂直滚动',
          subtitle: '对齐 Vant 的垂直滚动 / 滚动播放，适合资讯播报和公告流。',
          child: Column(
            children: [
              AppNoticeBar(
                direction: AppNoticeBarDirection.vertical,
                verticalItems: [
                  '上海站线下交流会开放报名',
                  '天气模块已接入城市搜索和空气质量',
                  'Hupu 页面继续补齐榜单和帖子详情',
                ],
              ),
              SizedBox(height: 12),
              AppNoticeBar(
                direction: AppNoticeBarDirection.vertical,
                verticalVisibleCount: 2,
                mode: AppNoticeBarMode.link,
                verticalItems: [
                  '发布：新版本支持 28 个基础组件',
                  '优化：基础示例已改成二级菜单分组',
                  '计划：下一步继续补展示类组件',
                  '提示：所有新增 demo 都走 Cupertino 风格',
                ],
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
      '支持横向滚动、垂直滚动、滚动播放、link、closeable、wrapable。',
      '垂直模式支持一次展示多条，更接近公告流和资讯 ticker 的场景。',
      'demo 里同时展示了基础用法和垂直播放两种重点能力。',
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
