import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
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
      return MaterialApp(
        title: 'Fluro',
        home: Scaffold(
          body: const Center(
            child: Text('ROUTE WAS NOT FOUND !!!'),
          ),
          // 返回按钮
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context!);
            },
            child: const Icon(Icons.arrow_back),
          ),
        ),
      );
    });
    router.define(root, handler: rootHandler);
    router.define(path1, handler: path1RouteHandler);
    router.define(
      path2,
      handler: path1RouteHandler,
      transitionType: TransitionType.inFromLeft,
    );
    router.define(path3, handler: path3RouteHandler);
    router.define(todolist, handler: todolistRouteHandler);
    router.define(fluro, handler: fluroRouteHandler);
  }
}
