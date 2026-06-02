import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/api/banner.dart';
import 'package:oolaf_flutted/model/banner/index.dart';
import 'package:oolaf_flutted/pages/request/widgets/request_item_card.dart';
import 'package:oolaf_flutted/pages/request/widgets/request_status_hero.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  IBanner? banner;
  dynamic dataList;
  int total = 0;
  bool isLoading = false;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = banner?.data?.list ?? const <GuestbookItem>[];

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              children: [
                RequestStatusHero(
                  total: total,
                  isLoading: isLoading,
                  hasData: banner != null,
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xAAFFFFFF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0x12FFFFFF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '请求结果',
                          style: TextStyle(
                            color: Color(0xFF1F2329),
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner == null
                              ? '当前还没有请求数据。'
                              : '共拿到 $total 条留言记录。',
                          style: const TextStyle(
                            color: Color(0xFF818B9A),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CupertinoActivityIndicator(radius: 12),
                            ),
                          )
                        else if (items.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 28,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xF7FFFFFF),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0x12000000)),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  CupertinoIcons.cloud_download,
                                  color: Color(0xFFB0B7C3),
                                  size: 26,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '点击下方按钮发起请求',
                                  style: TextStyle(
                                    color: Color(0xFF88909E),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: RequestItemCard(item: item),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: const Color(0xFFF0F2F6),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () {
                      setState(() {
                        banner = null;
                        dataList = null;
                        total = 0;
                      });
                    },
                    child: const Text(
                      '清除数据',
                      style: TextStyle(
                        color: Color(0xFF5F6878),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CupertinoButton.filled(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    borderRadius: BorderRadius.circular(18),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final result = await commonGetRequest();
                      if (!mounted) {
                        return;
                      }
                      if (result is! Map<String, dynamic>) {
                        setState(() {
                          banner = null;
                          dataList = null;
                          total = 0;
                          isLoading = false;
                        });
                        return;
                      }
                      final parsedBanner = IBanner.fromJson(result);
                      setState(() {
                        banner = parsedBanner;
                        dataList = parsedBanner.data?.list;
                        total = parsedBanner.data?.list?.length ?? 0;
                        isLoading = false;
                      });
                    },
                    child: const Text(
                      '请求数据',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
