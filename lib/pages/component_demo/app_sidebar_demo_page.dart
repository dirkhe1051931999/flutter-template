import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_sidebar/app_sidebar_types.dart';
import 'package:oolaf_flutted/components/app_sidebar/index.dart';

class AppSidebarDemoPage extends StatefulWidget {
  const AppSidebarDemoPage({super.key});

  @override
  State<AppSidebarDemoPage> createState() => _AppSidebarDemoPageState();
}

class _AppSidebarDemoPageState extends State<AppSidebarDemoPage> {
  int _activeKey = 0;

  static const _items = [
    AppSidebarItemData(title: '推荐', badge: '12'),
    AppSidebarItemData(title: '新品'),
    AppSidebarItemData(title: '活动', dot: true),
    AppSidebarItemData(title: '会员专享'),
    AppSidebarItemData(title: '已售罄', disabled: true),
  ];

  static const _content = [
    (
      title: '推荐分组',
      description: '适合首页聚合、精选专题和默认主入口。',
      color: Color(0xFF2563EB),
    ),
    (
      title: '新品分组',
      description: '适合按系列展示新到商品、更新服务和版本清单。',
      color: Color(0xFF0EA5E9),
    ),
    (
      title: '活动分组',
      description: '适合闪促、节日主题和需要红点提醒的运营模块。',
      color: Color(0xFFF59E0B),
    ),
    (
      title: '会员专享',
      description: '适合权益、折扣券和高价值会员内容独立承载。',
      color: Color(0xFF7C3AED),
    ),
    (
      title: '已售罄',
      description: 'disabled 状态下不可切换，用于关闭入口或灰掉分类。',
      color: Color(0xFF98A2B3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final current = _content[_activeKey];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Sidebar，补齐激活态、禁用、徽标和右侧内容联动。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '点击左侧分类切换右侧内容，适合商品分类、个人中心和设置面板。',
          child: SizedBox(
            height: 320,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSidebar(
                  items: _items,
                  activeKey: _activeKey,
                  onChange: (value) {
                    setState(() {
                      _activeKey = value;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          current.color.withValues(alpha: 0.16),
                          const Color(0xFFFFFFFF),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.title,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            current.description,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            height: 88,
                            decoration: BoxDecoration(
                              color: current.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${current.title} 内容区',
                              style: TextStyle(
                                color: current.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
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
      '支持 activeKey、禁用项、红点和 badge，并保留典型的左栏切换交互。',
      '适合商品分类、账户设置、内容频道和侧边筛选菜单。',
      'demo 里包含联动内容区，不是单纯的菜单静态展示。',
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
