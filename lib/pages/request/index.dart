import 'package:flutter/material.dart';
import 'package:oolaf_flutted/api/banner.dart';
import 'package:oolaf_flutted/model/banner/index.dart';

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
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final item = banner!.data!.list![index];
                    return ListTile(
                      title: Text(item.author ?? ''),
                      subtitle: Text(item.content ?? ''),
                    );
                  },
                ),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    banner = null;
                    dataList = null;
                    total = 0;
                  });
                },
                child: const Text('清除数据'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  dynamic result = await commonGetRequest();
                  IBanner banner = IBanner.fromJson(result);
                  setState(() {
                    this.banner = banner;
                    dataList = banner.data?.list;
                    total = banner.data?.list?.length ?? 0;
                    isLoading = false;
                  });
                },
                child: const Text('请求数据'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
