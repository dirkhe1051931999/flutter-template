import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/layouts/app_theme.dart';
import 'package:flutter_template_start/store/index.dart';
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
            onGenerateRoute: router.generator,
            builder: EasyLoading.init(),
          ),
        );
      },
    );
  }
}
