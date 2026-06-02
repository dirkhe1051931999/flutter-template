import 'package:flutter/cupertino.dart';

Future<bool?> showAppDialog({
  required BuildContext context,
  String? title,
  String? message,
  String confirmButtonText = '确认',
  String cancelButtonText = '取消',
  bool showCancelButton = false,
  bool barrierDismissible = true,
  bool closeOnPop = true,
  Color confirmButtonColor = const Color(0xFF2563EB),
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'dialog',
    barrierColor: const Color(0x33000000),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, __) {
      return _AppDialogPanel(
        title: title,
        message: message,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        showCancelButton: showCancelButton,
        closeOnPop: closeOnPop,
        confirmButtonColor: confirmButtonColor,
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

class _AppDialogPanel extends StatelessWidget {
  const _AppDialogPanel({
    required this.title,
    required this.message,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.showCancelButton,
    required this.closeOnPop,
    required this.confirmButtonColor,
  });

  final String? title;
  final String? message;
  final String confirmButtonText;
  final String cancelButtonText;
  final bool showCancelButton;
  final bool closeOnPop;
  final Color confirmButtonColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFDFDFE),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 30,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title?.isNotEmpty ?? false)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (message?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (showCancelButton)
                      Expanded(
                        child: CupertinoButton(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          borderRadius: BorderRadius.circular(18),
                          color: const Color(0xFFF2F4F7),
                          onPressed: () {
                            if (closeOnPop) {
                              Navigator.of(context).pop(false);
                            }
                          },
                          child: Text(
                            cancelButtonText,
                            style: const TextStyle(
                              color: Color(0xFF202127),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    if (showCancelButton) const SizedBox(width: 10),
                    Expanded(
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        borderRadius: BorderRadius.circular(18),
                        color: confirmButtonColor,
                        onPressed: () {
                          if (closeOnPop) {
                            Navigator.of(context).pop(true);
                          }
                        },
                        child: Text(
                          confirmButtonText,
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
