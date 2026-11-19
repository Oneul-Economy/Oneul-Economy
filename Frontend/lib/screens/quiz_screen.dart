import 'package:flutter/material.dart';

import '../models/news.dart';
import '../models/quiz.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quiz,
    required this.news,
  });

  final Quiz quiz;
  final News news;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedIndex;
  int _correctCount = 0;
  final List<QuizItem> _wrongItems = [];

  QuizItem get _currentItem => widget.quiz.quizzes[_currentIndex];
  bool get _hasAnswered => _selectedIndex != null;
  bool get _isLastQuestion => _currentIndex == widget.quiz.quizzes.length - 1;

  void _selectChoice(int index) {
    if (_hasAnswered) return; // 한 번 고르면 다시 못 고름

    setState(() {
      _selectedIndex = index;
      if (index == _currentItem.answerIndex) {
        _correctCount++;
      } else {
        _wrongItems.add(_currentItem);
      }
    });
  }

  void _next() {
    if (!_isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => QuizResultScreen(
          news: widget.news,
          totalCount: widget.quiz.quizzes.length,
          correctCount: _correctCount,
          wrongItems: _wrongItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: Text(
          '용어 퀴즈 (${_currentIndex + 1}/${widget.quiz.quizzes.length})',
          style: TextStyle(
            fontFamily: AppFonts.sans,
            color: AppColors.ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.question,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < item.choices.length; i++) ...[
                _ChoiceButton(
                  text: item.choices[i],
                  isAnswered: _hasAnswered,
                  isSelected: _selectedIndex == i,
                  isCorrect: i == item.answerIndex,
                  onTap: () => _selectChoice(i),
                ),
                const SizedBox(height: 10),
              ],
              if (_hasAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedIndex == item.answerIndex ? '정답이에요!' : '아쉬워요!',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.explanation,
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          color: AppColors.ink,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              if (_hasAnswered)
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.paper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_isLastQuestion ? '결과 보기' : '다음'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.text,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrect,
    required this.onTap,
  });

  final String text;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.ink;
    Color backgroundColor = AppColors.paper;
    Color textColor = AppColors.ink;

    if (isAnswered) {
      if (isCorrect) {
        // 정답 보기 강조
        borderColor = AppColors.gold;
        backgroundColor = AppColors.ink;
        textColor = AppColors.paper;
      } else if (isSelected) {
        // 고른 오답 표시
        borderColor = AppColors.muted;
        backgroundColor = AppColors.muted.withValues(alpha: 0.15);
        textColor = AppColors.muted;
      }
    }

    return OutlinedButton(
      onPressed: isAnswered ? null : onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor,
        foregroundColor: textColor,
        disabledForegroundColor: textColor,
        side: BorderSide(color: borderColor, width: isAnswered && isCorrect ? 2 : 1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.sans,
          fontSize: 15,
          fontWeight: isAnswered && isCorrect ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}