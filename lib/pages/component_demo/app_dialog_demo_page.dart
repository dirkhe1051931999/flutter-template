import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_dialog/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppDialogDemoPage extends StatelessWidget {
  const AppDialogDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Dialog，统一 confirm / cancel 语义和仓库内弹窗视觉。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持标题、内容、确认、取消、点击遮罩关闭。',
          child: AppButton(
            block: true,
            onPressed: () async {
              final result = await showAppDialog(
                context: context,
                title: '删除草稿',
                message: '删除后将无法恢复，是否继续？',
                showCancelButton: true,
                confirmButtonText: '删除',
                confirmButtonColor: const Color(0xFFE5484D),
              );
              if (!context.mounted) {
                return;
              }
              AppToast.showText('dialog result: $result');
            },
            child: const Text('打开 Dialog'),
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
      '支持 confirm / cancel、barrierDismissible、危险确认按钮颜色。',
      '比直接 scattered 的 CupertinoAlertDialog 更统一，更适合仓库内组件演示层。',
      '适合删除确认、退出确认、发布确认等高频弹窗场景。',
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
