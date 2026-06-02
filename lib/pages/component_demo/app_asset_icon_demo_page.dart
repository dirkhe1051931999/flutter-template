import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';

class AppAssetIconDemoPage extends StatelessWidget {
  const AppAssetIconDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: const [
        _IconDemoSection(
          title: '基础图标',
          subtitle: '直接按资源名渲染 svg 图标',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _IconPreview(assetName: 'image', label: 'image'),
              _IconPreview(assetName: 'search', label: 'search'),
              _IconPreview(assetName: 'like', label: 'like'),
            ],
          ),
        ),
        SizedBox(height: 14),
        _IconDemoSection(
          title: '颜色与尺寸',
          subtitle: '支持统一染色和不同尺寸输出',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _IconPreview(
                assetName: 'image',
                label: '20',
                size: 20,
                color: Color(0xFF667085),
              ),
              _IconPreview(
                assetName: 'image',
                label: '28',
                size: 28,
                color: Color(0xFFE5484D),
              ),
              _IconPreview(
                assetName: 'image',
                label: '40',
                size: 40,
                color: Color(0xFF2E90FA),
              ),
            ],
          ),
        ),
        SizedBox(height: 14),
        _IconDemoSection(
          title: 'fallback 占位',
          subtitle: '资源不存在时，可用 fallbackIcon 顶上',
          child: Row(
            children: [
              Expanded(
                child: _FallbackCard(
                  title: '存在资源',
                  child: AppAssetIcon(
                    assetName: 'image',
                    size: 30,
                    color: Color(0xFF202127),
                    fallbackIcon: CupertinoIcons.photo,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FallbackCard(
                  title: '不存在资源',
                  child: AppAssetIcon(
                    assetName: 'missing_icon',
                    size: 30,
                    color: Color(0xFF202127),
                    fallbackIcon: CupertinoIcons.exclamationmark_triangle,
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

class _IconDemoSection extends StatelessWidget {
  const _IconDemoSection({
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

class _IconPreview extends StatelessWidget {
  const _IconPreview({
    required this.assetName,
    required this.label,
    this.size = 28,
    this.color,
  });

  final String assetName;
  final String label;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: AppAssetIcon(
              assetName: assetName,
              size: size,
              color: color,
              fallbackIcon: CupertinoIcons.question,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
