import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show SelectionArea, SelectableText;
import 'package:oolaf_flutted/components/network_img/index.dart';

class ShortVideoInteractionOverlay extends StatelessWidget {
  const ShortVideoInteractionOverlay({
    super.key,
    this.avatarUrl,
    required this.source,
    required this.title,
    required this.updateTime,
    required this.isFavorite,
    required this.onTapFavorite,
    required this.onTapComment,
    required this.onTapShare,
    this.onLongPressAvatarStart,
    this.onLongPressAvatarEnd,
    this.isAvatarSpeedActive = false,
    this.hideMetaText = false,
  });

  final String? avatarUrl;
  final String source;
  final String title;
  final String updateTime;
  final bool isFavorite;
  final VoidCallback onTapFavorite;
  final VoidCallback onTapComment;
  final VoidCallback onTapShare;
  final VoidCallback? onLongPressAvatarStart;
  final VoidCallback? onLongPressAvatarEnd;
  final bool isAvatarSpeedActive;
  final bool hideMetaText;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const IgnorePointer(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 220,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x00000000),
                            Color(0x4D000000),
                            Color(0xB3000000),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!hideMetaText)
                Positioned(
                  left: 0,
                  bottom: 24,
                  right: 90,
                  child: SelectionArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectableText(
                          source,
                          maxLines: 1,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (updateTime.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          SelectableText(
                            updateTime,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 12,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        SelectableText(
                          title,
                          maxLines: 3,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _AvatarActionButton(
                      avatarUrl: avatarUrl,
                      onLongPressStart: onLongPressAvatarStart,
                      onLongPressEnd: onLongPressAvatarEnd,
                      isSpeedActive: isAvatarSpeedActive,
                    ),
                    const SizedBox(height: 18),
                    _IconButton(
                      icon: CupertinoIcons.heart_fill,
                      label: isFavorite ? '已喜欢' : '喜欢',
                      color: isFavorite
                          ? CupertinoColors.systemRed
                          : CupertinoColors.white,
                      onTap: onTapFavorite,
                    ),
                    const SizedBox(height: 18),
                    _IconButton(
                      icon: CupertinoIcons.chat_bubble_text_fill,
                      label: '评论',
                      onTap: onTapComment,
                    ),
                    const SizedBox(height: 18),
                    _IconButton(
                      icon: CupertinoIcons.share_solid,
                      label: '分享',
                      onTap: onTapShare,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.music_note,
                        color: CupertinoColors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarActionButton extends StatefulWidget {
  const _AvatarActionButton({
    required this.avatarUrl,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.isSpeedActive,
  });

  final String? avatarUrl;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final bool isSpeedActive;

  @override
  State<_AvatarActionButton> createState() => _AvatarActionButtonState();
}

class _AvatarActionButtonState extends State<_AvatarActionButton> {
  static const Duration _holdThreshold = Duration(milliseconds: 220);

  Timer? _holdTimer;
  bool _didTriggerLongPress = false;

  @override
  void didUpdateWidget(covariant _AvatarActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isSpeedActive && oldWidget.isSpeedActive && _didTriggerLongPress) {
      _didTriggerLongPress = false;
    }
  }

  @override
  void dispose() {
    _cancelHoldTimer();
    super.dispose();
  }

  void _cancelHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _cancelHoldTimer();
    _didTriggerLongPress = false;
    _holdTimer = Timer(_holdThreshold, () {
      _holdTimer = null;
      _didTriggerLongPress = true;
      widget.onLongPressStart?.call();
    });
  }

  void _handlePointerEnd() {
    final didTrigger = _didTriggerLongPress;
    _cancelHoldTimer();
    _didTriggerLongPress = false;
    if (didTrigger) {
      widget.onLongPressEnd?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = (widget.avatarUrl ?? '').isNotEmpty;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerUp: (_) {
        _handlePointerEnd();
      },
      onPointerCancel: (_) {
        _handlePointerEnd();
      },
      onPointerMove: (event) {
        if (!event.down) {
          _handlePointerEnd();
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0x33000000),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x66FFFFFF), width: 1.5),
                ),
                child: ClipOval(
                  child: hasAvatar
                      ? CustomNetworkImage(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const _AvatarFallback();
                          },
                        )
                      : const _AvatarFallback(),
                ),
              ),
              if (widget.isSpeedActive)
                Positioned(
                  right: -2,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '2x',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.isSpeedActive ? '松开恢复' : '长按加速',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0x33FFFFFF),
      child: Center(
        child: Icon(
          CupertinoIcons.person_fill,
          color: CupertinoColors.white,
          size: 22,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = CupertinoColors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
