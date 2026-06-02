import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_popover/app_popover_types.dart';
import 'package:oolaf_flutted/components/app_popover/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppPopoverDemoPage extends StatefulWidget {
  const AppPopoverDemoPage({super.key});

  @override
  State<AppPopoverDemoPage> createState() => _AppPopoverDemoPageState();
}

class _AppPopoverDemoPageState extends State<AppPopoverDemoPage> {
  final AppPopoverController _controller = AppPopoverController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Popover，提供锚点定位弹层和操作菜单。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '支持 bottom / top、受控打开、禁用项和菜单选择回调。',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPopover(
                controller: _controller,
                placement: AppPopoverPlacement.bottom,
                actions: const [
                  AppPopoverAction(text: '分享', icon: '🔗'),
                  AppPopoverAction(text: '收藏', icon: '⭐'),
                  AppPopoverAction(text: '删除', icon: '🗑', disabled: true),
                ],
                onSelect: (index) => AppToast.showText('select: $index'),
                child: AppButton(
                  onPressed: _controller.toggle,
                  child: const Text('打开 Popover'),
                ),
              ),
              const SizedBox(height: 18),
              AppPopover(
                placement: AppPopoverPlacement.top,
                actions: const [
                  AppPopoverAction(text: '编辑', icon: '✏️'),
                  AppPopoverAction(text: '复制链接', icon: '📎'),
                  AppPopoverAction(text: '举报', icon: '🚩'),
                ],
                onSelect: (index) => AppToast.showText('顶部 popover: $index'),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0x12000000)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.ellipsis_circle,
                          size: 18,
                          color: Color(0xFF616A78),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '更多操作',
                          style: TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
      '支持 top / bottom 定位、controller 受控开关、禁用菜单项和选择回调。',
      '实现方式是锚点 + overlay follower，不是简单 sheet，交互更接近真正 popover。',
      'demo 里展示了按钮触发和轻量入口触发两种形态。',
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
