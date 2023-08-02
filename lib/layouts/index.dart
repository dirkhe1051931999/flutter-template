import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/layouts/app_theme.dart';
import 'package:flutter_template_start/router/config.dart';
import 'package:flutter_template_start/router/routes.dart';
import 'package:flutter_template_start/store/todolist/reducer.dart';
import 'package:flutter_template_start/utils/helper.dart';

class Layout extends StatelessWidget {
  Layout({Key? key}) : super(key: key) {
    _initializeFluro();
  }
  // 初始化Fluro路由
  void _initializeFluro() {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  void printScreenInformation() {
    final deviceDetails = {
      '设备宽度': '${1.sw}dp',
      '设备高度': '${1.sh}dp',
      '设备的像素密度': '${ScreenUtil().pixelRatio}',
      '底部安全区距离': '${ScreenUtil().bottomBarHeight}dp',
      '状态栏高度': '${ScreenUtil().statusBarHeight}dp',
      '实际宽度和字体(dp)与设计稿(dp)的比例': '${ScreenUtil().scaleWidth}',
      '实际高度(dp)与设计稿(dp)的比例': '${ScreenUtil().scaleHeight}',
      '高度相对于设计稿放大的比例': '${ScreenUtil().scaleHeight}',
      '系统的字体缩放比例': '${ScreenUtil().textScaleFactor}',
      '屏幕宽度的0.5': '${0.5.sw}dp',
      '屏幕高度的0.5': '${0.5.sh}dp',
      '屏幕方向': '${ScreenUtil().orientation}',
    };
    customLogger.log(deviceDetails);
  }

  final store =
      Store<List<String>>(todoListReducer, initialState: ['initial item']);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return StoreProvider(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Template Start',
        theme: AppTheme.light,
        onGenerateRoute: Application.router.generator,
      ),
    );
  }
}