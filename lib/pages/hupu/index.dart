import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/route_bottom_nav_bar/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_home_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_zone_page.dart';

class HupuPage extends StatefulWidget {
  const HupuPage({super.key});

  @override
  State<HupuPage> createState() => _HupuPageState();
}

class _HupuPageState extends State<HupuPage> {
  static const String homeTabKey = 'home';
  static const String zoneTabKey = 'zone';
  static const String publishTabKey = 'publish';
  static const String discoverTabKey = 'discover';
  static const String mineTabKey = 'mine';

  static const List<RouteBottomNavBarItem> navItems = <RouteBottomNavBarItem>[
    RouteBottomNavBarItem(
      key: homeTabKey,
      label: '首页',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    RouteBottomNavBarItem(
      key: zoneTabKey,
      label: '专区',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
    ),
    RouteBottomNavBarItem(
      key: publishTabKey,
      label: '',
      icon: Icons.add,
      isCenterAction: true,
    ),
    RouteBottomNavBarItem(
      key: discoverTabKey,
      label: '探索',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
    RouteBottomNavBarItem(
      key: mineTabKey,
      label: '我的',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  String activeTabKey = homeTabKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _resolvePageIndex(activeTabKey),
                children: const [
                  HupuHomePage(),
                  HupuZonePage(),
                  HupuPlaceholderPage(
                    title: '发布',
                    description: '这里先做前端占位，后续再接发帖或创作能力。',
                  ),
                  HupuPlaceholderPage(
                    title: '探索',
                    description: '这里先做前端占位，后续再接探索内容流。',
                  ),
                  HupuPlaceholderPage(
                    title: '我的',
                    description: '这里先做前端占位，后续再接个人中心。',
                  ),
                ],
              ),
            ),
            RouteBottomNavBar(
              items: navItems,
              activeKey: activeTabKey,
              respectBottomSafeArea: true,
              onTap: (key) {
                setState(() {
                  activeTabKey = key;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  int _resolvePageIndex(String key) {
    switch (key) {
      case zoneTabKey:
        return 1;
      case publishTabKey:
        return 2;
      case discoverTabKey:
        return 3;
      case mineTabKey:
        return 4;
      case homeTabKey:
      default:
        return 0;
    }
  }
}

class HupuPlaceholderPage extends StatelessWidget {
  const HupuPlaceholderPage({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF202127),
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
