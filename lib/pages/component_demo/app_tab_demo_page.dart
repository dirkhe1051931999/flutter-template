import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_tab/app_tab_types.dart';
import 'package:oolaf_flutted/components/app_tab/index.dart';

class AppTabDemoPage extends StatefulWidget {
  const AppTabDemoPage({super.key});

  @override
  State<AppTabDemoPage> createState() => _AppTabDemoPageState();
}

class _AppTabDemoPageState extends State<AppTabDemoPage> {
  int _basicActive = 0;
  int _cardActive = 0;
  int _scrollActive = 0;
  int _swipeActive = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        const _DemoSection(
          title: '组件说明',
          subtitle: '参考 Vant Tab，做成 iOS 风格标签页，支持 line/card、禁用、滚动和滑动切换。',
          child: _FeatureList(),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '基础用法',
          subtitle: '通过 activeKey 和 onChange 管理选中项，内容由父级传入。',
          child: SizedBox(
            height: 210,
            child: AppTabs(
              activeKey: _basicActive,
              onChange: (value) {
                setState(() {
                  _basicActive = value;
                });
              },
              border: true,
              items: const [
                AppTabItemData(
                  title: '关注',
                  child: _TabPanel(
                    title: '关注内容',
                    description: '这里展示已关注频道的更新，可以承载列表、卡片或筛选状态。',
                    color: Color(0xFF2563EB),
                  ),
                ),
                AppTabItemData(
                  title: '推荐',
                  child: _TabPanel(
                    title: '推荐内容',
                    description: '默认 line 风格使用底部指示条，对齐 Vant Tabs 的基础形态。',
                    color: Color(0xFF0EA5E9),
                  ),
                ),
                AppTabItemData(
                  title: '热榜',
                  child: _TabPanel(
                    title: '热榜内容',
                    description: 'Tab 内容完全由业务决定，组件只负责标题区和切换行为。',
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '卡片风格',
          subtitle: 'type 设置为 card，适合较短的筛选分组或分段选择。',
          child: SizedBox(
            height: 190,
            child: AppTabs(
              type: AppTabsType.card,
              activeKey: _cardActive,
              color: const Color(0xFF111827),
              backgroundColor: const Color(0xFFF7F8FB),
              onChange: (value) {
                setState(() {
                  _cardActive = value;
                });
              },
              items: const [
                AppTabItemData(
                  title: '全部',
                  child: _TabPanel(
                    title: '全部订单',
                    description: '卡片风格保留轻边框和圆角，避免 Material TabBar 的视觉。',
                    color: Color(0xFF111827),
                  ),
                ),
                AppTabItemData(
                  title: '待处理',
                  child: _TabPanel(
                    title: '待处理',
                    description: '适合筛选态、状态流转和需要更强分组感的入口。',
                    color: Color(0xFF7C3AED),
                  ),
                ),
                AppTabItemData(
                  title: '已关闭',
                  disabled: true,
                  child: _TabPanel(
                    title: '已关闭',
                    description: '禁用项不会触发切换，可用于临时关闭入口。',
                    color: Color(0xFF98A2B3),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '横向滚动',
          subtitle: 'tab 数量超过 swipeThreshold 后自动横向滚动，桌面鼠标和触摸板也可拖动。',
          child: SizedBox(
            height: 190,
            child: AppTabs(
              activeKey: _scrollActive,
              swipeThreshold: 4,
              shrink: true,
              lineWidth: 28,
              onChange: (value) {
                setState(() {
                  _scrollActive = value;
                });
              },
              items: List<AppTabItemData>.generate(8, (index) {
                final titles = [
                  '新闻',
                  '体育',
                  '财经',
                  '科技',
                  '影视',
                  '游戏',
                  '汽车',
                  '本地生活',
                ];
                return AppTabItemData(
                  title: titles[index],
                  disabled: index == 6,
                  child: _TabPanel(
                    title: '${titles[index]}频道',
                    description: '当前频道索引 $index，禁用频道会保留样式但不可选中。',
                    color: const Color(0xFF16A34A),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _DemoSection(
          title: '滑动切换',
          subtitle: '开启 swipeable 和 animated 后，内容区支持左右滑动，兼容 Windows/Web 指针拖动。',
          child: SizedBox(
            height: 220,
            child: AppTabs(
              activeKey: _swipeActive,
              swipeable: true,
              animated: true,
              lazyRender: false,
              color: const Color(0xFFE5484D),
              onChange: (value) {
                setState(() {
                  _swipeActive = value;
                });
              },
              items: const [
                AppTabItemData(
                  title: '图文',
                  child: _TabPanel(
                    title: '图文内容',
                    description: '滑动切换由 PageView 承载，支持触摸、鼠标和触控板拖动。',
                    color: Color(0xFFE5484D),
                  ),
                ),
                AppTabItemData(
                  title: '视频',
                  child: _TabPanel(
                    title: '视频内容',
                    description: '如果页面里有 sticky 布局，建议业务层拆开处理，不和动画容器混用。',
                    color: Color(0xFF2563EB),
                  ),
                ),
                AppTabItemData(
                  title: '评论',
                  child: _TabPanel(
                    title: '评论内容',
                    description: 'lazyRender=false 时会保留所有 panel，适合需要保活的输入状态。',
                    color: Color(0xFFF59E0B),
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
      '支持 line/card、activeKey、disabled、ellipsis、shrink、swipeThreshold、lineWidth 和 lineHeight。',
      '支持 animated、swipeable、lazyRender、showHeader，并用受控接口保持状态边界清楚。',
      'sticky/scrollspy 属于页面滚动容器能力，业务页可在父层组合，不放进通用 Tab 组件。',
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

class _TabPanel extends StatelessWidget {
  const _TabPanel({
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.14),
              const Color(0xFFFFFFFF),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF202127),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 42,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
