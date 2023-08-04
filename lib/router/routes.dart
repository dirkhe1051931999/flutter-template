import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_start/pages/404/index.dart';
import 'package:flutter_template_start/router/handler.dart';

class Routes {
  static String root = "/";
  static String path1 = "/path1";
  static String path2 = "/path2";
  static String path3 = "/path3";
  static String todolist = "/todolist";
  static String fluro = "/fluro";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (
      BuildContext? context,
      Map<String, List<String>> params,
    ) {
      return const NotFoundPage();
    });
    // 首页
    router.define(root, handler: rootHandler);
    // 落地页
    router.define(path1, handler: path1RouteHandler);
    // 落地页
    router.define(
      path2,
      handler: path1RouteHandler,
      transitionType: TransitionType.inFromLeft,
    );
    // dialog 弹窗
    router.define(path3, handler: path3RouteHandler);
    // todolist
    router.define(todolist, handler: todolistRouteHandler);
    // fluro
    router.define(fluro, handler: fluroRouteHandler);
  }
}
