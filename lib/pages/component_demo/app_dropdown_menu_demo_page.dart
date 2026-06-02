import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_dropdown_menu/index.dart';

class AppDropdownMenuDemoPage extends StatefulWidget {
  const AppDropdownMenuDemoPage({super.key});

  @override
  State<AppDropdownMenuDemoPage> createState() => _AppDropdownMenuDemoPageState();
}

class _AppDropdownMenuDemoPageState extends State<AppDropdownMenuDemoPage> {
  String _sort = 'hot';
  String _city = 'shanghai';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant DropdownMenu，用顶部筛选菜单承接列表页常见筛选场景。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础示例',
          subtitle: '支持多列菜单项和 option 切换，点按后用 top sheet 展开选项。',
          child: AppDropdownMenu(
            items: [
              AppDropdownMenuItem<String>(
                value: _sort,
                options: const [
                  AppDropdownOption(text: '最热', value: 'hot'),
                  AppDropdownOption(text: '最新', value: 'latest'),
                  AppDropdownOption(text: '推荐', value: 'recommend'),
                ],
                onChanged: (value) {
                  setState(() {
                    _sort = value;
                  });
                },
              ),
              AppDropdownMenuItem<String>(
                value: _city,
                options: const [
                  AppDropdownOption(text: '上海', value: 'shanghai'),
                  AppDropdownOption(text: '北京', value: 'beijing'),
                  AppDropdownOption(text: '深圳', value: 'shenzhen'),
                ],
                onChanged: (value) {
                  setState(() {
                    _city = value;
                  });
                },
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
      '支持多列 item，每列都有自己的 options、value 和 onChanged。',
      '适合内容流、商品列表、城市筛选和排序切换场景。',
      '下拉层复用 top sheet，视觉上更贴近当前仓库的弹层体系。',
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
