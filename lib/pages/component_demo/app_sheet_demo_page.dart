import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_button/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';

class AppSheetDemoPage extends StatelessWidget {
  const AppSheetDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        _SheetDemoSection(
          title: '底部弹层',
          subtitle: '默认 bottom sheet，带 handle',
          child: _ActionButton(
            label: '打开底部弹层',
            onPressed: () {
              showAppSheet<void>(
                context: context,
                builder: (_) {
                  return const _SheetContent(
                    title: '底部弹层',
                    description: '适合承载操作列表、表单片段、评论面板。',
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _SheetDemoSection(
          title: '顶部弹层',
          subtitle: '从顶部滑入，适合轻量提示或筛选面板',
          child: _ActionButton(
            label: '打开顶部弹层',
            onPressed: () {
              showAppSheet<void>(
                context: context,
                position: AppSheetPosition.top,
                maxHeightFactor: 0.55,
                builder: (_) {
                  return const _SheetContent(
                    title: '顶部弹层',
                    description: '和顶部页面层级更接近，适合筛选或提示内容。',
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _SheetDemoSection(
          title: 'edgeToEdge + blur',
          subtitle: '适合沉浸式大面板或全宽业务弹层',
          child: _ActionButton(
            label: '打开沉浸式弹层',
            onPressed: () {
              showAppSheet<void>(
                context: context,
                edgeToEdge: true,
                enableBlur: true,
                showHandle: false,
                backgroundColor: const Color(0xFFF8FAFD),
                maxHeightFactor: 0.72,
                builder: (_) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '沉浸式弹层',
                        style: TextStyle(
                          color: Color(0xFF202127),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '这里演示 edgeToEdge、blur、隐藏 handle 的组合。',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0x12000000)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              child: Text(
                                '操作项 ${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF202127),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _SheetDemoSection(
          title: '点击回调',
          subtitle: '演示返回值和关闭后的处理',
          child: _ActionButton(
            label: '打开选择弹层',
            onPressed: () async {
              final result = await showAppSheet<String>(
                context: context,
                builder: (_) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _OptionTile(
                        label: '复制链接',
                        onTap: () => Navigator.of(context).pop('copy'),
                      ),
                      _OptionTile(
                        label: '分享',
                        onTap: () => Navigator.of(context).pop('share'),
                      ),
                      _OptionTile(
                        label: '举报',
                        onTap: () => Navigator.of(context).pop('report'),
                      ),
                    ],
                  );
                },
              );
              if (!context.mounted || result == null) {
                return;
              }
              AppToast.showText('返回值: $result');
            },
          ),
        ),
      ],
    );
  }
}

class _SheetDemoSection extends StatelessWidget {
  const _SheetDemoSection({
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

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Text(
                  '示例内容 ${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF202127),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF202127),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
