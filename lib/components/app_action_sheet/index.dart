import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';

class AppActionSheetAction {
  const AppActionSheetAction({
    required this.name,
    this.subname,
    this.color,
    this.disabled = false,
    this.loading = false,
  });

  final String name;
  final String? subname;
  final Color? color;
  final bool disabled;
  final bool loading;
}

Future<int?> showAppActionSheet({
  required BuildContext context,
  required List<AppActionSheetAction> actions,
  String? title,
  String? description,
  String cancelText = '取消',
  bool closeOnClickAction = true,
  bool showCancel = true,
}) {
  return showAppSheet<int>(
    context: context,
    enableBlur: true,
    backgroundColor: const Color(0xFFF8FAFD),
    builder: (_) {
      return _AppActionSheetContent(
        title: title,
        description: description,
        actions: actions,
        cancelText: cancelText,
        closeOnClickAction: closeOnClickAction,
        showCancel: showCancel,
      );
    },
  );
}

class _AppActionSheetContent extends StatelessWidget {
  const _AppActionSheetContent({
    required this.title,
    required this.description,
    required this.actions,
    required this.cancelText,
    required this.closeOnClickAction,
    required this.showCancel,
  });

  final String? title;
  final String? description;
  final List<AppActionSheetAction> actions;
  final String cancelText;
  final bool closeOnClickAction;
  final bool showCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if ((title?.isNotEmpty ?? false) || (description?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                if (title?.isNotEmpty ?? false)
                  Text(
                    title!,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (description?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 6),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF8F96A3),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ...List<Widget>.generate(actions.length, (index) {
          final action = actions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index == actions.length - 1 ? 0 : 10),
            child: _ActionTile(
              action: action,
              onTap: action.disabled || action.loading
                  ? null
                  : () {
                      if (closeOnClickAction) {
                        Navigator.of(context).pop(index);
                      }
                    },
            ),
          );
        }),
        if (showCancel) ...[
          const SizedBox(height: 14),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFFFFFFF),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              cancelText,
              style: const TextStyle(
                color: Color(0xFF202127),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    required this.onTap,
  });

  final AppActionSheetAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Opacity(
        opacity: action.disabled ? 0.45 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xCCFFFFFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x12000000)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        action.name,
                        style: TextStyle(
                          color: action.color ?? const Color(0xFF202127),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (action.subname?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          action.subname!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF8F96A3),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action.loading)
                  const CupertinoActivityIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
