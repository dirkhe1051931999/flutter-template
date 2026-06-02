import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppToastDemoPage extends StatelessWidget {
  const AppToastDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _ToastDemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Toast，收口成项目内统一调用的轻提示组件。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _ToastDemoSection(
          title: '基础提示',
          subtitle: '支持文字、成功、失败三种常见状态。',
          child: Column(
            children: [
              _ActionButton(
                label: '文字提示',
                onPressed: () {
                  AppToast.showText('已加入稍后再看');
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '成功提示',
                onPressed: () {
                  AppToast.showSuccess('保存成功');
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '失败提示',
                onPressed: () {
                  AppToast.showFail('提交失败，请稍后重试');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ToastDemoSection(
          title: '位置与时长',
          subtitle: '支持顶部、中间、底部定位，也支持自定义消失时长。',
          child: Column(
            children: [
              _ActionButton(
                label: '顶部提示',
                onPressed: () {
                  AppToast.showText(
                    '顶部提示更适合轻量通知',
                    position: AppToastPosition.top,
                  );
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '底部长提示',
                onPressed: () {
                  AppToast.showText(
                    '底部提示可以承载稍长一些的文案',
                    position: AppToastPosition.bottom,
                    duration: const Duration(milliseconds: 3200),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ToastDemoSection(
          title: 'Loading',
          subtitle: '支持手动关闭的 loading 态，也支持禁止点击。',
          child: Column(
            children: [
              _ActionButton(
                label: '打开 Loading',
                onPressed: () {
                  AppToast.showLoading('上传中...', forbidClick: true);
                  Timer(const Duration(milliseconds: 1600), () {
                    AppToast.clear();
                    AppToast.showSuccess('上传完成');
                  });
                },
              ),
              const SizedBox(height: 10),
              _ActionButton(
                label: '手动关闭',
                onPressed: () {
                  AppToast.clear();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToastDemoSection extends StatelessWidget {
  const _ToastDemoSection({
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
      '统一封装 `AppToast.showText/showSuccess/showFail/showLoading`。',
      '不依赖页面 context，可在全局任意位置直接调用。',
      '支持位置、时长、禁止点击和手动关闭。',
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      block: true,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
