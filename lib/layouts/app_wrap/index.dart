import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/route_page_header/index.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.widget,
  });

  final String title;
  final Widget widget;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFD),
              Color(0xFFF2F4F8),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              RoutePageHeader(
                title: title,
                onBack: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(child: widget),
            ],
          ),
        ),
      ),
    );
  }
}
