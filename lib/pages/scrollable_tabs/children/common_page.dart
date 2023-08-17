import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template_start/components/network_img/index.dart';
import 'package:flutter_template_start/model/news/news_list_ad.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TabContent extends StatefulWidget {
  const TabContent({
    Key? key,
    required this.tabId,
    required this.newsIdMap,
    required this.pullToRefresh,
    required this.moreLoad,
    required this.itemTap,
  }) : super(key: key);
  final int tabId;
  final Map<int, List<INewsListAd>> newsIdMap;
  final Function(int, RefreshController) pullToRefresh;
  final Function(int, RefreshController) moreLoad;
  final Function(NewsItem) itemTap;

  @override
  State<TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  @override
  Widget build(BuildContext context) {
    var newsList = widget.newsIdMap[widget.tabId];
    if (newsList == null) {
      return const Center(child: Text('加载中...'));
    } else {
      return CommonPage(
        newsList: newsList,
        tabId: widget.tabId,
        pullToRefresh: widget.pullToRefresh,
        moreLoad: widget.moreLoad,
        itemTap: widget.itemTap,
      );
    }
  }
}

class CommonPage extends StatelessWidget {
  CommonPage({
    Key? key,
    required List<INewsListAd> this.newsList,
    required this.tabId,
    required this.pullToRefresh,
    required this.moreLoad,
    required this.itemTap,
  }) : super(key: key);
  final List<INewsListAd>? newsList;
  final int tabId;
  final Function(int, RefreshController) pullToRefresh;
  final Function(int, RefreshController) moreLoad;
  final Function(NewsItem) itemTap;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    var newsItem = [];
    for (var element in newsList!) {
      for (var element in element.respData!) {
        newsItem.add(element);
      }
    }
    return SmartRefresher(
      enablePullDown: true,
      enablePullUp: true,
      header: const WaterDropHeader(),
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = const CupertinoActivityIndicator();
          } else if (mode == LoadStatus.failed) {
            body = const Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = const Text("release to load more");
          } else {
            body = const Text("No more Data");
          }
          return SizedBox(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      controller: _refreshController,
      onRefresh: () => pullToRefresh(tabId, _refreshController),
      onLoading: () {
        _refreshController.loadComplete();
        moreLoad(tabId, _refreshController);
      },
      child: ListView.builder(
        key: PageStorageKey<String>(tabId.toString()),
        itemCount: newsItem.length,
        itemBuilder: (context, index) {
          List<dynamic> images = newsItem[index].smallImgs != null
              ? jsonDecode(newsItem[index].smallImgs)
              : [];
          return GestureDetector(
            onTap: () {
              itemTap(newsItem[index]);
            },
            child: Column(
              children: [
                ListTile(
                  title: Text(newsItem[index].title ?? ''),
                ),
                images.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.sp),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 每行3个
                            mainAxisSpacing: 10.sp, // 主轴间距为10
                            crossAxisSpacing: 10.sp, // 横轴间距为10
                          ),
                          itemCount: images.length,
                          itemBuilder: (context, imageIndex) {
                            return ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(4.sp), // 设置圆角为4
                              child: CustomNetworkImage(
                                images[imageIndex],
                              ),
                            );
                          },
                          shrinkWrap: true, // 使其自适应内容大小
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        },
      ),
    );
  }
}
