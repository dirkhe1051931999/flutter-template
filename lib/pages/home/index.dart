import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/home/widgets/background_orb.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_entry.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_hero.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_list_tile.dart';
import 'package:oolaf_flutted/pages/home/widgets/section_panel.dart';
import 'package:oolaf_flutted/router/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _examplesExpanded = false;
  bool _businessExpanded = true;

  void _openRoute(String key) {
    const transition = TransitionType.inFromRight;
    Application.router.navigateTo(
      context,
      '/$key',
      transition: transition,
    );
  }

  @override
  Widget build(BuildContext context) {
    final exampleItems = <HomeEntry>[
      const HomeEntry(
        title: 'TodoList',
        subtitle: 'Redux 状态、输入、增删清空',
        routeKey: 'todolist',
        icon: CupertinoIcons.check_mark_circled,
      ),
      const HomeEntry(
        title: 'Fluro',
        subtitle: '路由动画、返回值、函数回调',
        routeKey: 'fluro',
        icon: CupertinoIcons.arrow_branch,
      ),
      const HomeEntry(
        title: 'Request',
        subtitle: 'Dio 请求、结果态、列表渲染',
        routeKey: 'request',
        icon: CupertinoIcons.globe,
      ),
      const HomeEntry(
        title: 'Profile',
        subtitle: 'Redux 用户信息、弹窗更新',
        routeKey: 'profile',
        icon: CupertinoIcons.person_crop_circle,
      ),
      const HomeEntry(
        title: 'Scrollable Tabs',
        subtitle: 'linked_tab_view、刷新、保活、禁滑',
        routeKey: 'scrollable-tabs',
        icon: CupertinoIcons.rectangle_3_offgrid,
      ),
      const HomeEntry(
        title: 'Network Img',
        subtitle: '网络图、骨架屏、错误回退',
        routeKey: 'network-image-demo',
        icon: CupertinoIcons.photo,
      ),
      const HomeEntry(
        title: 'App Asset Icon',
        subtitle: 'svg 图标、染色、fallback',
        routeKey: 'app-asset-icon-demo',
        icon: CupertinoIcons.square_grid_2x2,
      ),
      const HomeEntry(
        title: 'App Calendar',
        subtitle: 'single/multiple/range、sheet 内日历',
        routeKey: 'app-calendar-demo',
        icon: CupertinoIcons.calendar,
      ),
      const HomeEntry(
        title: 'App Date Picker',
        subtitle: 'year/month/day 列组合、sheet 内选择',
        routeKey: 'app-date-picker-demo',
        icon: CupertinoIcons.time,
      ),
      const HomeEntry(
        title: 'App Picker',
        subtitle: 'single/multiple/cascade、通用选择器',
        routeKey: 'app-picker-demo',
        icon: CupertinoIcons.slider_horizontal_3,
      ),
      const HomeEntry(
        title: 'App Field',
        subtitle: '表单输入、校验、clear、textarea、is-link',
        routeKey: 'app-field-demo',
        icon: CupertinoIcons.square_pencil,
      ),
      const HomeEntry(
        title: 'App Toast',
        subtitle: '轻提示、成功失败、loading、位置控制',
        routeKey: 'app-toast-demo',
        icon: CupertinoIcons.bell,
      ),
      const HomeEntry(
        title: 'Area Pick',
        subtitle: '省市区县镇四级联动、iOS 风格弹层',
        routeKey: 'area-pick-demo',
        icon: CupertinoIcons.location_solid,
      ),
      const HomeEntry(
        title: 'App Sheet',
        subtitle: '顶部/底部弹层、blur、回调',
        routeKey: 'app-sheet-demo',
        icon: CupertinoIcons.layers_alt,
      ),
      const HomeEntry(
        title: 'Gallery Preview',
        subtitle: '图片预览、长图、双击缩放',
        routeKey: 'gallery-preview-demo',
        icon: CupertinoIcons.photo_on_rectangle,
      ),
      const HomeEntry(
        title: 'Route Bottom Nav Bar',
        subtitle: '底部导航、主操作按钮、状态切换',
        routeKey: 'route-bottom-nav-bar-demo',
        icon: CupertinoIcons.square_split_2x1,
      ),
      const HomeEntry(
        title: 'Route Page Header',
        subtitle: '通用页面头、头像标题、操作区',
        routeKey: 'route-page-header-demo',
        icon: CupertinoIcons.square_list,
      ),
    ];

    final businessItems = <HomeEntry>[
      const HomeEntry(
        title: '短视频',
        subtitle: '视频流、搜索、评论、设置',
        routeKey: 'short-video',
        icon: CupertinoIcons.play_rectangle,
      ),
      const HomeEntry(
        title: '天气',
        subtitle: '城市搜索、预报、空气质量',
        routeKey: 'weather',
        icon: CupertinoIcons.cloud_sun,
      ),
      const HomeEntry(
        title: '虎扑',
        subtitle: '推荐流、NBA、帖子详情',
        routeKey: 'hupu',
        icon: CupertinoIcons.flame,
      ),
      const HomeEntry(
        title: '动感音频',
        subtitle: '音频播放与媒体能力实验',
        routeKey: 'oolaf-dynamic-audio',
        icon: CupertinoIcons.music_note_list,
      ),
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7F8FB),
              Color(0xFFF1F3F7),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -80,
              right: -20,
              child: BackgroundOrb(
                size: 220,
                color: Color(0x50FFFFFF),
              ),
            ),
            const Positioned(
              top: 140,
              left: -40,
              child: BackgroundOrb(
                size: 180,
                color: Color(0x36DCE6F6),
              ),
            ),
            SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                children: [
                  const HomeHero(),
                  const SizedBox(height: 14),
                  SectionPanel(
                    title: '基础示例',
                    subtitle: '更适合看交互和组件，默认收起',
                    count: exampleItems.length,
                    expanded: _examplesExpanded,
                    onToggle: () {
                      setState(() {
                        _examplesExpanded = !_examplesExpanded;
                      });
                    },
                    children: exampleItems
                        .map(
                          (item) => HomeListTile(
                            item: item,
                            onTap: () => _openRoute(item.routeKey),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 12),
                  SectionPanel(
                    title: '业务模块',
                    subtitle: '默认展开，方便直接进入主要能力',
                    count: businessItems.length,
                    expanded: _businessExpanded,
                    onToggle: () {
                      setState(() {
                        _businessExpanded = !_businessExpanded;
                      });
                    },
                    children: businessItems
                        .map(
                          (item) => HomeListTile(
                            item: item,
                            onTap: () => _openRoute(item.routeKey),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
