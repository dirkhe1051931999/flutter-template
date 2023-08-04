import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/router/config.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/todolist/type.dart';
import 'package:flutter_template_start/store/user/type.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // helpers
    Widget menuButton(BuildContext context,
        {required String title, required String key}) {
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
          StoreConnector<AppState, VoidCallback>(
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: () {
                  callback();
                },
                child: const Text('Add'),
              );
            },
            converter: (store) {
              return () {
                store.dispatch(ITodolistAdd('controller!.text'));
              };
            },
          ),
          StoreConnector<AppState, VoidCallback>(
            builder: (context, callback) {
              return ElevatedButton(
                onPressed: () {
                  callback();
                },
                child: const Text('Update'),
              );
            },
            converter: (store) {
              return () {
                store.dispatch(IUserUpdate(fields: {'age': 2}));
              };
            },
          ),
          Stack(
            children: [
              StoreConnector<AppState, List<String>>(
                builder: (context, state) {
                  return Text(
                    "当前todolist的长度为：${state.toString()}",
                  );
                },
                converter: (store) => store.state.todos,
              ),
              StoreConnector<AppState, IUserinfo>(
                builder: (context, state) {
                  // 打印state
                  return Text(
                    state.age.toString(),
                  );
                },
                converter: (store) => store.state.userinfo,
              ),
            ],
          )
        ],
      ),
    );
  }
}
