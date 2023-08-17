import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/api/news/index.dart';
import 'package:flutter_template_start/components/network_img/index.dart';
import 'package:flutter_template_start/layouts/app_theme.dart';
import 'package:flutter_template_start/model/news/inews_detail_ad.dart';
import 'package:flutter_template_start/utils/helper.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:marquee/marquee.dart';

class ScrollableTabsDetailPage extends StatefulWidget {
  const ScrollableTabsDetailPage(
      {Key? key, required this.title, required this.id})
      : super(key: key);
  final String title;
  final int id;

  @override
  State<ScrollableTabsDetailPage> createState() =>
      _ScrollableTabsDetailPageState();
}

class _ScrollableTabsDetailPageState extends State<ScrollableTabsDetailPage>
    with TickerProviderStateMixin {
  Future<INewsDetailAd>? detailsFuture;
  TabController? _tabController;
  final grid = List.generate(3, (index) => index);
  final list = List.generate(3, (index) => index);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    detailsFuture = getNewsDetailAd({
      "news_id": widget.id,
      "channelCode": "tt",
    });
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController?.dispose();
  }

  Widget _buildPersistentHeader(Widget child,
      {double? minHeight, double? maxHeight}) {
    return SliverPersistentHeader(
        pinned: true,
        delegate: _SliverDelegate(
          minHeight: minHeight ?? 40.0,
          maxHeight: maxHeight ?? 40.0,
          children: child,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 错误处理
        }
        NewsVO? newsvo = snapshot.data?.respData?.newsvo;
        String content = newsvo?.content ?? '';
        if (newsvo == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return MaterialApp(
          title: 'News',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().light,
          home: Scaffold(
            appBar: AppBar(
              title: SizedBox(
                height: 50,
                child: Marquee(
                  text: widget.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 10.sp,
                    right: 10.sp,
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // 设置主轴方向的排列方式为两端对齐
                    children: [
                      Icon(Icons.access_alarms_outlined), // 左边的图标
                      Text('输入框'), // 中间的文本
                      Icon(Icons.share), // 右边的图标
                    ],
                  ),
                ),
              ),
            ),
            body: CustomScrollView(
              slivers: <Widget>[
                /// 在customScrollView插入单个盒子组件
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(10.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          children: [
                            Text(
                              newsvo.title ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10.sp),
                          child: Row(
                            children: [
                              ClipOval(
                                child: CustomNetworkImage(
                                  newsvo.sourceImage ?? '',
                                  width: 20.sp,
                                  height: 20.sp,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.sp),
                                child: Text(
                                  newsvo.source ?? '',
                                  style: TextStyle(
                                    color: Color(
                                      ColorHelpers.fromHexString(
                                        '#a5a5a5',
                                      ),
                                    ),
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10.sp,
                      right: 10.sp,
                      bottom: 10.sp,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: parseHtmlString(content),
                    ),
                  ),
                ),

                /// 固定高度和滚动吸顶
                _buildPersistentHeader(
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('这些回复亮了'),
                        ),
                        Row(
                          children: [
                            Text('最亮'),
                            Text('最早'),
                          ],
                        )
                      ],
                    ),
                  ),
                  maxHeight: 40,
                  minHeight: 40,
                ),
                SliverList.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      height: 100,
                      color: Colors.grey[100],
                      child: const Center(child: Text('这是评论区')),
                    );
                  },
                  itemCount: 10,
                ),
                const SliverToBoxAdapter(
                  child: Divider(),
                ),
                SliverList.builder(
                  itemBuilder: (context, index) {
                    return Container(
                      height: 100,
                      color: Colors.grey[50],
                      child: const Center(child: Text('这是相关新闻区')),
                    );
                  },
                  itemCount: 5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverDelegate extends SliverPersistentHeaderDelegate {
  _SliverDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.children,
  });
  final double minHeight;
  final double maxHeight;
  final Widget children;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: children,
    );
  }

  @override
  bool shouldRebuild(_SliverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        children != oldDelegate.children;
  }
}

List<Widget> parseHtmlString(String htmlString) {
  final document = html_parser.parse(htmlString);
  final List<Widget> widgets = [];

  for (var element in document.body!.children) {
    if (element.localName == 'p') {
      if (element.children.isNotEmpty &&
          element.children.first.localName == 'img') {
        final src = element.children.first.attributes['src'];
        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: 10.sp, bottom: 10.sp),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.sp),
                child: CustomNetworkImage(
                  src!,
                  width: 200.sp,
                  height: 100.sp,
                ),
              ),
            ),
          ),
        ); // 使用你自定义的CustomNetworkImage组件
      } else {
        widgets.add(Text(
          element.text,
          style: TextStyle(
            color: Color(
              ColorHelpers.fromHexString('#323232'),
            ),
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
        ));
      }
    }
  }

  return widgets;
}
