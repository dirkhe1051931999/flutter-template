import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_text_ellipsis/app_text_ellipsis_types.dart';

class AppTextEllipsis extends StatefulWidget {
  const AppTextEllipsis({
    super.key,
    required this.text,
    this.rows = 1,
    this.expandText = '展开',
    this.collapseText = '收起',
    this.dots = '...',
    this.contentPosition = AppTextEllipsisContentPosition.end,
    this.textStyle = const TextStyle(
      color: Color(0xFF202127),
      fontSize: 14,
      height: 1.5,
    ),
    this.actionStyle = const TextStyle(
      color: Color(0xFF2563EB),
      fontSize: 14,
      fontWeight: FontWeight.w700,
    ),
  });

  final String text;
  final int rows;
  final String expandText;
  final String collapseText;
  final String dots;
  final AppTextEllipsisContentPosition contentPosition;
  final TextStyle textStyle;
  final TextStyle actionStyle;

  @override
  State<AppTextEllipsis> createState() => _AppTextEllipsisState();
}

class _AppTextEllipsisState extends State<AppTextEllipsis> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (_expanded) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _expanded = false;
          });
        },
        child: RichText(
          text: TextSpan(
            style: widget.textStyle,
            children: [
              TextSpan(text: widget.text),
              TextSpan(
                text: ' ${widget.collapseText}',
                style: widget.actionStyle,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          textDirection: Directionality.of(context),
          maxLines: widget.rows,
        );

        textPainter.text = TextSpan(
          text: widget.text,
          style: widget.textStyle,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);

        if (!textPainter.didExceedMaxLines) {
          return Text(
            widget.text,
            style: widget.textStyle,
          );
        }

        final collapsedText = _buildCollapsedText();
        final displayText = _fitCollapsedText(
          constraints.maxWidth,
          collapsedText,
          Directionality.of(context),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _expanded = true;
            });
          },
          child: RichText(
            text: TextSpan(
              style: widget.textStyle,
              children: [
                TextSpan(text: displayText),
                TextSpan(
                  text: ' ${widget.expandText}',
                  style: widget.actionStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _buildCollapsedText() {
    return switch (widget.contentPosition) {
      AppTextEllipsisContentPosition.end => widget.text,
      AppTextEllipsisContentPosition.start => widget.text.split('').reversed.join(),
      AppTextEllipsisContentPosition.middle => widget.text,
    };
  }

  String _fitCollapsedText(
    double maxWidth,
    String source,
    TextDirection textDirection,
  ) {
    final suffix = '${widget.dots} ${widget.expandText}';
    if (widget.contentPosition == AppTextEllipsisContentPosition.middle) {
      var left = source.length ~/ 2;
      var right = left;
      while (left > 0 && right < source.length) {
        final candidate =
            '${source.substring(0, left)}${widget.dots}${source.substring(right)} ${widget.expandText}';
        final painter = TextPainter(
          text: TextSpan(
            text: candidate,
            style: widget.textStyle,
          ),
          textDirection: textDirection,
          maxLines: widget.rows,
        )..layout(maxWidth: maxWidth);
        if (!painter.didExceedMaxLines) {
          return '${source.substring(0, left)}${widget.dots}${source.substring(right)}';
        }
        left -= 1;
        right += 1;
      }
      return widget.dots;
    }

    var low = 0;
    var high = source.length;
    var best = '';
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      final candidate = widget.contentPosition == AppTextEllipsisContentPosition.start
          ? '${widget.dots}${source.substring(0, mid)} $suffix'
          : '${source.substring(0, mid)} $suffix';
      final painter = TextPainter(
        text: TextSpan(
          text: candidate,
          style: widget.textStyle,
        ),
        textDirection: textDirection,
        maxLines: widget.rows,
      )..layout(maxWidth: maxWidth);
      if (painter.didExceedMaxLines) {
        high = mid - 1;
      } else {
        best = widget.contentPosition == AppTextEllipsisContentPosition.start
            ? '${widget.dots}${source.substring(0, mid)}'
            : source.substring(0, mid);
        low = mid + 1;
      }
    }

    if (widget.contentPosition == AppTextEllipsisContentPosition.start) {
      final restored = best.replaceFirst(widget.dots, '');
      return '${widget.dots}${restored.split('').reversed.join()}';
    }
    return best;
  }
}
