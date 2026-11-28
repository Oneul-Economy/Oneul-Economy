import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// 문제마다 주어지는 제한 시간 (초).
const quizTimeLimit = 30;

/// 이 초 이하로 남으면 타이머를 빨간색으로.
const quizTimeWarning = 10;

const _warningRed = Color(0xFFD93025);

/// 퀴즈 상단 남은 시간 `0:30` → `0:00`. 10초 남았을 때부터 빨간색.
class QuizTimerLabel extends StatelessWidget {
  const QuizTimerLabel({super.key, required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final warn = remaining <= quizTimeWarning;
    final color = warn ? _warningRed : AppColors.muted;
    final r = remaining.clamp(0, 5999);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.access_time, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          '${r ~/ 60}:${(r % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: color,
            fontSize: 12,
            fontWeight: warn ? FontWeight.w800 : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
