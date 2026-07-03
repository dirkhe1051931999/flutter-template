import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/short_video/short_video_player_wrapper.dart';
import 'package:oolaf_flutted/utils/oolaf_video_player_controller.dart';

class ClientPostVideoPreviewPage extends StatefulWidget {
  const ClientPostVideoPreviewPage({super.key, required this.path});

  final String path;

  @override
  State<ClientPostVideoPreviewPage> createState() =>
      _ClientPostVideoPreviewPageState();
}

class _ClientPostVideoPreviewPageState
    extends State<ClientPostVideoPreviewPage> {
  OolafVideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final controller = await OolafVideoPlayerController.fromUrl(widget.path);
    await controller.initialize();
    await controller.play();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    if (controller.isPlaying.value) {
      await controller.pause();
      return;
    }
    await controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: ShortVideoPlayerWrapper(
              controller: _controller,
              fit: BoxFit.cover,
              enableVerticalSwipeGestures: false,
              enableDoubleTapLikeBurst: false,
              onSingleTap: _togglePlay,
              onLongPress: () {},
              onDoubleTap: () {},
              onSwipeUp: () {},
              onSwipeDown: () {},
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(36, 36),
                color: const Color(0x66000000),
                borderRadius: BorderRadius.circular(18),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(CupertinoIcons.clear,
                    color: CupertinoColors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
