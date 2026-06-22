import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/pages/profile/profile_view_data.dart';
import 'package:oolaf_flutted/pages/profile/widgets/profile_hero.dart';
import 'package:oolaf_flutted/pages/profile/widgets/profile_info_card.dart';
import 'package:oolaf_flutted/store/index.dart';
import 'package:oolaf_flutted/store/user/type.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: StoreConnector<AppState, ProfileViewData>(
        converter: (store) =>
            ProfileViewData.fromUserInfo(store.state.userInfo),
        builder: (context, viewData) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              ProfileHero(
                age: viewData.age,
                username: viewData.username,
              ),
              const SizedBox(height: 14),
              ProfileInfoCard(
                items: viewData.infoItems,
                onItemChanged: (item, value) {
                  final store = StoreProvider.of<AppState>(
                    context,
                    listen: false,
                  );
                  store.dispatch(_createUpdateAction(item.key, value));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  UpdateUserInfoAction _createUpdateAction(String key, String value) {
    switch (key) {
      case 'name':
        return UpdateUserInfoAction(name: value);
      case 'age':
        return UpdateUserInfoAction(age: int.tryParse(value) ?? -1);
      case 'username':
        return UpdateUserInfoAction(username: value);
      case 'password':
        return UpdateUserInfoAction(password: value);
      case 'token':
        return UpdateUserInfoAction(token: value);
      case 'email':
        return UpdateUserInfoAction(email: value);
      case 'phone':
        return UpdateUserInfoAction(phone: value);
      default:
        return const UpdateUserInfoAction();
    }
  }
}
