import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/utils/short_video_blocked_persistence.dart';

class ShortVideoBlockedManagePage extends StatefulWidget {
  const ShortVideoBlockedManagePage({super.key});

  @override
  State<ShortVideoBlockedManagePage> createState() =>
      _ShortVideoBlockedManagePageState();
}

class _ShortVideoBlockedManagePageState
    extends State<ShortVideoBlockedManagePage> {
  ShortVideoBlockedSnapshot _snapshot = const ShortVideoBlockedSnapshot(
    videoIds: <String>{},
    sources: <String>{},
    titleKeywords: <String>{},
  );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await ShortVideoBlockedPersistence.loadSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = snapshot;
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    await ShortVideoBlockedPersistence.clearAll();
    await _loadSnapshot();
  }

  Future<void> _removeVideo(String id) async {
    await ShortVideoBlockedPersistence.removeVideo(id);
    await _loadSnapshot();
  }

  Future<void> _removeSource(String source) async {
    await ShortVideoBlockedPersistence.removeSource(source);
    await _loadSnapshot();
  }

  Future<void> _removeTitleKeyword(String keyword) async {
    await ShortVideoBlockedPersistence.removeTitleKeyword(keyword);
    await _loadSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('屏蔽管理'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _snapshot.isEmpty ? null : _clearAll,
          child: Text(
            '清空',
            style: TextStyle(
              color: _snapshot.isEmpty
                  ? CupertinoColors.inactiveGray
                  : CupertinoColors.systemRed,
              fontSize: 14,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _snapshot.isEmpty
                ? const Center(
                    child: Text(
                      '暂无屏蔽内容',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  )
                : ListView(
                    children: [
                      _BlockedSection(
                        title: '不看此视频',
                        values: _snapshot.videoIds,
                        emptyText: '暂无视频屏蔽',
                        onRemove: _removeVideo,
                      ),
                      _BlockedSection(
                        title: '不看该来源',
                        values: _snapshot.sources,
                        emptyText: '暂无来源屏蔽',
                        onRemove: _removeSource,
                      ),
                      _BlockedSection(
                        title: '屏蔽标题词',
                        values: _snapshot.titleKeywords,
                        emptyText: '暂无标题词屏蔽',
                        onRemove: _removeTitleKeyword,
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _BlockedSection extends StatelessWidget {
  const _BlockedSection({
    required this.title,
    required this.values,
    required this.emptyText,
    required this.onRemove,
  });

  final String title;
  final Set<String> values;
  final String emptyText;
  final Future<void> Function(String value) onRemove;

  @override
  Widget build(BuildContext context) {
    final sortedValues = values.toList(growable: false)..sort();

    return CupertinoListSection.insetGrouped(
      header: Text(title),
      children: [
        if (sortedValues.isEmpty)
          CupertinoListTile(
            title: Text(
              emptyText,
              style: const TextStyle(color: Color(0xFF8E8E93)),
            ),
          )
        else
          for (final value in sortedValues)
            CupertinoListTile(
              title: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  onRemove(value);
                },
                child: const AppAssetIcon(
                  assetName: 'close-circle',
                  color: CupertinoColors.systemRed,
                  size: 22,
                  fallbackIcon: CupertinoIcons.xmark_circle_fill,
                ),
              ),
            ),
      ],
    );
  }
}
