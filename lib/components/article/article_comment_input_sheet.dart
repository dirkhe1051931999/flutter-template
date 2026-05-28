import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oolaf_flutted/api/short_video/comment.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/components/article/article_quick_login_sheet.dart';
import 'package:oolaf_flutted/utils/helper.dart';
import 'package:oolaf_flutted/utils/ifeng_auth_storage.dart';

class CommentSubmissionResult {
  const CommentSubmissionResult({
    required this.comment,
    this.parentCommentId,
  });

  final ShortVideoCommentItem comment;
  final String? parentCommentId;
}

Future<CommentSubmissionResult?> showArticleCommentInputSheet(
  BuildContext context, {
  required ShortVideoCommentSubmitRequest request,
}) async {
  final result = await showCupertinoModalPopup<CommentSubmissionResult>(
    context: context,
    builder: (sheetContext) {
      return _ArticleCommentInputSheet(
        request: request,
      );
    },
  );
  return result;
}

class _ArticleCommentInputSheet extends StatefulWidget {
  const _ArticleCommentInputSheet({
    required this.request,
  });

  final ShortVideoCommentSubmitRequest request;

  @override
  State<_ArticleCommentInputSheet> createState() =>
      _ArticleCommentInputSheetState();
}

class _ArticleCommentInputSheetState extends State<_ArticleCommentInputSheet> {
  static const double _selectedImageSize = 70;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isHandlingSubmit = false;
  _SelectedCommentImage? _selectedImage;

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

  Future<void> _pickImage() async {
    if (_isHandlingSubmit) {
      return;
    }
    try {
      final selectedImage = await _selectCommentImage();
      if (selectedImage == null || !mounted) {
        return;
      }
      setState(() {
        _selectedImage = selectedImage;
      });
    } catch (error, stackTrace) {
      customLogger.log('pick comment image failed: $error');
      customLogger.log(stackTrace);
      if (mounted) {
        EasyLoading.showToast('选择图片失败');
      }
    }
  }

  Future<_SelectedCommentImage?> _selectCommentImage() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const <String>[
          'jpg',
          'jpeg',
          'png',
          'webp',
          'gif',
          'bmp',
        ],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return null;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }
      return _SelectedCommentImage(
        fileName: file.name,
        bytes: bytes,
      );
    }

    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return null;
    }
    final bytes = await picked.readAsBytes();
    return _SelectedCommentImage(
      fileName: picked.name,
      bytes: bytes,
    );
  }

  void _removeSelectedImage() {
    if (_selectedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = null;
    });
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
      EasyLoading.show(status: '正在发送评论...');
      final result = await submitShortVideoComment(
        request: widget.request.copyWith(
          content: _controller.text.trim(),
          imageUpload: _selectedImage == null
              ? null
              : ShortVideoCommentImageUploadPayload(
                  fileName: _selectedImage!.fileName,
                  bytes: _selectedImage!.bytes,
                ),
        ),
      );
      EasyLoading.dismiss();
      if (!mounted) {
        return;
      }
      EasyLoading.showToast(result.message);
      if (result.isSuccess) {
        Navigator.of(context).pop(
          CommentSubmissionResult(
            comment: ShortVideoCommentItem(
              commentId: 'local_${DateTime.now().millisecondsSinceEpoch}',
              docUrl: widget.request.docUrl?.trim().isNotEmpty == true
                  ? widget.request.docUrl!.trim()
                  : widget.request.docId.trim(),
              contentType: widget.request.docType.apiValue,
              user: ShortVideoCommentUser(
                id: session.guid.trim().isNotEmpty
                    ? session.guid.trim()
                    : session.username.trim(),
                name: session.nickname.trim().isNotEmpty
                    ? session.nickname.trim()
                    : session.username.trim(),
                avatarUrl: session.userImage.trim(),
                isAnonymous: false,
              ),
              content: _controller.text.trim(),
              replyToUserId: widget.request.replyToComment?.user.id,
              replyToUserName: widget.request.replyToComment?.user.name,
              publishTimeText: '已发送',
              likeCount: 0,
              replyCount: 0,
              children: const <ShortVideoCommentItem>[],
              imageUrls: const <String>[],
              localImageBytes: _selectedImage?.bytes,
              childrenPage: 0,
              canLoadMoreChildren: false,
            ),
            parentCommentId: widget.request.replyToComment?.commentId,
          ),
        );
      }
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
                        maxLines: _selectedImage == null ? 5 : 3,
                        minLines: _selectedImage == null ? 4 : 2,
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
                  if (_selectedImage != null) ...[
                    const SizedBox(width: 12),
                    _SelectedCommentImagePreview(
                      image: _selectedImage!,
                      onRemove: _removeSelectedImage,
                    ),
                  ],
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
              Row(
                children: [
                  const _ToolbarIcon(assetName: 'camera-outline', fallbackIcon: CupertinoIcons.camera),
                  const SizedBox(width: 22),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pickImage,
                    child: const _ToolbarIcon(
                      assetName: 'image-outline',
                      fallbackIcon: CupertinoIcons.photo,
                    ),
                  ),
                  const SizedBox(width: 22),
                  const _ToolbarIcon(assetName: 'happy-outline', fallbackIcon: CupertinoIcons.smiley),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on ShortVideoCommentSubmitRequest {
  ShortVideoCommentSubmitRequest copyWith({
    String? content,
    ShortVideoCommentImageUploadPayload? imageUpload,
  }) {
    return ShortVideoCommentSubmitRequest(
      docId: docId,
      docName: docName,
      content: content ?? this.content,
      docType: docType,
      docUrl: docUrl,
      docThumbnail: docThumbnail,
      subId: subId,
      subName: subName,
      subType: subType,
      nickname: nickname,
      userImageUrl: userImageUrl,
      from: from,
      isTrends: isTrends,
      location: location,
      latitude: latitude,
      longitude: longitude,
      imageUpload: imageUpload,
      replyToComment: replyToComment,
    );
  }
}

class _SelectedCommentImage {
  const _SelectedCommentImage({
    required this.fileName,
    required this.bytes,
  });

  final String fileName;
  final Uint8List bytes;
}

class _SelectedCommentImagePreview extends StatelessWidget {
  const _SelectedCommentImagePreview({
    required this.image,
    required this.onRemove,
  });

  final _SelectedCommentImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _ArticleCommentInputSheetState._selectedImageSize,
      height: _ArticleCommentInputSheetState._selectedImageSize,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              image.bytes,
              width: _ArticleCommentInputSheetState._selectedImageSize,
              height: _ArticleCommentInputSheetState._selectedImageSize,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -4,
            top: -4,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(24, 24),
              onPressed: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
        ],
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
