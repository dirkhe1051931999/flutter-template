import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_calendar/app_calendar_types.dart';

class AppCalendarHeader extends StatelessWidget {
  const AppCalendarHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.switchMode,
    required this.onCancel,
    required this.onConfirm,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousYear,
    required this.onNextYear,
    this.confirmEnabled = true,
    this.canGoPreviousMonth = true,
    this.canGoNextMonth = true,
    this.canGoPreviousYear = true,
    this.canGoNextYear = true,
  });

  final String title;
  final String subtitle;
  final AppCalendarSwitchMode switchMode;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final bool confirmEnabled;
  final bool canGoPreviousMonth;
  final bool canGoNextMonth;
  final bool canGoPreviousYear;
  final bool canGoNextYear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(28, 28),
              onPressed: onCancel,
              child: const Text(
                '取消',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(28, 28),
              onPressed: confirmEnabled ? onConfirm : null,
              child: Text(
                '完成',
                style: TextStyle(
                  color: confirmEnabled
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFB6BDC9),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (switchMode != AppCalendarSwitchMode.none) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              if (switchMode == AppCalendarSwitchMode.yearMonth) ...[
                _NavButton(
                  icon: CupertinoIcons.chevron_back,
                  onTap: canGoPreviousYear ? onPreviousYear : null,
                ),
                const SizedBox(width: 8),
              ],
              _NavButton(
                icon: CupertinoIcons.chevron_back,
                onTap: canGoPreviousMonth ? onPreviousMonth : null,
              ),
              const Spacer(),
              _NavButton(
                icon: CupertinoIcons.chevron_forward,
                onTap: canGoNextMonth ? onNextMonth : null,
              ),
              if (switchMode == AppCalendarSwitchMode.yearMonth) ...[
                const SizedBox(width: 8),
                _NavButton(
                  icon: CupertinoIcons.chevron_forward,
                  onTap: canGoNextYear ? onNextYear : null,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: onTap == null ? 0.35 : 1,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0x14000000)),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
