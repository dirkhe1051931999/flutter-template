import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/hupu/index.dart';
import 'package:oolaf_flutted/model/hupu/index.dart';
import 'package:oolaf_flutted/pages/hupu/hupu_post_detail_page.dart';

class HupuNbaHotNewsPage extends StatefulWidget {
  const HupuNbaHotNewsPage({super.key});

  @override
  State<HupuNbaHotNewsPage> createState() => _HupuNbaHotNewsPageState();
}

class _HupuNbaHotNewsPageState extends State<HupuNbaHotNewsPage> {
  late final Future<HupuNbaHotNewsData> _future;

  @override
  void initState() {
    super.initState();
    _future = getHupuNbaHotNews();
  }

  Future<void> _openPostDetail(HupuNbaNewsItem item) async {
    if (item.tid.isEmpty) {
      return;
    }
    await Navigator.of(context).push<void>(
      CupertinoPageRoute<void>(
        builder: (_) => HupuPostDetailPage(
          tid: item.tid,
          initialTitle: item.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        bottom: false,
        child: FutureBuilder<HupuNbaHotNewsData>(
          future: _future,
          builder: (context, snapshot) {
            final items = snapshot.data?.items ?? const <HupuNbaNewsItem>[];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _HotNewsHeader(
                    dateText: _formatHeaderDate(DateTime.now()),
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child:
                        Center(child: CupertinoActivityIndicator(radius: 14)),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: _HotNewsError(detail: snapshot.error?.toString()),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    sliver: SliverList.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _HotNewsTile(
                          item: item,
                          onTap: () => _openPostDetail(item),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HotNewsHeader extends StatelessWidget {
  const _HotNewsHeader({required this.dateText});

  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 376,
      decoration: const BoxDecoration(
        color: Color(0xFFF20D23),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 18,
            left: 20,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(
                CupertinoIcons.chevron_left,
                color: CupertinoColors.white,
                size: 34,
              ),
            ),
          ),
          Positioned(
            top: 78,
            left: 36,
            right: 36,
            child: Container(
              height: 82,
              decoration: BoxDecoration(
                color: CupertinoColors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Positioned(
            top: 168,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '热门资讯',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  '最新篮坛热门，资讯实时更新',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 34,
            bottom: 18,
            child: Text(
              dateText,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HotNewsTile extends StatelessWidget {
  const _HotNewsTile({
    required this.item,
    required this.onTap,
  });

  final HupuNbaNewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFEDEEF2), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF202127),
                      fontSize: 21,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.replySummary,
                    style: const TextStyle(
                      color: Color(0xFF7D8491),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                item.imageUrl,
                width: 118,
                height: 84,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotNewsError extends StatelessWidget {
  const _HotNewsError({this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          detail == null ? '加载失败' : '加载失败\n$detail',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

String _formatHeaderDate(DateTime date) {
  const weekdayNames = <int, String>{
    DateTime.monday: '周一',
    DateTime.tuesday: '周二',
    DateTime.wednesday: '周三',
    DateTime.thursday: '周四',
    DateTime.friday: '周五',
    DateTime.saturday: '周六',
    DateTime.sunday: '周日',
  };
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day ${weekdayNames[date.weekday] ?? ''}';
}
