import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/components/fluro_detail/index.dart';
import 'package:oolaf_flutted/layouts/app_wrap/index.dart';
import 'package:oolaf_flutted/pages/fluro/index.dart';
import 'package:oolaf_flutted/pages/home/index.dart';
import 'package:oolaf_flutted/pages/oolaf_dynamic_audio/index.dart';
import 'package:oolaf_flutted/pages/short_video/index.dart';
import 'package:oolaf_flutted/pages/media_kit_test/index.dart';
import 'package:oolaf_flutted/pages/profile/index.dart';
import 'package:oolaf_flutted/pages/request/index.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/detail.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/index.dart';
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

var mediaKitTestRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const MediaKitTestPage();
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
var scrollableTabsDetailRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    String? title = params["title"]?.first;
    int? id = int.tryParse(params["id"]?.first ?? '');
    return ScrollableTabsDetailPage(
      id: id!,
      title: title ?? 'Flutter Template',
    );
  },
);
