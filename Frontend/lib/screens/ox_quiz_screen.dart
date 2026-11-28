import 'dart:async';

import 'package:flutter/material.dart';

import '../models/news.dart';
import '../models/ox_quiz.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/quiz_timer.dart';
import 'quiz_result_screen.dart';

class OxQuizScreen extends StatefulWidget {
  const OxQuizScreen({super.key, required this.quiz, required this.news});

  final OxQuiz quiz;
  final News news;

  @override
  State<OxQuizScreen> createState() => _OxQuizScreenState();
}

class _OxQuizScreenState extends State<OxQuizScreen> {
  static const _errorRed = Color(0xFFD93025);

  int _currentIndex = 0;
  bool? _selectedAnswer;
  int _correctCount = 0;
  final Set<String> _savedQuizIds = {};

  Timer? _timer;
  int _remaining = quizTimeLimit;

  /// 답을 고르기 전에 시간이 다 됐는지 (오답 처리)
  bool _timedOut = false;

  OxQuizItem get _currentItem => widget.quiz.quizzes[_currentIndex];
  bool get _hasAnswered => _selectedAnswer != null || _timedOut;
  bool get _isLastQuestion => _currentIndex == widget.quiz.quizzes.length - 1;
  bool get _isCurrentSaved => _savedQuizIds.contains(_currentItem.id);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _hasAnswered) return;
      setState(() {
        _remaining--;
        if (_remaining <= 0) _timedOut = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectAnswer(bool value) {
    if (_hasAnswered) return;

    final isCorrect = value == _currentItem.answer;
    setState(() {
      _selectedAnswer = value;
      if (isCorrect) {
        _correctCount++;
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

  void _next() {
    if (!_isLastQuestion) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
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
          wrongItems: const [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final total = widget.quiz.quizzes.length;
    final isCorrectSelected = _selectedAnswer == item.answer;

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
                    // 01 · OX 퀴즈 + 저장 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '01 · OX 퀴즈',
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
                    const SizedBox(height: 32),

                    // O / X 대형 카드 2개
                    Row(
                      children: [
                        Expanded(
                          child: _OxCard(
                            symbol: 'O',
                            label: '맞아요',
                            isAnswered: _hasAnswered,
                            isSelected: _selectedAnswer == true,
                            isCorrect: item.answer == true,
                            errorColor: _errorRed,
                            onTap: () => _selectAnswer(true),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _OxCard(
                            symbol: 'X',
                            label: '아니에요',
                            isAnswered: _hasAnswered,
                            isSelected: _selectedAnswer == false,
                            isCorrect: item.answer == false,
                            errorColor: _errorRed,
                            onTap: () => _selectAnswer(false),
                          ),
                        ),
                      ],
                    ),

                    // 힌트 (답변 전에만 표시)
                    if (!_hasAnswered && item.hint.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 15,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '힌트: ${item.hint}',
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    if (item.evidence.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '기사 속 근거',
                              style: TextStyle(
                                fontFamily: AppFonts.sans,
                                color: AppColors.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '“${item.evidence}”',
                              style: TextStyle(
                                fontFamily: AppFonts.serif,
                                color: AppColors.ink,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isLastQuestion ? '결과 보기' : '다음 문제',
                        style: TextStyle(
                          fontFamily: AppFonts.sans,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
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

class _OxCard extends StatelessWidget {
  const _OxCard({
    required this.symbol,
    required this.label,
    required this.isAnswered,
    required this.isSelected,
    required this.isCorrect,
    required this.errorColor,
    required this.onTap,
  });

  final String symbol;
  final String label;
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

    Color bgColor = Colors.white;
    Color borderColor = AppColors.ink.withValues(alpha: 0.1);
    Color symbolColor = AppColors.ink;
    Color labelColor = AppColors.muted;

    if (isCorrectShown) {
      bgColor = AppColors.ink;
      borderColor = AppColors.ink;
      symbolColor = Colors.white;
      labelColor = Colors.white.withValues(alpha: 0.8);
    } else if (isWrongSelected) {
      bgColor = errorColor.withValues(alpha: 0.08);
      borderColor = errorColor;
      symbolColor = errorColor;
      labelColor = errorColor;
    } else if (isFaded) {
      bgColor = Colors.white.withValues(alpha: 0.55);
      symbolColor = AppColors.muted.withValues(alpha: 0.35);
      labelColor = AppColors.muted.withValues(alpha: 0.35);
    }

    return InkWell(
      onTap: isAnswered ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: isWrongSelected ? 1.6 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontFamily: AppFonts.serif,
                color: symbolColor,
                fontSize: 64,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.sans,
                color: labelColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
