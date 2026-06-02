import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_index_bar/app_index_bar_types.dart';

class AppIndexBar extends StatefulWidget {
  const AppIndexBar({
    super.key,
    required this.sections,
    this.sticky = true,
    this.stickyOffsetTop = 0,
    this.indexWidth = 30,
    this.indexColor = const Color(0xFF98A2B3),
    this.indexActiveColor = const Color(0xFF2563EB),
    this.sectionHeaderColor = const Color(0xFFF6F8FB),
  });

  final List<AppIndexBarSection> sections;
  final bool sticky;
  final double stickyOffsetTop;
  final double indexWidth;
  final Color indexColor;
  final Color indexActiveColor;
  final Color sectionHeaderColor;

  @override
  State<AppIndexBar> createState() => _AppIndexBarState();
}

class _AppIndexBarState extends State<AppIndexBar> {
  final ScrollController _scrollController = ScrollController();
  late final List<GlobalKey> _sectionKeys;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _sectionKeys = List<GlobalKey>.generate(
      widget.sections.length,
      (_) => GlobalKey(),
    );
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    for (var i = widget.sections.length - 1; i >= 0; i -= 1) {
      final context = _sectionKeys[i].currentContext;
      if (context == null) {
        continue;
      }
      final box = context.findRenderObject() as RenderBox?;
      if (box == null) {
        continue;
      }
      final position = box.localToGlobal(Offset.zero);
      if (position.dy <= 120 + widget.stickyOffsetTop) {
        if (_activeIndex != i) {
          setState(() {
            _activeIndex = i;
          });
        }
        return;
      }
    }
    if (_activeIndex != 0) {
      setState(() {
        _activeIndex = 0;
      });
    }
  }

  Future<void> _scrollToSection(int index) async {
    final context = _sectionKeys[index].currentContext;
    if (context == null) {
      return;
    }
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x12000000)),
      ),
      child: SizedBox(
        height: 460,
        child: Stack(
          children: [
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 0, 40, 18),
              itemCount: widget.sections.length,
              itemBuilder: (context, index) {
                final section = widget.sections[index];
                return KeyedSubtree(
                  key: _sectionKeys[index],
                  child: _IndexSection(
                    section: section,
                    sticky: widget.sticky,
                    stickyOffsetTop: widget.stickyOffsetTop,
                    sectionHeaderColor: widget.sectionHeaderColor,
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 6,
              bottom: 16,
              child: Center(
                child: SizedBox(
                  width: widget.indexWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(widget.sections.length, (index) {
                      final active = index == _activeIndex;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _scrollToSection(index),
                        child: Container(
                          width: widget.indexWidth,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            widget.sections[index].index,
                            style: TextStyle(
                              color: active ? widget.indexActiveColor : widget.indexColor,
                              fontSize: 12,
                              fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexSection extends StatelessWidget {
  const _IndexSection({
    required this.section,
    required this.sticky,
    required this.stickyOffsetTop,
    required this.sectionHeaderColor,
  });

  final AppIndexBarSection section;
  final bool sticky;
  final double stickyOffsetTop;
  final Color sectionHeaderColor;

  @override
  Widget build(BuildContext context) {
    final header = Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: sectionHeaderColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        section.title,
        style: const TextStyle(
          color: Color(0xFF344054),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sticky)
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: stickyOffsetTop == 0 ? 12 : stickyOffsetTop + 12,
              bottom: 8,
            ),
            child: header,
          )
        else
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: header,
          ),
        ...section.children,
      ],
    );
  }
}
