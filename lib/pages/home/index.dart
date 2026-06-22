import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/components/app_notice_bar/app_notice_bar_types.dart';
import 'package:oolaf_flutted/components/app_notice_bar/index.dart';
import 'package:oolaf_flutted/pages/home/widgets/background_orb.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_entry.dart';
import 'package:oolaf_flutted/pages/home/widgets/home_entry_group.dart';
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
    '搭页面骨架',
    '收集输入',
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
        subtitle: '用来确认 Redux 状态流、列表增删和基础输入闭环',
        routeKey: 'todolist',
        icon: CupertinoIcons.check_mark_circled,
      ),
      const HomeEntry(
        title: 'Fluro',
        subtitle: '需要路由跳转、转场、返回值或回调传参时看它',
        routeKey: 'fluro',
        icon: CupertinoIcons.arrow_branch,
      ),
      const HomeEntry(
        title: 'Request',
        subtitle: '接接口、处理 loading/error/empty/list 结果态时看它',
        routeKey: 'request',
        icon: CupertinoIcons.globe,
      ),
      const HomeEntry(
        title: 'Profile',
        subtitle: '需要把用户资料映射成表单和全局状态时看它',
        routeKey: 'profile',
        icon: CupertinoIcons.person_crop_circle,
      ),
      const HomeEntry(
        title: 'Scrollable Tabs',
        subtitle: '页面里有横向 tab、刷新、保活或禁滑诉求时用',
        routeKey: 'scrollable-tabs',
        icon: CupertinoIcons.rectangle_3_offgrid,
      ),
      const HomeEntry(
        title: 'Network Img',
        subtitle: '展示远程图片并需要骨架、失败回退或占位时用',
        routeKey: 'network-image-demo',
        icon: CupertinoIcons.photo,
      ),
      const HomeEntry(
        title: 'App Asset Icon',
        subtitle: '需要统一展示本地图标、染色或 fallback 图标时用',
        routeKey: 'app-asset-icon-demo',
        icon: CupertinoIcons.square_grid_2x2,
      ),
      const HomeEntry(
        title: 'App Calendar',
        subtitle: '需要单选、多选、范围选择或弹层日历时用',
        routeKey: 'app-calendar-demo',
        icon: CupertinoIcons.calendar,
      ),
      const HomeEntry(
        title: 'App Date Picker',
        subtitle: '需要年/月/日列式选择，且结果是日期值时用',
        routeKey: 'app-date-picker-demo',
        icon: CupertinoIcons.time,
      ),
      const HomeEntry(
        title: 'App Picker',
        subtitle: '需要单列、多列或级联选择，但不是日期时用',
        routeKey: 'app-picker-demo',
        icon: CupertinoIcons.slider_horizontal_3,
      ),
      const HomeEntry(
        title: 'App Checkbox',
        subtitle: '用户可以选多个选项，或需要限制最多选几个时用',
        routeKey: 'app-checkbox-demo',
        icon: CupertinoIcons.check_mark_circled,
      ),
      const HomeEntry(
        title: 'App Button',
        subtitle: '需要统一主按钮、次按钮、禁用或加载态按钮时用',
        routeKey: 'app-button-demo',
        icon: CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
      ),
      const HomeEntry(
        title: 'App Action Sheet',
        subtitle: '从底部弹出一组操作，让用户选一个动作时用',
        routeKey: 'app-action-sheet-demo',
        icon: CupertinoIcons.ellipsis_circle,
      ),
      const HomeEntry(
        title: 'App Switch',
        subtitle: '只有开/关两种状态，并可能有 loading/disabled 时用',
        routeKey: 'app-switch-demo',
        icon: CupertinoIcons.switch_camera,
      ),
      const HomeEntry(
        title: 'App Tag',
        subtitle: '展示状态、属性、角标、筛选条件或可关闭标签时用',
        routeKey: 'app-tag-demo',
        icon: CupertinoIcons.tag,
      ),
      const HomeEntry(
        title: 'App Stepper',
        subtitle: '数量只能按步长增减，且需要最小/最大/小数时用',
        routeKey: 'app-stepper-demo',
        icon: CupertinoIcons.plus_slash_minus,
      ),
      const HomeEntry(
        title: 'App Steps',
        subtitle: '展示流程进度、订单节点或横纵向步骤状态时用',
        routeKey: 'app-steps-demo',
        icon: CupertinoIcons.list_number,
      ),
      const HomeEntry(
        title: 'App Dialog',
        subtitle: '需要用户确认、取消，或承载小段关键内容时用',
        routeKey: 'app-dialog-demo',
        icon: CupertinoIcons.chat_bubble_2,
      ),
      const HomeEntry(
        title: 'App Dropdown Menu',
        subtitle: '列表顶部需要排序、筛选、状态切换菜单时用',
        routeKey: 'app-dropdown-menu-demo',
        icon: CupertinoIcons.chevron_down_square,
      ),
      const HomeEntry(
        title: 'App Index Bar',
        subtitle: '长列表按字母/分组浏览，需要右侧快速索引时用',
        routeKey: 'app-index-bar-demo',
        icon: CupertinoIcons.textformat_abc,
      ),
      const HomeEntry(
        title: 'App Notice Bar',
        subtitle: '需要公告、提示条、滚动文本或轻量运营位时用',
        routeKey: 'app-notice-bar-demo',
        icon: CupertinoIcons.speaker_2,
      ),
      const HomeEntry(
        title: 'App Field',
        subtitle: '收集文本、手机号、备注，并需要清空/校验/链接态时用',
        routeKey: 'app-field-demo',
        icon: CupertinoIcons.square_pencil,
      ),
      const HomeEntry(
        title: 'App Password Input',
        subtitle: '支付密码、验证码格子或固定长度隐藏输入时用',
        routeKey: 'app-password-input-demo',
        icon: CupertinoIcons.lock_shield,
      ),
      const HomeEntry(
        title: 'App Popover',
        subtitle: '围绕某个按钮弹出小菜单、更多操作或解释说明时用',
        routeKey: 'app-popover-demo',
        icon: CupertinoIcons.bubble_left_bubble_right,
      ),
      const HomeEntry(
        title: 'App Radio',
        subtitle: '用户只能从一组选项里选一个，且需要显式选中态时用',
        routeKey: 'app-radio-demo',
        icon: CupertinoIcons.smallcircle_fill_circle,
      ),
      const HomeEntry(
        title: 'App Search',
        subtitle: '搜索入口、筛选关键字、可清空输入或提交搜索时用',
        routeKey: 'app-search-demo',
        icon: CupertinoIcons.search,
      ),
      const HomeEntry(
        title: 'App Sidebar',
        subtitle: '左侧分类、右侧内容联动，或二级导航场景时用',
        routeKey: 'app-sidebar-demo',
        icon: CupertinoIcons.sidebar_left,
      ),
      const HomeEntry(
        title: 'App Tab',
        subtitle: '同层内容切换，适合 line/card tab 和横向滚动 tab',
        routeKey: 'app-tab-demo',
        icon: CupertinoIcons.rectangle_split_3x1,
      ),
      const HomeEntry(
        title: 'App Text Ellipsis',
        subtitle: '长文案需要多行省略、展开收起或头中尾截断时用',
        routeKey: 'app-text-ellipsis-demo',
        icon: CupertinoIcons.text_alignleft,
      ),
      const HomeEntry(
        title: 'App Rolling Text',
        subtitle: '数字翻牌、奖池金额、倒计时或短文本轮播时用',
        routeKey: 'app-rolling-text-demo',
        icon: CupertinoIcons.number,
      ),
      const HomeEntry(
        title: 'App Swipe Cell',
        subtitle: '列表行需要左滑删除、右滑操作或快捷动作时用',
        routeKey: 'app-swipe-cell-demo',
        icon: CupertinoIcons.arrow_left_right,
      ),
      const HomeEntry(
        title: 'App Swipe',
        subtitle: '轮播图、横向卡片、分页滑动或自动播放场景时用',
        routeKey: 'app-swipe-demo',
        icon: CupertinoIcons.rectangle_stack,
      ),
      const HomeEntry(
        title: 'App Toast',
        subtitle: '操作后给短反馈，不需要用户做选择时用',
        routeKey: 'app-toast-demo',
        icon: CupertinoIcons.bell,
      ),
      const HomeEntry(
        title: 'Area Pick',
        subtitle: '选择省市区县镇这类行政区划层级时用',
        routeKey: 'area-pick-demo',
        icon: CupertinoIcons.location_solid,
      ),
      const HomeEntry(
        title: 'App Sheet',
        subtitle: '承载更完整内容的顶部/底部弹层、半屏面板时用',
        routeKey: 'app-sheet-demo',
        icon: CupertinoIcons.layers_alt,
      ),
      const HomeEntry(
        title: 'Gallery Preview',
        subtitle: '图片大图预览、长图浏览、缩放和横滑查看时用',
        routeKey: 'gallery-preview-demo',
        icon: CupertinoIcons.photo_on_rectangle,
      ),
      const HomeEntry(
        title: 'Route Bottom Nav Bar',
        subtitle: '页面底部需要主导航、凸出主操作或状态切换时用',
        routeKey: 'route-bottom-nav-bar-demo',
        icon: CupertinoIcons.square_split_2x1,
      ),
      const HomeEntry(
        title: 'Route Page Header',
        subtitle: '详情页/个人页需要头像、标题和右侧操作区时用',
        routeKey: 'route-page-header-demo',
        icon: CupertinoIcons.square_list,
      ),
    ];

    final exampleGroups = <HomeEntryGroup>[
      HomeEntryGroup(
        title: '搭页面骨架',
        subtitle: '先决定页面导航、头部、底栏、tab 和基础数据流',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'todolist',
            'fluro',
            'request',
            'profile',
            'scrollable-tabs',
            'route-bottom-nav-bar-demo',
            'route-page-header-demo',
            'app-tab-demo',
            'app-sidebar-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '展示状态与内容',
        subtitle: '展示图片、图标、标签、长文本、公告和动态数字',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-steps-demo',
            'app-tag-demo',
            'app-text-ellipsis-demo',
            'app-rolling-text-demo',
            'app-notice-bar-demo',
            'app-asset-icon-demo',
            'network-image-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '收集输入',
        subtitle: '用户需要输入、搜索、提交、开关或调整数量',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-button-demo',
            'app-field-demo',
            'app-search-demo',
            'app-stepper-demo',
            'app-switch-demo',
            'app-password-input-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '让用户做选择',
        subtitle: '单选、多选、日期、地区、级联或列表筛选',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-checkbox-demo',
            'app-radio-demo',
            'app-calendar-demo',
            'app-date-picker-demo',
            'app-picker-demo',
            'area-pick-demo',
            'app-dropdown-menu-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '弹出反馈',
        subtitle: '需要确认、轻提示、菜单、动作面板或半屏承载',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-action-sheet-demo',
            'app-dialog-demo',
            'app-sheet-demo',
            'app-toast-demo',
            'app-popover-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
      HomeEntryGroup(
        title: '处理列表手势',
        subtitle: '长列表索引、图片预览、滑动行和横向轮播',
        items: exampleItems.where((item) {
          const routeKeys = <String>{
            'app-index-bar-demo',
            'app-swipe-cell-demo',
            'app-swipe-demo',
            'gallery-preview-demo',
          };
          return routeKeys.contains(item.routeKey);
        }).toList(growable: false),
      ),
    ];

    final businessItems = <HomeEntry>[
      const HomeEntry(
        title: 'Auth',
        subtitle: '登录、注册和账号能力示例入口',
        routeKey: 'auth',
        icon: CupertinoIcons.lock_shield,
      ),
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
                  SectionPanel(
                    title: '基础示例',
                    subtitle: '按任务找组件：先想用户要完成什么',
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
                  const _OolafDynamicAudioNowPlayingBanner(),
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
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
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
