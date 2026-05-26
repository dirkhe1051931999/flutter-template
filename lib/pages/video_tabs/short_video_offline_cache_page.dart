import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_asset_icon/index.dart';
import 'package:oolaf_flutted/utils/short_video_offline_cache_persistence.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoOfflineCachePage extends StatefulWidget {
  const ShortVideoOfflineCachePage({super.key});

  @override
  State<ShortVideoOfflineCachePage> createState() => _ShortVideoOfflineCachePageState();
}

class _ShortVideoOfflineCachePageState extends State<ShortVideoOfflineCachePage> {
  bool _isLoading = true;
  List<ShortVideoOfflineCacheEntry> _entries =
      const <ShortVideoOfflineCacheEntry>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await ShortVideoOfflineCachePersistence.loadAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  Future<void> _clearAll() async {
    await ShortVideoOfflineCachePersistence.clearAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = const <ShortVideoOfflineCacheEntry>[];
    });
  }

  Future<void> _removeSingle(String videoId) async {
    await ShortVideoOfflineCachePersistence.remove(videoId);
    if (!mounted) {
      return;
    }
    await _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      navigationBar: CupertinoNavigationBar(
        middle: const Text('离线缓存'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          onPressed: _entries.isEmpty ? null : _clearAll,
          child: Text(
            '清空',
            style: TextStyle(
              color: _entries.isEmpty
                  ? CupertinoColors.inactiveGray
                  : CupertinoColors.systemBlue,
              fontSize: 14,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _entries.isEmpty
                ? const Center(
                    child: Text(
                      '暂无离线缓存任务',
                      style: TextStyle(color: Color(0xFF8E8E93)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CustomNetworkImage(
                                  entry.coverUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: ColoredBox(color: Color(0xFFE5E5EA)),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF1C1C1E),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      entry.source ?? '短视频',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                onPressed: () {
                                  _removeSingle(entry.videoId);
                                },
                                child: const AppAssetIcon(
                                  assetName: 'trash',
                                  color: CupertinoColors.systemRed,
                                  fallbackIcon: CupertinoIcons.delete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
