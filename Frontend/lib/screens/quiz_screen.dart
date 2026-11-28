import 'dart:async';

import 'package:flutter/material.dart';

import '../models/news.dart';
import '../models/quiz.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/quiz_timer.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quiz, required this.news});

  final Quiz quiz;
  final News news;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _choiceLabels = ['A', 'B', 'C', 'D'];
  static const _errorRed = Color(0xFFD93025);

  int _currentIndex = 0;
  int? _selectedIndex;
  int _correctCount = 0;
  final List<QuizItem> _wrongItems = [];
  final Set<String> _savedQuizIds = {};
  final Set<String> _savedWords = {};

  Timer? _timer;
  int _remaining = quizTimeLimit;

  /// 답을 고르기 전에 시간이 다 됐는지
  bool _timedOut = false;

  QuizItem get _currentItem => widget.quiz.quizzes[_currentIndex];
  bool get _hasAnswered => _selectedIndex != null || _timedOut;
  bool get _isLastQuestion => _currentIndex == widget.quiz.quizzes.length - 1;
  bool get _isCurrentSaved => _savedQuizIds.contains(_currentItem.id);
  bool get _isWordSaved => _savedWords.contains(_currentItem.word);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _hasAnswered) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          // 시간 초과는 오답으로
          _timedOut = true;
          _wrongItems.add(_currentItem);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectChoice(int index) {
    if (_hasAnswered) return;

    final isCorrect = index == _currentItem.answerIndex;
    setState(() {
      _selectedIndex = index;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongItems.add(_currentItem);
      }
    });
  }

  void _toggleSaveQuiz() {
    setState(() {
      if (_isCurrentSaved) {
        _savedQuizIds.remove(_currentItem.id);
      } else {
        _savedQuizIds.add(_currentItem.id);
      }
    });
  }

  void _toggleSaveWord() {
    setState(() {
      if (_isWordSaved) {
        _savedWords.remove(_currentItem.word);
      } else {
        _savedWords.add(_currentItem.word);
      }
    });
  }

  void _next() {
    if (!_isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _timedOut = false;
        _remaining = quizTimeLimit;
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
    final total = widget.quiz.quizzes.length;
    final isCorrectSelected = _selectedIndex == item.answerIndex;
    final correctLabel = item.answerIndex < _choiceLabels.length
        ? _choiceLabels[item.answerIndex]
        : '${item.answerIndex + 1}';

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 닫기 + 세그먼트 진행률 바 + 타이머
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.ink,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: List.generate(total, (i) {
                        final isActive = i <= _currentIndex;
                        return Expanded(
                          child: Container(
                            height: 3,
                            margin: EdgeInsets.only(
                              right: i == total - 1 ? 0 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.ink
                                  : AppColors.ink.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  QuizTimerLabel(remaining: _remaining),
                ],
              ),
            ),

            // 본문 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 02 · 용어 퀴즈 + 저장 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '02 · 용어 퀴즈',
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: _toggleSaveQuiz,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isCurrentSaved
                                  ? AppColors.ink
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isCurrentSaved
                                    ? AppColors.ink
                                    : AppColors.ink.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isCurrentSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  size: 14,
                                  color: _isCurrentSaved
                                      ? AppColors.paper
                                      : AppColors.ink,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isCurrentSaved ? '저장됨' : '저장',
                                  style: TextStyle(
                                    fontFamily: AppFonts.sans,
                                    color: _isCurrentSaved
                                        ? AppColors.paper
                                        : AppColors.ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 질문 텍스트
                    Text(
                      item.question,
                      style: TextStyle(
                        fontFamily: AppFonts.serif,
                        color: AppColors.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 기사 제목 출처
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 14,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.news.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 보기 4개
                    for (var i = 0; i < item.choices.length; i++) ...[
                      _ChoiceCard(
                        label: i < _choiceLabels.length
                            ? _choiceLabels[i]
                            : '${i + 1}',
                        text: item.choices[i],
                        isAnswered: _hasAnswered,
                        isSelected: _selectedIndex == i,
                        isCorrect: i == item.answerIndex,
                        errorColor: _errorRed,
                        onTap: () => _selectChoice(i),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),

            // 하단 해설 시트 (정답 선택 후 표시)
            if (_hasAnswered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isCorrectSelected
                                ? AppColors.gold
                                : _errorRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrectSelected ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isCorrectSelected
                              ? '정답이에요!'
                              : (_timedOut ? '시간이 다 됐어요' : '아쉬워요'),
                          style: TextStyle(
                            fontFamily: AppFonts.sans,
                            color: AppColors.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (!isCorrectSelected)
                          Text(
                            '정답 $correctLabel',
                            style: TextStyle(
                              fontFamily: AppFonts.sans,
                              color: AppColors.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.explanation,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _toggleSaveWord,
                            icon: Icon(
                              _isWordSaved
                                  ? Icons.menu_book
                                  : Icons.menu_book_outlined,
                              size: 16,
                            ),
                            label: Text(_isWordSaved ? '담김' : '용어집에 담기'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              side: BorderSide(
                                color: AppColors.ink.withValues(alpha: 0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _next,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.ink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isLastQuestion ? '결과 보기' : '다음 문제',
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.text,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrect,
    required this.errorColor,
    required this.onTap,
  });

  final String label;
  final String text;
  final bool isAnswered;
  final bool isSelected;
  final bool isCorrect;
  final Color errorColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isWrongSelected = isAnswered && isSelected && !isCorrect;
    final bool isCorrectShown = isAnswered && isCorrect;
    final bool isFaded = isAnswered && !isCorrect && !isSelected;

    Color borderColor = AppColors.ink.withValues(alpha: 0.12);
    Color badgeBgColor = AppColors.paper;
    Color badgeTextColor = AppColors.muted;
    Color textColor = AppColors.ink;
    double borderWidth = 1;

    if (isCorrectShown) {
      borderColor = AppColors.ink;
      badgeBgColor = AppColors.ink;
      badgeTextColor = Colors.white;
      borderWidth = 1.8;
    } else if (isWrongSelected) {
      borderColor = errorColor;
      badgeBgColor = errorColor;
      badgeTextColor = Colors.white;
      borderWidth = 1.5;
    } else if (isFaded) {
      textColor = AppColors.muted.withValues(alpha: 0.5);
      badgeTextColor = AppColors.muted.withValues(alpha: 0.5);
    }

    return OutlinedButton(
      onPressed: isAnswered ? null : onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        disabledBackgroundColor: isFaded
            ? Colors.white.withValues(alpha: 0.6)
            : Colors.white,
        side: BorderSide(color: borderColor, width: borderWidth),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: badgeBgColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: badgeTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: textColor,
                fontSize: 14,
                fontWeight: isCorrectShown || isWrongSelected
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
          ),
          if (isCorrectShown)
            const Icon(Icons.check, color: AppColors.ink, size: 18)
          else if (isWrongSelected)
            Icon(Icons.close, color: errorColor, size: 18),
        ],
      ),
    );
  }
}
