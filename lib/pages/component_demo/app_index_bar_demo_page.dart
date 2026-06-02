import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_index_bar/app_index_bar_types.dart';
import 'package:oolaf_flutted/components/app_index_bar/index.dart';

class AppIndexBarDemoPage extends StatelessWidget {
  const AppIndexBarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = <AppIndexBarSection>[
      _buildSection('A', 'A', ['阿里云', '安克', '爱彼迎']),
      _buildSection('B', 'B', ['百度', '哔哩哔哩', 'Boss 直聘']),
      _buildSection('C', 'C', ['曹操出行', '菜鸟', 'Context Labs']),
      _buildSection('D', 'D', ['滴滴', '得物', 'Disney+']),
      _buildSection('F', 'F', ['飞书', 'Figma', '丰巢']),
      _buildSection('H', 'H', ['华为', '虎扑', '鸿蒙社区']),
      _buildSection('J', 'J', ['京东', '极氪', '即刻']),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant IndexBar，实现分组标题、索引高亮、点击跳转和右侧索引栏。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '适合城市、通讯录、品牌库和按字母索引的列表导航。',
          child: AppIndexBar(
            sections: sections,
          ),
        ),
      ],
    );
  }

  static AppIndexBarSection _buildSection(
    String index,
    String title,
    List<String> items,
  ) {
    return AppIndexBarSection(
      index: index,
      title: title,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Text(
                        item.substring(0, 1),
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF202127),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 15,
                        color: Color(0xFF98A2B3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false),
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
      '支持右侧索引字母、高亮当前分组、点击索引跳转和分组标题展示。',
      '适合通讯录、品牌库、城市选择、服务目录等长列表导航场景。',
      'demo 里提供完整可滚动列表，而不是静态占位。',
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
