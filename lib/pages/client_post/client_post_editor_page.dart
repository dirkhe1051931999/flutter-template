import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oolaf_flutted/api/aphelios_client/post.dart';
import 'package:oolaf_flutted/components/app_dialog/index.dart';
import 'package:oolaf_flutted/components/app_field/index.dart';
import 'package:oolaf_flutted/components/app_sheet/index.dart';
import 'package:oolaf_flutted/components/app_toast/index.dart';
import 'package:oolaf_flutted/components/gallery_preview/index.dart';
import 'package:oolaf_flutted/pages/client_post/client_post_api_key_gate.dart';
import 'package:oolaf_flutted/pages/client_post/client_post_draft_storage.dart';
import 'package:oolaf_flutted/pages/client_post/client_post_video_preview_page.dart';
import 'package:oolaf_flutted/pages/client_post/widgets/client_post_link_card.dart';
import 'package:oolaf_flutted/pages/client_post/widgets/client_post_media_grid.dart';
import 'package:oolaf_flutted/pages/client_post/widgets/client_post_option_tile.dart';

class ClientPostEditorPage extends StatefulWidget {
  const ClientPostEditorPage({super.key});

  @override
  State<ClientPostEditorPage> createState() => _ClientPostEditorPageState();
}

class _ClientPostEditorPageState extends State<ClientPostEditorPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _restrictedController = TextEditingController();
  final TextEditingController _linkTitleController = TextEditingController();
  final TextEditingController _linkUrlController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> _imagePaths = <String>[];
  String _visibility = 'public';
  String? _videoPath;
  String _clientApiKey = '';
  bool _checkingApiKey = true;
  bool _submitting = false;

  bool get _hasContent =>
      _textController.text.trim().isNotEmpty ||
      _imagePaths.isNotEmpty ||
      _videoPath != null ||
      _linkUrlController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refreshSubmitState);
    _linkUrlController.addListener(_refreshSubmitState);
    _ensureApiKeyAndLoadDraft();
  }

  @override
  void dispose() {
    _textController.removeListener(_refreshSubmitState);
    _linkUrlController.removeListener(_refreshSubmitState);
    _textController.dispose();
    _restrictedController.dispose();
    _linkTitleController.dispose();
    _linkUrlController.dispose();
    super.dispose();
  }

  void _refreshSubmitState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadDraft() async {
    final draft = await ClientPostDraftStorage.load();
    if (!mounted || draft == null) {
      return;
    }
    setState(() {
      _textController.text = draft.text;
      _restrictedController.text = draft.restrictedOptions;
      _linkTitleController.text = draft.linkTitle;
      _linkUrlController.text = draft.linkUrl;
      _visibility = draft.visibility;
      _videoPath = draft.videoPath;
      _imagePaths
        ..clear()
        ..addAll(draft.imagePaths.take(9));
    });
  }

  Future<void> _ensureApiKeyAndLoadDraft() async {
    final apiKey = await requireClientPostApiKey(context);
    if (!mounted) {
      return;
    }
    if (apiKey == null || apiKey.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      _clientApiKey = apiKey;
      _checkingApiKey = false;
    });
    await _loadDraft();
  }

  ClientPostDraft _toDraft() {
    return ClientPostDraft(
      text: _textController.text,
      imagePaths: List<String>.from(_imagePaths),
      videoPath: _videoPath,
      visibility: _visibility,
      restrictedOptions: _restrictedController.text,
      linkTitle: _linkTitleController.text,
      linkUrl: _linkUrlController.text,
    );
  }

  Future<void> _handleCancel() async {
    if (!_hasContent) {
      _goHome();
      return;
    }
    final shouldSave = await showAppDialog(
      context: context,
      title: '保存草稿？',
      message: '下次进入新增动态时，可继续编辑最近一次保存的内容。',
      confirmButtonText: '保存',
      cancelButtonText: '不保存',
      showCancelButton: true,
      confirmButtonColor: const Color(0xFF07C160),
    );
    if (shouldSave == true) {
      await ClientPostDraftStorage.save(_toDraft());
      _goHome();
      return;
    }
    if (shouldSave == false) {
      await ClientPostDraftStorage.clear();
      _goHome();
    }
  }

  void _goHome() {
    if (!mounted) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _showMediaSheet() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImages();
            },
            child: const Text('选择图片'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _pickVideo();
            },
            child: const Text('选择视频'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消')),
      ),
    );
  }

  Future<void> _pickImages() async {
    if (_videoPath != null) {
      AppToast.showFail('图片和视频不能同时发布');
      return;
    }
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'gif'],
      );
      _appendImages(result?.paths.whereType<String>().toList() ?? <String>[]);
      return;
    }
    final picked = await _imagePicker.pickMultiImage(imageQuality: 92);
    _appendImages(picked.map((item) => item.path).toList());
  }

  Future<void> _pickVideo() async {
    if (_imagePaths.isNotEmpty) {
      AppToast.showFail('图片和视频不能同时发布');
      return;
    }
    final result = await FilePicker.pickFiles(
        type: FileType.custom, allowedExtensions: const ['mp4', 'webm', 'mov']);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _videoPath = path);
    }
  }

  void _appendImages(List<String> paths) {
    if (paths.isEmpty) {
      return;
    }
    final next = <String>{..._imagePaths, ...paths}.take(9).toList();
    setState(() {
      _imagePaths
        ..clear()
        ..addAll(next);
    });
    if (next.length == 9) {
      AppToast.showText('图片最多 9 张');
    }
  }

  void _previewImage(String path) {
    openGalleryPreview(context, imageUrls: _imagePaths, initialImageUrl: path);
  }

  Future<void> _previewVideo(String path) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      CupertinoPageRoute<void>(
          builder: (_) => ClientPostVideoPreviewPage(path: path)),
    );
  }

  void _reorderImage(int fromIndex, int toIndex) {
    setState(() {
      final item = _imagePaths.removeAt(fromIndex);
      _imagePaths.insert(toIndex, item);
    });
  }

  void _moveImage(int fromIndex, int direction) {
    final toIndex = fromIndex + direction;
    if (toIndex < 0 || toIndex >= _imagePaths.length) {
      return;
    }
    _reorderImage(fromIndex, toIndex);
  }

  Future<void> _chooseVisibility() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('谁可以看'),
        actions: [
          CupertinoActionSheetAction(
              onPressed: () => _setVisibility(context, 'public'),
              child: const Text('公开')),
          CupertinoActionSheetAction(
              onPressed: () => _setVisibility(context, 'restricted'),
              child: const Text('受限')),
        ],
        cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消')),
      ),
    );
  }

  void _setVisibility(BuildContext context, String visibility) {
    Navigator.of(context).pop();
    setState(() => _visibility = visibility);
  }

  Future<void> _editLink() async {
    var title = _linkTitleController.text;
    var url = _linkUrlController.text;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.72,
      edgeToEdge: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('添加链接',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            AppField(
                label: '标题',
                value: title,
                placeholder: '外链标题',
                clearable: true,
                onChanged: (value) => setSheetState(() => title = value)),
            const SizedBox(height: 10),
            AppField(
                label: '链接',
                value: url,
                placeholder: 'https://example.com',
                clearable: true,
                onChanged: (value) => setSheetState(() => url = value)),
            const SizedBox(height: 18),
            CupertinoButton.filled(
              onPressed: () {
                setState(() {
                  _linkTitleController.text = title.trim();
                  _linkUrlController.text = url.trim();
                });
                Navigator.of(sheetContext).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editRestrictedOptions() async {
    var options = _restrictedController.text;
    await showAppSheet<void>(
      context: context,
      maxHeightFactor: 0.55,
      edgeToEdge: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('客户端选项',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            AppField(
              label: '选项',
              value: options,
              placeholder: '多个用英文逗号分隔，如 read-private',
              clearable: true,
              onChanged: (value) => setSheetState(() => options = value),
            ),
            const SizedBox(height: 18),
            CupertinoButton.filled(
              onPressed: () {
                setState(() => _restrictedController.text = options.trim());
                Navigator.of(sheetContext).pop();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearLink() {
    setState(() {
      _linkTitleController.clear();
      _linkUrlController.clear();
    });
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final text = _textController.text.trim();
    final linkTitle = _linkTitleController.text.trim();
    final linkUrl = _linkUrlController.text.trim();
    if (linkTitle.isNotEmpty != linkUrl.isNotEmpty) {
      AppToast.showFail('外链标题和地址必须同时填写');
      return;
    }
    final restrictedOptions = _restrictedController.text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (_visibility == 'restricted' && restrictedOptions.isEmpty) {
      AppToast.showFail('受限可见必须填写客户端选项');
      return;
    }
    if (!_hasContent) {
      AppToast.showFail('动态内容不能为空');
      return;
    }

    setState(() => _submitting = true);
    AppToast.showLoading('发表中...');
    try {
      final imageMediaIds = <String>[];
      for (final path in _imagePaths) {
        imageMediaIds
            .add((await uploadClientPostMedia(path, _clientApiKey)).id);
      }
      final videoMediaId = _videoPath == null
          ? null
          : (await uploadClientPostMedia(_videoPath!, _clientApiKey)).id;
      await createClientPost(
        ClientPostPayload(
          text: text,
          visibility: _visibility,
          restrictedOptions:
              _visibility == 'restricted' ? restrictedOptions : null,
          imageMediaIds: imageMediaIds,
          videoMediaId: videoMediaId,
          linkTitle: linkTitle.isEmpty ? null : linkTitle,
          linkUrl: linkUrl.isEmpty ? null : linkUrl,
        ),
        _clientApiKey,
      );
      await ClientPostDraftStorage.clear();
      if (!mounted) {
        return;
      }
      AppToast.showSuccess('发表成功');
      await Future<void>.delayed(const Duration(milliseconds: 650));
      _goHome();
    } on DioException catch (error) {
      AppToast.showFail(_resolveErrorMessage(error.response?.data) ??
          error.message ??
          '发布失败');
    } catch (error) {
      AppToast.showFail(error.toString());
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String? _resolveErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasLink = _linkUrlController.text.trim().isNotEmpty;
    final optionsValue =
        _restrictedController.text.trim().isEmpty ? '未选择' : '已选择';
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: const Border(
            bottom: BorderSide(color: Color(0xFFEAEAEA), width: 0.5)),
        middle: const Text('发表文字'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _handleCancel,
          child: const Text('取消', style: TextStyle(color: Color(0xFF1F1F1F))),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed:
              _hasContent && !_submitting && !_checkingApiKey ? _submit : null,
          child: Text(
            _submitting ? '发表中' : '发表',
            style: TextStyle(
                color: _hasContent && !_submitting
                    ? const Color(0xFF07C160)
                    : const Color(0xFFBDBDBD),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            CupertinoTextField.borderless(
              controller: _textController,
              minLines: 6,
              maxLines: 10,
              maxLength: 5000,
              placeholder: '这一刻的想法...',
              placeholderStyle:
                  const TextStyle(color: Color(0xFFB7B7B7), fontSize: 19),
              style: const TextStyle(
                  color: Color(0xFF1F1F1F), fontSize: 19, height: 1.35),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 18),
            ClientPostMediaGrid(
              imagePaths: _imagePaths,
              videoPath: _videoPath,
              onAdd: _showMediaSheet,
              onPreviewImage: _previewImage,
              onPreviewVideo: _previewVideo,
              onReorderImage: _reorderImage,
              onMoveImage: _moveImage,
              onRemoveImage: (path) => setState(() => _imagePaths.remove(path)),
              onRemoveVideo: () => setState(() => _videoPath = null),
            ),
            if (hasLink)
              ClientPostLinkCard(
                  title: _linkTitleController.text.trim(),
                  url: _linkUrlController.text.trim(),
                  onRemove: _clearLink),
            const SizedBox(height: 24),
            ClientPostOptionTile(
                icon: CupertinoIcons.eye,
                title: '谁可以看',
                value: _visibility == 'public' ? '公开' : '受限',
                onTap: _chooseVisibility),
            ClientPostOptionTile(
                icon: CupertinoIcons.link,
                title: '外链',
                value: hasLink ? '已添加' : '未添加',
                onTap: _editLink),
            if (_visibility == 'restricted')
              ClientPostOptionTile(
                  icon: CupertinoIcons.lock,
                  title: '客户端选项',
                  value: optionsValue,
                  onTap: _editRestrictedOptions),
          ],
        ),
      ),
    );
  }
}
