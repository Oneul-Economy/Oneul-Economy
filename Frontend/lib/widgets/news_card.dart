import 'package:flutter/material.dart';

import '../models/news.dart';
import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// 홈 화면의 다크 뉴스 카드 (Figma 교육형 홈 카드, node 15-35).
///
/// `종목명 · N분` → 제목 → 요약 → 퀴즈 3개 → 본문 읽기 버튼 순서.
/// 카드(퀴즈 행 제외)를 누르면 [onTap], 퀴즈 행을 누르면 [onQuizTap].
class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.onQuizTap,
  });

  final News news;
  final VoidCallback onTap;

  /// 몇 번째 퀴즈(0부터)를 눌렀는지 전달. 퀴즈 화면이 생기기 전까지는 비워 둬도 된다.
  final ValueChanged<int>? onQuizTap;

  // 퀴즈 데이터가 #3 형식에 아직 없어서 자리만 잡아 둔 임시 문구.
  static const _quizzes = [
    (label: 'OX 퀴즈 · 30초', title: '핵심 내용 맞혀 보기'),
    (label: '용어 퀴즈 · 30초', title: '오늘 나온 용어 뜻 고르기'),
    (label: '생각 퀴즈 · 1분', title: '내 종목에는 어떤 영향일까'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${news.stockName} · ${news.readMinutes}분',
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                news.title,
                style: TextStyle(
                  fontFamily: AppFonts.serif,
                  color: AppColors.paper,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                news.summary,
                style: TextStyle(
                  fontFamily: AppFonts.sans,
                  color: AppColors.onInkMuted,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.inkDivider,
              ),
              for (var i = 0; i < _quizzes.length; i++)
                _QuizRow(
                  number: i + 1,
                  label: _quizzes[i].label,
                  title: _quizzes[i].title,
                  onTap: () => onQuizTap?.call(i),
                ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  '본문 읽기',
                  style: TextStyle(
                    fontFamily: AppFonts.sans,
                    color: AppColors.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 안 퀴즈 한 줄: `01 | 라벨 / 제목 | 빈 원` (Figma 01~03 행 스타일).
class _QuizRow extends StatelessWidget {
  const _QuizRow({
    required this.number,
    required this.label,
    required this.title,
    required this.onTap,
  });

  final int number;
  final String label;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.inkDivider)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
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
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.onInkSubtle,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppFonts.sans,
                      color: AppColors.paper,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Figma 빈 원 아이콘: 20×20 안에 지름 17, 선 두께 1.5
            SizedBox.square(
              dimension: 20,
              child: Center(
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.inkRing, width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
