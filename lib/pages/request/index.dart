import 'package:flutter/material.dart';
import 'package:flutter_template_start/api/banner.dart';
import 'package:flutter_template_start/model/banner/index.dart';

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
    return Scrollbar(
      controller: _scrollController,
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: total,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(banner!.banners![index].typeTitle!),
                subtitle: Text(banner!.banners![index].imageUrl!),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                dynamic result = await commonGetRequest();
                IBanner banner = IBanner.fromJson(result);
                setState(() {
                  this.banner = banner;
                  dataList = banner.banners;
                  total = banner.banners!.length;
                  isLoading = false;
                });
              },
              child: const Text('请求数据'),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  banner = null;
                  dataList = null;
                  total = 0;
                });
              },
              child: const Text('清除数据'),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}