import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oolaf_flutted/components/network_img/index.dart';

class LoginCaptchaDialogPayload {
  const LoginCaptchaDialogPayload({
    required this.captchaId,
    required this.imageUrl,
    required this.words,
    this.requiredPointCount = 4,
  });

  final String captchaId;
  final String imageUrl;
  final String words;
  final int requiredPointCount;
}

class LoginCaptchaPoint {
  const LoginCaptchaPoint({
    required this.x,
    required this.y,
    required this.displayX,
    required this.displayY,
  });

  final double x;
  final double y;
  final double displayX;
  final double displayY;

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }
}

class LoginCaptchaDialogResult {
  const LoginCaptchaDialogResult({
    required this.captchaId,
    required this.positions,
  });

  final String captchaId;
  final List<LoginCaptchaPoint> positions;
}

Future<LoginCaptchaDialogResult?> showLoginCaptchaDialog({
  required BuildContext context,
  required LoginCaptchaDialogPayload payload,
}) {
  return showDialog<LoginCaptchaDialogResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => LoginCaptchaDialog(payload: payload),
  );
}

class LoginCaptchaDialog extends StatefulWidget {
  const LoginCaptchaDialog({
    super.key,
    required this.payload,
  });

  final LoginCaptchaDialogPayload payload;

  @override
  State<LoginCaptchaDialog> createState() => _LoginCaptchaDialogState();
}

class _LoginCaptchaDialogState extends State<LoginCaptchaDialog> {
  final List<LoginCaptchaPoint> _points = <LoginCaptchaPoint>[];
  static const double _canonicalImageWidth = 240;
  static const double _canonicalImageHeight = 140;

  void _handleReset() {
    setState(() {
      _points.clear();
    });
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (_points.length >= widget.payload.requiredPointCount) {
      return;
    }
    final localPosition = details.localPosition;
    final safeX = localPosition.dx.clamp(0.0, size.width);
    final safeY = localPosition.dy.clamp(0.0, size.height);
    final scaledX = (safeX / size.width * _canonicalImageWidth)
        .clamp(0.0, _canonicalImageWidth)
        ;
    final scaledY = (safeY / size.height * _canonicalImageHeight)
        .clamp(0.0, _canonicalImageHeight)
        ;
    setState(() {
      _points.add(
        LoginCaptchaPoint(
          x: scaledX,
          y: scaledY,
          displayX: safeX,
          displayY: safeY,
        ),
      );
    });
  }

  void _handleConfirm() {
    if (_points.length < widget.payload.requiredPointCount) {
      EasyLoading.showToast('请先完成 ${widget.payload.requiredPointCount} 个点位选择');
      return;
    }
    Navigator.of(context).pop(
      LoginCaptchaDialogResult(
        captchaId: widget.payload.captchaId,
        positions: List<LoginCaptchaPoint>.unmodifiable(_points),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordsText = widget.payload.words.trim().isEmpty ? '图中的文字' : widget.payload.words;
    final confirmEnabled = _points.length >= widget.payload.requiredPointCount;
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 346),
          child: CupertinoPopupSurface(
            isSurfacePainted: true,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                border: Border.all(color: const Color(0xFFE3E8EE)),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '安全验证',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -0.2,
                            color: Color(0xFF0D253D),
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(28, 28),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          size: 20,
                          color: Color(0xFF64748D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748D),
                        height: 1.45,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        const TextSpan(text: '请依次点击 '),
                        TextSpan(
                          text: wordsText,
                          style: const TextStyle(
                            color: Color(0xFF533AFD),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CaptchaTapArea(
                    imageUrl: widget.payload.imageUrl,
                    points: _points,
                    onTapImage: _handleTap,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _points.isEmpty
                              ? '点击图片完成验证'
                              : '已选择 ${_points.length}/${widget.payload.requiredPointCount} 个点位',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748D),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(28, 28),
                        onPressed: _handleReset,
                        child: const Text(
                          '重选',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF533AFD),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DialogActionButton(
                          label: '取消',
                          foregroundColor: const Color(0xFF0D253D),
                          backgroundColor: const Color(0xFFF8FAFC),
                          borderColor: const Color(0xFFE3E8EE),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DialogActionButton(
                          label: '确认',
                          foregroundColor: confirmEnabled
                              ? CupertinoColors.white
                              : const Color(0xFF94A3B8),
                          backgroundColor: confirmEnabled
                              ? const Color(0xFF533AFD)
                              : const Color(0xFFF1F5F9),
                          borderColor: confirmEnabled
                              ? const Color(0xFF533AFD)
                              : const Color(0xFFE3E8EE),
                          onPressed: confirmEnabled ? _handleConfirm : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onPressed,
  });

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size(double.infinity, 44),
      onPressed: onPressed,
      disabledColor: Colors.transparent,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _CaptchaTapArea extends StatelessWidget {
  const _CaptchaTapArea({
    required this.imageUrl,
    required this.points,
    required this.onTapImage,
  });

  final String imageUrl;
  final List<LoginCaptchaPoint> points;
  final void Function(TapUpDetails details, Size size) onTapImage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (140 / 240);
        final size = Size(width, height);
        final normalizedImageUrl = imageUrl.trim();
        final isBase64DataUri = normalizedImageUrl.startsWith('data:image');
        final imageBytes = isBase64DataUri
            ? base64Decode(normalizedImageUrl.substring(normalizedImageUrl.indexOf(',') + 1))
            : null;
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: isBase64DataUri
                      ? Image(
                          image: MemoryImage(imageBytes!),
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                        )
                      : CustomNetworkImage(
                          normalizedImageUrl,
                          width: width,
                          height: height,
                          fit: BoxFit.cover,
                          skeletonBorderRadius: BorderRadius.circular(14),
                        ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) => onTapImage(details, size),
                  ),
                ),
                for (int index = 0; index < points.length; index++)
                  Positioned(
                    left: (points[index].displayX - 12)
                        .clamp(0.0, width - 24)
                        ,
                    top: (points[index].displayY - 12)
                        .clamp(0.0, height - 24)
                        ,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
