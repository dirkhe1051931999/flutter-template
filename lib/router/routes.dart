import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/pages/404/index.dart';
import 'package:oolaf_flutted/router/handler.dart';

class Routes {
  static const root = "/";
  static const transitionDetail = "/transition-detail";
  static const fixedTransitionDetail = "/fixed-transition-detail";
  static const dialogDemo = "/dialog-demo";
  static const todolist = "/todolist";
  static const fluro = "/fluro";
  static const request = "/request";
  static const oolafDynamicAudio = "/oolaf-dynamic-audio";
  static const shortVideo = "/short-video";
  static const profile = "/profile";
  static const scrollableTabs = "/scrollable-tabs";
  static const scrollableTabsDetail = "/scrollable-tabs-detail";
  static const weather = "/weather";
  static const hupu = "/hupu";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (
      BuildContext? context,
      Map<String, List<String>> params,
    ) {
      return const NotFoundPage();
    });
    router.define(root, handler: rootHandler);
    router.define(transitionDetail, handler: transitionDetailRouteHandler);
    router.define(
      fixedTransitionDetail,
      handler: transitionDetailRouteHandler,
      transitionType: TransitionType.inFromLeft,
    );
    router.define(dialogDemo, handler: dialogDemoRouteHandler);
    router.define(todolist, handler: todolistRouteHandler);
    router.define(fluro, handler: fluroRouteHandler);
    router.define(request, handler: requestRouteHandler);
    router.define(oolafDynamicAudio, handler: oolafDynamicAudioRouteHandler);
    router.define(shortVideo, handler: shortVideoRouteHandler);
    router.define(
      profile,
      handler: profileRouteHandler,
    );
    router.define(
      scrollableTabs,
      handler: scrollableTabsRouteHandler,
    );
    router.define(
      scrollableTabsDetail,
      handler: scrollableTabsDetailRouteHandler,
    );
    router.define(
      weather,
      handler: weatherRouteHandler,
    );
    router.define(
      hupu,
      handler: hupuRouteHandler,
    );
  }
}
