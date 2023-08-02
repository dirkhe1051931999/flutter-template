import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/router/config.dart';

class FluroPage extends StatelessWidget {
  const FluroPage({super.key});

  @override
  Widget build(BuildContext context) {
    // actions
    void tappedMenuButton(BuildContext context, {required String key}) async {
      String message = "";
      String hexCode = "";
      TransitionType transitionType = TransitionType.native;
      if (key != "custom" &&
          key != "function-call" &&
          key != "fixed-trans" &&
          key != "todolist") {
        String? result;
        if (key == "native") {
          hexCode = "#F76F00";
          message = "系统默认动画";
        } else if (key == "preset-from-left") {
          hexCode = "#5BF700";
          message = "从左侧过渡滑入";
          transitionType = TransitionType.inFromLeft;
        } else if (key == "preset-fade") {
          hexCode = "#F700D2";
          message = "淡入淡出";
          transitionType = TransitionType.fadeIn;
        } else if (key == "pop-result") {
          transitionType = TransitionType.native;
          hexCode = "#7d41f4";
          message = "监听返回事件";
          result = "OK，你成功返回了！";
        }
        String route =
            "/path1?message=${Uri.encodeComponent(message)}&color_hex=$hexCode";
        route += result != null ? "&result=${Uri.encodeComponent(result)}" : "";
        Application.router
            .navigateTo(context, route, transition: transitionType)
            .then((value) {
          if (key == "pop-result") {
            Application.router.navigateTo(
                context, "/path3?message=${Uri.encodeComponent(value)}");
          }
        });
      } else if (key == "custom") {
        hexCode = "#DFF700";
        message = "自定义过渡";
        transition(
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return ScaleTransition(
            scale: animation,
            child: RotationTransition(
              turns: animation,
              child: child,
            ),
          );
        }

        Application.router.navigateTo(
          context,
          "/path1?message=${Uri.encodeComponent(message)}&color_hex=$hexCode",
          transition: TransitionType.custom,
          transitionBuilder: transition,
          transitionDuration: const Duration(milliseconds: 600),
        );
      } else if (key == "fixed-trans") {
        hexCode = "#f4424b";
        message = "在注册路由的时候就已经定义好了动画";
        Application.router.navigateTo(context,
            "/path2?message=${Uri.encodeComponent(message)}&color_hex=$hexCode");
      } else if (key == "function-call") {
        message = "功能按钮！";
        Application.router.navigateTo(
            context, "/path3?message=${Uri.encodeComponent(message)}");
      } else if (key == 'todolist') {
        message = "todolist";
        Application.router.navigateTo(
          context,
          "/todolist?message=${Uri.encodeComponent(message)}",
          transition: TransitionType.inFromRight,
        );
      } else {
        message = '未知类型按钮';
        Application.router.navigateTo(
            context, "/path3?message=${Uri.encodeComponent(message)}");
      }
    }

    // helpers
    Widget menuButton(BuildContext context,
        {required String title, required String key}) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            tappedMenuButton(context, key: key);
          },
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    var menuWidgets = <Widget>[
      menuButton(context, title: "系统默认动画", key: "native"),
      menuButton(context, title: "从左侧过渡滑入", key: "preset-from-left"),
      menuButton(context, title: "淡入淡出", key: "preset-fade"),
      menuButton(context, title: "在注册路由的时候就已经定义好了动画", key: "fixed-trans"),
      menuButton(context, title: "自定义动画", key: "custom"),
      menuButton(context, title: "监听返回事件", key: "pop-result"),
      menuButton(context, title: "函数回调", key: "function-call"),
    ];
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GridView.count(
              childAspectRatio: size.width / (size.height / 2),
              crossAxisCount: 2,
              children: menuWidgets,
            ),
          ),
          Stack(
            children: <Widget>[
              Text(
                "mock bottom navbar",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 22.sp,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
