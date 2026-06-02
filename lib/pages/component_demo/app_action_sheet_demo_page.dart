import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_action_sheet/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppActionSheetDemoPage extends StatelessWidget {
  const AppActionSheetDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant ActionSheet，基于现有 AppSheet 做 iOS 风格动作面板。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持标题、描述、动作列表、禁用态、loading 和取消按钮。',
          child: AppButton(
            block: true,
            onPressed: () async {
              final index = await showAppActionSheet(
                context: context,
                title: '内容操作',
                description: '更接近 iOS 26 语义的轻量动作面板',
                actions: const [
                  AppActionSheetAction(name: '收藏'),
                  AppActionSheetAction(name: '分享', subname: '发送给朋友或复制链接'),
                  AppActionSheetAction(name: '删除', color: Color(0xFFE5484D)),
                ],
              );
              if (!context.mounted || index == null) {
                return;
              }
              AppToast.showText('点击 action: $index');
            },
            child: const Text('打开 Action Sheet'),
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
      '支持 title、description、cancelText、disabled、loading、危险动作颜色。',
      '底层复用现有 AppSheet，视觉和弹层行为能与仓库已有组件保持一致。',
      '适合操作面板、内容菜单、评论操作和更多动作入口。',
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
