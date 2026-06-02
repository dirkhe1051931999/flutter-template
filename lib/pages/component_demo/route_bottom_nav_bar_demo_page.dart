import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/route_bottom_nav_bar/index.dart';

class RouteBottomNavBarDemoPage extends StatefulWidget {
  const RouteBottomNavBarDemoPage({super.key});

  @override
  State<RouteBottomNavBarDemoPage> createState() =>
      _RouteBottomNavBarDemoPageState();
}

class _RouteBottomNavBarDemoPageState extends State<RouteBottomNavBarDemoPage> {
  static const String homeTabKey = 'home';
  static const String chatTabKey = 'chat';
  static const String publishTabKey = 'publish';
  static const String exploreTabKey = 'explore';
  static const String mineTabKey = 'mine';

  String _activeTabKey = homeTabKey;
  bool _useCupertinoStyle = false;

  List<RouteBottomNavBarItem> _buildNavItems(BuildContext context) {
    return <RouteBottomNavBarItem>[
      const RouteBottomNavBarItem(
        key: homeTabKey,
        label: '首页',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
      ),
      RouteBottomNavBarItem(
        key: chatTabKey,
        label: '消息',
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        badgeText: '12',
        onLongPress: () {
          _showDemoSheet(
            context,
            title: '消息长按',
            description: '这里演示的是通用 onLongPress 钩子，sheet 本身仍由业务层注入。',
          );
        },
      ),
      RouteBottomNavBarItem(
        key: publishTabKey,
        label: '',
        icon: Icons.add,
        isCenterAction: true,
        onLongPress: () {
          _showDemoSheet(
            context,
            title: '发布长按',
            description: '像抖音那种长按弹业务面板，可以从这里接，不需要耦进底部导航组件。',
          );
        },
      ),
      RouteBottomNavBarItem(
        key: exploreTabKey,
        label: '探索',
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        selectedBuilder: (context, state, defaultChild) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0x141F2329),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: defaultChild,
            ),
          );
        },
        onDoubleTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('双击探索 tab')),
          );
        },
      ),
      RouteBottomNavBarItem(
        key: mineTabKey,
        label: '我的',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        showDot: true,
        itemBuilder: (context, state, defaultChild) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              defaultChild,
              const Positioned(
                top: -6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFF202127),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ];
  }

  String get _activeTitle {
    switch (_activeTabKey) {
      case chatTabKey:
        return '消息';
      case publishTabKey:
        return '发布';
      case exploreTabKey:
        return '探索';
      case mineTabKey:
        return '我的';
      case homeTabKey:
      default:
        return '首页';
    }
  }

  String get _activeDescription {
    switch (_activeTabKey) {
      case chatTabKey:
        return '这里演示了 badge 和长按回调，业务层可以自己接消息面板或快捷操作。';
      case publishTabKey:
        return '中间按钮支持长按钩子，像抖音那种长按弹 sheet 可以在业务层接入。';
      case exploreTabKey:
        return '这里演示了双击钩子，适合做回顶部、刷新或再次聚焦。';
      case mineTabKey:
        return '这里演示了纯红点模式和 itemBuilder，可以在默认渲染外再附加业务标识。';
      case homeTabKey:
      default:
        return '这个 demo 现在可以看状态切换、badge、红点、自定义渲染、长按、双击、重选和 Cupertino 化样式。';
    }
  }

  void _showDemoSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showAppSheet<void>(
      context: context,
      builder: (_) {
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = _buildNavItems(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                children: [
                  DecoratedBox(
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
                          const Text(
                            '当前选中',
                            style: TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _activeTitle,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _activeDescription,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DecoratedBox(
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
                          const Text(
                            '这次重点可以看：\n1. 普通 tab 的 active/inactive 样式\n2. badge、红点、selectedBuilder / itemBuilder\n3. 长按/双击只是透出钩子，业务层自己决定弹什么\n4. 重选回调、底部安全区和 Cupertino 风格',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text(
                                'Cupertino 风格',
                                style: TextStyle(
                                  color: Color(0xFF202127),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Switch(
                                value: _useCupertinoStyle,
                                onChanged: (value) {
                                  setState(() {
                                    _useCupertinoStyle = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            RouteBottomNavBar(
              items: navItems,
              activeKey: _activeTabKey,
              style: _useCupertinoStyle
                  ? const RouteBottomNavBarStyle.cupertino()
                  : const RouteBottomNavBarStyle(),
              respectBottomSafeArea: true,
              onTap: (key) {
                setState(() {
                  _activeTabKey = key;
                });
              },
              onReselect: (key) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('重复点击了 $key')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
