import 'package:flutter/material.dart';
import 'package:flutter_template_start/api/area.dart';
import 'package:flutter_template_start/model/area/index.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  IAreaCodes? iAreaCodes;
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
                title: Text(iAreaCodes!.data[index].merger),
                subtitle: Text(iAreaCodes!.data[index].code.toString()),
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
                dynamic result = await commonPostRequest();
                IAreaCodes iAreaCodes = IAreaCodes.fromJson(result);
                setState(() {
                  this.iAreaCodes = iAreaCodes;
                  dataList = iAreaCodes.data;
                  total = iAreaCodes.data.length;
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
                  iAreaCodes = null;
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
