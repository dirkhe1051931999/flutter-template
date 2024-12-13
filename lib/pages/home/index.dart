import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template_start/router/config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // helpers
    Widget menuButton(
      BuildContext context, {
      required String title,
      required String key,
    }) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () {
            var transition = TransitionType.inFromRight;
            Application.router.navigateTo(
              context,
              "/$key",
              transition: transition,
            );
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
      menuButton(context, title: "redux 做的 todolist", key: "todolist"),
      menuButton(context, title: "fluro 的使用", key: "fluro"),
      menuButton(context, title: "dio 的使用", key: "request"),
      menuButton(context, title: "profile", key: "profile"),
      menuButton(context, title: "可滑动选项卡", key: "scrollable-tabs"),
    ];
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: GridView.count(
              childAspectRatio: size.width / (size.height / 2) / 0.5,
              crossAxisCount: 2,
              children: menuWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
