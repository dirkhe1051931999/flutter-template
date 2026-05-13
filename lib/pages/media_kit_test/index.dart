import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class MediaKitTestPage extends StatefulWidget {
  const MediaKitTestPage({super.key});

  @override
  State<MediaKitTestPage> createState() => _MediaKitTestPageState();
}

class _MediaKitTestPageState extends State<MediaKitTestPage> {
  late final Player _player;
  late final VideoController _videoController;

  static VideoControllerConfiguration _createVideoConfiguration() {
    if (kIsWeb) {
      return const VideoControllerConfiguration();
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return const VideoControllerConfiguration(
        vo: 'gpu',
        hwdec: 'no',
        enableHardwareAcceleration: false,
        androidAttachSurfaceAfterVideoParameters: false,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.windows) {
      return const VideoControllerConfiguration(
        vo: 'libmpv',
        hwdec: 'no',
        enableHardwareAcceleration: false,
      );
    }

    return const VideoControllerConfiguration(
      vo: 'gpu',
      hwdec: 'auto-safe',
      enableHardwareAcceleration: true,
    );
  }

  String get _diagnostics {
    final width = _player.state.width;
    final height = _player.state.height;
    final params = _player.state.videoParams;
    final textureId = _videoController.id.value;
    return 'texture=$textureId  state=${width ?? 0}x${height ?? 0}  params=${params.w ?? 0}x${params.h ?? 0}';
  }

  @override
  void initState() {
    super.initState();
    final configuration = _createVideoConfiguration();
    _player = Player(
      configuration: PlayerConfiguration(
        vo: configuration.vo,
      ),
    );
    _videoController = VideoController(
      _player,
      configuration: configuration,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _player.open(
        Media(
          'https://video19.ifeng.com/video09/2026/05/05/p7457248973636510504-102-101716.mp4',
        ),
        play: true,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Media Kit Test'),
      ),
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: CupertinoColors.black),
            Video(
              controller: _videoController,
              fit: BoxFit.contain,
              controls: (state) => const SizedBox.shrink(),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0x99000000),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ValueListenableBuilder<int?>(
                    valueListenable: _videoController.id,
                    builder: (context, _, __) {
                      return Text(
                        _diagnostics,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
