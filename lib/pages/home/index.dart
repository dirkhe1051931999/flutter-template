import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_notice_bar/app_notice_bar_types.dart';
import 'package:oolaf_flutted/components/app_notice_bar/index.dart';
import 'package:oolaf_flutted/pages/home/widgets/background_orb.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_entry.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_entry_group.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_hero.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_list_tile.dart';
import 'package:oolaf_flutted/pages/home/widgets/section_panel.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/oolaf_music/state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _examplesExpanded = false;
  bool _businessExpanded = true;
  final Set<String> _expandedExampleGroups = <String>{
    '基础能力',
  };

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
        title: 'App Checkbox',
        subtitle: 'Vant Checkbox 参数模型、group、多选与 max',
        routeKey: 'app-checkbox-demo',
        icon: CupertinoIcons.check_mark_circled,
      ),
      const HomeEntry(
        title: 'App Button',
        subtitle: 'Vant Button 参数模型，统一基础示例触发按钮',
        routeKey: 'app-button-demo',
        icon: CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
      ),
      const HomeEntry(
        title: 'App Action Sheet',
        subtitle: 'Vant ActionSheet 参数模型、动作面板',
        routeKey: 'app-action-sheet-demo',
        icon: CupertinoIcons.ellipsis_circle,
      ),
      const HomeEntry(
        title: 'App Switch',
        subtitle: 'Vant Switch 参数模型、loading、disabled、size',
        routeKey: 'app-switch-demo',
        icon: CupertinoIcons.switch_camera,
      ),
      const HomeEntry(
        title: 'App Tag',
        subtitle: 'Vant Tag 鍙傛暟妯″瀷銆佺┖蹇冦€佸渾瑙掋€佹爣璁板拰鍙叧闂牱寮?',
        routeKey: 'app-tag-demo',
        icon: CupertinoIcons.tag,
      ),
      const HomeEntry(
        title: 'App Stepper',
        subtitle: 'Vant Stepper 参数模型、数量步进与小数',
        routeKey: 'app-stepper-demo',
        icon: CupertinoIcons.plus_slash_minus,
      ),
      const HomeEntry(
        title: 'App Steps',
        subtitle: 'Vant Steps 鍙傛暟妯″瀷銆佹í鍚戜笌绾靛悜姝ラ娴?',
        routeKey: 'app-steps-demo',
        icon: CupertinoIcons.list_number,
      ),
      const HomeEntry(
        title: 'App Dialog',
        subtitle: 'Vant Dialog 参数模型、confirm/cancel 弹窗',
        routeKey: 'app-dialog-demo',
        icon: CupertinoIcons.chat_bubble_2,
      ),
      const HomeEntry(
        title: 'App Dropdown Menu',
        subtitle: 'Vant DropdownMenu 参数模型、顶部筛选菜单',
        routeKey: 'app-dropdown-menu-demo',
        icon: CupertinoIcons.chevron_down_square,
      ),
      const HomeEntry(
        title: 'App Index Bar',
        subtitle: 'Vant IndexBar 分组索引、右侧字母导航和点击跳转',
        routeKey: 'app-index-bar-demo',
        icon: CupertinoIcons.textformat_abc,
      ),
      const HomeEntry(
        title: 'App Notice Bar',
        subtitle: 'Vant NoticeBar 参数模型、垂直滚动和滚动播放',
        routeKey: 'app-notice-bar-demo',
        icon: CupertinoIcons.speaker_2,
      ),
      const HomeEntry(
        title: 'App Field',
        subtitle: '表单输入、校验、clear、textarea、is-link',
        routeKey: 'app-field-demo',
        icon: CupertinoIcons.square_pencil,
      ),
      const HomeEntry(
        title: 'App Password Input',
        subtitle: 'Vant PasswordInput 参数模型、支付密码格子',
        routeKey: 'app-password-input-demo',
        icon: CupertinoIcons.lock_shield,
      ),
      const HomeEntry(
        title: 'App Popover',
        subtitle: 'Vant Popover 参数模型、锚点菜单弹层',
        routeKey: 'app-popover-demo',
        icon: CupertinoIcons.bubble_left_bubble_right,
      ),
      const HomeEntry(
        title: 'App Radio',
        subtitle: 'Vant Radio 参数模型、group、单选状态',
        routeKey: 'app-radio-demo',
        icon: CupertinoIcons.smallcircle_fill_circle,
      ),
      const HomeEntry(
        title: 'App Search',
        subtitle: 'Vant Search 参数模型、iOS 26 搜索框、首页 example',
        routeKey: 'app-search-demo',
        icon: CupertinoIcons.search,
      ),
      const HomeEntry(
        title: 'App Sidebar',
        subtitle: 'Vant Sidebar 左侧菜单、激活态、badge 和内容联动',
        routeKey: 'app-sidebar-demo',
        icon: CupertinoIcons.sidebar_left,
      ),
      const HomeEntry(
        title: 'App Tab',
        subtitle: 'Vant Tab 标签页、line/card、滚动与滑动切换',
        routeKey: 'app-tab-demo',
        icon: CupertinoIcons.rectangle_split_3x1,
      ),
      const HomeEntry(
        title: 'App Text Ellipsis',
        subtitle: 'Vant TextEllipsis 多行省略、展开收起和头中尾截断',
        routeKey: 'app-text-ellipsis-demo',
        icon: CupertinoIcons.text_alignleft,
      ),
      const HomeEntry(
        title: 'App Rolling Text',
        subtitle: 'Vant RollingText 参数模型、数字翻牌与文本轮播',
        routeKey: 'app-rolling-text-demo',
        icon: CupertinoIcons.number,
      ),
      const HomeEntry(
        title: 'App Swipe Cell',
        subtitle: 'Vant SwipeCell 参数模型、左右滑动操作',
        routeKey: 'app-swipe-cell-demo',
        icon: CupertinoIcons.arrow_left_right,
      ),
      const HomeEntry(
        title: 'App Swipe',
        subtitle: 'Vant Swipe 鍙傛暟妯″瀷銆佽疆鎾€佽嚜鍔ㄦ挱鏀惧拰澶氬崱鐗囪绐?',
        routeKey: 'app-swipe-demo',
        icon: CupertinoIcons.rectangle_stack,
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

    final exampleGroups = <HomeEntryGroup>[
      HomeEntryGroup(
        title: '基础能力',
        subtitle: '路由、状态、请求、图像与通用结构',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'todolist',
            'fluro',
            'request',
            'profile',
            'scrollable-tabs',
            'network-image-demo',
            'gallery-preview-demo',
            'app-rolling-text-demo',
            'route-bottom-nav-bar-demo',
            'route-page-header-demo',
            'app-asset-icon-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '表单输入',
        subtitle: '输入框、按钮、选择、步进、密码与搜索',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-button-demo',
            'app-field-demo',
            'app-search-demo',
            'app-sidebar-demo',
            'app-stepper-demo',
            'app-steps-demo',
            'app-tab-demo',
            'app-switch-demo',
            'app-tag-demo',
            'app-text-ellipsis-demo',
            'app-password-input-demo',
            'app-checkbox-demo',
            'app-radio-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '弹层反馈',
        subtitle: '动作面板、对话框、抽屉与轻提示',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-action-sheet-demo',
            'app-dialog-demo',
            'app-sheet-demo',
            'app-toast-demo',
            'app-notice-bar-demo',
            'app-popover-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '选择器',
        subtitle: '日期、级联、地区和顶部筛选菜单',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-calendar-demo',
            'app-date-picker-demo',
            'app-index-bar-demo',
            'app-picker-demo',
            'area-pick-demo',
            'app-dropdown-menu-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '列表交互',
        subtitle: '滑动操作与列表行交互容器',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-swipe-cell-demo',
            'app-swipe-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
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
      const HomeEntry(
        title: '俄罗斯方块',
        subtitle: '键盘控制、消行计分、完整单机玩法',
        routeKey: 'tetris',
        icon: CupertinoIcons.game_controller,
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
                    children: exampleGroups
                        .map(
                          (group) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SectionPanel(
                              title: group.title,
                              subtitle: group.subtitle,
                              count: group.items.length,
                              expanded:
                                  _expandedExampleGroups.contains(group.title),
                              onToggle: () {
                                setState(() {
                                  if (_expandedExampleGroups.contains(
                                    group.title,
                                  )) {
                                    _expandedExampleGroups.remove(group.title);
                                  } else {
                                    _expandedExampleGroups.add(group.title);
                                  }
                                });
                              },
                              children: group.items
                                  .map(
                                    (item) => HomeListTile(
                                      item: item,
                                      onTap: () => _openRoute(item.routeKey),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
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
                    children: [
                      for (final item in businessItems) ...[
                        if (item.routeKey == 'oolaf-dynamic-audio')
                          const _OolafDynamicAudioNowPlayingBanner(),
                        HomeListTile(
                          item: item,
                          onTap: () => _openRoute(item.routeKey),
                        ),
                      ],
                    ],
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

class _OolafDynamicAudioNowPlayingVm {
  const _OolafDynamicAudioNowPlayingVm({
    required this.trackTitle,
    required this.nextTrackTitle,
    required this.isPlaying,
  });

  final String? trackTitle;
  final String? nextTrackTitle;
  final bool isPlaying;

  @override
  bool operator ==(Object other) {
    return other is _OolafDynamicAudioNowPlayingVm &&
        other.trackTitle == trackTitle &&
        other.nextTrackTitle == nextTrackTitle &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => Object.hash(trackTitle, nextTrackTitle, isPlaying);
}

class _OolafDynamicAudioNowPlayingBanner extends StatelessWidget {
  const _OolafDynamicAudioNowPlayingBanner();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _OolafDynamicAudioNowPlayingVm>(
      distinct: true,
      converter: (store) {
        final music = store.state.oolafMusic;
        String? nextTrackTitle;
        final queue = music.queue;
        final currentIndex = music.queueIndex;
        if (queue.isNotEmpty &&
            currentIndex >= 0 &&
            currentIndex < queue.length) {
          final nextIndex = currentIndex + 1;
          if (nextIndex < queue.length) {
            nextTrackTitle = queue[nextIndex].title;
          } else if (music.loopMode == OolafLoopMode.all) {
            nextTrackTitle = queue.first.title;
          }
        }
        return _OolafDynamicAudioNowPlayingVm(
          trackTitle: music.nowPlaying?.title,
          nextTrackTitle: nextTrackTitle,
          isPlaying: music.isPlaying,
        );
      },
      builder: (context, vm) {
        final trackTitle = vm.trackTitle?.trim() ?? '';
        if (trackTitle.isEmpty) {
          return const SizedBox.shrink();
        }
        final nextTrackTitle = vm.nextTrackTitle?.trim() ?? '';
        final noticeText = nextTrackTitle.isEmpty
            ? '正在播放：$trackTitle'
            : '正在播放：$trackTitle    下一首：$nextTrackTitle';

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          child: SizedBox(
            height: 18,
            child: AppNoticeBar(
              text: noticeText,
              scrollable: true,
              mode: AppNoticeBarMode.none,
              leftIcon: CupertinoIcons.music_note,
              color: const Color(0xFFB06A12),
              backgroundColor: const Color(0xFFFFF6E6),
              padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              iconSize: 12,
              textStyle: const TextStyle(
                color: Color(0xFFB06A12),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
