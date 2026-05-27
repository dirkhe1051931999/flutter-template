import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/article/article_quick_login_sheet.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';

Future<void> showArticleCommentInputSheet(BuildContext context) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetContext) {
      return const _ArticleCommentInputSheet();
    },
  );
}

class _ArticleCommentInputSheet extends StatefulWidget {
  const _ArticleCommentInputSheet();

  @override
  State<_ArticleCommentInputSheet> createState() =>
      _ArticleCommentInputSheetState();
}

class _ArticleCommentInputSheetState extends State<_ArticleCommentInputSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isHandlingSubmit = false;

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit || _isHandlingSubmit) {
      return;
    }
    setState(() {
      _isHandlingSubmit = true;
    });
    try {
      final session = await IfengAuthStorage.loadSession();
      if (!mounted) {
        return;
      }
      if (!session.isLoggedIn) {
        final didLogin = await showArticleQuickLoginSheet(context);
        if (!mounted) {
          return;
        }
        if (didLogin) {
          EasyLoading.showToast('登录成功，请再次点击确定发表评论');
        }
        return;
      }
      EasyLoading.showToast('评论发送功能开发中');
    } finally {
      if (mounted) {
        setState(() {
          _isHandlingSubmit = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: viewInsetsBottom),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 14, 16, safeBottom > 0 ? safeBottom : 12),
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 104),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: CupertinoTextField.borderless(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: 5,
                        minLines: 4,
                        placeholder: '友善评论，说点好听的～',
                        style: const TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontSize: 16,
                          height: 1.4,
                        ),
                        placeholderStyle: const TextStyle(
                          color: Color(0xFFAEAEB2),
                          fontSize: 16,
                        ),
                        padding: EdgeInsets.zero,
                        decoration: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(52, 40),
                    onPressed: _canSubmit ? _handleSubmit : null,
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: _canSubmit
                            ? CupertinoColors.activeBlue
                            : const Color(0xFFC7C7CC),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  _ToolbarIcon(assetName: 'camera-outline', fallbackIcon: CupertinoIcons.camera),
                  SizedBox(width: 22),
                  _ToolbarIcon(assetName: 'image-outline', fallbackIcon: CupertinoIcons.photo),
                  SizedBox(width: 22),
                  _ToolbarIcon(assetName: 'happy-outline', fallbackIcon: CupertinoIcons.smiley),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  const _ToolbarIcon({
    required this.assetName,
    required this.fallbackIcon,
  });

  final String assetName;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return AppAssetIcon(
      assetName: assetName,
      size: 24,
      color: const Color(0xFF6B7280),
      fallbackIcon: fallbackIcon,
    );
  }
}
