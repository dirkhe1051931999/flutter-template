import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:oolaf_flutted/pages/profile/profile_age_edit_dialog.dart';
import 'package:oolaf_flutted/pages/profile/profile_view_data.dart';
import 'package:oolaf_flutted/pages/profile/widgets/profile_hero.dart';
import 'package:oolaf_flutted/pages/profile/widgets/profile_info_card.dart';
import 'package:oolaf_flutted/store/index.dart';

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
              ProfileInfoCard(items: viewData.infoItems),
              const SizedBox(height: 14),
              CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 14),
                borderRadius: BorderRadius.circular(18),
                onPressed: () => showProfileAgeEditDialog(context),
                child: const Text(
                  '修改用户年龄',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
