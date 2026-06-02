import 'package:flutter/cupertino.dart';
import 'package:oolaf_flutted/components/app_steps/app_steps_types.dart';

class AppSteps extends StatelessWidget {
  const AppSteps({
    super.key,
    required this.steps,
    this.active = 0,
    this.direction = AppStepsDirection.horizontal,
    this.activeColor = const Color(0xFF2563EB),
    this.inactiveColor = const Color(0xFFD0D5DD),
  });

  final List<AppStepItem> steps;
  final int active;
  final AppStepsDirection direction;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    if (direction == AppStepsDirection.vertical) {
      return Column(
        children: List<Widget>.generate(steps.length, (index) {
          return _StepTile(
            item: steps[index],
            index: index,
            isLast: index == steps.length - 1,
            status: _statusFor(index),
            direction: direction,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          );
        }),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List<Widget>.generate(steps.length, (index) {
        return Expanded(
          child: _StepTile(
            item: steps[index],
            index: index,
            isLast: index == steps.length - 1,
            status: _statusFor(index),
            direction: direction,
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        );
      }),
    );
  }

  AppStepStatus _statusFor(int index) {
    if (index < active) {
      return AppStepStatus.finish;
    }
    if (index == active) {
      return AppStepStatus.process;
    }
    return AppStepStatus.waiting;
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.item,
    required this.index,
    required this.isLast,
    required this.status,
    required this.direction,
    required this.activeColor,
    required this.inactiveColor,
  });

  final AppStepItem item;
  final int index;
  final bool isLast;
  final AppStepStatus status;
  final AppStepsDirection direction;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final isActive = status != AppStepStatus.waiting;
    final dotColor = isActive ? activeColor : inactiveColor;
    final textColor =
        status == AppStepStatus.process ? const Color(0xFF202127) : const Color(0xFF667085);

    if (direction == AppStepsDirection.vertical) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepDot(
                index: index,
                status: status,
                color: dotColor,
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 44,
                  color: dotColor.withValues(alpha: 0.35),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _StepText(
                item: item,
                textColor: textColor,
                active: status == AppStepStatus.process,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _StepDot(
              index: index,
              status: status,
              color: dotColor,
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: dotColor.withValues(alpha: 0.35),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _StepText(
          item: item,
          textColor: textColor,
          active: status == AppStepStatus.process,
          centered: true,
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.index,
    required this.status,
    required this.color,
  });

  final int index;
  final AppStepStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: status == AppStepStatus.waiting ? const Color(0xFFFFFFFF) : color,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: status == AppStepStatus.finish
            ? const Icon(
                CupertinoIcons.check_mark,
                size: 13,
                color: Color(0xFFFFFFFF),
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: status == AppStepStatus.waiting
                      ? color
                      : const Color(0xFFFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _StepText extends StatelessWidget {
  const _StepText({
    required this.item,
    required this.textColor,
    required this.active,
    this.centered = false,
  });

  final AppStepItem item;
  final Color textColor;
  final bool active;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          item.title,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        if (item.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            item.description!,
            textAlign: centered ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
