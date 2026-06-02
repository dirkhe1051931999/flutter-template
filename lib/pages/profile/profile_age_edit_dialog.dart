import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/user/type.dart';

Future<void> showProfileAgeEditDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  final store = StoreProvider.of<AppState>(context, listen: false);

  try {
    await showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text('请输入一个数'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              placeholder: '请输入1-100之间的数字',
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                final age = int.tryParse(controller.text);
                if (age == null || age <= 1 || age >= 100) {
                  EasyLoading.showToast('请输入1-100之间的数字');
                  return;
                }

                store.dispatch(UpdateUserInfoAction(age: age));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
