import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_template_start/store/index.dart';
import 'package:flutter_template_start/store/user/type.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _showDialog(BuildContext context) async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context2) {
        return AlertDialog(
          title: const Text('请输入一个数'),
          content: Builder(
            builder: (BuildContext context) {
              return TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '请输入1-100之间的数字',
                ),
              );
            },
          ),
          actions: <Widget>[
            StoreConnector<AppState, VoidCallback>(
              builder: (context, callback) {
                return ElevatedButton(
                  onPressed: () {
                    int? value = int.tryParse(controller.text);
                    if (value != null && value > 1 && value < 100) {
                      callback();
                      Navigator.of(context).pop();
                    } else {
                      EasyLoading.showToast('请输入1-100之间的数字');
                    }
                  },
                  child: const Text('确定'),
                );
              },
              converter: (store) {
                return () {
                  int age = int.parse(controller.text);
                  store.dispatch(IUserUpdate(fields: {'age': age}));
                };
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreProvider.of<AppState>(context);
    var size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        StoreConnector<AppState, IUserinfo>(
          builder: (context, state) {
            IUserinfo userinfo = store.state.userinfo;
            List<Widget> list = [];
            userinfo.toMap().forEach((key, value) {
              list.add(
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border.all()),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Text("$key: $value"),
                    ),
                  ),
                ),
              );
            });
            return Expanded(
              child: GridView.count(
                childAspectRatio: size.width / (size.height / 2) / 0.5,
                crossAxisCount: 2,
                children: list,
              ),
            );
          },
          converter: (store) => store.state.userinfo,
        ),
        ElevatedButton(
          onPressed: () {
            _showDialog(context);
          },
          child: const Text("修改用户年龄"),
        ),
      ],
    );
  }
}
