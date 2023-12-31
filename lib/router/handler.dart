import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_start/components/fluro_detail/index.dart';
import 'package:flutter_template_start/layouts/app_wrap/index.dart';
import 'package:flutter_template_start/pages/fluro/index.dart';
import 'package:flutter_template_start/pages/home/index.dart';
import 'package:flutter_template_start/pages/profile/index.dart';
import 'package:flutter_template_start/pages/request/index.dart';
import 'package:flutter_template_start/pages/scrollable_tabs/detail.dart';
import 'package:flutter_template_start/pages/scrollable_tabs/index.dart';
import 'package:flutter_template_start/pages/todolist/index.dart';
import 'package:flutter_template_start/utils/helper.dart';

/// 定义一个首页
var rootHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const HomePage();
  },
);

var path1RouteHandler = Handler(
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
    return PathDetail(
      message: message ?? 'Testing',
      color: color,
      result: result,
    );
  },
);

var path3RouteHandler = Handler(
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
    return const MaterialAppWrapWidget(
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
    return const MaterialAppWrapWidget(
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
    return const MaterialAppWrapWidget(
      title: 'Request',
      widget: RequestPage(),
    );
  },
);

var profileRouteHandler = Handler(
  handlerFunc: (
    BuildContext? context,
    Map<String, List<String>> params,
  ) {
    return const MaterialAppWrapWidget(
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
      title: title ?? 'Testing',
    );
  },
);
