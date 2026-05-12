import 'package:flutter/cupertino.dart';
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

  @override
  void initState() {
    super.initState();
    _player = Player();
    _videoController = VideoController(_player);

    _player.open(
      Media(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
      ),
      play: true,
    );
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
            ),
          ],
        ),
      ),
    );
  }
}
