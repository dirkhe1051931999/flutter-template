import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/fluro_detail/index.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';
import 'package:oolaf_flutted/pages/auth/auth_demo_pages.dart';
import 'package:oolaf_flutted/pages/auth/index.dart';
import 'package:oolaf_flutted/pages/component_demo/app_asset_icon_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_action_sheet_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_button_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_calendar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_date_picker_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_dialog_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_dropdown_menu_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_index_bar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_notice_bar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_picker_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_checkbox_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_field_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_password_input_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_popover_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_radio_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_rolling_text_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_search_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_stepper_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_steps_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_switch_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_swipe_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_swipe_cell_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_tab_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_tag_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_text_ellipsis_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_toast_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_sidebar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/area_pick_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_sheet_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/gallery_preview_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/network_image_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/route_bottom_nav_bar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/route_page_header_demo_page.dart';
import 'package:oolaf_flutted/pages/fluro/index.dart';
import 'package:oolaf_flutted/pages/home/index.dart';
import 'package:oolaf_flutted/pages/tetris_game/index.dart';
import 'package:oolaf_flutted/pages/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_login_page.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/index.dart';
import 'package:oolaf_flutted/pages/profile/index.dart';
import 'package:oolaf_flutted/pages/request/index.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/index.dart';
import 'package:oolaf_flutted/pages/video_tabs/short_video_shell_page.dart';
import 'package:oolaf_flutted/pages/weather/index.dart';
import 'package:oolaf_flutted/pages/todolist/index.dart';
import 'package:oolaf_flutted/utils/helper.dart';

/// 定义一个首页
var rootHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const HomePage();
  },
);

var transitionDetailRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    String? message = params["message"]?.first;
    String? colorHex = params["color_hex"]?.first;
    String? result = params["result"]?.first;
    Color color = const Color(0xFFFFFFFF);
    if (colorHex != null && colorHex.isNotEmpty) {
      color = Color(ColorHelpers.fromHexString(colorHex));
    }
    return TransitionDetailPage(
      message: message ?? 'Flutter Template',
      color: color,
      result: result,
    );
  },
);

var dialogDemoRouteHandler = Handler(
  type: HandlerType.function,
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    String? message = params["message"]?.first;
    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "这是弹窗",
            textAlign: TextAlign.center,
          ),
          content: Text("$message"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
    return;
  },
);

var todolistRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'TodoList',
      widget: TodoListPage(),
    );
  },
);

var fluroRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Fluro',
      widget: FluroPage(),
    );
  },
);

var requestRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Request',
      widget: RequestPage(),
    );
  },
);

var oolafDynamicAudioRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const OolafDynamicAudioPage();
  },
);

var shortVideoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const ShortVideoPage();
  },
);

var authRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthPage();
  },
);

var authSplashGateRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthSplashGatePage();
  },
);

var authLoginRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthLoginPage();
  },
);

var authRegisterRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthRegisterPage();
  },
);

var authOtpRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthOtpPage();
  },
);

var authForgotPasswordRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthPasswordFlowPage(mode: AuthPasswordFlowMode.forgot);
  },
);

var authResetPasswordRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthPasswordFlowPage(mode: AuthPasswordFlowMode.reset);
  },
);

var authChangePasswordRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthPasswordFlowPage(mode: AuthPasswordFlowMode.change);
  },
);

var authBindingRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthBindingPage(unbindMode: false);
  },
);

var authUnbindingRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthBindingPage(unbindMode: true);
  },
);

var authCompleteProfileRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthProfileCompletionPage();
  },
);

var authPermissionIntroRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthPermissionIntroPage();
  },
);

var authVerificationStatusRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthVerificationStatusPage();
  },
);

var authMfaRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthMfaPage();
  },
);

var authSessionExpiredRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthSessionExpiredPage();
  },
);

var authAccountSecurityRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthAccountSecurityPage();
  },
);

var authDevicesRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthDeviceManagementPage();
  },
);

var authDeleteRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthDeleteAccountPage();
  },
);

var authTermsRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthTermsPage();
  },
);

var authPrivacyRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthTermsPage(privacy: true);
  },
);

var authThirdPartyCallbackRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthThirdPartyCallbackPage();
  },
);

var authExceptionRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const AuthExceptionStatePage();
  },
);

var profileRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Profile',
      widget: ProfilePage(),
    );
  },
);
var scrollableTabsRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const ScrollableTabsPage();
  },
);
var networkImageDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Network Img',
      widget: NetworkImageDemoPage(),
    );
  },
);
var appAssetIconDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Asset Icon',
      widget: AppAssetIconDemoPage(),
    );
  },
);
var appButtonDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Button',
      widget: AppButtonDemoPage(),
    );
  },
);
var appActionSheetDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Action Sheet',
      widget: AppActionSheetDemoPage(),
    );
  },
);
var appCalendarDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Calendar',
      widget: AppCalendarDemoPage(),
    );
  },
);
var appDatePickerDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Date Picker',
      widget: AppDatePickerDemoPage(),
    );
  },
);
var appDialogDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Dialog',
      widget: AppDialogDemoPage(),
    );
  },
);
var appDropdownMenuDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Dropdown Menu',
      widget: AppDropdownMenuDemoPage(),
    );
  },
);
var appIndexBarDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Index Bar',
      widget: AppIndexBarDemoPage(),
    );
  },
);
var appNoticeBarDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Notice Bar',
      widget: AppNoticeBarDemoPage(),
    );
  },
);
var appPickerDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Picker',
      widget: AppPickerDemoPage(),
    );
  },
);
var appCheckboxDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Checkbox',
      widget: AppCheckboxDemoPage(),
    );
  },
);
var appSwitchDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Switch',
      widget: AppSwitchDemoPage(),
    );
  },
);
var appSwipeCellDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Swipe Cell',
      widget: AppSwipeCellDemoPage(),
    );
  },
);
var appStepperDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Stepper',
      widget: AppStepperDemoPage(),
    );
  },
);
var appStepsDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Steps',
      widget: AppStepsDemoPage(),
    );
  },
);
var appTabDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Tab',
      widget: AppTabDemoPage(),
    );
  },
);
var appFieldDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Field',
      widget: AppFieldDemoPage(),
    );
  },
);
var appPasswordInputDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Password Input',
      widget: AppPasswordInputDemoPage(),
    );
  },
);
var appPopoverDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Popover',
      widget: AppPopoverDemoPage(),
    );
  },
);
var appRadioDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Radio',
      widget: AppRadioDemoPage(),
    );
  },
);
var appRollingTextDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Rolling Text',
      widget: AppRollingTextDemoPage(),
    );
  },
);
var appSwipeDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Swipe',
      widget: AppSwipeDemoPage(),
    );
  },
);
var appSearchDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Search',
      widget: AppSearchDemoPage(),
    );
  },
);
var appTagDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Tag',
      widget: AppTagDemoPage(),
    );
  },
);
var appTextEllipsisDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Text Ellipsis',
      widget: AppTextEllipsisDemoPage(),
    );
  },
);
var appToastDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Toast',
      widget: AppToastDemoPage(),
    );
  },
);
var appSidebarDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Sidebar',
      widget: AppSidebarDemoPage(),
    );
  },
);
var areaPickDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Area Pick',
      widget: AreaPickDemoPage(),
    );
  },
);
var appSheetDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'App Sheet',
      widget: AppSheetDemoPage(),
    );
  },
);
var galleryPreviewDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Gallery Preview',
      widget: GalleryPreviewDemoPage(),
    );
  },
);
var routeBottomNavBarDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: 'Route Bottom Nav Bar',
      widget: RouteBottomNavBarDemoPage(),
    );
  },
);
var routePageHeaderDemoRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const RoutePageHeaderDemoPage();
  },
);
var weatherRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const WeatherPage();
  },
);
var hupuRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const HupuPage();
  },
);
var hupuLoginRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const HupuLoginPage();
  },
);
var tetrisRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const PageScaffold(
      title: '俄罗斯方块',
      widget: TetrisGamePage(),
    );
  },
);
var hupuPostDetailRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    final tid = params['tid']?.first ?? '';
    final fid = params['fid']?.first ?? '';
    final topicId = int.tryParse(params['topicId']?.first ?? '') ?? 0;
    final title = params['title']?.first ?? '';
    return HupuPostDetailPage(
      tid: tid,
      fid: fid,
      topicId: topicId,
      initialTitle: title,
    );
  },
);
