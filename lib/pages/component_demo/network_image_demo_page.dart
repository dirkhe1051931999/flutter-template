import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class NetworkImageDemoPage extends StatelessWidget {
  const NetworkImageDemoPage({super.key});

  static const String _coverImageUrl = 'https://picsum.photos/id/237/960/540';
  static const String _avatarImageUrl = 'https://picsum.photos/id/1005/200/200';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: const [
        _DemoSection(
          title: '横图加载',
          subtitle: '默认骨架屏 + cover 裁切',
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: CustomNetworkImage(
              _coverImageUrl,
              height: 188,
              width: double.infinity,
              skeletonBorderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '头像场景',
          subtitle: '固定尺寸 + 圆角骨架',
          child: Row(
            children: [
              ClipOval(
                child: CustomNetworkImage(
                  _avatarImageUrl,
                  width: 72,
                  height: 72,
                  skeletonBorderRadius: BorderRadius.all(Radius.circular(36)),
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  '适合列表头像、作者信息、顶部导航头像位。',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        _DemoSection(
          title: '异常回退',
          subtitle: '空链接或错误链接会落到默认占位图',
          child: Row(
            children: [
              _ErrorItem(label: '空链接', url: ''),
              SizedBox(width: 12),
              _ErrorItem(label: '错误链接', url: 'https://example.com/missing.png'),
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

class _ErrorItem extends StatelessWidget {
  const _ErrorItem({
    required this.label,
    required this.url,
  });

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF202127),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: CustomNetworkImage(
              url,
              width: double.infinity,
              height: 96,
              skeletonBorderRadius: BorderRadius.circular(18),
            ),
          ),
        ],
      ),
    );
  }
}
