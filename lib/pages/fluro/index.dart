import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/fluro/widgets/action_tile.dart';
import 'package:oolaf_flutted/pages/fluro/widgets/fluro_group.dart';
import 'package:oolaf_flutted/pages/fluro/widgets/hero_card.dart';
import 'package:oolaf_flutted/router/config.dart';
import 'package:oolaf_flutted/router/routes.dart';

class FluroPage extends StatelessWidget {
  const FluroPage({super.key});

  Future<void> _tappedMenuButton(
    BuildContext context, {
    required String key,
  }) async {
    String message = '';
    String hexCode = '';
    TransitionType transitionType = TransitionType.native;
    if (key != 'custom' &&
        key != 'function-call' &&
        key != 'fixed-trans' &&
        key != 'todolist') {
      String? result;
      if (key == 'native') {
        hexCode = '#F76F00';
        message = '系统默认动画';
      } else if (key == 'preset-from-left') {
        hexCode = '#5BF700';
        message = '从左侧过渡滑入';
        transitionType = TransitionType.inFromLeft;
      } else if (key == 'preset-fade') {
        hexCode = '#F700D2';
        message = '淡入淡出';
        transitionType = TransitionType.fadeIn;
      } else if (key == 'pop-result') {
        transitionType = TransitionType.native;
        hexCode = '#7d41f4';
        message = '监听返回事件';
        result = 'OK，你成功返回了！';
      }
      String route =
          '${Routes.transitionDetail}?message=${Uri.encodeComponent(message)}&color_hex=$hexCode';
      route += result != null ? '&result=${Uri.encodeComponent(result)}' : '';
      Application.router
          .navigateTo(context, route, transition: transitionType)
          .then((value) {
        if (!context.mounted) {
          return;
        }
        if (key == 'pop-result') {
          Application.router.navigateTo(
            context,
            '${Routes.dialogDemo}?message=${Uri.encodeComponent(value)}',
          );
        }
      });
    } else if (key == 'custom') {
      hexCode = '#DFF700';
      message = '自定义过渡';
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
        '${Routes.transitionDetail}?message=${Uri.encodeComponent(message)}&color_hex=$hexCode',
        transition: TransitionType.custom,
        transitionBuilder: transition,
        transitionDuration: const Duration(milliseconds: 600),
      );
    } else if (key == 'fixed-trans') {
      hexCode = '#f4424b';
      message = '在注册路由的时候就已经定义好了动画';
      Application.router.navigateTo(
        context,
        '${Routes.fixedTransitionDetail}?message=${Uri.encodeComponent(message)}&color_hex=$hexCode',
      );
    } else if (key == 'function-call') {
      message = '功能按钮！';
      Application.router.navigateTo(
        context,
        '${Routes.dialogDemo}?message=${Uri.encodeComponent(message)}',
      );
    } else if (key == 'todolist') {
      message = 'todolist';
      Application.router.navigateTo(
        context,
        '${Routes.todolist}?message=${Uri.encodeComponent(message)}',
        transition: TransitionType.inFromRight,
      );
    } else {
      message = '未知类型按钮';
      Application.router.navigateTo(
        context,
        '${Routes.transitionDetail}?message=${Uri.encodeComponent(message)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <FluroGroup>[
      const FluroGroup(
        title: '基础过渡',
        subtitle: '默认动画和内置切换类型',
        items: [
          FluroActionItem(
            title: '系统默认动画',
            detail: '系统导航动画',
            keyValue: 'native',
          ),
          FluroActionItem(
            title: '从左侧过渡滑入',
            detail: 'TransitionType.inFromLeft',
            keyValue: 'preset-from-left',
          ),
          FluroActionItem(
            title: '淡入淡出',
            detail: 'TransitionType.fadeIn',
            keyValue: 'preset-fade',
          ),
        ],
      ),
      const FluroGroup(
        title: '扩展能力',
        subtitle: '路由预设、回调、结果监听',
        items: [
          FluroActionItem(
            title: '注册时定义动画',
            detail: 'fixed transition route',
            keyValue: 'fixed-trans',
          ),
          FluroActionItem(
            title: '自定义动画',
            detail: 'scale + rotation',
            keyValue: 'custom',
          ),
          FluroActionItem(
            title: '监听返回事件',
            detail: 'pop result',
            keyValue: 'pop-result',
          ),
          FluroActionItem(
            title: '函数回调',
            detail: 'function-call route',
            keyValue: 'function-call',
          ),
        ],
      ),
    ];

    return SafeArea(
      top: false,
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          const FluroHeroCard(
            title: 'Fluro Router',
            description: '保留原来的所有跳转逻辑，只把入口改成更适合扫读的分组列表。',
          ),
          const SizedBox(height: 14),
          ...groups.map(
            (group) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xAAFFFFFF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x12FFFFFF)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.title,
                        style: const TextStyle(
                          color: Color(0xFF1F2329),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.subtitle,
                        style: const TextStyle(
                          color: Color(0xFF838C9B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...group.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: ActionTile(
                            title: item.title,
                            detail: item.detail,
                            onTap: () => _tappedMenuButton(
                              context,
                              key: item.keyValue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
