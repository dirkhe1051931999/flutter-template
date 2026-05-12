import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/router/config.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFD43C33);

    void openRoute(String key) {
      const transition = TransitionType.inFromRight;
      Application.router.navigateTo(
        context,
        '/$key',
        transition: transition,
      );
    }

    IconData iconForKey(String key) {
      return switch (key) {
        'todolist' => CupertinoIcons.check_mark_circled,
        'fluro' => CupertinoIcons.arrow_branch,
        'request' => CupertinoIcons.globe,
        'oolaf-dynamic-audio' => CupertinoIcons.music_note_list,
        'short-video' => CupertinoIcons.play_rectangle,
        'profile' => CupertinoIcons.person_crop_circle,
        'scrollable-tabs' => CupertinoIcons.rectangle_3_offgrid,
        _ => CupertinoIcons.square_grid_2x2,
      };
    }

    Widget menuCard({
      required String title,
      required String key,
    }) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          openRoute(key);
        },
        child: SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x0F000000)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x1AD43C33),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    iconForKey(key),
                    color: themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            color: const Color(0xFF1C1C1E),
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final menuWidgets = <Widget>[
      menuCard(title: 'redux 做的 todolist', key: 'todolist'),
      menuCard(title: 'fluro 的使用', key: 'fluro'),
      menuCard(title: 'dio 的使用', key: 'request'),
      menuCard(title: 'oolaf 动感音频', key: 'oolaf-dynamic-audio'),
      menuCard(title: '短视频', key: 'short-video'),
      menuCard(title: 'profile', key: 'profile'),
      menuCard(title: '可滑动选项卡', key: 'scrollable-tabs'),
    ];

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: const CupertinoNavigationBar(
        middle: Text('功能入口'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: GridView.builder(
            itemCount: menuWidgets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 128,
            ),
            itemBuilder: (context, index) {
              return menuWidgets[index];
            },
          ),
        ),
      ),
    );
  }
}
