import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/fluro_detail/index.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';
import 'package:oolaf_flutted/pages/component_demo/app_asset_icon_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/app_sheet_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/gallery_preview_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/network_image_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/route_bottom_nav_bar_demo_page.dart';
import 'package:oolaf_flutted/pages/component_demo/route_page_header_demo_page.dart';
import 'package:oolaf_flutted/pages/fluro/index.dart';
import 'package:oolaf_flutted/pages/home/index.dart';
import 'package:oolaf_flutted/pages/hupu/index.dart';
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
