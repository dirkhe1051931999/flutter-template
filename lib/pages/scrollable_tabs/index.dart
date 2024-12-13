import 'package:flutter/material.dart';
import 'package:flutter_template_start/api/news/index.dart';
import 'package:flutter_template_start/layouts/app_theme.dart';
import 'package:flutter_template_start/model/news/index.dart';
import 'package:flutter_template_start/pages/scrollable_tabs/children/common_page.dart';
import 'package:flutter_template_start/router/config.dart';

class ScrollableTabsPage extends StatefulWidget {
  const ScrollableTabsPage({super.key});

  @override
  State<ScrollableTabsPage> createState() => _ScrollableTabsPageState();
}

class _ScrollableTabsPageState extends State<ScrollableTabsPage> with TickerProviderStateMixin {
  Future<TabsModel?>? tabsFuture;
  TabController? _tabController;
  Map<int, Map<String, dynamic>> _newsPagination = {};
  TabsModel? allTabs;
  final Map<int, List<ListModel?>> _newsIdMap = {};

  @override
  void initState() {
    super.initState();
    tabsFuture = getNewsColumnAdd();
    tabsFuture!.then((value) async {
      allTabs = value;
      // 遍历value.respData?.columnTypeList，然后给map加唯一key的value
      Map<int, Map<String, dynamic>> pagination = {};
      value?.respData?.columnTypeList?.forEach((item) {
        pagination[item.id!] = {
          "pageNum": 1,
          "pageSize": 10,
          "total": 0,
        };
      });
      _tabController = TabController(
        length: value?.respData?.columnTypeList?.length ?? 0,
        vsync: this,
      );
      _tabController!.addListener(_tabBarListener);
      ListModel? newsListAd = await getNewsListAd(
        {
          "column_id": value?.respData?.columnTypeList?[0].id,
          "pageNum": pagination[value?.respData?.columnTypeList?[0].id!]?['pageNum'],
          "flag": false,
          "channelCode": "tt",
        },
      );
      setState(() {
        _newsIdMap[value?.respData?.columnTypeList?[0].id ?? 0] = [newsListAd];
        _newsPagination = pagination;
      });
    });
  }

  @override
  void dispose() {
    _tabController!.removeListener(_tabBarListener);
    _tabController!.dispose();
    super.dispose();
  }

  void _tabBarListener() async {
    int index = _tabController!.index;
    int tabId = allTabs?.respData?.columnTypeList?[index].id ?? 0;
    if (_newsIdMap[tabId] == null) {
      ListModel? newsListAd = await getNewsListAd(
        {
          "column_id": tabId,
          "pageNum": _newsPagination[tabId]?['pageNum'],
          "flag": false,
          "channelCode": "tt",
        },
      );
      setState(() {
        _newsIdMap[tabId] = [newsListAd];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 错误处理
        }
        var columnTypeList = snapshot.data?.respData.columnTypeList;
        if (columnTypeList != null && _tabController != null) {
          return MaterialApp(
            title: 'News',
            debugShowCheckedModeBanner: false,
            theme: AppTheme().light,
            home: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: columnTypeList.map<Widget>((item) {
                    return Tab(
                      text: item.name,
                    );
                  }).toList(),
                ),
                title: const Text('新闻tab切换'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: columnTypeList.map<Widget>((item) {
                  return TabContent(
                    tabId: item.id!,
                    newsIdMap: _newsIdMap,
                    itemTap: (news) {
                      Application.router.navigateTo(
                        context,
                        "/scrollable-tabs-detail?title=${Uri.encodeComponent(news.title!)}&id=${news.id}",
                      );
                    },
                    pullToRefresh: (tabId, refreshController) async {
                      ListModel? newsListAd = await getNewsListAd(
                        {
                          "column_id": tabId,
                          "pageNum": 1,
                          "flag": false,
                          "channelCode": "tt",
                        },
                      );
                      if (mounted) {
                        setState(() {
                          _newsIdMap[tabId] = [newsListAd];
                        });
                      }
                      refreshController.refreshCompleted();
                    },
                    moreLoad: (tabId, refreshController) async {
                      int pageNum = _newsPagination[tabId]?['pageNum'] ?? 1;
                      pageNum++;
                      ListModel? newsListAd = await getNewsListAd(
                        {
                          "column_id": tabId,
                          "pageNum": pageNum,
                          "flag": false,
                          "channelCode": "tt",
                        },
                      );
                      if (mounted) {
                        setState(() {
                          _newsIdMap[tabId]!.add(newsListAd);
                          _newsPagination[tabId]?['pageNum'] = pageNum;
                        });
                      }
                      refreshController.loadComplete();
                    },
                  );
                }).toList() as List<Widget>,
              ),
            ),
          );
        } else {
          return Container();
        }
      },
      future: tabsFuture,
    );
  }
}
