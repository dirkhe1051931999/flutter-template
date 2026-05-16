import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oolaf_flutted/pages/video_tabs/index.dart';

class ShortVideoChannelManagePage extends StatefulWidget {
  const ShortVideoChannelManagePage({
    super.key,
    required this.initialOrderIds,
  });

  final List<String> initialOrderIds;

  @override
  State<ShortVideoChannelManagePage> createState() =>
      _ShortVideoChannelManagePageState();
}

class _ShortVideoChannelManagePageState extends State<ShortVideoChannelManagePage> {
  late List<VideoTabChannelMeta> _channels;

  @override
  void initState() {
    super.initState();
    _channels = VideoTabsRegistry.resolveChannelOrder(widget.initialOrderIds);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    if (oldIndex == newIndex ||
        oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= _channels.length ||
        newIndex >= _channels.length) {
      return;
    }

    setState(() {
      final item = _channels.removeAt(oldIndex);
      _channels.insert(newIndex, item);
    });
  }

  void _finish() {
    final ids = _channels.map((e) => e.id).toList(growable: false);
    Navigator.of(context).pop(ids);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('频道管理'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _finish,
          child: const Text('完成'),
        ),
      ),
      child: SafeArea(
        child: ReorderableListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
          itemCount: _channels.length,
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Material(
                  color: Colors.transparent,
                  child: Transform.scale(
                    scale: Tween<double>(begin: 1, end: 1.02).evaluate(animation),
                    child: child,
                  ),
                );
              },
            );
          },
          itemBuilder: (context, index) {
            final channel = _channels[index];
            return Container(
              key: ValueKey(channel.id),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                title: Text(
                  channel.label,
                  style: const TextStyle(
                    color: Color(0xFF1C1C1E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  '长按右侧拖动排序',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 12,
                  ),
                ),
                trailing: ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    CupertinoIcons.line_horizontal_3,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
