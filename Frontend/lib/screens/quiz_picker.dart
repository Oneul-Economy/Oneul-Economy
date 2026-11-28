import 'package:flutter/material.dart';

import '../models/news.dart';
import '../models/ox_quiz.dart';
import '../models/quiz.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';
import '../widgets/toast.dart';
import 'home_screen.dart' show canOpenQuiz, loadQuiz;
import 'ox_quiz_screen.dart';
import 'quiz_screen.dart';

/// OX 퀴즈 예시 문제. 서버에 OX 퀴즈 API(#31)가 생기기 전까지 쓴다.
OxQuiz sampleOxQuiz(News news) {
  return OxQuiz(
    newsId: news.id,
    quizzes: const [
      OxQuizItem(
        id: 'ox-1',
        question: '기사 내용에 따르면, 새로운 노동조합 설립은 기존 임금교섭 구도에 영향을 줄 수 있다.',
        answer: true,
        hint: '복수노조 체제에서의 교섭 창구 단일화를 떠올려 보세요.',
        explanation: '새 노조가 설립되면 대표 교섭 노조 선정과 임금교섭 구도에 변화가 생길 수 있습니다.',
        evidence: '기사 요약: 임금교섭 구도가 바뀔 수 있어요.',
      ),
      OxQuizItem(
        id: 'ox-2',
        question: '환율이 상승하면 수출 비중이 높은 기업의 원화 환산 매출은 항상 감소한다.',
        answer: false,
        hint: '달러로 번 돈을 원화로 바꿀 때를 생각해 보세요.',
        explanation:
            '원·달러 환율이 오르면 같은 달러 매출이라도 원화로 환산했을 때 금액이 커져 수출 기업에 유리할 수 있습니다.',
        evidence: '수출 기업은 환율 상승 시 원화 기준 매출이 늘어나는 효과가 있습니다.',
      ),
    ],
  );
}

/// 기사 하나에 딸린 퀴즈 세 가지 중 고르는 바텀시트.
///
/// [quiz]를 넘기면 그 용어 퀴즈를 쓰고(테스트·홈에서 미리 읽어 둔 것),
/// 없으면 그때 읽는다.
Future<void> showQuizPicker(BuildContext context, News news, {Quiz? quiz}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      Future<void> openTermQuiz() async {
        final q = quiz ?? await loadQuiz();
        if (!sheetContext.mounted) return;
        if (!canOpenQuiz(news, q)) {
          showToast(sheetContext, '이 기사의 용어 퀴즈는 준비 중이에요');
          return;
        }
        Navigator.pop(sheetContext);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(quiz: q!, news: news),
          ),
        );
      }

      void openOxQuiz() {
        Navigator.pop(sheetContext);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OxQuizScreen(quiz: sampleOxQuiz(news), news: news),
          ),
        );
      }

      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '어떤 퀴즈를 풀까요?',
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                news.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              _QuizOption(
                number: 1,
                label: 'OX 퀴즈 · 30초',
                title: '핵심 내용 맞혀 보기',
                onTap: openOxQuiz,
              ),
              _QuizOption(
                number: 2,
                label: '용어 퀴즈 · 30초',
                title: '오늘 나온 용어 뜻 고르기',
                onTap: openTermQuiz,
              ),
              _QuizOption(
                number: 3,
                label: '생각 퀴즈 · 1분',
                title: '내 종목에는 어떤 영향일까',
                comingSoon: true,
                onTap: () => showToast(sheetContext, '생각 퀴즈는 준비 중이에요'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _QuizOption extends StatelessWidget {
  const _QuizOption({
    required this.number,
    required this.label,
    required this.title,
    required this.onTap,
    this.comingSoon = false,
  });

  final int number;
  final String label;
  final String title;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.ink.withValues(alpha: 0.08)),
          ),
        ),
        child: Opacity(
          opacity: comingSoon ? 0.45 : 1,
          child: Row(
            children: [
              SizedBox(
                width: 34,
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontFamily: AppFonts.serif,
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.sans,
                        color: AppColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                comingSoon ? '준비 중' : '풀기 ›',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
