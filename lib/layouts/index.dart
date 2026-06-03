import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oolaf_flutted/layouts/app_theme.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/route_observer.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:redux/redux.dart';

class Layout extends StatelessWidget {
  const Layout({
    super.key,
    required this.router,
    required this.store,
  });

  final FluroRouter router;
  final Store<AppState> store;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return StoreProvider(
          store: store,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Template Start',
            theme: AppTheme().light,
            navigatorKey: Application.navigatorKey,
            onGenerateRoute: router.generator,
            navigatorObservers: [appRouteObserver],
            builder: (context, child) {
              return DefaultTextStyle.merge(
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  decorationColor: Color(0x00000000),
                  fontWeight: FontWeight.w400,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
