import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/mock_models.dart';
import 'package:oolaf_flutted/pages/scrollable_tabs/widgets/helpers.dart';

class ScrollableTabsTabView extends StatefulWidget {
  const ScrollableTabsTabView({
    required this.tab,
    required this.sessionId,
    required this.refreshCount,
    required this.accentColor,
    super.key,
  });

  final ScrollableTabsMockTab tab;
  final String sessionId;
  final int refreshCount;
  final Color accentColor;

  @override
  State<ScrollableTabsTabView> createState() => _ScrollableTabsTabViewState();
}

class _ScrollableTabsTabViewState extends State<ScrollableTabsTabView> {
  late final String _mountedAt;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _mountedAt =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFF0F1F4)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tab.label,
                      style: const TextStyle(
                        color: Color(0xFF1F2329),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.tab.description,
                      style: const TextStyle(
                        color: Color(0xFF586172),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MetaPill(
                          label: 'session ${widget.sessionId}',
                          accentColor: widget.accentColor,
                        ),
                        MetaPill(
                          label: 'mountedAt $_mountedAt',
                          accentColor: widget.accentColor,
                        ),
                        MetaPill(
                          label: 'refresh ${widget.refreshCount}',
                          accentColor: widget.accentColor,
                        ),
                        MetaPill(
                          label:
                              'keepAlive ${widget.tab.keepAlive ? 'on' : 'off'}',
                          accentColor: widget.accentColor,
                        ),
                        MetaPill(
                          label: widget.tab.swipeEnabled
                              ? 'swipe enabled'
                              : 'swipe disabled',
                          accentColor: widget.accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
          sliver: SliverList.separated(
            itemCount: widget.tab.cards.length,
            itemBuilder: (context, index) {
              final card = widget.tab.cards[index];
              return FeatureCard(
                card: card,
                accentColor: widget.accentColor,
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    required this.card,
    required this.accentColor,
    super.key,
  });

  final ScrollableTabsMockCard card;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                linkedTabIconFromName(card.icon),
                color: accentColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          card.title,
                          style: const TextStyle(
                            color: Color(0xFF1F2329),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TagBadge(
                        label: card.tag,
                        accentColor: accentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.summary,
                    style: const TextStyle(
                      color: Color(0xFF4F5867),
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    card.meta,
                    style: const TextStyle(
                      color: Color(0xFF8C93A2),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetaPill extends StatelessWidget {
  const MetaPill({
    required this.label,
    required this.accentColor,
    super.key,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TagBadge extends StatelessWidget {
  const TagBadge({
    required this.label,
    required this.accentColor,
    super.key,
  });

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
