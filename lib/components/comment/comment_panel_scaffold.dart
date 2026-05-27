import 'package:flutter/cupertino.dart';

class CommentPanelScaffold extends StatelessWidget {
  const CommentPanelScaffold({
    super.key,
    this.panelKey,
    this.header,
    required this.content,
    this.bottomBar,
    this.expandContent = true,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final Key? panelKey;
  final Widget? header;
  final Widget content;
  final Widget? bottomBar;
  final bool expandContent;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: panelKey,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (header != null) header!,
          if (expandContent) Expanded(child: content) else content,
          if (bottomBar != null) bottomBar!,
        ],
      ),
    );
  }
}
